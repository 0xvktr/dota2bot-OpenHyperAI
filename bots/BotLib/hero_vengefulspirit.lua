local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: carry/offlane/support; forced mid uses carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/vengefulspirit')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local isCore = sRole == 'pos_1' or sRole == 'pos_2' or sRole == 'pos_3'
-- [1] Magic Missile, [2] Wave of Terror, [3] Vengeance Aura, [6] Nether Swap.
local nAbilityBuildList = isCore and {1,2,2,3,2,6,2,3,3,3,6,1,1,1,6}
    or {1,2,1,2,1,6,1,2,2,3,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild(isCore
    and {t10={0,10},t15={0,10},t20={0,10},t25={0,10}}
    or {t10={0,10},t15={0,10},t20={10,0},t25={10,0}})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_1 = {
    'item_quelling_blade','item_slippers','item_double_branches','item_circlet','item_tango',
    'item_wraith_band','item_magic_wand','item_power_treads','item_yasha','item_ultimate_scepter',
    'item_manta','item_dragon_lance','item_hydras_breath',
    -- Bot policy: observed optional evasion/crit; consume Scepter before BKB fills slot six.
    'item_butterfly','item_lesser_crit','item_greater_crit','item_aghanims_shard',
    'item_ultimate_scepter_2','item_black_king_bar','item_moon_shard',
}
sRoleItemsBuyList.pos_3 = {
    'item_quelling_blade','item_slippers','item_double_branches','item_circlet','item_tango',
    'item_wraith_band','item_magic_wand','item_power_treads','item_yasha','item_ultimate_scepter',
    'item_manta',
    -- Bot policy: observed optional range/damage progression.
    'item_dragon_lance','item_hydras_breath',
    -- Bot policy: observed optional evasion/crit; consume Scepter before BKB fills slot six.
    'item_butterfly','item_lesser_crit','item_greater_crit','item_aghanims_shard',
    'item_ultimate_scepter_2','item_black_king_bar','item_moon_shard',
}
sRoleItemsBuyList.pos_4 = {
    'item_double_branches','item_branches','item_magic_stick','item_ward_sentry','item_tango',
    'item_blood_grenade','item_magic_wand','item_tranquil_boots',
    -- Bot policy: observed optional utility, then Force/Bearing/Lotus; consume Scepter.
    'item_glimmer_cape','item_aether_lens','item_aghanims_shard','item_vladmir','item_ultimate_scepter',
    'item_ultimate_scepter_2','item_force_staff','item_ancient_janggo','item_boots_of_bearing',
    'item_lotus_orb',
}
sRoleItemsBuyList.pos_5 = {
    'item_double_branches','item_magic_stick','item_ward_sentry','item_tango','item_faerie_fire',
    'item_blood_grenade','item_magic_wand','item_tranquil_boots',
    -- Bot policy: observed optional Solar/Force/Lens/Shard, then consumed Scepter/Glimmer/Bearing/Lotus.
    'item_pavise','item_solar_crest','item_force_staff','item_aether_lens','item_aghanims_shard',
    'item_ultimate_scepter','item_ultimate_scepter_2','item_glimmer_cape','item_ancient_janggo',
    'item_boots_of_bearing','item_lotus_orb',
}
sRoleItemsBuyList.pos_2 = sRoleItemsBuyList.pos_1
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = isCore and {'item_hydras_breath','item_quelling_blade','item_butterfly','item_wraith_band','item_butterfly','item_magic_wand'}
    or {'item_ultimate_scepter','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = { 'PvN_antimage' }, {} end
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

local MagicMissile,WaveOfTerror,NetherSwap
local function Refresh()
 bot=GetBot();MagicMissile=bot:GetAbilityByName('vengefulspirit_magic_missile');WaveOfTerror=bot:GetAbilityByName('vengefulspirit_wave_of_terror');NetherSwap=bot:GetAbilityByName('vengefulspirit_nether_swap')
end
local function Range(ability)
 local range=ability:GetCastRange()
 if not bot:IsIllusion() then
  for slot=0,5 do
   local item=bot:GetItemInSlot(slot)
   if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end
  end
 end
 local passive=bot:GetAbilityByName('rubick_arcane_supremacy')
 if passive~=nil and not passive:IsNull() and passive:IsTrained() and not J.HasBreakModifier(bot) then range=range+passive:GetSpecialValueInt('cast_range') end
 return range
end
local function Enemy(unit,pierce)
 return J.IsValid(unit) and (pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit))
  and not J.CannotBeKilled(bot,unit) and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Fighting()
 return J.IsGoingOnSomeone(bot) or (bot:IsIllusion() and J.IsValidHero(bot:GetAttackTarget()))
end
local function Held(unit)
 return unit:HasModifier('modifier_faceless_void_chronosphere_freeze') or unit:HasModifier('modifier_enigma_black_hole_pull')
  or unit:HasModifier('modifier_legion_commander_duel') or unit:HasModifier('modifier_bane_fiends_grip')
  or unit:HasModifier('modifier_mars_arena_of_blood_leash')
end
local function Safe(point)
 return not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point) and not J.IsLocHaveTower(700,true,point)
end
function X.ConsiderMagicMissile()
 if not J.CanCastAbility(MagicMissile) then return 0 end
 local range=Range(MagicMissile);local damage=MagicMissile:GetSpecialValueInt('magic_missile_damage');local target=J.GetProperTarget(bot)
 local choice,score=nil,-1
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
   local eta=MagicMissile:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/MagicMissile:GetSpecialValueInt('magic_missile_speed')
   if enemy:IsChanneling() then return BOT_ACTION_DESIRE_HIGH,enemy end
   if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,enemy end
   local useful=(Fighting() and enemy==target) or J.IsInTeamFight(bot,1200) or (J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot))
   for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
    if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,ally) then useful=true end
   end
   if useful and not J.IsDisabled(enemy) and not Held(enemy) then
    local value=enemy:GetEstimatedDamageToTarget(false,bot,3,DAMAGE_TYPE_ALL)
    if bot:HasModifier('modifier_item_aghanims_shard') then
     for _,secondary in ipairs(J.GetEnemiesNearLoc(enemy:GetLocation(),range*0.75)) do
      if secondary~=enemy and J.IsValidHero(secondary) and Enemy(secondary,false) then value=value+100 end
     end
    end
    if value>score then choice,score=enemy,value end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 return 0
end
local function WavePoint(unit,range,speed)
 local point=J.GetCorrectLoc(unit,WaveOfTerror:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/speed)
 if (point-bot:GetLocation()):Length2D()>range then point=bot:GetLocation()+(point-bot:GetLocation()):Normalized()*range end
 return point
end
local function Hits(unit,point,range,width,speed)
 local position=J.GetCorrectLoc(unit,WaveOfTerror:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/speed)-bot:GetLocation()
 local direction=(point-bot:GetLocation()):Normalized();local along=position.x*direction.x+position.y*direction.y
 return along>=0 and along<=range and (position-direction*along):Length2D()<=width
end
function X.ConsiderWaveOfTerror()
 if not J.CanCastAbility(WaveOfTerror) then return 0 end
 local range=Range(WaveOfTerror);local width=WaveOfTerror:GetSpecialValueInt('wave_width');local speed=WaveOfTerror:GetSpecialValueInt('wave_speed')
 local target=J.GetProperTarget(bot);local heroes=J.GetNearbyHeroes(bot,math.min(range+width,1600),true,BOT_MODE_NONE)
 local choice,score=nil,0
 for _,enemy in ipairs(heroes) do
  if Enemy(enemy,false) then
   local point=WavePoint(enemy,range,speed)
   if Hits(enemy,point,range,width,speed) then
    local eta=WaveOfTerror:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/speed
    if J.WillKillTarget(enemy,WaveOfTerror:GetAbilityDamage(),DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,point end
    local useful=(Fighting() and enemy==target) or (J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot))
     or ((J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,WaveOfTerror:GetManaCost()))
    if useful and not enemy:HasModifier('modifier_vengefulspirit_wave_of_terror') then
     local count=0;for _,other in ipairs(heroes) do if Enemy(other,false) and Hits(other,point,range,width,speed) then count=count+1 end end
     if count>score then choice,score=point,count end
    end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,WaveOfTerror:GetManaCost()) then
  local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
  for _,creep in ipairs(creeps) do
   if Enemy(creep,false) then
    local point=WavePoint(creep,range,speed);local count,kills=0,0
    for _,other in ipairs(creeps) do
     if Enemy(other,false) and not other:HasModifier('modifier_fountain_glyph') and Hits(other,point,range,width,speed) then
      count=count+1
      if J.WillKillTarget(other,WaveOfTerror:GetAbilityDamage(),DAMAGE_TYPE_MAGICAL,WaveOfTerror:GetCastPoint()+GetUnitToUnitDistance(bot,other)/speed) then kills=kills+1 end
     end
    end
    if (J.IsLaning(bot) and kills>=2) or (not J.IsLaning(bot) and count>=3) then return BOT_ACTION_DESIRE_HIGH,point end
   end
  end
 end
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(target,false) and J.IsAttacking(bot) and GetUnitToUnitDistance(bot,target)<=range
  and not target:HasModifier('modifier_vengefulspirit_wave_of_terror') and J.IsAllowedToSpam(bot,WaveOfTerror:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH,WavePoint(target,range,speed) end
 return 0
end
function X.ConsiderNetherSwap()
 if not J.CanCastAbility(NetherSwap) then return 0 end
 local range=Range(NetherSwap);local allies=J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)
 local origin=bot:GetLocation();local originSafe=Safe(origin) and not Held(bot)
 local friends=J.GetAlliesNearLoc(origin,600);local foes=J.GetEnemiesNearLoc(origin,600)
 for _,ally in ipairs(allies) do
  if J.IsValidHero(ally) and ally~=bot and not ally:IsIllusion() and not ally:IsInvulnerable() and GetUnitToUnitDistance(bot,ally)<=range and GetUnitToUnitDistance(bot,ally)>250
   and originSafe and #foes<=#friends+1 then
   local trapped=Held(ally)
   if trapped or (not ally:IsChanneling() and J.GetHP(ally)<0.35 and ally:WasRecentlyDamagedByAnyHero(2) and #J.GetEnemiesNearLoc(ally:GetLocation(),500)>#foes) then return BOT_ACTION_DESIRE_HIGH,ally end
  end
 end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,true) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range and Safe(enemy:GetLocation())
   and not Held(enemy) and #J.GetEnemiesNearLoc(enemy:GetLocation(),500)<=#friends+1 then
   if enemy:IsChanneling() then return BOT_ACTION_DESIRE_HIGH,enemy end
   if not enemy:IsMagicImmune() and J.WillKillTarget(enemy,NetherSwap:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,NetherSwap:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,enemy end
   if Fighting() and enemy==J.GetProperTarget(bot) and GetUnitToUnitDistance(bot,enemy)>400 and #friends>=1 and originSafe
    and not J.IsDisabled(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end
  end
 end
 return 0
end
function X.SkillsComplement()
 Refresh();if J.CanNotUseAbility(bot) then return end
 local desire,target=X.ConsiderNetherSwap()
 if desire>0 then bot:Action_UseAbilityOnEntity(NetherSwap,target);return end
 desire,target=X.ConsiderMagicMissile()
 if desire>0 then bot:Action_UseAbilityOnEntity(MagicMissile,target);return end
 desire,target=X.ConsiderWaveOfTerror()
 if desire>0 then bot:Action_UseAbilityOnLocation(WaveOfTerror,target) end
end
return X
