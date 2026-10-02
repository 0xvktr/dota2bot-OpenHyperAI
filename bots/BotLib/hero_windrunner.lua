local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; all five positions.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/windrunner')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Shackleshot, [2] Powershot, [3] Windrun, [6] Focus Fire.
local roleAbilityBuilds, roleTalentTrees = {}, {}
roleAbilityBuilds.pos_1 = {2,3,2,1,2,6,2,3,3,3,6,1,1,1,6}
roleTalentTrees.pos_1 = {
    t10={10,0}, -- Windrun duration
    t15={0,10}, -- Tailwind speed
    t20={10,0}, -- Focus Fire damage reduction
    t25={10,0}, -- Focus Fire kill cooldown
}
roleAbilityBuilds.pos_2 = {2,3,2,1,2,6,2,3,3,3,6,1,1,1,6}
roleTalentTrees.pos_2 = {
    t10={10,0}, -- Windrun duration
    t15={0,10}, -- Tailwind speed
    t20={10,0}, -- Focus Fire damage reduction
    t25={10,0}, -- Focus Fire kill cooldown
}
roleAbilityBuilds.pos_3 = {2,3,2,1,2,6,2,3,3,3,6,1,1,1,6}
roleTalentTrees.pos_3 = {
    t10={10,0}, -- Windrun duration
    t15={0,10}, -- Tailwind speed
    t20={10,0}, -- Focus Fire damage reduction
    t25={10,0}, -- Focus Fire kill cooldown
}
roleAbilityBuilds.pos_4 = {2,3,2,1,2,6,2,3,3,3,6,1,1,1,6}
roleTalentTrees.pos_4 = {
    t10={10,0}, -- Windrun duration
    t15={10,0}, -- Powershot damage reduction
    t20={0,10}, -- Shackleshot duration
    t25={0,10}, -- Powershot execute
}
roleAbilityBuilds.pos_5 = {2,3,2,1,2,6,2,3,3,3,6,1,1,1,6}
roleTalentTrees.pos_5 = {
    t10={10,0}, -- Windrun duration
    t15={10,0}, -- Powershot damage reduction
    t20={0,10}, -- Shackleshot duration
    t25={0,10}, -- Powershot execute
}
local nAbilityBuildList = roleAbilityBuilds[sRole] or roleAbilityBuilds.pos_4
local nTalentBuildList = J.Skill.GetTalentBuild(roleTalentTrees[sRole] or roleTalentTrees.pos_4)
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList, sRoleItemsSellList = {}, {}
sRoleItemsBuyList.pos_1 = {
        'item_double_branches','item_double_circlet','item_tango','item_faerie_fire','item_magic_wand',
        'item_null_talisman','item_power_treads','item_maelstrom','item_mjollnir','item_dragon_lance',
        'item_black_king_bar',
        -- Bot policy: selected situational items and late upgrades.
        'item_lesser_crit','item_hydras_breath','item_greater_crit','item_satanic','item_aghanims_shard',
        'item_moon_shard',
}
sRoleItemsSellList.pos_1 = {'item_black_king_bar','item_magic_wand','item_lesser_crit','item_null_talisman'}
sRoleItemsBuyList.pos_2 = {
        'item_double_branches','item_double_branches','item_tango','item_faerie_fire','item_bottle',
        'item_magic_wand','item_power_treads','item_maelstrom','item_black_king_bar',
        -- Bot policy: selected situational items and late upgrades.
        'item_blink','item_lesser_crit','item_mjollnir','item_greater_crit','item_swift_blink',
        'item_satanic','item_aghanims_shard','item_moon_shard',
}
sRoleItemsSellList.pos_2 = {'item_blink','item_bottle','item_lesser_crit','item_magic_wand'}
sRoleItemsBuyList.pos_3 = {
        'item_double_branches','item_double_circlet','item_tango','item_faerie_fire','item_null_talisman',
        'item_bracer','item_magic_wand','item_power_treads','item_maelstrom','item_black_king_bar',
        -- Bot policy: selected situational items and late upgrades.
        'item_blink','item_lesser_crit','item_sphere','item_mjollnir','item_greater_crit',
        'item_swift_blink','item_aghanims_shard','item_moon_shard',
}
sRoleItemsSellList.pos_3 = {'item_black_king_bar','item_null_talisman','item_blink','item_bracer','item_lesser_crit','item_magic_wand'}
sRoleItemsBuyList.pos_4 = {
        'item_branches','item_circlet','item_magic_stick','item_tango','item_ward_observer',
        'item_ward_sentry','item_blood_grenade','item_urn_of_shadows','item_magic_wand','item_essence_distiller',
        'item_blink',
        -- Bot policy: selected situational items and late upgrades.
        'item_aghanims_shard','item_arcane_boots','item_force_staff','item_lotus_orb','item_sheepstick',
        'item_overwhelming_blink',
}
sRoleItemsSellList.pos_4 = {'item_force_staff','item_magic_wand'}
sRoleItemsBuyList.pos_5 = {
        'item_branches','item_circlet','item_magic_stick','item_ward_sentry','item_tango',
        'item_blood_grenade','item_urn_of_shadows','item_magic_wand',
        -- Bot policy: selected situational items and late upgrades.
        'item_essence_distiller','item_arcane_boots','item_force_staff','item_glimmer_cape','item_lotus_orb',
        'item_sheepstick','item_aghanims_shard',
}
sRoleItemsSellList.pos_5 = {'item_force_staff','item_magic_wand'}
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = sRoleItemsSellList[sRole]
-- Core bots omit observed starting wards.
if sRole == 'pos_1' or sRole == 'pos_2' or sRole == 'pos_3' then
    local coreBuyList = {}
    for _, item in ipairs(X.sBuyList) do
        if item ~= 'item_ward_observer' and item ~= 'item_ward_sentry' then table.insert(coreBuyList, item) end
    end
    X.sBuyList = coreBuyList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT takes an ability at 10, then the first talent at 11.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local ShackleShot,Powershot,Windrun,FocusFire,FocusCancel
local function Refresh()
 bot=GetBot();ShackleShot=bot:GetAbilityByName('windrunner_shackleshot');Powershot=bot:GetAbilityByName('windrunner_powershot');Windrun=bot:GetAbilityByName('windrunner_windrun');FocusFire=bot:GetAbilityByName('windrunner_focusfire');FocusCancel=bot:GetAbilityByName('windrunner_focusfire_cancel')
end
local function Range(a)
 local range=a:GetCastRange()
 for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
 local passive=bot:GetAbilityByName('rubick_arcane_supremacy')
 if passive~=nil and not passive:IsNull() and passive:IsTrained() and not J.HasBreakModifier(bot) then range=range+passive:GetSpecialValueInt('cast_range') end
 return range
end
local function Enemy(unit,pierce)
 return J.IsValid(unit) and (pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit)) and not J.IsSuspiciousIllusion(unit)
end
local function Useful(enemy)
 if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then return true end
 if J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then return true end
 for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,ally) then return true end
 end
 return false
end
local function Behind(primary,anchor,radius,angle)
 local toward=primary-bot:GetLocation();local delta=anchor-primary;local a,b=toward:Length2D(),delta:Length2D()
 if a<1 or b<1 or b>radius then return false end
 return (toward.x*delta.x+toward.y*delta.y)/(a*b)>=math.cos(angle*math.pi/180)
end
local function Units()
 local units=GetUnitList(UNIT_LIST_ENEMIES);local seen={};for _,unit in ipairs(units) do seen[unit]=true end
 for _,unit in ipairs(bot:GetNearbyNeutralCreeps(1600)) do if not seen[unit] then units[#units+1]=unit;seen[unit]=true end end
 return units
end
local function ShacklePrimary(target)
 local range=Range(ShackleShot);local radius=ShackleShot:GetSpecialValueInt('shackle_distance');local angle=ShackleShot:GetSpecialValueInt('shackle_angle')
 local units=Units()
 for _,primary in ipairs(units) do
  if J.IsValid(primary) and J.CanCastOnNonMagicImmune(primary) and J.CanCastOnTargetAdvanced(primary) and GetUnitToUnitDistance(bot,primary)<=range then
   local eta=ShackleShot:GetCastPoint()+GetUnitToUnitDistance(bot,primary)/ShackleShot:GetSpecialValueInt('arrow_speed')
   local point=J.GetCorrectLoc(primary,eta)
   if primary~=target then
    if Behind(point,J.GetCorrectLoc(target,eta),radius,angle) then return primary end
   else
    for _,anchor in ipairs(units) do if anchor~=primary and J.IsValid(anchor) and Behind(point,J.GetCorrectLoc(anchor,eta),radius,angle) then return primary end end
    for _,tree in ipairs(target:GetNearbyTrees(radius)) do local location=GetTreeLocation(tree);if location~=nil and Behind(point,location,radius,angle) then return primary end end
   end
  end
 end
 return nil
end
function X.ConsiderShackleShot()
 if not J.CanCastAbility(ShackleShot) then return 0 end
 local range=Range(ShackleShot);local choice,best=nil,0
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range+ShackleShot:GetSpecialValueInt('shackle_distance'),1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) then
   if enemy:IsChanneling() and GetUnitToUnitDistance(bot,enemy)<=range and J.CanCastOnTargetAdvanced(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end
   if Useful(enemy) or J.IsInTeamFight(bot,1200) or enemy:IsChanneling() then
    local primary=ShacklePrimary(enemy)
    if primary~=nil and J.GetRemainStunTime(enemy)<=ShackleShot:GetCastPoint()+GetUnitToUnitDistance(bot,primary)/ShackleShot:GetSpecialValueInt('arrow_speed')+0.15 then
     local score=enemy:GetEstimatedDamageToTarget(false,bot,3,DAMAGE_TYPE_PHYSICAL)+(enemy==J.GetProperTarget(bot) and 100 or 0)
     if score>=best then choice,best=primary,score end
    elseif GetUnitToUnitDistance(bot,enemy)<=range and J.CanCastOnTargetAdvanced(enemy) and J.GetRemainStunTime(enemy)<=0.2
     and (J.IsChasingTarget(enemy,bot) or (Useful(enemy) and not (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)))) then return BOT_ACTION_DESIRE_HIGH,enemy end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 return 0
end
local function Shot(target)
 local range=math.min(Range(Powershot),Powershot:GetSpecialValueInt('arrow_range'))
 local eta=Powershot:GetCastPoint()+Powershot:GetChannelTime()+GetUnitToUnitDistance(bot,target)/Powershot:GetSpecialValueInt('arrow_speed')
 local point=J.GetCorrectLoc(target,eta);local delta=point-bot:GetLocation();local length=delta:Length2D()
 if length<1 or length>range then return nil end
 local direction=delta:Normalized();local blockers=0;local hits=0
 for _,unit in ipairs(Units()) do
  if J.IsValid(unit) then
   local offset=J.GetCorrectLoc(unit,eta)-bot:GetLocation();local along=offset.x*direction.x+offset.y*direction.y
   if along>=0 and along<=length and math.abs(offset.x*direction.y-offset.y*direction.x)<=Powershot:GetSpecialValueInt('arrow_width') then
    hits=hits+1;if unit~=target and along<length-1 then blockers=blockers+1 end
   end
  end
 end
 -- Flat attenuation is conservative when the engine compounds reductions.
 local fraction=math.max(0,1-blockers*Powershot:GetSpecialValueInt('damage_reduction')/100)
 return point,Powershot:GetSpecialValueInt('powershot_damage')*fraction,eta,hits
end
function X.ConsiderPowershot()
 if not J.CanCastAbility(Powershot) or (J.GetHP(bot)<0.45 and bot:WasRecentlyDamagedByAnyHero(2)) then return 0 end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,450,true,BOT_MODE_NONE)) do if Enemy(enemy,true) and enemy:GetAttackTarget()==bot then return 0 end end
 local choice,best=nil,0
 for _,enemy in ipairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
  if Enemy(enemy,false) and not J.CannotBeKilled(bot,enemy) and not enemy:HasModifier('modifier_item_blade_mail_reflect') and not enemy:HasModifier('modifier_nyx_assassin_spiked_carapace') then
   local point,damage,eta,hits=Shot(enemy)
   if point~=nil then
    if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,point end
    if (Useful(enemy) or J.IsInTeamFight(bot,1200)) and GetUnitToUnitDistance(bot,enemy)>bot:GetAttackRange() and hits>best then choice,best=point,hits end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 if J.IsAllowedToSpam(bot,Powershot:GetManaCost()) then
  local units={};if J.IsFarming(bot) then units=bot:GetNearbyNeutralCreeps(1600) elseif J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot) then units=bot:GetNearbyLaneCreeps(1600,true) end
  for _,creep in ipairs(units) do
   if Enemy(creep,false) then
    local point,damage,eta,hits=Shot(creep)
    if point~=nil and ((not J.IsLaning(bot) and hits>=3) or (J.IsLaning(bot) and J.IsKeyWordUnit('ranged',creep) and J.WillKillTarget(creep,damage,DAMAGE_TYPE_MAGICAL,eta))) then return BOT_ACTION_DESIRE_HIGH,point end
   end
  end
 end
 return 0
end
function X.ConsiderWindrun()
 if not J.CanCastAbility(Windrun) or bot:HasModifier('modifier_windrunner_windrun') then return 0 end
 if J.GetAttackProjectileDamageByRange(bot,1000)>0 then return BOT_ACTION_DESIRE_HIGH end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,1000,true,BOT_MODE_NONE)) do
  if Enemy(enemy,true) and enemy:GetAttackTarget()==bot and GetUnitToUnitDistance(bot,enemy)<=enemy:GetAttackRange()+100 then return BOT_ACTION_DESIRE_HIGH end
 end
 if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and not bot:HasModifier('modifier_bloodseeker_rupture') then return BOT_ACTION_DESIRE_HIGH end
 local target=J.GetProperTarget(bot)
 if J.IsGoingOnSomeone(bot) and Enemy(target,true) and GetUnitToUnitDistance(bot,target)>bot:GetAttackRange() and not bot:IsRooted()
  and not bot:HasModifier('modifier_bloodseeker_rupture') and not bot:HasModifier('modifier_puck_coiled') and not bot:HasModifier('modifier_slark_pounce_leash') then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderFocusFire()
 if not J.CanCastAbility(FocusFire) or bot:IsDisarmed() or bot:HasModifier('modifier_windrunner_focusfire') then return 0 end
 local target=J.GetProperTarget(bot)
 if J.IsPushing(bot) then target=bot:GetAttackTarget() end
 if (J.IsValid(target) or J.IsValidBuilding(target)) and target:GetTeam()~=bot:GetTeam() and J.CanBeAttacked(target) and J.CanCastOnTargetAdvanced(target)
  and GetUnitToUnitDistance(bot,target)<=Range(FocusFire) and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange()+100
  and not J.CannotBeKilled(bot,target) and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace') and not target:HasModifier('modifier_fountain_glyph') then
  if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) then return BOT_ACTION_DESIRE_HIGH,target end
  if (J.IsPushing(bot) and J.IsValidBuilding(target) or J.IsDoingRoshan(bot)) and J.IsAttacking(bot) and target:GetHealth()>bot:GetAttackDamage()*3 then return BOT_ACTION_DESIRE_HIGH,target end
 end
 return 0
end
function X.ConsiderFocusFireCancel()
 if not J.CanCastAbility(FocusCancel) or not bot:HasModifier('modifier_windrunner_focusfire') then return 0 end
 local target=bot:GetAttackTarget()
 if target~=nil and (not J.CanBeAttacked(target) or target:HasModifier('modifier_item_blade_mail_reflect') or target:HasModifier('modifier_nyx_assassin_spiked_carapace') or J.CannotBeKilled(bot,target)) then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderGaleForce()
 -- Vector direction cannot be expressed by the documented bot API. Do not issue blind displacement.
 return 0
end
function X.ConsiderPowershotSafety()
 local current=GetBot();if not current:IsChanneling() then return false end
 local active=current:GetCurrentActiveAbility();if active==nil or active:IsNull() or active:GetName()~='windrunner_powershot' then return false end
 if not current:IsAlive() or current:NumQueuedActions()>0 or current:IsStunned() or current:IsHexed() or current:IsNightmared() or current:IsSilenced()
  or current:HasModifier('modifier_ringmaster_the_box_buff') or current:HasModifier('modifier_doom_bringer_doom') or current:HasModifier('modifier_item_forcestaff_active') then return false end
 if J.GetHP(current)<0.4 and (current:WasRecentlyDamagedByAnyHero(1) or J.GetAttackProjectileDamageByRange(current,1000)>current:GetHealth()*0.2) then
  -- Cancelling can release a partial arrow; never count it as a full-charge lethal.
  current:Action_ClearActions(true);current:Action_MoveToLocation(J.GetEscapeLoc());return true
 end
 return false
end
function X.SkillsComplement()
 Refresh();if X.ConsiderPowershotSafety() then return end
 if J.CanNotUseAbility(bot) or bot:NumQueuedActions()>0 then return end
 if X.ConsiderFocusFireCancel()>0 then bot:Action_UseAbility(FocusCancel);return end
 if X.ConsiderWindrun()>0 then bot:Action_UseAbility(Windrun);return end
 local desire,target=X.ConsiderShackleShot()
 if desire>0 then J.SetQueuePtToINT(bot,false);bot:ActionQueue_UseAbilityOnEntity(ShackleShot,target);return end
 desire,target=X.ConsiderFocusFire()
 if desire>0 then bot:Action_UseAbilityOnEntity(FocusFire,target);return end
 desire,target=X.ConsiderPowershot()
 if desire>0 then J.SetQueuePtToINT(bot,false);bot:ActionQueue_UseAbilityOnLocation(Powershot,target);return end
end
return X
