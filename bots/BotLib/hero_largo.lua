local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/largo')
X.UseRhapsodyOff = SpellDecisions.UseRhapsodyOff
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: mid/offlane/both supports; forced carry uses offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/largo')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Catchy Lick, [2] Frogstomp, [3] Croak of Genius, [6] Amphibian Rhapsody.
local nAbilityBuildList = sRole == 'pos_2'
    and {1,2,1,2,1,2,1,2,6,3,6,3,3,3,6}
    or {1,2,1,2,1,6,1,2,2,3,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +15 Frogstomp damage per stomp
    t15={0,10}, -- Croak of Genius adds 1% max-health damage per second
    t20={0,10}, -- 2 Catchy Lick charges
    t25={0,10}, -- +30% song buffs
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_2' then
    X.sBuyList = {
        'item_double_branches', 'item_double_branches', 'item_tango', 'item_faerie_fire',
        'item_bottle', 'item_magic_wand', 'item_soul_ring', 'item_phase_boots',
        'item_kaya', 'item_kaya_and_sange', 'item_ultimate_scepter', 'item_aghanims_shard',
        -- Bot policy: late protection/armour, consumed Scepter and cooldown utility.
        'item_black_king_bar', 'item_shivas_guard', 'item_ultimate_scepter_2', 'item_octarine_core',
    }
    X.sSellList = {
        'item_ultimate_scepter','item_magic_wand',
        'item_black_king_bar','item_bottle',
        'item_shivas_guard','item_soul_ring',
    }
elseif sRole == 'pos_4' or sRole == 'pos_5' then
    if sRole == 'pos_4' then
        X.sBuyList = {'item_boots','item_ward_observer','item_ward_sentry','item_blood_grenade'}
    else
        X.sBuyList = {
            'item_double_branches','item_magic_stick','item_ward_sentry','item_ward_sentry',
            'item_tango','item_blood_grenade',
        }
    end
    for _, item in ipairs({
        'item_magic_wand', 'item_arcane_boots', 'item_holy_locket', 'item_glimmer_cape',
        'item_aghanims_shard', 'item_lotus_orb',
        -- Bot policy: natural team-heal upgrade, consumed Scepter and late disable.
        'item_mekansm', 'item_guardian_greaves', 'item_ultimate_scepter', 'item_ultimate_scepter_2', 'item_sheepstick',
    }) do table.insert(X.sBuyList, item) end
    X.sSellList = {}
else
    X.sBuyList = {
        'item_double_gauntlets', 'item_double_branches', 'item_magic_stick',
        'item_magic_wand', 'item_soul_ring', 'item_phase_boots', 'item_kaya', 'item_kaya_and_sange',
        'item_aghanims_shard', 'item_ultimate_scepter',
        -- Bot policy: late protection/armour, consumed Scepter and cooldown utility.
        'item_black_king_bar', 'item_shivas_guard', 'item_ultimate_scepter_2', 'item_octarine_core',
    }
    X.sSellList = {'item_ultimate_scepter','item_magic_wand','item_shivas_guard','item_soul_ring'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Croak at 10, first talent at 11; preserve custom overrides.
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



local CatchyLick        = bot:GetAbilityByName('largo_catchy_lick')
local Frogstomp         = bot:GetAbilityByName('largo_frogstomp')
local CroakOfGenius     = bot:GetAbilityByName('largo_croak_of_genius')
local AmphibianRhapsody = bot:GetAbilityByName('largo_amphibian_rhapsody')
local BullbellyBlitz    = bot:GetAbilityByName('largo_song_fight_song')
local HotfeetHustle     = bot:GetAbilityByName('largo_song_double_time')
local IslandElixir      = bot:GetAbilityByName('largo_song_good_vibrations')

local CatchyLickDesire, CatchyLickTarget
local FrogstompDesire, FrogstompLocation
local CroakOfGeniusDesire, CroakOfGeniusTarget
local AmphibianRhapsodyDesire

local bAttacking = false
local botTarget, botHP
local nAllyHeroes, nEnemyHeroes

function X.SkillsComplement()
    if X.UseRhapsodyOff() then return end
    if J.CanNotUseAbility(bot) then return end
    if bot:HasModifier('modifier_largo_amphibian_rhapsody_self') then
        SpellDecisions.PlaySongs(AmphibianRhapsody)
        return
    end
    bAttacking = J.IsAttacking(bot)
    botHP = J.GetHP(bot)
    botTarget = J.GetProperTarget(bot)
    nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local save=SpellDecisions.LickTarget(CatchyLick,true)
    if save~=nil then
        J.SetQueuePtToINT(bot,false,CatchyLick)
        bot:ActionQueue_UseAbilityOnEntity(CatchyLick,save)
        return
    end
    local interrupt=SpellDecisions.StompPoint(Frogstomp,true)
    if interrupt~=nil then
        J.SetQueuePtToINT(bot,false,Frogstomp)
        bot:ActionQueue_UseAbilityOnLocation(Frogstomp,interrupt)
        return
    end
    if SpellDecisions.ConsiderStolenSpell(CroakOfGenius) then return end
    if SpellDecisions.ConsiderStolenSpell(CatchyLick) then return end
    FrogstompDesire,FrogstompLocation=X.ConsiderFrogstomp()
    if FrogstompDesire>0 then
        local delta=FrogstompLocation-bot:GetLocation()
        local range=SpellDecisions.Range(Frogstomp)
        if delta:Length2D()>range then FrogstompLocation=bot:GetLocation()+delta:Normalized()*range end
        J.SetQueuePtToINT(bot,false,Frogstomp)
        bot:ActionQueue_UseAbilityOnLocation(Frogstomp,FrogstompLocation)
        return
    end
    if SpellDecisions.ShouldBegin(AmphibianRhapsody) then bot:Action_UseAbility(AmphibianRhapsody) end
end

function X.ConsiderCatchLick()
    local target=SpellDecisions.LickTarget(CatchyLick,false)
    return target~=nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE,target
end

function X.ConsiderFrogstomp()
    if not J.CanCastAbility(Frogstomp) then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = SpellDecisions.Range(Frogstomp)
    local nRadius = Frogstomp:GetSpecialValueInt('radius')
    local nManaCost = Frogstomp:GetManaCost()
	local fManaAfter = J.GetManaAfter(nManaCost)
	local fManaThreshold1 = J.GetManaThreshold(bot, nManaCost, {CatchyLick, CroakOfGenius})

    local point=SpellDecisions.StompPoint(Frogstomp,false)
    if point~=nil then return BOT_ACTION_DESIRE_HIGH,point end

    local nEnemyCreeps = bot:GetNearbyCreeps(Min(nCastRange + 300, 1600), true)

    if J.IsPushing(bot) and #nAllyHeroes <= 2 and bAttacking and fManaAfter > fManaThreshold1 and #nEnemyHeroes == 0 then
        for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 4) then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
    end

    if J.IsDefending(bot) and bAttacking and fManaAfter > fManaThreshold1 then
        for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 4)
                or (nLocationAoE.count >= 3 and string.find(creep:GetUnitName(), 'upgraded'))
                then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
    end

    if J.IsFarming(bot) and bAttacking and fManaAfter > fManaThreshold1 then
        for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 3)
                or (nLocationAoE.count >= 2 and creep:IsAncientCreep())
                or (nLocationAoE.count >= 1 and creep:GetHealth() >= 550)
                then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
    end

    if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and bAttacking
        and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and bAttacking
        and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderCroakOfGenius()
    local target=SpellDecisions.CroakTarget(CroakOfGenius)
    return target~=nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE,target
end
function X.ConsiderAmphibianRhapsody()
    if bot:HasModifier('modifier_largo_amphibian_rhapsody_self') then
        SpellDecisions.PlaySongs(AmphibianRhapsody)
        return BOT_ACTION_DESIRE_NONE
    end
    return SpellDecisions.ShouldBegin(AmphibianRhapsody) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end
return X
