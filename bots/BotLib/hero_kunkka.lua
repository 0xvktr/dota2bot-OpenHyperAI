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

-- Updated to 7.41f from D2PT: offlane and mid; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/kunkka')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Torrent, [2] Tidebringer, [3] X Marks the Spot, [6] Ghostship.
local nAbilityBuildList = {2,1,2,3,2,6,2,3,3,3,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Tidebringer applies 60% slow for 1s
    t15={0,10}, -- +25% Torrent damage/knockup duration
    t20={0,10}, -- -4s Torrent cooldown
    t25={0,10}, -- +100 spell area of effect
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade', 'item_gauntlets', 'item_double_branches', 'item_circlet', 'item_tango',
    'item_bracer', 'item_magic_wand', 'item_phase_boots', 'item_blade_mail',
    'item_ultimate_scepter', 'item_aghanims_shard', 'item_black_king_bar', 'item_shivas_guard',
    -- Bot policy: consume Scepter and add cooldown/ultimate utility within six slots.
    'item_ultimate_scepter_2', 'item_octarine_core', 'item_refresher',
}
X.sSellList = {
    'item_blade_mail','item_quelling_blade',
    'item_ultimate_scepter','item_bracer',
    'item_black_king_bar','item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- X Marks at 10, first talent at 11; preserve custom overrides.
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

--[[

npc_dota_hero_kunkka

"Ability1"		"kunkka_torrent"
"Ability2"		"kunkka_tidebringer"
"Ability3"		"kunkka_x_marks_the_spot"
"Ability4"		"kunkka_admirals_rum"
"Ability5"		"kunkka_tidal_wave"
"Ability6"		"kunkka_ghostship"
"Ability7"		"kunkka_return"
"Ability10"		"special_bonus_attack_damage_40"
"Ability11"		"special_bonus_armor_6"
"Ability12"		"special_bonus_hp_regen_12"
"Ability13"		"special_bonus_unique_kunkka_2"
"Ability14"		"special_bonus_unique_kunkka"
"Ability15"		"special_bonus_strength_25"
"Ability16"		"special_bonus_unique_kunkka_3"
"Ability17"		"special_bonus_unique_kunkka_4"

modifier_kunkka_torrent_thinker
modifier_kunkka_torrent
modifier_kunkka_torrent_slow
modifier_kunkka_tidebringer
modifier_kunkka_x_marks_the_spot
modifier_kunkka_x_marks_the_spot_marker
modifier_kunkka_x_marks_the_spot_thinker
modifier_kunkka_ghost_ship_fleet
modifier_kunkka_ghost_ship_knockback
modifier_kunkka_ghost_ship_loaded
modifier_kunkka_ghost_ship_damage_absorb
modifier_kunkka_ghost_ship_damage_delay

--]]

local K = require(GetScriptDirectory()..'/FunLib/kunkka_abilities')
local abilityQ=bot:GetAbilityByName('kunkka_torrent')
local abilityW=bot:GetAbilityByName('kunkka_tidebringer')
local abilityE=bot:GetAbilityByName('kunkka_x_marks_the_spot')
local abilityE2=bot:GetAbilityByName('kunkka_return')
local abilityR=bot:GetAbilityByName('kunkka_ghostship')
local tidalWave=bot:GetAbilityByName('kunkka_tidal_wave')
local mark={}
local function castPoint(ability,point,combo)
    if combo then bot:Action_UseAbilityOnLocation(ability,point)
    else J.SetQueuePtToINT(bot,true,ability);bot:ActionQueue_UseAbilityOnLocation(ability,point) end
    K.RecordSpell(mark,ability)
end
function X.SkillsComplement()
    if not bot:IsAlive() then mark.target=nil;return end
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    if abilityW and abilityW:IsTrained() and not abilityW:GetAutoCastState() then abilityW:ToggleAutoCast() end
    local observed=K.Observe(bot,mark)
    if K.Return(bot,abilityE2,mark)>0 then bot:Action_UseAbility(abilityE2);mark.target=nil;return end
    if observed then
        -- Each step is reconsidered after the preceding cast actually completes.
        if not mark.shipAt and not mark.torrentAt and J.CanCastAbility(abilityR)
            and bot:GetMana()>=abilityR:GetManaCost()+(J.CanCastAbility(abilityQ) and abilityQ:GetManaCost() or 0) then
            local desire,point=K.Ship(bot,abilityR,mark)
            if desire>0 then castPoint(abilityR,point,true);return end
        end
        if not mark.torrentAt then
            local desire,point=K.Torrent(bot,abilityQ,mark)
            if desire>0 then castPoint(abilityQ,point,true);return end
        end
    elseif not mark.target then
        local desire,target=K.X(bot,abilityE)
        if desire>0 then
            J.SetQueuePtToINT(bot,false,abilityE);bot:ActionQueue_UseAbilityOnEntity(abilityE,target)
            K.RecordX(mark,abilityE,target);return
        end
        local desire,point=K.Ship(bot,abilityR)
        if desire>0 then castPoint(abilityR,point,false);return end
        desire,point=K.Torrent(bot,abilityQ)
        if desire>0 then castPoint(abilityQ,point,false);return end
        desire,point=K.Wave(bot,tidalWave)
        if desire>0 then castPoint(tidalWave,point,false);return end
    end
    local desire,target=K.Tide(bot,abilityW)
    if desire>0 then bot:Action_UseAbilityOnEntity(abilityW,target) end
end
function X.ConsiderQ() return K.Torrent(bot,abilityQ,mark) end
function X.ConsiderE() return K.X(bot,abilityE) end
function X.ConsiderR() return K.Ship(bot,abilityR,mark) end
function X.ConsiderW() return K.Tide(bot,abilityW) end
function X.ConsiderAS() return K.Wave(bot,tidalWave) end
return X
