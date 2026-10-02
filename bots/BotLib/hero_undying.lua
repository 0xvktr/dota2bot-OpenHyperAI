local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: offlane and supports; skipped cores use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/undying')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local buildRole = BuildData.roles[sRole].skipped and 'pos_3' or sRole
-- [1] Decay, [2] Soul Rip, [3] Tombstone, [6] Flesh Golem.
local abilityBuilds = {
    pos_3={1,3,1,2,1,6,1,2,2,2,6,3,3,3,6},
    pos_4={1,3,1,3,1,6,1,3,3,2,6,2,2,2,6},
    pos_5={1,3,1,3,1,6,1,3,3,2,6,2,2,2,6},
}
local talentBuilds = {
    pos_3={t10={0,10},t15={0,10},t20={0,10},t25={0,10}},
    pos_4={t10={0,10},t15={0,10},t20={0,10},t25={10,0}},
    pos_5={t10={0,10},t15={0,10},t20={10,0},t25={10,0}},
}
local nAbilityBuildList = abilityBuilds[buildRole]
local nTalentBuildList = J.Skill.GetTalentBuild(talentBuilds[buildRole])
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {
    pos_3={
        'item_double_gauntlets','item_double_branches','item_magic_stick',
        'item_soul_ring','item_magic_wand','item_phase_boots','item_octarine_core','item_blink',
        'item_aghanims_shard','item_black_king_bar','item_shivas_guard',
        -- Bot policy: consume Scepter, upgrade Blink and finish with control.
        'item_ultimate_scepter','item_ultimate_scepter_2','item_overwhelming_blink','item_sheepstick',
    },
    pos_4={
        'item_branches','item_magic_stick','item_ward_sentry','item_tango','item_enchanted_mango','item_enchanted_mango','item_blood_grenade',
        'item_magic_wand','item_arcane_boots','item_mekansm','item_aghanims_shard','item_glimmer_cape','item_guardian_greaves',
        -- Bot policy: team utility, natural Blink upgrade and consumed Scepter.
        'item_blink','item_lotus_orb','item_pipe','item_ultimate_scepter','item_ultimate_scepter_2','item_overwhelming_blink','item_sheepstick',
    },
    pos_5={
        'item_branches','item_magic_stick','item_ward_sentry','item_tango','item_enchanted_mango','item_enchanted_mango','item_blood_grenade',
        'item_magic_wand','item_arcane_boots','item_mekansm','item_aghanims_shard','item_holy_locket','item_guardian_greaves','item_blink',
        -- Bot policy: practical saves/utility, consumed Scepter and late mobility.
        'item_glimmer_cape','item_lotus_orb','item_ultimate_scepter','item_ultimate_scepter_2','item_overwhelming_blink','item_sheepstick',
    },
}
X.sBuyList = sRoleItemsBuyList[buildRole]
local sellLists = {
    pos_3={'item_octarine_core','item_magic_wand','item_blink','item_soul_ring'},
    pos_4={'item_lotus_orb','item_magic_wand'},
    pos_5={'item_guardian_greaves','item_magic_stick'}, -- Locket reuses the Wand.
}
X.sSellList = sellLists[buildRole]

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_antimage'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

local Decay,SoulRip,Tombstone,FleshGolem
local function Refresh()
 bot=GetBot();Decay=bot:GetAbilityByName('undying_decay');SoulRip=bot:GetAbilityByName('undying_soul_rip')
 Tombstone=bot:GetAbilityByName('undying_tombstone');FleshGolem=bot:GetAbilityByName('undying_flesh_golem')
end
Refresh()
local function ActualRange(ability)
 local range=ability:GetCastRange()
 for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
 local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
 if supremacy~=nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
 return range
end
local function Enemy(unit)
 return J.IsValid(unit) and J.CanCastOnNonMagicImmune(unit) and not J.CannotBeKilled(bot,unit)
  and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Stone(unit)
 return unit~=nil and not unit:IsNull() and unit:IsAlive() and unit:CanBeSeen() and unit:GetTeam()==bot:GetTeam() and string.find(unit:GetUnitName(),'undying_tombstone')~=nil
end
local function PointFor(unit,ability,radius,delay)
 local point=J.GetCorrectLoc(unit,delay);local delta=point-bot:GetLocation();local range=ActualRange(ability)
 if delta:Length2D()>range+radius then return nil end
 if delta:Length2D()>range then point=bot:GetLocation()+delta:Normalized()*range end
 return point
end
local function RipCount(target)
 local radius=SoulRip:GetSpecialValueInt('radius');local seen={};local count=0
 local lists={J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE),J.GetNearbyHeroes(bot,math.min(radius,1600),false,BOT_MODE_NONE),bot:GetNearbyCreeps(math.min(radius,1600),true),bot:GetNearbyCreeps(math.min(radius,1600),false),bot:GetNearbyNeutralCreeps(math.min(radius,1600))}
 for _,list in ipairs(lists) do
  for _,unit in ipairs(list) do
   if unit~=bot and unit~=target and not seen[unit] and J.IsValid(unit) and not unit:IsInvulnerable() and not unit:IsInvisible() and not unit:IsBuilding()
    and GetUnitToUnitDistance(bot,unit)<=radius and (unit:GetTeam()==bot:GetTeam() or not unit:IsMagicImmune()) then seen[unit]=true;count=count+1 end
  end
 end
 return math.min(count,SoulRip:GetSpecialValueInt('max_units'))
end
function X.ConsiderSoulRip()
 if not J.CanCastAbility(SoulRip) then return 0 end
 local range=ActualRange(SoulRip);local best,missing=nil,0
 local allies=J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE);allies[#allies+1]=bot
 for _,ally in ipairs(allies) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not ally:HasModifier('modifier_ice_blast') and GetUnitToUnitDistance(bot,ally)<=range then
   local heal=RipCount(ally)*SoulRip:GetSpecialValueInt('damage_per_unit');local need=ally:GetMaxHealth()-ally:GetHealth()
   if heal>0 and need>=math.min(heal,80) and (J.GetHP(ally)<0.6 or ally:WasRecentlyDamagedByAnyHero(2)) then
    local score=math.min(heal,need)*(J.GetHP(ally)<0.3 and 3 or 1);if score>missing then missing=score;best=ally end
   end
  end
 end
 if best~=nil then return BOT_ACTION_DESIRE_HIGH,best,'heal' end
 for _,unit in ipairs(GetUnitList(UNIT_LIST_ALLIES)) do
  if Stone(unit) and not unit:IsInvulnerable() and GetUnitToUnitDistance(bot,unit)<=range and unit:GetMaxHealth()-unit:GetHealth()>=4 then
   for _,enemy in ipairs(J.GetEnemiesNearLoc(unit:GetLocation(),900)) do
    if enemy:GetAttackTarget()==unit then return BOT_ACTION_DESIRE_HIGH,unit,'repair' end
   end
  end
 end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
   local damage=RipCount(enemy)*SoulRip:GetSpecialValueInt('damage_per_unit')
   if damage>0 and (J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,SoulRip:GetCastPoint())
    or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and damage>=SoulRip:GetSpecialValueInt('damage_per_unit')*4)) then return BOT_ACTION_DESIRE_HIGH,enemy,'damage' end
  end
 end
 return 0
end
function X.ConsiderDecay()
 if not J.CanCastAbility(Decay) then return 0 end
 local range=ActualRange(Decay);local radius=Decay:GetSpecialValueInt('radius');local damage=Decay:GetSpecialValueInt('decay_damage');local delay=Decay:GetCastPoint()
 local enemies=J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)
 for _,enemy in ipairs(enemies) do
  if Enemy(enemy) then
   local point=PointFor(enemy,Decay,radius,delay)
   if point~=nil then
    local count=0;for _,other in ipairs(enemies) do if J.IsValidHero(other) and not other:IsIllusion() and Enemy(other) and (J.GetCorrectLoc(other,delay)-point):Length2D()<=radius then count=count+1 end end
    if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,delay) or ((J.IsInTeamFight(bot,1200) or J.IsLaning(bot)) and count>=2)
     or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)) or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) then return BOT_ACTION_DESIRE_HIGH,point end
   end
  end
 end
 if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot)) and J.IsAllowedToSpam(bot,Decay:GetManaCost()) then
  local creeps=bot:GetNearbyCreeps(math.min(range+radius,1600),true)
  for _,creep in ipairs(creeps) do
   if Enemy(creep) and not creep:HasModifier('modifier_fountain_glyph') then
    local point=PointFor(creep,Decay,radius,delay)
    if point~=nil then
     if J.IsLaning(bot) and string.find(creep:GetUnitName(),'ranged') and GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()
      and J.WillKillTarget(creep,damage*Decay:GetSpecialValueFloat('creep_damage_multiplier'),DAMAGE_TYPE_MAGICAL,delay) then return BOT_ACTION_DESIRE_HIGH,point end
     if not J.IsLaning(bot) then local count=0;for _,other in ipairs(creeps) do if Enemy(other) and not other:HasModifier('modifier_fountain_glyph') and (J.GetCorrectLoc(other,delay)-point):Length2D()<=radius then count=count+1 end end;if count>=3 then return BOT_ACTION_DESIRE_HIGH,point end end
    end
   end
  end
 end
 return 0
end
local function NeedsBunker(ally)
 return J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not ally:HasModifier('modifier_undying_tombstone_bunker')
  and (ally:HasModifier('modifier_legion_commander_duel') or ally:HasModifier('modifier_bane_fiends_grip')
   or (J.GetHP(ally)<0.35 and ally:WasRecentlyDamagedByAnyHero(2)))
end
local function BunkerSafe(point)
 local hits=0
 for _,enemy in ipairs(J.GetEnemiesNearLoc(point,1000)) do
  if J.IsValidHero(enemy) and not enemy:IsDisarmed() and not J.IsDisabled(enemy) then
   local travel=math.max(0,GetUnitToLocationDistance(enemy,point)-enemy:GetAttackRange())/math.max(1,enemy:GetCurrentMovementSpeed())
   hits=hits+math.max(0,2-travel)/math.max(0.2,enemy:GetSecondsPerAttack())
  end
 end
 return hits<Tombstone:GetSpecialValueInt('hits_to_destroy_tooltip')-1
end
function X.ConsiderTombstone()
 if not J.CanCastAbility(Tombstone) then return 0 end
 local range=ActualRange(Tombstone)
 if J.HasAghanimsShard(bot) then
  local allies=J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE);allies[#allies+1]=bot
  for _,ally in ipairs(allies) do if NeedsBunker(ally) and GetUnitToUnitDistance(bot,ally)<=range and BunkerSafe(ally:GetLocation()) then return BOT_ACTION_DESIRE_HIGH,ally,'save' end end
 end
 local radius=Tombstone:GetSpecialValueInt('radius')
 local point=bot:GetLocation()+(J.GetEscapeLoc()-bot:GetLocation()):Normalized()*range
 if not IsLocationPassable(point) or J.IsLocHaveTower(700,true,point) or J.IsLocationInChrono(point) or J.IsLocationInBlackHole(point) then return 0 end
 for _,unit in ipairs(GetUnitList(UNIT_LIST_ALLIES)) do if Stone(unit) and GetUnitToLocationDistance(unit,point)<radius*0.5 then return 0 end end
 local count=0;for _,enemy in ipairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do if J.IsValidHero(enemy) and not enemy:IsIllusion() and J.CanBeAttacked(enemy) and GetUnitToLocationDistance(enemy,point)<=radius then count=count+1 end end
 if (J.IsInTeamFight(bot,1200) and count>=2) or ((J.IsGoingOnSomeone(bot) or J.IsRetreating(bot)) and count>=1 and bot:WasRecentlyDamagedByAnyHero(2)) then return BOT_ACTION_DESIRE_HIGH,point,'point' end
 return 0
end
function X.ConsiderFleshGolem()
 if not J.CanCastAbility(FleshGolem) or bot:HasModifier('modifier_undying_flesh_golem') then return 0 end
 local target=J.GetProperTarget(bot)
 if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanBeAttacked(target) and not bot:IsDisarmed() and GetUnitToUnitDistance(bot,target)<=650
  and (J.IsInTeamFight(bot,1200) or bot:WasRecentlyDamagedByAnyHero(2) or J.IsAttacking(bot)) then return BOT_ACTION_DESIRE_HIGH end
 if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and J.GetHP(bot)<0.4 and #J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
 local attack=bot:GetAttackTarget()
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(attack) and J.CanBeAttacked(attack) and GetUnitToUnitDistance(bot,attack)<=bot:GetAttackRange()+50
  and J.IsAttacking(bot) and #J.GetNearbyHeroes(bot,600,false,BOT_MODE_NONE)>=1 then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderTombstoneMinion(unit)
 if unit==nil or not Stone(unit) or unit:GetPlayerID()~=bot:GetPlayerID() or unit:IsInvulnerable() or unit:IsSilenced() or unit:IsStunned() or unit:IsHexed() or unit:IsChanneling() or unit:IsUsingAbility() or unit:IsCastingAbility() or unit:NumQueuedActions()>0 then return false end
 local grab=unit:GetAbilityByName('undying_tombstone_unit_grab')
 if not J.CanCastAbility(grab) then return false end
 -- Use the conservative documented bunker collection radius, not the legacy 1200 cast metadata.
 for _,ally in ipairs(J.GetAlliesNearLoc(unit:GetLocation(),350)) do
  if NeedsBunker(ally) and unit:GetHealth()>unit:GetMaxHealth()*0.4 then unit:Action_UseAbilityOnEntity(grab,ally);return true end
 end
 return false
end

function X.MinionThink(unit)
 Refresh();if X.ConsiderTombstoneMinion(unit) then return end
 Minion.MinionThink(unit)
end
function X.SkillsComplement()
 Refresh();if J.CanNotUseAbility(bot) then return end
 local wd,wt,kind=X.ConsiderSoulRip();if wd>0 and kind~='damage' then bot:Action_UseAbilityOnEntity(SoulRip,wt);return end
 local ed,et,ek=X.ConsiderTombstone();if ed>0 and ek=='save' then bot:Action_UseAbilityOnEntity(Tombstone,et);return end
 if X.ConsiderFleshGolem()>0 then bot:Action_UseAbility(FleshGolem);return end
 if ed>0 then bot:Action_UseAbilityOnLocation(Tombstone,et);return end
 if wd>0 then bot:Action_UseAbilityOnEntity(SoulRip,wt);return end
 local qd,qp=X.ConsiderDecay();if qd>0 then bot:Action_UseAbilityOnLocation(Decay,qp);return end
end
return X
