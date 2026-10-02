local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: mid, offlane and both supports; forced carry uses support.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/phoenix')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Icarus Dive, [2] Fire Spirits, [3] Sun Ray, [6] Supernova.
local nAbilityBuildList = {2,1,2,1,2,6,2,1,1,3,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +25% Icarus Dive slow
    t15={0,10}, -- +20 Fire Spirits damage per second
    t20={0,10}, -- +1.25% max health Sun Ray damage
    t25={0,10}, -- +2 Supernova hit count
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_4 = {
    'item_branches','item_circlet','item_magic_stick','item_ward_sentry','item_tango','item_blood_grenade',
    'item_urn_of_shadows','item_tranquil_boots','item_magic_wand','item_spirit_vessel',
    'item_aghanims_shard','item_shivas_guard','item_aeon_disk',
    -- Bot policy: late Refresher and consumed Scepter, then defensive Eul's upgrade.
    'item_refresher','item_ultimate_scepter','item_ultimate_scepter_2','item_cyclone','item_wind_waker',
}
sRoleItemsBuyList.pos_5 = {
    'item_branches','item_circlet','item_magic_stick','item_ward_sentry','item_tango','item_blood_grenade',
    'item_urn_of_shadows','item_tranquil_boots','item_magic_wand','item_spirit_vessel',
    'item_aghanims_shard','item_shivas_guard','item_aeon_disk','item_refresher',
    -- Bot policy: consumed Scepter and defensive Eul's upgrade.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_cyclone','item_wind_waker',
}
sRoleItemsBuyList.pos_2 = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_gauntlets','item_double_branches','item_circlet','item_tango','item_faerie_fire',
    'item_bracer','item_bracer','item_urn_of_shadows','item_tranquil_boots','item_spirit_vessel',
    'item_shivas_guard','item_aghanims_shard','item_refresher','item_ultimate_scepter',
    -- Bot policy: consume Scepter, then protection and late disable.
    'item_ultimate_scepter_2','item_black_king_bar','item_sheepstick',
}
sRoleItemsBuyList.pos_3 = {
    'item_gauntlets','item_double_branches','item_circlet','item_tango','item_faerie_fire',
    'item_bracer','item_bracer','item_urn_of_shadows','item_tranquil_boots','item_spirit_vessel',
    'item_shivas_guard','item_aghanims_shard','item_refresher',
    -- Bot policy: consumed Scepter, late disable and protection.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_sheepstick','item_black_king_bar',
}
sRoleItemsBuyList.pos_1 = {}
for _,item in ipairs(sRoleItemsBuyList.pos_4) do
    if item ~= 'item_ward_sentry' then table.insert(sRoleItemsBuyList.pos_1,item) end
end
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {'item_shivas_guard','item_magic_wand','item_shivas_guard','item_bracer','item_shivas_guard','item_bracer'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_antimage'}, {} end

nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X.bDeafaultAbility = false
X.bDeafaultItem = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local IcarusDive        = bot:GetAbilityByName('phoenix_icarus_dive')
local IcarusDiveStop    = bot:GetAbilityByName('phoenix_icarus_dive_stop')
local FireSpirits       = bot:GetAbilityByName('phoenix_fire_spirits')
local FireSpiritsLaunch = bot:GetAbilityByName('phoenix_launch_fire_spirit')
local SunRay            = bot:GetAbilityByName('phoenix_sun_ray')
local SunRayStop        = bot:GetAbilityByName('phoenix_sun_ray_stop')
local ToggleMovement    = bot:GetAbilityByName('phoenix_sun_ray_toggle_move')
local Supernova         = bot:GetAbilityByName('phoenix_supernova')


function X.SkillsComplement()
    if X.ConsiderEggSunRay() then return end
    if J.CanNotUseAbility(bot) then return end
    if X.ConsiderIcarusDiveStop()>0 then bot:Action_UseAbility(IcarusDiveStop);bot.phoenixDiveGoal=nil;return end
    if X.ConsiderSunRayStop()>0 then bot:Action_UseAbility(SunRayStop);bot.phoenixRayTarget=nil;bot.sun_ray_target=nil;return end
    if X.ConsiderToggleMovement()>0 then bot:Action_UseAbility(ToggleMovement);return end
    local desire,target=X.ConsiderSupernova()
    if desire>0 then
        if target~=nil then bot:Action_UseAbilityOnEntity(Supernova,target) else bot:Action_UseAbility(Supernova) end
        return
    end
    local desire,point,target,eta=X.ConsiderFireSpiritsLaunch()
    if desire>0 then bot:Action_UseAbilityOnLocation(FireSpiritsLaunch,point);bot.phoenixSpiritPending={target=target,untilTime=DotaTime()+eta+0.2};return end
    if X.ConsiderFireSpirits()>0 then bot:Action_UseAbility(FireSpirits);return end
    local desire,point=X.ConsiderIcarusDive()
    if desire>0 then bot.phoenixDiveGoal=point;bot:Action_UseAbilityOnLocation(IcarusDive,point);return end
    local desire,point=X.ConsiderSunRay()
    if desire>0 then bot:Action_UseAbilityOnLocation(SunRay,point) end
end
local function ActualRange(ability)
    local range=ability:GetCastRange()
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(target)
    return J.IsValid(target) and J.CanCastOnNonMagicImmune(target) and not J.CannotBeKilled(bot,target)
        and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function SafePoint(point)
    return not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point) and not J.IsLocHaveTower(700,true,point)
end
local function Toward(location,range)
    local delta=location-bot:GetLocation()
    return delta:Length2D()==0 and bot:GetLocation() or bot:GetLocation()+delta:Normalized()*math.min(range,delta:Length2D())
end
local function SpiritPoint(ability,target)
    local range=ActualRange(ability)
    local eta=ability:GetCastPoint()+GetUnitToUnitDistance(bot,target)/ability:GetSpecialValueInt('spirit_speed')
    local predicted=J.GetCorrectLoc(target,eta)
    local point=Toward(predicted,range)
    if (point-predicted):Length2D()>ability:GetSpecialValueInt('radius') then return nil end
    if target:HasModifier('modifier_phoenix_fire_spirit_burn') then
        local index=target:GetModifierByName('modifier_phoenix_fire_spirit_burn')
        if index>=0 and target:GetModifierRemainingDuration(index)>eta+0.2 then return nil end
    end
    local pending=bot.phoenixSpiritPending
    if pending~=nil and pending.target==target and DotaTime()<pending.untilTime then return nil end
    return point,eta
end
local function SpiritOpportunity(ability)
    local range=ActualRange(ability)+ability:GetSpecialValueInt('radius')
    local target=J.GetProperTarget(bot)
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy) then
            local point,eta=SpiritPoint(ability,enemy)
            if point~=nil then
                local lethal=J.WillKillTarget(enemy,ability:GetSpecialValueInt('damage_per_second')*ability:GetSpecialValueFloat('duration'),DAMAGE_TYPE_MAGICAL,eta+ability:GetSpecialValueFloat('duration'))
                if lethal or (J.IsGoingOnSomeone(bot) and (enemy==target or enemy:GetAttackTarget()==bot))
                    or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) or J.IsInTeamFight(bot,1200) then return point,enemy,eta end
            end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,100) then
        local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
        for _,creep in ipairs(creeps) do
            if Enemy(creep) then
                local point,eta=SpiritPoint(ability,creep)
                if point~=nil then
                    local count=0
                    for _,other in ipairs(creeps) do if Enemy(other) and (J.GetCorrectLoc(other,eta)-point):Length2D()<=ability:GetSpecialValueInt('radius') then count=count+1 end end
                    if count>=3 then return point,creep,eta end
                end
            end
        end
    end
    return nil
end
function X.ConsiderFireSpirits()
    if not J.CanCastAbility(FireSpirits) or bot:HasModifier('modifier_phoenix_supernova_hiding')
        or bot:HasModifier('modifier_phoenix_fire_spirit_count') or J.GetHP(bot)*(1-FireSpirits:GetSpecialValueInt('hp_cost_perc')/100)<0.25 then return 0 end
    if SpiritOpportunity(FireSpirits)~=nil then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderFireSpiritsLaunch()
    if not J.CanCastAbility(FireSpiritsLaunch) or bot:HasModifier('modifier_phoenix_supernova_hiding') then return 0 end
    local point,target,eta=SpiritOpportunity(FireSpiritsLaunch)
    if point~=nil then return BOT_ACTION_DESIRE_HIGH,point,target,eta end
    return 0
end
function X.ConsiderIcarusDive()
    if not J.CanCastAbility(IcarusDive) or bot:IsRooted() or bot:HasModifier('modifier_phoenix_icarus_dive')
        or bot:HasModifier('modifier_phoenix_supernova_hiding') or bot:HasModifier('modifier_bloodseeker_rupture')
        or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled') then return 0 end
    local range=IcarusDive:GetSpecialValueInt('dash_length')
    local health=J.GetHP(bot)*(1-IcarusDive:GetSpecialValueInt('hp_cost_perc')/100)
    if (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) or J.IsStuck(bot) then
        local point=Toward(J.GetEscapeLoc(),range)
        if health>0.12 and SafePoint(point) then return BOT_ACTION_DESIRE_HIGH,point end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsValidHero(target) and health>0.4
        and GetUnitToUnitDistance(bot,target)>400 and GetUnitToUnitDistance(bot,target)<=range
        and SafePoint(target:GetLocation()) and #J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)<=#J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)+1 then return BOT_ACTION_DESIRE_HIGH,target:GetLocation() end
    return 0
end
function X.ConsiderIcarusDiveStop()
    if not J.CanCastAbility(IcarusDiveStop) or not bot:HasModifier('modifier_phoenix_icarus_dive') then return 0 end
    if bot:HasModifier('modifier_bloodseeker_rupture') then return BOT_ACTION_DESIRE_HIGH end
    local goal=bot.phoenixDiveGoal
    if goal~=nil and GetUnitToLocationDistance(bot,goal)<=175 and SafePoint(bot:GetLocation()) and IsLocationPassable(bot:GetLocation()) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local function RayTarget()
    local range=SunRay:GetCastRange()
    if J.GetHP(bot)<0.35 and not bot:HasModifier('modifier_phoenix_supernova_hiding') then return nil end
    for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not ally:HasModifier('modifier_ice_blast')
            and ally:GetMaxHealth()-ally:GetHealth()>=150 and (J.GetHP(ally)<0.6 or ally:WasRecentlyDamagedByAnyHero(2)) then return ally end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsValidHero(target) and GetUnitToUnitDistance(bot,target)<=range then return target end
    return nil
end
function X.ConsiderSunRay()
    if not J.CanCastAbility(SunRay) or bot:HasModifier('modifier_phoenix_sun_ray') or bot:HasModifier('modifier_phoenix_icarus_dive') then return 0 end
    local target=RayTarget()
    if target~=nil then bot.phoenixRayTarget=target;bot.sun_ray_target=target;return BOT_ACTION_DESIRE_HIGH,J.GetCorrectLoc(target,SunRay:GetCastPoint()) end
    return 0
end
function X.ConsiderSunRayStop()
    if not J.CanCastAbility(SunRayStop) or not bot:HasModifier('modifier_phoenix_sun_ray') or bot:HasModifier('modifier_phoenix_supernova_hiding') then return 0 end
    if J.GetHP(bot)<0.2 then return BOT_ACTION_DESIRE_HIGH end
    local target=bot.phoenixRayTarget
    if target~=nil and (not J.IsValidHero(target) or target:GetTeam()~=bot:GetTeam() and not Enemy(target)
        or target:GetTeam()==bot:GetTeam() and (J.GetHP(target)>0.9 or target:HasModifier('modifier_ice_blast'))
        or GetUnitToUnitDistance(bot,target)>(SunRay~=nil and SunRay:GetCastRange() or 1200)+200) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderToggleMovement()
    if not J.CanCastAbility(ToggleMovement) or not bot:HasModifier('modifier_phoenix_sun_ray') or bot:HasModifier('modifier_phoenix_supernova_hiding') then return 0 end
    local target=bot.phoenixRayTarget
    local move=not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture') and J.IsValidHero(target)
        and GetUnitToUnitDistance(bot,target)>900 and bot:IsFacingLocation(target:GetLocation(),20)
        and SafePoint(bot:GetLocation()+Vector(math.cos(bot:GetFacing()*math.pi/180),math.sin(bot:GetFacing()*math.pi/180),0)*250)
    if move~=ToggleMovement:GetToggleState() then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local function EggSafe()
    local limit=Supernova:GetSpecialValueInt(bot:HasScepter() and 'max_hero_attacks_scepter' or 'max_hero_attacks')
    local attacks=0
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not enemy:IsIllusion() and not enemy:IsDisarmed() then
            local delay=math.max(0,GetUnitToUnitDistance(bot,enemy)-enemy:GetAttackRange())/math.max(1,enemy:GetCurrentMovementSpeed())
            attacks=attacks+math.max(0,6-delay)/math.max(0.2,enemy:GetSecondsPerAttack())
        end
    end
    return attacks<limit
end
function X.ConsiderSupernova()
    if not J.CanCastAbility(Supernova) or bot:HasModifier('modifier_phoenix_supernova_hiding') then return 0 end
    if not EggSafe() then return 0 end
    if bot:HasScepter() then
        for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(ActualRange(Supernova),1600),false,BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and GetUnitToUnitDistance(bot,ally)<=ActualRange(Supernova)
                and J.GetHP(ally)<0.25 and ally:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH,ally end
        end
    end
    if J.GetHP(bot)<0.3 and bot:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH end
    local enemies=J.GetNearbyHeroes(bot,math.min(Supernova:GetSpecialValueInt('aura_radius'),1600),true,BOT_MODE_NONE)
    if #enemies>=2 and J.IsInTeamFight(bot,1200) and #J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)>=1 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderEggSunRay()
    if not bot:HasModifier('modifier_phoenix_supernova_hiding') or not bot:HasModifier('modifier_item_aghanims_shard')
        or not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsSilenced() or bot:IsChanneling()
        or bot:IsCastingAbility() or bot:IsUsingAbility() or J.HasQueuedAction(bot) or bot:IsNightmared()
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local desire,point=X.ConsiderSunRay()
    if desire>0 then bot:Action_UseAbilityOnLocation(SunRay,point);return true end
    return false
end

return X
