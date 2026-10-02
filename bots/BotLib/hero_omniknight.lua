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

-- Updated to 7.41f from D2PT: pos 5/3; forced picks use the support build without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/omniknight')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local isCore = sRole == 'pos_3'
-- [1] Purification, [2] Repel (Martyr), [3] Hammer of Purity, [6] Guardian Angel.
local nAbilityBuildList = isCore and {3,1,3,1,3,1,3,1,2,6,6,2,2,2,6}
    or {3,1,1,2,1,6,1,2,2,2,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild(isCore and {
    t10={10,0}, t15={0,10}, t20={10,0}, t25={10,0},
} or {
    t10={0,10}, t15={10,0}, t20={10,0}, t25={0,10},
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if isCore then
    X.sBuyList = {
        'item_double_gauntlets','item_double_branches','item_magic_stick',
        'item_magic_wand','item_soul_ring','item_phase_boots','item_echo_sabre',
        'item_harpoon','item_blink','item_aghanims_shard','item_black_king_bar',
        -- Bot policy: consumed Scepter, armor and late dispel within six slots.
        'item_ultimate_scepter','item_ultimate_scepter_2','item_assault',
        'item_overwhelming_blink','item_nullifier','item_moon_shard',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand','item_ultimate_scepter','item_soul_ring'}
else
    X.sBuyList = {'item_boots','item_blood_grenade'}
    if sRole == 'pos_4' or sRole == 'pos_5' then table.insert(X.sBuyList,'item_ward_sentry') end
    local progression = {
        'item_magic_wand','item_arcane_boots','item_mekansm','item_holy_locket',
        'item_guardian_greaves','item_aghanims_shard','item_ultimate_scepter',
        -- Bot policy: consume Scepter before late mobility, dispel and control.
        'item_ultimate_scepter_2','item_blink','item_lotus_orb','item_sheepstick',
        'item_overwhelming_blink','item_refresher','item_moon_shard',
    }
    for _,item in ipairs(progression) do table.insert(X.sBuyList,item) end
    X.sSellList = {}
end
if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_tank'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X.sBuyList,X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList,nAbilityBuildList,sTalentList,nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
X.bDeafaultAbility = false
X.bDeafaultItem = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end


local abilityQ=bot:GetAbilityByName(sAbilityList[1])
local abilityW=bot:GetAbilityByName(sAbilityList[2])
local abilityE=bot:GetAbilityByName(sAbilityList[3])
local abilityR=bot:GetAbilityByName(sAbilityList[6])
function X.SkillsComplement()
    if X.ConsiderSilencedHammer() then return end
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    local desire=X.ConsiderR()
    if desire>0 then J.SetQueuePtToINT(bot,true,abilityR);bot:ActionQueue_UseAbility(abilityR);return end
    for _,choice in ipairs({{abilityW,X.ConsiderW},{abilityQ,X.ConsiderQ},{abilityE,X.ConsiderE}}) do
        local d,target=choice[2]()
        if d>0 then J.SetQueuePtToINT(bot,true,choice[1]);bot:ActionQueue_UseAbilityOnEntity(choice[1],target);return end
    end
end

local function SpellRange(ability)
    local range=ability:GetCastRange()
    local lens=J.IsItemAvailable('item_aether_lens')
    if lens~=nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Ally(ally,ability)
    return J.IsValid(ally) and ally:GetTeam()==bot:GetTeam() and not ally:IsIllusion()
        and not ally:IsInvulnerable() and J.IsInRange(bot,ally,SpellRange(ability))
end
local function Allies(range)
    local allies=J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)
    allies[#allies+1]=bot
    return allies
end
function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    local range,radius=SpellRange(abilityQ),abilityQ:GetSpecialValueInt('radius')
    local heal=abilityQ:GetSpecialValueInt('heal')
    local candidates=Allies(range)
    for _,creep in ipairs(bot:GetNearbyCreeps(math.min(range,1600),false)) do candidates[#candidates+1]=creep end
    local best,score=nil,0
    for _,ally in ipairs(candidates) do
        if Ally(ally,abilityQ) then
            local healing=not ally:HasModifier('modifier_ice_blast') and not ally:HasModifier('modifier_fountain_aura')
                and math.min(heal,ally:GetMaxHealth()-ally:GetHealth()) or 0
            if ally:IsHero() and healing>0 and J.GetHP(ally)<0.3
                and (ally:WasRecentlyDamagedByAnyHero(2) or J.GetHP(ally)<0.15) then return BOT_ACTION_DESIRE_HIGH,ally end
            local hit=0
            for _,enemy in ipairs(J.GetNearbyHeroes(ally,radius,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy) and not J.IsSuspiciousIllusion(enemy)
                    and not J.CannotBeKilled(bot,enemy)
                    and (J.GetCorrectLoc(enemy,abilityQ:GetCastPoint())-J.GetCorrectLoc(ally,abilityQ:GetCastPoint())):Length2D()<=radius then
                    if J.WillKillTarget(enemy,heal,DAMAGE_TYPE_PURE,abilityQ:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,ally end
                    hit=hit+1
                end
            end
            local creepKills=0
            if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
                for _,creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range+radius,1600),true)) do
                    if J.IsValid(creep) and J.CanCastOnMagicImmune(creep) and J.IsInRange(ally,creep,radius)
                        and not creep:HasModifier('modifier_fountain_glyph')
                        and J.WillKillTarget(creep,heal,DAMAGE_TYPE_PURE,abilityQ:GetCastPoint())
                        and (not J.IsLaning(bot) or J.IsKeyWordUnit('ranged',creep) and not J.IsOtherAllysTarget(creep)) then creepKills=creepKills+1 end
                end
            end
            local useful=healing>=heal*0.65 and (hit>0 or J.IsRetreating(bot) or not J.IsLaning(bot))
                or hit>=2 and (J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot))
                or creepKills>=(J.IsLaning(bot) and 1 or 3) and J.IsAllowedToSpam(bot,abilityQ:GetManaCost())
            if useful then
                local value=healing+hit*heal+creepKills*50
                if value>score then best,score=ally,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    if J.IsFarming(bot) and J.IsAllowedToSpam(bot,abilityQ:GetManaCost()) then
        local count=0
        for _,creep in ipairs(bot:GetNearbyNeutralCreeps(radius)) do
            if J.IsValid(creep) and J.CanCastOnMagicImmune(creep) then count=count+1 end
        end
        if count>=3 then return BOT_ACTION_DESIRE_HIGH,bot end
    end
    return 0
end
function X.ConsiderW()
    if not J.CanCastAbility(abilityW) then return 0 end
    local best,score=nil,0
    for _,ally in ipairs(Allies(SpellRange(abilityW))) do
        if Ally(ally,abilityW) and ally:IsHero() and not ally:IsMagicImmune()
            and not ally:HasModifier('modifier_omniknight_martyr') then
            if J.IsUnitTargetProjectileIncoming(ally,400) or J.IsWillBeCastUnitTargetSpell(ally,1200)
                or (ally:IsRooted() or ally:IsSilenced()) and #J.GetNearbyHeroes(ally,900,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH,ally end
            local magic=0
            for _,enemy in ipairs(J.GetNearbyHeroes(ally,1000,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) then
                    local all=enemy:GetEstimatedDamageToTarget(true,ally,2,DAMAGE_TYPE_ALL)
                    local physical=enemy:GetEstimatedDamageToTarget(true,ally,2,DAMAGE_TYPE_PHYSICAL)
                    magic=magic+math.max(0,all-physical)
                end
            end
            local engage=J.IsGoingOnSomeone(ally) and J.IsValidHero(J.GetProperTarget(ally))
                and J.IsInRange(ally,J.GetProperTarget(ally),700)
            local useful=magic>ally:GetHealth()*0.2 and (ally:WasRecentlyDamagedByAnyHero(2) or engage)
            if useful then
                local value=magic+(J.IsCore(ally) and 200 or 0)
                if value>score then best,score=ally,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    return 0
end
local function HammerTarget(target)
    return J.IsValid(target) and J.CanBeAttacked(target) and J.CanCastOnMagicImmune(target)
        and not J.IsSuspiciousIllusion(target) and J.CanCastOnTargetAdvanced(target)
        and J.IsInRange(bot,target,bot:GetAttackRange()+abilityE:GetSpecialValueInt('attack_range_bonus'))
        and not J.CannotBeKilled(bot,target) and not target:HasModifier('modifier_item_blade_mail_reflect')
        and not target:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
function X.ConsiderE()
    if not J.CanCastAbility(abilityE) or bot:IsDisarmed() then return 0 end
    local damage=abilityE:GetSpecialValueInt('bonus_damage')+bot:GetBaseDamage()*abilityE:GetSpecialValueFloat('base_damage')/100
    local range=bot:GetAttackRange()+abilityE:GetSpecialValueInt('attack_range_bonus')
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if HammerTarget(enemy) and J.WillKillTarget(enemy,damage,DAMAGE_TYPE_PURE,bot:GetAttackPoint()) then return BOT_ACTION_DESIRE_HIGH,enemy end
    end
    local target=J.GetProperTarget(bot)
    if HammerTarget(target) and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot) and J.IsChasingTarget(target,bot)) then return BOT_ACTION_DESIRE_HIGH,target end
    if J.IsLaning(bot) then
        for _,creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range,1600),true)) do
            if HammerTarget(creep) and J.IsKeyWordUnit('ranged',creep) and not J.IsOtherAllysTarget(creep)
                and J.WillKillTarget(creep,damage,DAMAGE_TYPE_PURE,bot:GetAttackPoint()) then return BOT_ACTION_DESIRE_HIGH,creep end
        end
    end
    target=bot:GetAttackTarget()
    if HammerTarget(target) and J.IsAttacking(bot) and (J.IsFarming(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) then return BOT_ACTION_DESIRE_HIGH,target end
    return 0
end
function X.ConsiderR()
    if not J.CanCastAbility(abilityR) or bot:HasModifier('modifier_omniknight_guardian_angel') then return 0 end
    local global=bot:HasScepter()
    local heroes=GetUnitList(UNIT_LIST_ALLIED_HEROES)
    local threatened=0
    for _,ally in ipairs(heroes) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
            and (global or J.IsInRange(bot,ally,abilityR:GetSpecialValueInt('radius')))
            and not ally:HasModifier('modifier_omniknight_guardian_angel') then
            local physical=0
            for _,enemy in ipairs(J.GetNearbyHeroes(ally,1200,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and not enemy:IsDisarmed() then physical=physical+enemy:GetEstimatedDamageToTarget(true,ally,2,DAMAGE_TYPE_PHYSICAL) end
            end
            if physical>=ally:GetHealth()*0.45 and (ally:WasRecentlyDamagedByAnyHero(2) or ally:HasModifier('modifier_legion_commander_duel')) then return BOT_ACTION_DESIRE_HIGH end
            if physical>=ally:GetHealth()*0.25 and ally:WasRecentlyDamagedByAnyHero(2) then threatened=threatened+1 end
        end
    end
    if threatened>=2 then return BOT_ACTION_DESIRE_HIGH end
    if global then
        for _,building in ipairs(GetUnitList(UNIT_LIST_ALLIED_BUILDINGS)) do
            if J.IsValidBuilding(building) and not building:HasModifier('modifier_fountain_glyph') and J.GetHP(building)<0.65 then
                for _,enemy in ipairs(J.GetNearbyHeroes(building,1000,true,BOT_MODE_NONE)) do
                    if J.IsValidHero(enemy) and enemy:GetAttackTarget()==building and not enemy:IsDisarmed() then return BOT_ACTION_DESIRE_HIGH end
                end
            end
        end
    end
    return 0
end
function X.ConsiderSilencedHammer()
    if not bot:IsAlive() or not bot:IsSilenced() or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility()
        or bot:NumQueuedActions()>0 or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsInvulnerable() or bot:IsInvisible()
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local desire,target=X.ConsiderE()
    if desire>0 then bot:Action_UseAbilityOnEntity(abilityE,target);return true end
    return false
end

return X
