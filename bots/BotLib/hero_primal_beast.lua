local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: mid/offlane; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/primal_beast')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local mid = sRole == 'pos_2'
-- [1] Onslaught, [2] Trample, [3] Uproar, [6] Pulverize.
local nAbilityBuildList = {2,1,2,1,2,6,2,1,1,3,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +25 Damage
    t15={0,10}, -- Trample cooldown
    t20={0,10}, -- Trample attack multiplier
    t25={10,0}, -- Pulverize duration
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local offlaneItems = {
    'item_double_gauntlets','item_double_branches','item_magic_stick',
    'item_phase_boots','item_magic_wand','item_soul_ring','item_blink','item_black_king_bar',
    'item_aghanims_shard','item_ultimate_scepter','item_shivas_guard','item_heart',
    -- Bot policy: consumed Scepter, cooldown reduction and a natural Blink upgrade.
    'item_ultimate_scepter_2','item_octarine_core','item_overwhelming_blink',
}
local midItems = {
    -- Observed ward omitted: core bots do not place wards.
    'item_four_branches','item_branches','item_tango',
    'item_bottle','item_phase_boots','item_magic_wand','item_blink','item_black_king_bar',
    'item_aghanims_shard','item_ultimate_scepter','item_shivas_guard','item_bloodstone',
    -- Bot policy: consumed Scepter, cooldown reduction and late initiation.
    'item_ultimate_scepter_2','item_octarine_core','item_overwhelming_blink',
}
X.sBuyList = mid and midItems or offlaneItems
X.sSellList = {
    'item_ultimate_scepter',mid and 'item_bottle' or 'item_soul_ring',
    'item_shivas_guard','item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_mid'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Onslaught         = bot:GetAbilityByName('primal_beast_onslaught') -- Q 突
local Trample           = bot:GetAbilityByName('primal_beast_trample') -- W 踏
local Uproar            = bot:GetAbilityByName('primal_beast_uproar') -- E 咤
local RockThrow         = bot:GetAbilityByName('primal_beast_rock_throw') -- D 砸
local Pulverize         = bot:GetAbilityByName('primal_beast_pulverize') -- R 捶
local BeginOnslaught    = bot:GetAbilityByName('primal_beast_onslaught_release')


function X.SkillsComplement()
    Onslaught=bot:GetAbilityByName('primal_beast_onslaught');BeginOnslaught=bot:GetAbilityByName('primal_beast_onslaught_release')
    Trample=bot:GetAbilityByName('primal_beast_trample');Uproar=bot:GetAbilityByName('primal_beast_uproar')
    Pulverize=bot:GetAbilityByName('primal_beast_pulverize');RockThrow=bot:GetAbilityByName('primal_beast_rock_throw')
    if not bot:HasModifier('modifier_primal_beast_trample') then bot.trample_status={'',0,nil} end
    if X.ConsiderPrimalContinuation() then return end
    if J.CanNotUseAbility(bot) or bot:HasModifier('modifier_prevent_taunts') or bot:HasModifier('modifier_primal_beast_onslaught_movement_adjustable') or bot:HasModifier('modifier_primal_beast_onslaught_windup') then return end
    local desire,target=X.ConsiderPulverize()
    if desire>0 then
        if J.CanBlackKingBar(bot) and bot.BlackKingBar~=nil then bot:Action_ClearActions(false);bot:ActionQueue_UseAbility(bot.BlackKingBar);bot:ActionQueue_UseAbilityOnEntity(Pulverize,target)
        else bot:Action_UseAbilityOnEntity(Pulverize,target) end
        return
    end
    if X.ConsiderUproar()>0 then bot:Action_UseAbility(Uproar);return end
    if X.ConsiderTrample()>0 then bot:Action_UseAbility(Trample);return end
    local desire,point=X.ConsiderRockThrow()
    if desire>0 then bot:Action_UseAbilityOnLocation(RockThrow,point);return end
    local desire,point=X.ConsiderOnslaught()
    if desire>0 then bot.onslaught_location=point;bot.primalChargeStart=nil;bot:Action_UseAbilityOnLocation(Onslaught,point) end
end
local function ActualRange(ability)
    local range=ability:GetCastRange()
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(target,pierce)
    return J.IsValid(target) and (pierce and J.CanCastOnMagicImmune(target) or not pierce and J.CanCastOnNonMagicImmune(target))
        and not J.CannotBeKilled(bot,target) and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function MobilityBlocked()
    return bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_slark_pounce_leash')
        or bot:HasModifier('modifier_puck_coiled') or bot:HasModifier('modifier_grimstroke_soul_chain')
end
local function SafePoint(point)
    return not J.IsLocHaveTower(700,true,point) and not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point)
end
function X.ConsiderOnslaught()
    if not J.CanCastAbility(Onslaught) or MobilityBlocked() or bot:HasModifier('modifier_primal_beast_onslaught_windup')
        or bot:HasModifier('modifier_primal_beast_onslaught_movement_adjustable') then return 0 end
    local range=Onslaught:GetSpecialValueInt('max_distance')
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        local delta=J.GetEscapeLoc()-bot:GetLocation()
        if delta:Length2D()>0 then
            local point=bot:GetLocation()+delta:Normalized()*math.min(range,delta:Length2D())
            if SafePoint(point) then bot.onslaught_status={'retreat',point};return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and Enemy(target,false) and GetUnitToUnitDistance(bot,target)<=range
        and GetUnitToUnitDistance(bot,target)>300 and SafePoint(target:GetLocation())
        and #J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)<=#J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)+1 then
        bot.onslaught_status={'engage',target};return BOT_ACTION_DESIRE_HIGH,J.GetCorrectLoc(target,0.5)
    end
    if J.IsLaning(bot) and J.IsAllowedToSpam(bot,Onslaught:GetManaCost()) then
        for _,creep in ipairs(bot:GetNearbyLaneCreeps(500,true)) do
            if Enemy(creep,false) and J.WillKillTarget(creep,Onslaught:GetSpecialValueInt('knockback_damage'),DAMAGE_TYPE_PHYSICAL,0.4)
                and not J.IsLocHaveTower(700,true,creep:GetLocation()) then bot.onslaught_status={'farm',creep:GetLocation()};return BOT_ACTION_DESIRE_HIGH,creep:GetLocation() end
        end
    end
    return 0
end
function X.ConsiderBeginOnslaughtDesire()
    if not J.CanCastAbility(BeginOnslaught) or not bot:HasModifier('modifier_primal_beast_onslaught_windup') then bot.primalChargeStart=nil;return 0 end
    if bot.primalChargeStart==nil then bot.primalChargeStart=DotaTime() end
    local goal=bot.onslaught_location
    local maxTime=Onslaught~=nil and Onslaught:GetSpecialValueFloat('max_charge_time') or 1.7
    local range=Onslaught~=nil and Onslaught:GetSpecialValueInt('max_distance') or 2000
    local needed=goal~=nil and math.max(0.3,math.min(maxTime,GetUnitToLocationDistance(bot,goal)/range*maxTime)) or maxTime
    if DotaTime()-bot.primalChargeStart>=needed and (goal==nil or bot:IsFacingLocation(goal,15)) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderTrample()
    if not J.CanCastAbility(Trample) or MobilityBlocked() or bot:HasModifier('modifier_primal_beast_trample')
        or bot:GetCurrentMovementSpeed()<100 then return 0 end
    local radius=Trample:GetSpecialValueInt('effect_radius')
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and Enemy(target,false)
        and GetUnitToUnitDistance(bot,target)<=radius+150 and SafePoint(target:GetLocation()) then bot.trample_status={'engaging',target:GetLocation(),target};return BOT_ACTION_DESIRE_HIGH end
    if bot:HasModifier('modifier_primal_beast_onslaught_movement_adjustable') then
        for _,enemy in ipairs(J.GetNearbyHeroes(bot,700,true,BOT_MODE_NONE)) do if Enemy(enemy,false) then bot.trample_status={'engaging',enemy:GetLocation(),enemy};return BOT_ACTION_DESIRE_HIGH end end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
            if Enemy(enemy,false) then bot.trample_status={'retreating',J.GetEscapeLoc(),nil};return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,Trample:GetManaCost()) then
        local count=0
        for _,creep in ipairs(bot:GetNearbyCreeps(radius+200,true)) do if Enemy(creep,false) then count=count+1 end end
        if count>=3 then bot.trample_status={'farming',0,nil};return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function X.ConsiderUproar()
    if not J.CanCastAbility(Uproar) then return 0 end
    local stacks=J.GetModifierCount(bot,'modifier_primal_beast_uproar')
    if stacks<1 then return 0 end
    if bot:HasModifier('modifier_primal_beast_pulverize_self') or bot:HasModifier('modifier_primal_beast_trample') then return BOT_ACTION_DESIRE_HIGH end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and GetUnitToUnitDistance(bot,target)<=Uproar:GetSpecialValueInt('radius')
        and (stacks>=3 or J.GetHP(bot)<0.5) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,math.min(Uproar:GetSpecialValueInt('radius'),1600),true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderPulverize()
    if not J.CanCastAbility(Pulverize) or bot:HasModifier('modifier_primal_beast_onslaught_movement_adjustable') then return 0 end
    local range=ActualRange(Pulverize)
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy,true) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
            if enemy:IsChanneling() or J.WillKillTarget(enemy,Pulverize:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,Pulverize:GetCastPoint()+Pulverize:GetSpecialValueFloat('interval')) then return BOT_ACTION_DESIRE_HIGH,enemy end
            if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and not J.IsDisabled(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end
        end
    end
    return 0
end
local function RockPoint(target)
    local range=ActualRange(RockThrow)
    local distance=GetUnitToUnitDistance(bot,target)
    local delay=RockThrow:GetCastPoint()+RockThrow:GetSpecialValueFloat('min_travel_time')+(RockThrow:GetSpecialValueFloat('max_travel_time')-RockThrow:GetSpecialValueFloat('min_travel_time'))*math.max(0,math.min(1,(distance-RockThrow:GetSpecialValueInt('min_range'))/(RockThrow:GetCastRange()-RockThrow:GetSpecialValueInt('min_range'))))
    local predicted=J.GetCorrectLoc(target,delay)
    local delta=predicted-bot:GetLocation()
    if delta:Length2D()==0 then return nil end
    local point=bot:GetLocation()+delta:Normalized()*math.max(RockThrow:GetSpecialValueInt('min_range'),math.min(range,delta:Length2D()))
    if (point-predicted):Length2D()<=RockThrow:GetSpecialValueInt('impact_radius') then return point,delay end
    return nil
end
function X.ConsiderRockThrow()
    if not J.CanCastAbility(RockThrow) or RockThrow:IsHidden() then return 0 end
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if Enemy(enemy,false) then
            local point,delay=RockPoint(enemy)
            if point~=nil and (enemy:IsChanneling() or J.WillKillTarget(enemy,RockThrow:GetSpecialValueInt('base_damage'),DAMAGE_TYPE_PHYSICAL,delay)
                or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)) or J.IsInTeamFight(bot,1200)) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,RockThrow:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(1600,true)
        for _,creep in ipairs(creeps) do
            local point,delay=RockPoint(creep)
            if point~=nil then
                local count=0
                for _,other in ipairs(creeps) do if Enemy(other,false) and (J.GetCorrectLoc(other,delay)-point):Length2D()<=RockThrow:GetSpecialValueInt('impact_radius') then count=count+1 end end
                if count>=3 then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    return 0
end
function X.ConsiderPrimalContinuation()
    local windup=bot:HasModifier('modifier_primal_beast_onslaught_windup')
    local moving=bot:HasModifier('modifier_primal_beast_onslaught_movement_adjustable')
    local pulverize=bot:IsChanneling() and bot:HasModifier('modifier_primal_beast_pulverize_self')
    if not windup and not moving and not pulverize then return false end
    local active=bot:GetCurrentActiveAbility()
    if bot:IsChanneling() and (active==nil or active:GetName()~='primal_beast_pulverize') then return false end
    if bot:IsUsingAbility() and (not windup or active==nil or active:GetName()~='primal_beast_onslaught') and not pulverize then return false end
    if not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsSilenced() or bot:IsInvulnerable()
        or bot:IsCastingAbility() or J.HasQueuedAction(bot) or bot:IsNightmared() or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    if windup and X.ConsiderBeginOnslaughtDesire()>0 then bot:Action_UseAbility(BeginOnslaught);bot.primalChargeStart=nil;return true end
    if moving and X.ConsiderTrample()>0 then bot:Action_UseAbility(Trample);return true end
    if (moving or pulverize) and X.ConsiderUproar()>0 then bot:Action_UseAbility(Uproar);return true end
    return false
end

return X
