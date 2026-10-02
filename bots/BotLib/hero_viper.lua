----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: mid/offlane; forced other roles use mid.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/viper')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Poison Attack, [2] Nethertoxin, [3] Corrosive Skin, [6] Viper Strike.
local nAbilityBuildList = sRole == 'pos_3'
    and {1,3,1,2,2,6,2,2,3,3,6,1,1,3,6}
    or {1,3,1,3,1,6,1,2,2,2,6,2,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({t10={0,10},t15={10,0},t20={0,10},t25={10,0}})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_2 = {
    'item_double_branches','item_double_circlet','item_tango','item_faerie_fire','item_bracer',
    'item_magic_wand','item_travel_boots','item_mage_slayer','item_dragon_lance','item_yasha',
    'item_force_staff','item_hurricane_pike','item_manta',
    -- Bot policy: observed optional Bracer/Mage Slayer/Manta/Skadi; Shard/BKB and upgraded boots finish six slots.
    'item_aghanims_shard','item_skadi','item_black_king_bar','item_travel_boots_2','item_moon_shard',
}
sRoleItemsBuyList.pos_3 = {
    'item_double_branches','item_double_circlet','item_tango','item_faerie_fire','item_wraith_band',
    'item_wraith_band','item_magic_wand','item_power_treads','item_dragon_lance','item_yasha',
    'item_force_staff','item_hurricane_pike','item_manta',
    -- Bot policy: observed optional Manta/BKB/Butterfly; Shard/Skadi complete six slots.
    'item_aghanims_shard','item_black_king_bar','item_butterfly','item_skadi','item_moon_shard',
}
sRoleItemsBuyList.pos_1, sRoleItemsBuyList.pos_4, sRoleItemsBuyList.pos_5 = sRoleItemsBuyList.pos_2, sRoleItemsBuyList.pos_2, sRoleItemsBuyList.pos_2
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = sRole == 'pos_3' and {'item_black_king_bar','item_wraith_band','item_butterfly','item_wraith_band','item_butterfly','item_magic_wand'}
    or {'item_manta','item_bracer','item_skadi','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = { 'PvN_mid' }, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
X.bDeafaultAbility = false
X.bDeafaultItem = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local PoisonAttack,NetherToxin,Nosedive,ViperStrike
local function Refresh()
 bot=GetBot();PoisonAttack=bot:GetAbilityByName('viper_poison_attack');NetherToxin=bot:GetAbilityByName('viper_nethertoxin');Nosedive=bot:GetAbilityByName('viper_nose_dive');ViperStrike=bot:GetAbilityByName('viper_viper_strike')
end
local function Available(ability)
 return ability~=nil and not ability:IsNull() and not ability:IsHidden() and ability:IsActivated() and ability:IsTrained()
end
local function Range(ability)
 local range=ability:GetCastRange()
 for slot=0,5 do
  local item=bot:GetItemInSlot(slot)
  if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end
 end
 local passive=bot:GetAbilityByName('rubick_arcane_supremacy')
 if passive~=nil and not passive:IsNull() and passive:IsTrained() and not J.HasBreakModifier(bot) then range=range+passive:GetSpecialValueInt('cast_range') end
 return range
end
local function Enemy(unit,pierce)
 return (J.IsValid(unit) or J.IsValidBuilding(unit)) and (pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit))
  and not J.CannotBeKilled(bot,unit) and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Reserve(cost)
 local needed=J.CanCastAbility(ViperStrike) and ViperStrike:GetManaCost() or 0
 return bot:GetMana()-cost>=needed and J.IsAllowedToSpam(bot,cost)
end
local function Useful(enemy)
 if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then return true end
 if J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then return true end
 for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,ally) then return true end
 end
 return false
end
function X.ConsiderPoisonAttack()
 if not J.CanCastAbility(PoisonAttack) or bot:IsDisarmed() then return 0 end
 local range=bot:GetAttackRange()+PoisonAttack:GetSpecialValueInt('bonus_range')
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) and J.CanBeAttacked(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
   local eta=bot:GetAttackPoint()+GetUnitToUnitDistance(bot,enemy)/math.max(bot:GetAttackProjectileSpeed(),1)
   if J.WillKillTarget(enemy,bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL,eta)
    or (Useful(enemy) and (J.IsRetreating(bot) or Reserve(PoisonAttack:GetManaCost())))
    or (J.IsLaning(bot) and Reserve(PoisonAttack:GetManaCost()) and not J.IsLocHaveTower(700,true,bot:GetLocation())) then return BOT_ACTION_DESIRE_HIGH,enemy end
  end
 end
 local attack=bot:GetAttackTarget()
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot) or (J.IsPushing(bot) and bot:HasModifier('modifier_item_aghanims_shard'))) and Enemy(attack,false)
  and J.CanBeAttacked(attack) and not attack:HasModifier('modifier_fountain_glyph') and GetUnitToUnitDistance(bot,attack)<=range and J.IsAttacking(bot)
  and Reserve(PoisonAttack:GetManaCost()) and (not J.IsValidBuilding(attack) or bot:HasModifier('modifier_item_aghanims_shard')) then return BOT_ACTION_DESIRE_HIGH,attack end
 return 0
end
function X.UsePoisonAttack(toggleOnly)
 if not Available(PoisonAttack) then return false end
 local desire,target=X.ConsiderPoisonAttack()
 local automatic=desire>0 and target==bot:GetAttackTarget() and J.IsAttacking(bot) and not J.IsRetreating(bot)
 if PoisonAttack:GetAutoCastState()~=automatic then PoisonAttack:ToggleAutoCast();return true end
 if not toggleOnly and desire>0 and not automatic then bot:Action_UseAbilityOnEntity(PoisonAttack,target);return true end
 return false
end
local function Clamp(point,range)
 if (point-bot:GetLocation()):Length2D()>range then return bot:GetLocation()+(point-bot:GetLocation()):Normalized()*range end
 return point
end
local function ToxinPoint(unit,range)
 local eta=NetherToxin:GetCastPoint()+math.min(GetUnitToUnitDistance(bot,unit),range)/NetherToxin:GetSpecialValueInt('projectile_speed')
 return Clamp(J.GetCorrectLoc(unit,eta),range),eta
end
function X.ConsiderNetherToxin()
 if not J.CanCastAbility(NetherToxin) then return 0 end
 local range=Range(NetherToxin);local radius=NetherToxin:GetSpecialValueInt('radius')
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) and Useful(enemy) and not enemy:HasModifier('modifier_viper_nethertoxin') then
   local point,eta=ToxinPoint(enemy,range)
   if (J.GetCorrectLoc(enemy,eta)-point):Length2D()<=radius then return BOT_ACTION_DESIRE_HIGH,point end
  end
 end
 if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and Reserve(NetherToxin:GetManaCost()) then
  local creeps=bot:GetNearbyCreeps(math.min(range+radius,1600),true)
  for _,creep in ipairs(creeps) do
   if Enemy(creep,false) then
    local point,eta=ToxinPoint(creep,range);local count=0
    for _,other in ipairs(creeps) do if Enemy(other,false) and not other:HasModifier('modifier_fountain_glyph') and (J.GetCorrectLoc(other,eta)-point):Length2D()<=radius then count=count+1 end end
    if count>=3 then return BOT_ACTION_DESIRE_HIGH,point end
   end
  end
 end
 local target=J.GetProperTarget(bot)
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(target,false) and J.IsAttacking(bot) and not target:HasModifier('modifier_viper_nethertoxin') and Reserve(NetherToxin:GetManaCost()) then
  local point,eta=ToxinPoint(target,range);if (J.GetCorrectLoc(target,eta)-point):Length2D()<=radius then return BOT_ACTION_DESIRE_HIGH,point end
 end
 return 0
end
local BreakValue={npc_dota_hero_bristleback=200,npc_dota_hero_huskar=200,npc_dota_hero_spectre=200,npc_dota_hero_phantom_assassin=200,npc_dota_hero_dragon_knight=200}
function X.ConsiderViperStrike()
 if not J.CanCastAbility(ViperStrike) then return 0 end
 local range=Range(ViperStrike);local choice,best=nil,-1
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,true) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range and not enemy:HasModifier('modifier_viper_viper_strike') then
   local eta=ViperStrike:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/ViperStrike:GetSpecialValueInt('projectile_speed')+1
   if not enemy:IsMagicImmune() and J.WillKillTarget(enemy,ViperStrike:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,enemy end
   if Useful(enemy) or (J.IsInTeamFight(bot,1200) and enemy:GetAttackTarget()~=nil) then
    local score=enemy:GetEstimatedDamageToTarget(false,bot,3,DAMAGE_TYPE_PHYSICAL)
    if not J.HasBreakModifier(enemy) then score=score+(BreakValue[enemy:GetUnitName()] or 0) end
    if enemy==J.GetProperTarget(bot) then score=score+50 end
    if score>best then choice,best=enemy,score end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 local target=J.GetProperTarget(bot)
 if J.IsDoingRoshan(bot) and J.IsRoshan(target) and Enemy(target,true) and J.CanCastOnTargetAdvanced(target) and J.IsAttacking(bot)
  and GetUnitToUnitDistance(bot,target)<=range and not target:HasModifier('modifier_viper_viper_strike') then return BOT_ACTION_DESIRE_HIGH,target end
 return 0
end
local function Safe(point)
 return IsLocationPassable(point) and not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point) and not J.IsLocHaveTower(700,true,point)
end
function X.ConsiderNosedive()
 if not J.CanCastAbility(Nosedive) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled') then return 0 end
 local range=Range(Nosedive);local radius=Nosedive:GetSpecialValueInt('corrosive_radius')
 if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
  local point=Clamp(J.GetEscapeLoc(),range)
  if Safe(point) and #J.GetEnemiesNearLoc(point,600)<#J.GetNearbyHeroes(bot,1000,true,BOT_MODE_NONE) then return BOT_ACTION_DESIRE_HIGH,point end
 end
 local target=J.GetProperTarget(bot);local skin=bot:GetAbilityByName('viper_corrosive_skin')
 if (Available(NetherToxin) or Available(skin)) and J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and Enemy(target,false) then
  local eta=Nosedive:GetCastPoint()+math.min(GetUnitToUnitDistance(bot,target),range)/Nosedive:GetSpecialValueInt('dive_speed')
  local predicted=J.GetCorrectLoc(target,eta);local point=Clamp(predicted,range)
  if (predicted-point):Length2D()<=radius and Safe(point) and J.GetHP(bot)>0.45 and #J.GetEnemiesNearLoc(point,600)<=#J.GetAlliesNearLoc(point,900)+1 then return BOT_ACTION_DESIRE_HIGH,point end
 end
 return 0
end
local function Cast(ability,target,point)
 -- Keep the existing affordable item-aware preparation for active spells.
 if J.HasPowerTreads(bot) then
  J.SetQueuePtToINT(bot,true)
  if point then bot:ActionQueue_UseAbilityOnLocation(ability,target) else bot:ActionQueue_UseAbilityOnEntity(ability,target) end
 else
  if point then bot:Action_UseAbilityOnLocation(ability,target) else bot:Action_UseAbilityOnEntity(ability,target) end
 end
end
function X.SkillsComplement()
 Refresh();if J.CanNotUseAbility(bot) or J.IsRealInvisible(bot) then return end
 local desire,target
 if J.IsRetreating(bot) then desire,target=X.ConsiderNosedive();if desire>0 then Cast(Nosedive,target,true);return end end
 desire,target=X.ConsiderViperStrike();if desire>0 then Cast(ViperStrike,target,false);return end
 desire,target=X.ConsiderNosedive();if desire>0 then Cast(Nosedive,target,true);return end
 desire,target=X.ConsiderNetherToxin();if desire>0 then Cast(NetherToxin,target,true);return end
 X.UsePoisonAttack()
end
return X
