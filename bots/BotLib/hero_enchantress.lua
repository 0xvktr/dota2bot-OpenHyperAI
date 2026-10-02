local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local EnchantressAbilities = require(GetScriptDirectory()..'/FunLib/enchantress_abilities')
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: offlane and both supports; forced carry/mid use pos 5.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/enchantress')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Impetus, [2] Enchant, [3] Nature's Attendants, [6] Untouchable.
local nAbilityBuildList = sRole == 'pos_3'
    and {1,3,1,3,1,6,1,2,2,2,6,3,3,2,6}
    or {3,2,2,3,2,6,2,3,3,1,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +5 Enchanted creep armor
    t15={0,10}, -- +30 Enchanted creep attack speed
    t20={10,0}, -- +150 health and +25 damage to Enchanted creeps
    t25={0,10}, -- +6.5% Impetus damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_3' then
    X.sBuyList = {
        'item_tango', 'item_double_branches', 'item_circlet', 'item_circlet', 'item_faerie_fire',
        'item_null_talisman', 'item_magic_wand', 'item_power_treads', 'item_ultimate_scepter',
        -- Prefer the robust Pike progression over the less-played Orchid branch.
        'item_dragon_lance', 'item_blink', 'item_force_staff', 'item_aghanims_shard',
        'item_hurricane_pike', 'item_black_king_bar',
        -- Bot policy: consume Scepter, upgrade Blink, then add late disable/damage.
        'item_ultimate_scepter_2', 'item_swift_blink', 'item_sheepstick', 'item_moon_shard',
    }
    X.sSellList = {'item_hurricane_pike','item_null_talisman','item_black_king_bar','item_magic_wand'}
elseif sRole == 'pos_4' then
    X.sBuyList = {
        'item_tango', 'item_branches', 'item_circlet', 'item_magic_stick',
        'item_ward_observer', 'item_ward_sentry', 'item_blood_grenade',
        'item_magic_wand', 'item_power_treads', 'item_ultimate_scepter',
        'item_dragon_lance', 'item_force_staff', 'item_aghanims_shard', 'item_orchid', 'item_hurricane_pike',
        -- Bot policy: upgrade Orchid, protect attacks, and add late disable within six slots.
        'item_bloodthorn', 'item_black_king_bar', 'item_ultimate_scepter_2', 'item_sheepstick', 'item_moon_shard',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand'}
else
    X.sBuyList = {
        'item_tango', 'item_double_branches', 'item_circlet',
        'item_faerie_fire', 'item_blood_grenade',
        'item_magic_wand', 'item_power_treads', 'item_ultimate_scepter',
        'item_force_staff', 'item_dragon_lance', 'item_aghanims_shard', 'item_hurricane_pike', 'item_witch_blade',
        -- Bot policy: natural upgrade, attack protection, and late disable within six slots.
        'item_revenants_brooch', 'item_black_king_bar', 'item_ultimate_scepter_2', 'item_sheepstick', 'item_moon_shard',
    }
    if sRole == 'pos_5' then table.insert(X.sBuyList, 4, 'item_ward_sentry') end
    X.sSellList = {'item_black_king_bar','item_magic_wand'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT takes a basic at level 10, then the first talent; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Impetus           = bot:GetAbilityByName('enchantress_impetus')
local Enchant           = bot:GetAbilityByName('enchantress_enchant')
local NaturesAttendant  = bot:GetAbilityByName('enchantress_natures_attendants')
local Sproink           = bot:GetAbilityByName('enchantress_bunny_hop')
local LittleFriends     = bot:GetAbilityByName('enchantress_little_friends')
-- local Untouchable       = bot:GetAbilityByName('enchantress_untouchable')

local ImpetusDesire
local EnchantDesire, EnchantTarget
local NaturesAttendantDesire
local SproinkDesire
local LittleFriendsDesire, LittleFriendsTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    -- Healing and a safe displacement take priority over enabling attack autocast.
    NaturesAttendantDesire = X.ConsiderNaturesAttendant()
    if NaturesAttendantDesire > 0 then
        bot:Action_UseAbility(NaturesAttendant); return
    end
    SproinkDesire = X.ConsiderSproink()
    if SproinkDesire > 0 then bot:Action_UseAbility(Sproink); return end

    LittleFriendsDesire, LittleFriendsTarget = X.ConsiderLittleFriends()
    if LittleFriendsDesire > 0
    then
        bot:Action_UseAbilityOnEntity(LittleFriends, LittleFriendsTarget)
        return
    end

    ImpetusDesire = X.ConsiderImpetus()
    if ImpetusDesire > 0
    then
        return
    end

    EnchantDesire, EnchantTarget = X.ConsiderEnchant()
    if EnchantDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Enchant, EnchantTarget)
        return
    end
end

function X.ConsiderImpetus() return EnchantressAbilities.Impetus(bot, Impetus) end
function X.ConsiderEnchant() return EnchantressAbilities.Enchant(bot, Enchant) end
function X.ConsiderNaturesAttendant() return EnchantressAbilities.Heal(bot, NaturesAttendant) end
function X.ConsiderSproink() return EnchantressAbilities.Sproink(bot, Sproink) end
function X.ConsiderLittleFriends() return EnchantressAbilities.LittleFriends(bot, LittleFriends) end

return X
