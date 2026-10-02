-- Credit goes to Furious Puppy for Bot Experiment

local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local K=require(GetScriptDirectory()..'/FunLib/keeper_of_the_light_abilities')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: mid and support; forced other roles use mid.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/keeper_of_the_light')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Illuminate, [2] Blinding Light, [3] Chakra Magic, [6] Spirit Form.
local nAbilityBuildList = {1,3,1,3,1,6,1,3,3,2,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- -2s Illuminate cooldown
    t15=sRole == 'pos_4' and {0,10} or {10,0}, -- +25% Spirit Form speed / +90 Blinding Light damage
    t20={0,10}, -- +15s Spirit Form duration
    t25={10,0}, -- +200 Illuminate damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_4' then
    X.sBuyList = {
        'item_boots', 'item_ward_observer', 'item_ward_sentry', 'item_blood_grenade',
        'item_tranquil_boots', 'item_magic_wand', 'item_holy_locket', 'item_force_staff',
        'item_glimmer_cape', 'item_aghanims_shard',
        -- Bot policy: teamfight Scepter, late disable/defence, and natural boot upgrade.
        'item_ultimate_scepter', 'item_ultimate_scepter_2', 'item_sheepstick',
        'item_ancient_janggo', 'item_boots_of_bearing', 'item_lotus_orb',
    }
    X.sSellList = {}
else
    X.sBuyList = {
        'item_ring_of_protection', 'item_double_branches', 'item_circlet', 'item_tango', 'item_faerie_fire',
        'item_urn_of_shadows', 'item_magic_wand', 'item_spirit_vessel', 'item_travel_boots',
        'item_octarine_core', 'item_aghanims_shard',
        -- Bot policy: protection and teamfight utility; Blessing frees a late slot.
        'item_black_king_bar', 'item_ultimate_scepter', 'item_ultimate_scepter_2',
        'item_sheepstick', 'item_travel_boots_2',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Blinding Light at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end
end

-- Ability handles (re-fetched each tick in SkillsComplement for safety)
local Illuminate    = bot:GetAbilityByName('keeper_of_the_light_illuminate')
local IlluminateEnd = bot:GetAbilityByName('keeper_of_the_light_illuminate_end')
local BlindingLight = bot:GetAbilityByName('keeper_of_the_light_blinding_light')
local ChakraMagic   = bot:GetAbilityByName('keeper_of_the_light_chakra_magic')
local SolarBind     = bot:GetAbilityByName('keeper_of_the_light_radiant_bind')
local Recall        = bot:GetAbilityByName('keeper_of_the_light_recall')
local WillOWisp     = bot:GetAbilityByName('keeper_of_the_light_will_o_wisp')
local SpiritForm    = bot:GetAbilityByName('keeper_of_the_light_spirit_form')

local IlluminateDesire, IlluminateLocation
local IlluminateEndDesire
local BlindingLightDesire, BlindingLightLocation
local ChakraMagicDesire, ChakraMagicTarget
local SolarBindDesire, SolarBindTarget
local RecallDesire, RecallTarget
local WillOWispDesire, WillOWispLocation
local SpiritFormDesire

local illuminateState = {}
local IlluminateCastedTime = -100

local nAllyHeroes, nEnemyHeroes
local botTarget
local botHP

function X.UseIlluminateRelease()
    return K.Release(bot,bot:GetAbilityByName('keeper_of_the_light_illuminate_end'),illuminateState)
end
function X.SkillsComplement()
    if X.UseIlluminateRelease() then return end
    if J.CanNotUseAbility(bot) then return end

    -- Re-fetch ability handles each tick for safety
    Illuminate    = bot:GetAbilityByName('keeper_of_the_light_illuminate')
    IlluminateEnd = bot:GetAbilityByName('keeper_of_the_light_illuminate_end')
    BlindingLight = bot:GetAbilityByName('keeper_of_the_light_blinding_light')
    ChakraMagic   = bot:GetAbilityByName('keeper_of_the_light_chakra_magic')
    SolarBind     = bot:GetAbilityByName('keeper_of_the_light_radiant_bind')
    Recall        = bot:GetAbilityByName('keeper_of_the_light_recall')
    WillOWisp     = bot:GetAbilityByName('keeper_of_the_light_will_o_wisp')
    SpiritForm    = bot:GetAbilityByName('keeper_of_the_light_spirit_form')

    -- Cache per-tick variables
    nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    botTarget = J.GetProperTarget(bot)
    botHP = J.GetHP(bot)

    SpiritFormDesire = X.ConsiderSpiritForm()
    if SpiritFormDesire > 0
    then
        bot:Action_UseAbility(SpiritForm)
        return
    end

    SolarBindDesire, SolarBindTarget = X.ConsiderSolarBind()
    if SolarBindDesire > 0
    then
        bot:Action_UseAbilityOnEntity(SolarBind, SolarBindTarget)
        return
    end

    WillOWispDesire, WillOWispLocation = X.ConsiderWillOWisp()
    if WillOWispDesire > 0
    then
        bot:Action_UseAbilityOnLocation(WillOWisp, WillOWispLocation)
        return
    end

    BlindingLightDesire, BlindingLightLocation = X.ConsiderBlindingLight()
    if BlindingLightDesire > 0
    then
        bot:Action_UseAbilityOnLocation(BlindingLight, BlindingLightLocation)
        return
    end

    -- Check IlluminateEnd BEFORE Illuminate so we release a channel for a kill/optimal damage
    -- before considering whether to start a new one
    IlluminateEndDesire = X.ConsiderIlluminateEnd()
    if IlluminateEndDesire > 0
    then
        bot:Action_UseAbility(IlluminateEnd)
        return
    end

    IlluminateDesire, IlluminateLocation = X.ConsiderIlluminate()
    if IlluminateDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Illuminate, IlluminateLocation)
        IlluminateCastedTime = DotaTime()
        K.Record(bot,Illuminate,IlluminateLocation,illuminateState)
        illuminateState.target=bot.illuminate_status and bot.illuminate_status[2]
        return
    end

    ChakraMagicDesire, ChakraMagicTarget = X.ConsiderChakraMagic()
    if ChakraMagicDesire > 0
    then
        bot:Action_UseAbilityOnEntity(ChakraMagic, ChakraMagicTarget)
        return
    end

    RecallDesire, RecallTarget = X.ConsiderRecall()
    if RecallDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Recall, RecallTarget)
        return
    end
end

function X.ConsiderIlluminate()
    if not bot:HasModifier('modifier_keeper_of_the_light_spirit_form') and #J.GetNearbyHeroes(bot,500,true,BOT_MODE_NONE)>0 then return 0,nil end
    if illuminateState.started and DotaTime()-illuminateState.started<3 and bot:HasModifier('modifier_keeper_of_the_light_spirit_form') then return 0,nil end
    if not J.CanCastAbility(Illuminate) then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = K.Range(bot,Illuminate)
    local nTravelDist = Illuminate:GetSpecialValueInt('range')
    local nRadius = Illuminate:GetSpecialValueInt('radius')
    local nMaxDamage = Illuminate:GetSpecialValueInt('total_damage')
    local nManaAfter = J.GetManaAfter(Illuminate:GetManaCost())

    bot.illuminate_status=nil
    local desire,point=K.Illuminate(bot,Illuminate)
    if desire>0 then
        local target=J.GetProperTarget(bot)
        if J.IsValidHero(target) then bot.illuminate_status={'kill',target} end
        return desire,point
    end
    if J.IsFarming(bot) and nManaAfter > 0.25 then
        local nEnemyCreeps = bot:GetNearbyCreeps(800, true)
        if #nEnemyCreeps >= 3
        and J.IsValid(nEnemyCreeps[1])
        and J.CanBeAttacked(nEnemyCreeps[1])
        and not J.IsRunning(nEnemyCreeps[1])
        then
            local nLocationAoE = bot:FindAoELocation(true, false, nEnemyCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
            if nLocationAoE.count >= 3 or (nLocationAoE.count >= 2 and nEnemyCreeps[1]:IsAncientCreep())
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(800, true)
    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        if #nEnemyLaneCreeps >= 3
        and J.IsValid(nEnemyLaneCreeps[1])
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        and not J.IsRunning(nEnemyLaneCreeps[1])
        then
            local nLocationAoE = bot:FindAoELocation(true, false, nEnemyLaneCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
            if nLocationAoE.count >= 3 then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    if  J.IsLaning(bot)
    and (J.IsCore(bot) or not J.IsCore(bot) and not J.IsThereCoreNearby(1200))
    and nManaAfter > 0.28
	then
        local hCreepList = {}
        local nNearbyTower = bot:GetNearbyTowers(1600, true)
		for _, creep in pairs(nEnemyLaneCreeps) do
			if  J.IsValid(creep)
			and J.IsKeyWordUnit('ranged', creep)
            and J.CanBeAttacked(creep)
            and not J.IsRunning(creep)
			and J.CanKillTarget(creep, nMaxDamage, DAMAGE_TYPE_MAGICAL)
			then
				if J.IsValidHero(nEnemyHeroes[1])
                and not J.IsSuspiciousIllusion(nEnemyHeroes[1])
				and GetUnitToUnitDistance(creep, nEnemyHeroes[1]) <= 600
                and (#nNearbyTower == 0 or J.IsValidBuilding(nNearbyTower[1]) and GetUnitToUnitDistance(nNearbyTower[1], creep) > 700)
				then
                    bot.illuminate_status = {'laning', creep}
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
				end
			end

            if  J.IsValid(creep)
            and J.CanKillTarget(creep, nMaxDamage, DAMAGE_TYPE_MAGICAL)
            then
                table.insert(hCreepList, creep)
            end
		end

        if #hCreepList >= 2 then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(hCreepList)
        end
	end

    if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
		and J.IsInRange(botTarget, bot, nCastRange)
		and J.CanBeAttacked(botTarget)
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
        and J.IsInRange(botTarget, bot, nCastRange)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderIlluminateEnd() return 0 end
function X.ConsiderBlindingLight() return K.Blind(bot,BlindingLight) end
function X.ConsiderChakraMagic() return K.Chakra(bot,ChakraMagic) end
function X.ConsiderSolarBind() return K.Bind(bot,SolarBind) end
function X.ConsiderWillOWisp() return K.Wisp(bot,WillOWisp) end
function X.ConsiderSpiritForm() return K.Form(bot,SpiritForm) end
function X.ConsiderRecall()
    if not J.CanCastAbility(Recall) then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    -- Use actual teleport delay from ability data instead of hardcoded value
    local nTeleportDelay = Recall:GetSpecialValueInt('teleport_delay')
    if nTeleportDelay == nil or nTeleportDelay == 0 then nTeleportDelay = 3 end

    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if J.IsValidHero(allyHero) and not allyHero:IsIllusion() and not J.IsMeepoClone(allyHero) then
            local bEnemyNearby = J.IsEnemyHeroAroundLocation(allyHero:GetLocation(), 1600)
            local nAllyInRangeEnemy = J.GetEnemiesNearLoc(allyHero:GetLocation(), 1600)

            if not bEnemyNearby then
                -- Recall low-HP retreating allies to safety (check damage window = teleport delay)
                if  J.IsRetreating(allyHero)
                and J.GetHP(allyHero) < 0.25
                and #nAllyInRangeEnemy == 0
                and allyHero:DistanceFromFountain() > 4500
                and bot:DistanceFromFountain() < 1600
                and not allyHero:WasRecentlyDamagedByAnyHero(nTeleportDelay)
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end

                if J.IsPushing(bot)
                and GetUnitToUnitDistance(bot, allyHero) > 4000
                and not J.IsFarming(allyHero)
                and not J.IsLaning(allyHero)
                and not J.IsDoingRoshan(allyHero)
                and not J.IsDoingTormentor(allyHero)
                and not J.IsDefending(allyHero)
                then
                    local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1600)
                    if #nInRangeAlly >= 2 then
                        return BOT_ACTION_DESIRE_HIGH, allyHero
                    end
                end
            end
        end

    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X
