local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; forced skipped roles use pos 4.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/weaver')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] The Swarm, [2] Shukuchi, [3] Geminate Attack, [6] Time Lapse.
local roleAbilityBuilds, roleTalentTrees = {}, {}
roleAbilityBuilds.pos_1 = {2,3,1,2,2,6,2,3,3,3,6,1,1,1,6}
roleTalentTrees.pos_1 = {
    t10={10,0}, -- Strength
    t15={10,0}, -- Swarm attacks to kill
    t20={0,10}, -- Geminate damage
    t25={10,0}, -- Additional Geminate attack
}
roleAbilityBuilds.pos_3 = {2,3,1,2,2,6,2,1,1,1,6,3,3,3,6}
roleTalentTrees.pos_3 = {
    t10={0,10}, -- Movement speed
    t15={0,10}, -- Shukuchi damage
    t20={0,10}, -- Geminate damage
    t25={0,10}, -- Shukuchi cooldown
}
roleAbilityBuilds.pos_4 = {2,3,1,2,2,6,2,1,1,1,6,3,3,3,6}
roleTalentTrees.pos_4 = {
    t10={10,0}, -- Strength
    t15={10,0}, -- Swarm attacks to kill
    t20={10,0}, -- Swarm armor reduction
    t25={0,10}, -- Shukuchi cooldown
}
roleAbilityBuilds.pos_5 = {2,3,1,2,2,6,2,1,1,1,6,3,3,3,6}
roleTalentTrees.pos_5 = {
    t10={10,0}, -- Strength
    t15={10,0}, -- Swarm attacks to kill
    t20={0,10}, -- Geminate damage
    t25={0,10}, -- Shukuchi cooldown
}
local nAbilityBuildList = roleAbilityBuilds[sRole] or roleAbilityBuilds.pos_4
local nTalentBuildList = J.Skill.GetTalentBuild(roleTalentTrees[sRole] or roleTalentTrees.pos_4)
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList, sRoleItemsSellList = {}, {}
sRoleItemsBuyList.pos_1 = {
        'item_magic_wand','item_faerie_fire','item_faerie_fire','item_falcon_blade','item_power_treads',
        'item_desolator','item_aghanims_shard','item_dragon_lance','item_lesser_crit',
        -- Bot policy: selected situational items and late upgrades.
        'item_black_king_bar','item_greater_crit','item_hurricane_pike','item_satanic','item_moon_shard',
}
sRoleItemsSellList.pos_1 = {'item_black_king_bar','item_magic_wand','item_greater_crit','item_falcon_blade'}
sRoleItemsBuyList.pos_3 = {
        'item_double_branches','item_circlet','item_magic_stick','item_faerie_fire','item_faerie_fire',
        'item_magic_wand','item_urn_of_shadows',
        -- Bot policy: selected situational items and late upgrades.
        'item_spirit_vessel','item_aghanims_shard','item_octarine_core','item_lotus_orb','item_lesser_crit',
        'item_black_king_bar','item_greater_crit','item_sheepstick',
}
sRoleItemsSellList.pos_3 = {'item_lotus_orb','item_magic_wand'}
sRoleItemsBuyList.pos_4 = {
        'item_branches','item_circlet','item_magic_stick','item_ward_sentry','item_tango',
        'item_blood_grenade','item_urn_of_shadows','item_magic_wand','item_spirit_vessel',
        -- Bot policy: selected situational items and late upgrades.
        'item_rod_of_atos','item_lotus_orb','item_ultimate_scepter','item_ultimate_scepter_2','item_aghanims_shard',
        'item_sheepstick','item_octarine_core','item_black_king_bar',
}
sRoleItemsSellList.pos_4 = {'item_rod_of_atos','item_magic_wand'}
sRoleItemsBuyList.pos_5 = {
        'item_branches','item_circlet','item_magic_stick','item_ward_sentry','item_tango',
        'item_blood_grenade','item_urn_of_shadows','item_magic_wand','item_spirit_vessel','item_aghanims_shard',
        -- Bot policy: selected situational items and late upgrades.
        'item_lotus_orb','item_glimmer_cape','item_ultimate_scepter','item_ultimate_scepter_2','item_force_staff',
        'item_sheepstick','item_octarine_core',
}
sRoleItemsSellList.pos_5 = {'item_glimmer_cape','item_magic_wand'}
sRoleItemsBuyList.pos_2 = sRoleItemsBuyList.pos_4
sRoleItemsSellList.pos_2 = sRoleItemsSellList.pos_4
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

local TheSwarm,Shukuchi,Geminate,TimeLapse
local function Refresh()
 bot=GetBot();TheSwarm=bot:GetAbilityByName('weaver_the_swarm');Shukuchi=bot:GetAbilityByName('weaver_shukuchi');Geminate=bot:GetAbilityByName('weaver_geminate_attack');TimeLapse=bot:GetAbilityByName('weaver_time_lapse')
end
local function Handle(a)
 return a~=nil and not a:IsNull() and a:IsTrained() and not a:IsHidden() and a:IsActivated()
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
  and not J.CannotBeKilled(bot,unit) and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace') and not unit:HasModifier('modifier_item_blade_mail_reflect')
end
local function Useful(enemy)
 if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then return true end
 if J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then return true end
 for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,ally) then return true end
 end
 return false
end
local function Safe(location)
 return IsLocationPassable(location) and not J.IsLocationInChrono(location) and not J.IsLocationInBlackHole(location) and not J.IsLocHaveTower(700,true,location)
  and #J.GetEnemiesNearLoc(location,800)<=#J.GetAlliesNearLoc(location,800)+1
end
local function Moving()
 return not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture') and not bot:HasModifier('modifier_puck_coiled') and not bot:HasModifier('modifier_slark_pounce_leash')
end
function X.ObserveTimeLapseHistory()
 local current=GetBot();local ability=current:GetAbilityByName('weaver_time_lapse')
 if not Handle(ability) then current.weaverHistory=nil;return end
 bot=current
 local now=DotaTime();local state=bot.weaverHistory
 if state==nil or state.time>now or now-state.time>0.75 or not bot:IsAlive() then state={time=now,units={}};bot.weaverHistory=state end
 if not bot:IsAlive() then return end
 local units={bot}
 if ability:GetSpecialValueInt('targets_allies')>0 then
  for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(Range(ability),1600),false,BOT_MODE_NONE)) do if J.IsValidHero(ally) and not ally:IsIllusion() then units[#units+1]=ally end end
 end
 state.time=now
 for id,entry in pairs(state.units) do if entry.unit:IsNull() or not entry.unit:IsAlive() then state.units[id]=nil end end
 for _,unit in ipairs(units) do
  local id=unit:GetPlayerID();local entry=state.units[id]
  if entry==nil or entry.unit~=unit or now-entry.time>0.75 or not unit:IsAlive() then entry={unit=unit,time=now,samples={}};state.units[id]=entry end
  if unit:IsAlive() and (entry.samples[#entry.samples]==nil or now-entry.time>=0.2) then
   entry.time=now;entry.samples[#entry.samples+1]={time=now,hp=unit:GetHealth(),location=unit:GetLocation()}
   while #entry.samples>0 and now-entry.samples[1].time>6 do table.remove(entry.samples,1) end
  end
 end
end
local function Past(unit)
 local state=bot.weaverHistory;if state==nil then return nil end
 local entry=state.units[unit:GetPlayerID()];if entry==nil or entry.unit~=unit or DotaTime()-entry.time>0.4 then return nil end
 local desired=DotaTime()+TimeLapse:GetCastPoint()-5;local chosen,delta=nil,0.26
 for _,sample in ipairs(entry.samples) do local error=math.abs(sample.time-desired);if error<delta then chosen,delta=sample,error end end
 return chosen
end
function X.ConsiderTimeLapse()
 if not J.CanCastAbility(TimeLapse) then return 0 end
 local friends={bot};local allies=TimeLapse:GetSpecialValueInt('targets_allies')>0
 if allies then for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(Range(TimeLapse),1600),false,BOT_MODE_NONE)) do friends[#friends+1]=ally end end
 local choice,best=nil,0
 for _,unit in ipairs(friends) do
  if J.IsValidHero(unit) and not unit:IsIllusion() and not unit:IsInvulnerable() and (not unit:IsChanneling() or J.GetHP(unit)<0.35) and (unit==bot or GetUnitToUnitDistance(bot,unit)<=Range(TimeLapse)) then
   local past=Past(unit)
   if past~=nil and Safe(past.location) then
    local gain=past.hp-unit:GetHealth();local threatened=unit:WasRecentlyDamagedByAnyHero(2) or J.GetAttackProjectileDamageByRange(unit,1000)>unit:GetHealth()*0.2
    local currentThreat=#J.GetEnemiesNearLoc(unit:GetLocation(),700);local oldThreat=#J.GetEnemiesNearLoc(past.location,700)
    local reposition=threatened and GetUnitToLocationDistance(unit,past.location)>500 and oldThreat<currentThreat
    if (gain>=math.max(150,unit:GetMaxHealth()*0.2) and (threatened or J.GetHP(unit)<0.5)) or reposition then
     local score=math.max(0,gain)+((1-J.GetHP(unit))*200)+(reposition and 150 or 0)
     if score>best then choice,best=unit,score end
    end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 return 0
end
function X.ConsiderTheSwarm()
 if not J.CanCastAbility(TheSwarm) or bot:HasModifier('modifier_weaver_shukuchi') then return 0 end
 local range=Range(TheSwarm);local width=TheSwarm:GetSpecialValueInt('radius');local choice,best=nil,0
 local units=GetUnitList(UNIT_LIST_ENEMY_HEROES)
 for _,host in ipairs(units) do
  if Enemy(host,false) and not host:HasModifier('modifier_weaver_swarm_debuff') and GetUnitToUnitDistance(bot,host)<=range and (Useful(host) or J.IsInTeamFight(bot,1200)) then
   local eta=TheSwarm:GetCastPoint()+GetUnitToUnitDistance(bot,host)/TheSwarm:GetSpecialValueInt('speed');local point=J.GetCorrectLoc(host,eta)
   local delta=point-bot:GetLocation();local length=delta:Length2D()
   if length>0 and length<=range then
    local direction=delta:Normalized();local count=0
    for _,enemy in ipairs(units) do
     if Enemy(enemy,false) and not enemy:HasModifier('modifier_weaver_swarm_debuff') then
      local offset=J.GetCorrectLoc(enemy,eta)-bot:GetLocation();local along=offset.x*direction.x+offset.y*direction.y
      if along>=0 and along<=length and math.abs(offset.x*direction.y-offset.y*direction.x)<=width then count=count+1 end
     end
    end
    if count>best then choice,best=point,count end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 local target=J.GetProperTarget(bot)
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(target,false) and J.IsAttacking(bot) and GetUnitToUnitDistance(bot,target)<=1200 and not target:HasModifier('modifier_weaver_swarm_debuff') then return BOT_ACTION_DESIRE_HIGH,target:GetLocation() end
 return 0
end
function X.ConsiderShukuchi()
 if not J.CanCastAbility(Shukuchi) or bot:HasModifier('modifier_weaver_shukuchi') then return 0 end
 if J.IsRetreating(bot) and (bot:WasRecentlyDamagedByAnyHero(2) or J.GetAttackProjectileDamageByRange(bot,1000)>0) then return BOT_ACTION_DESIRE_HIGH end
 local radius=Shukuchi:GetSpecialValueInt('radius');local speed=math.max(bot:GetCurrentMovementSpeed(),Shukuchi:GetSpecialValueInt('min_movespeed_override'));local duration=Shukuchi:GetSpecialValueFloat('duration')
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) then
   local distance=GetUnitToUnitDistance(bot,enemy);local eta=Shukuchi:GetSpecialValueFloat('fade_time')+math.max(0,distance-radius)/speed
   local predicted=J.GetCorrectLoc(enemy,eta)
   eta=Shukuchi:GetSpecialValueFloat('fade_time')+math.max(0,GetUnitToLocationDistance(bot,predicted)-radius)/speed
   local reachable=distance<=radius or (Moving() and eta<duration-0.5 and Safe(predicted))
   if reachable and J.WillKillTarget(enemy,Shukuchi:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH end
   if Moving() and Useful(enemy) and J.IsGoingOnSomeone(bot) and distance>bot:GetAttackRange()+100 and eta<duration-0.5 and Safe(enemy:GetLocation()) then return BOT_ACTION_DESIRE_HIGH end
  end
 end
 if J.IsAllowedToSpam(bot,Shukuchi:GetManaCost()) then
  if J.IsFarming(bot) and Moving() and J.IsAttacking(bot) and #bot:GetNearbyNeutralCreeps(500)>=2 then return BOT_ACTION_DESIRE_HIGH end
  if J.IsLaning(bot) then
   for _,creep in ipairs(bot:GetNearbyLaneCreeps(radius,true)) do
    if Enemy(creep,false) and J.IsKeyWordUnit('ranged',creep) and J.WillKillTarget(creep,Shukuchi:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,Shukuchi:GetSpecialValueFloat('fade_time')) then return BOT_ACTION_DESIRE_HIGH end
   end
  end
 end
 return 0
end
function X.UseGeminate(toggleOnly)
 if not Handle(Geminate) then return false end
 local target=bot:GetAttackTarget();local valid=not bot:IsDisarmed() and not J.HasBreakModifier(bot) and (J.IsValid(target) or J.IsValidBuilding(target)) and J.CanBeAttacked(target)
  and target:GetTeam()~=bot:GetTeam() and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange() and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace')
  and not target:HasModifier('modifier_fountain_glyph')
 local desired=valid and J.IsAttacking(bot)
 if Geminate:GetAutoCastState()~=desired then Geminate:ToggleAutoCast();return true end
 if not toggleOnly and valid and J.CanCastAbility(Geminate) and not desired and (J.IsGoingOnSomeone(bot) or J.IsFarming(bot) or J.IsLaning(bot)) then bot:Action_UseAbilityOnEntity(Geminate,target);return true end
 return false
end
function X.SkillsComplement()
 Refresh();X.ObserveTimeLapseHistory()
 if J.CanNotUseAbility(bot) or bot:NumQueuedActions()>0 then return end
 local desire,target=X.ConsiderTimeLapse()
 if desire>0 then
  if TimeLapse:GetSpecialValueInt('targets_allies')>0 then bot:Action_UseAbilityOnEntity(TimeLapse,target) else bot:Action_UseAbility(TimeLapse) end
  return
 end
 desire=X.ConsiderShukuchi()
 if desire>0 then J.SetQueuePtToINT(bot,false);bot:Action_UseAbility(Shukuchi);return end
 if X.UseGeminate() then return end
 desire,target=X.ConsiderTheSwarm()
 if desire>0 then J.SetQueuePtToINT(bot,false);bot:Action_UseAbilityOnLocation(TheSwarm,target);return end
end
return X
