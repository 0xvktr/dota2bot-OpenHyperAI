local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local H = require(GetScriptDirectory()..'/FunLib/hoodwink_abilities')
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: pos 4/5; forced other roles use pos 4.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/hoodwink')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Acorn Shot, [2] Bushwhack, [3] Scurry, [6] Sharpshooter.
local nAbilityBuildList = {2,1,2,3,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +50 Bushwhack damage
    t15={0,10}, -- +1 Scurry charge
    t20={0,10}, -- Sharpshooter charging vision
    t25={0,10}, -- +400 Sharpshooter damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_5' then
    X.sBuyList = {'item_double_branches','item_ward_sentry','item_tango','item_blight_stone','item_blood_grenade'}
else
    -- Forced core roles use pos 4; only supports buy its observed wards.
    X.sBuyList = {'item_double_branches','item_circlet','item_tango','item_faerie_fire','item_blood_grenade'}
    if sRole == 'pos_4' then
        table.insert(X.sBuyList,'item_ward_observer')
        table.insert(X.sBuyList,'item_ward_sentry')
    end
end
local core = {'item_magic_wand','item_urn_of_shadows','item_essence_distiller','item_arcane_boots','item_aghanims_shard','item_blink'}
for _, item in ipairs(core) do table.insert(X.sBuyList,item) end
-- Bot policy: compact utility continuation from the observed options.
if sRole == 'pos_5' then
    local utility = {'item_glimmer_cape','item_force_staff','item_sheepstick','item_ultimate_scepter','item_ultimate_scepter_2'}
    for _, item in ipairs(utility) do table.insert(X.sBuyList,item) end
    X.sSellList = {'item_essence_distiller','item_blight_stone','item_sheepstick','item_magic_wand'}
else
    local utility = {'item_cyclone','item_glimmer_cape','item_sheepstick','item_wind_waker','item_ultimate_scepter','item_ultimate_scepter_2'}
    for _, item in ipairs(utility) do table.insert(X.sBuyList,item) end
    X.sSellList = {'item_sheepstick','item_magic_wand'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Acorn Shot point at 10, then the first talent at 11. Preserve custom progressions.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local AcornShot         = bot:GetAbilityByName('hoodwink_acorn_shot')
local Bushwhack         = bot:GetAbilityByName('hoodwink_bushwhack')
local Scurry            = bot:GetAbilityByName('hoodwink_scurry')
local HuntersBoomerang  = bot:GetAbilityByName('hoodwink_hunters_boomerang')
local Decoy             = bot:GetAbilityByName('hoodwink_decoy')
local Sharpshooter      = bot:GetAbilityByName('hoodwink_sharpshooter')

local startedShot
function X.UseSharpshooterRelease()
    return H.Release(bot, Sharpshooter, bot:GetAbilityByName('hoodwink_sharpshooter_release'), startedShot)
end
function X.SkillsComplement()
    if X.UseSharpshooterRelease() then return end
    if J.CanNotUseAbility(bot) or bot:HasModifier('modifier_hoodwink_sharpshooter_windup') then return end
    local desire = X.ConsiderDecoy()
    if desire > 0 then bot:Action_UseAbility(Decoy); return end
    desire = X.ConsiderScurry()
    if desire > 0 then bot:Action_UseAbility(Scurry); return end
    local target
    desire, target = X.ConsiderBushwhack()
    if desire > 0 then bot:Action_UseAbilityOnLocation(Bushwhack, target); return end
    desire, target = X.ConsiderHuntersBoomerang()
    if desire > 0 then bot:Action_UseAbilityOnLocation(HuntersBoomerang, target); return end
    local point
    desire, target, point = X.ConsiderAcornShot()
    if desire > 0 then
        if AcornShot:GetAutoCastState() then AcornShot:ToggleAutoCast() end
        if point then bot:Action_UseAbilityOnLocation(AcornShot, target) else bot:Action_UseAbilityOnEntity(AcornShot, target) end
        return
    end
    desire, target = X.ConsiderSharpshooter()
    if desire > 0 then bot:Action_UseAbilityOnLocation(Sharpshooter, target); startedShot = DotaTime(); return end
end
function X.ConsiderAcornShot() return H.Acorn(bot, AcornShot) end
function X.ConsiderBushwhack() return H.Bush(bot, Bushwhack) end
function X.ConsiderScurry() return H.Scurry(bot, Scurry) end
function X.ConsiderHuntersBoomerang() return H.Boomerang(bot, HuntersBoomerang) end
function X.ConsiderDecoy() return H.Decoy(bot, Decoy) end
function X.ConsiderSharpshooter() return H.Sharpshooter(bot, Sharpshooter) end
return X
