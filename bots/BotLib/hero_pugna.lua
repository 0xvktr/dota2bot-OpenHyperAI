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

-- Updated to 7.41f from D2PT: mid and both supports; forced skipped roles use hard support.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/pugna')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Nether Blast, [2] Decrepify, [3] Nether Ward, [6] Life Drain.
local isMid = sRole == 'pos_2'
local nAbilityBuildList = isMid and {1,2,1,2,1,6,1,2,2,3,6,3,3,3,6}
    or {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild(isMid and {
    t10={0,10}, -- -1s Nether Blast cooldown
    t15={10,0}, -- +250 health
    t20={10,0}, -- +1.5s Decrepify duration
    t25={0,10}, -- +200 Nether Blast damage
} or {
    t10={10,0}, -- +2 Nether Ward health
    t15={10,0}, -- +250 health
    t20={0,10}, -- +15% Life Drain heal
    t25={10,0}, -- +1.9 Nether Ward damage per mana
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = isMid and {
    'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_arcane_boots','item_aether_lens','item_blink',
    'item_ultimate_scepter','item_aghanims_shard','item_black_king_bar',
    -- Bot policy: consume Scepter and add late control/cooldown within six slots.
    'item_ultimate_scepter_2','item_sheepstick','item_octarine_core',
} or {
    'item_double_branches','item_magic_stick','item_ward_sentry','item_tango','item_blood_grenade',
    'item_magic_wand','item_arcane_boots','item_glimmer_cape','item_aether_lens',
    'item_aghanims_shard','item_blink','item_ultimate_scepter',
    -- Bot policy: consume Scepter, then add late control and survival within six slots.
    'item_ultimate_scepter_2','item_sheepstick','item_aeon_disk',
}
X.sSellList = isMid and {'item_blink','item_bottle','item_black_king_bar','item_magic_wand'}
    or {'item_blink','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(unit)
 if Minion.IsValidUnit(unit) then
  if J.IsKeyWordUnit('pugna_nether_ward',unit) then bot.pugnaNetherWard=unit;return end
  Minion.IllusionThink(unit)
 end
end
local NetherBlast,Decrepify,NetherWard,LifeDrain
local function Refresh()
 bot=GetBot()
 NetherBlast=bot:GetAbilityByName('pugna_nether_blast');Decrepify=bot:GetAbilityByName('pugna_decrepify')
 NetherWard=bot:GetAbilityByName('pugna_nether_ward');LifeDrain=bot:GetAbilityByName('pugna_life_drain')
end
Refresh()
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
local function PointFor(target,ability,radius,delay)
    local point=J.GetCorrectLoc(target,delay)
    local delta=point-bot:GetLocation();local length=delta:Length2D();local range=ActualRange(ability)
    if length>range+radius then return nil end
    if length>range then point=bot:GetLocation()+delta:Normalized()*range end
    return point
end
local function OwnWard(unit)
    if not J.IsValid(unit) or unit:GetTeam()~=bot:GetTeam() or not string.find(unit:GetUnitName(),'pugna_nether_ward') then return false end
    if unit==bot.pugnaNetherWard then return true end
    local index=unit:GetModifierByName('modifier_pugna_nether_ward')
    if index<0 then return false end
    local source=unit:GetModifierSourceAbility(index)
    return source~=nil and not source:IsNull() and source:GetName()=='pugna_nether_ward' and source:GetCaster()==bot
end
local function NearbyWards()
    local wards={}
    for _,unit in ipairs(GetUnitList(UNIT_LIST_ALLIES)) do if OwnWard(unit) then wards[#wards+1]=unit end end
    return wards
end
local function PhysicalThreat(ally)
    local damage=J.GetAttackProjectileDamageByRange(ally,1000)
    for _,enemy in ipairs(J.GetNearbyHeroes(ally,900,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not enemy:IsDisarmed() and not J.IsDisabled(enemy) and enemy:GetAttackTarget()==ally
            and GetUnitToUnitDistance(enemy,ally)<=enemy:GetAttackRange()+100 then
            damage=damage+enemy:GetEstimatedDamageToTarget(false,ally,1,DAMAGE_TYPE_PHYSICAL)
        end
    end
    return damage
end
function X.ConsiderDecrepify()
    if not J.CanCastAbility(Decrepify) then return 0 end
    local range=ActualRange(Decrepify)
    local allies=J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE);allies[#allies+1]=bot
    for _,ally in ipairs(allies) do
        if J.IsValidHero(ally) and not ally:IsInvulnerable() and not ally:HasModifier('modifier_pugna_decrepify')
            and GetUnitToUnitDistance(bot,ally)<=range and (J.GetHP(ally)<0.5 or J.IsRetreating(ally)) and PhysicalThreat(ally)>100 then
            return BOT_ACTION_DESIRE_HIGH,ally,'save'
        end
    end
    for _,ward in ipairs(NearbyWards()) do
        if GetUnitToUnitDistance(bot,ward)<=range and not ward:HasModifier('modifier_pugna_decrepify') then
            for _,enemy in ipairs(J.GetEnemiesNearLoc(ward:GetLocation(),900)) do
                if J.IsValidHero(enemy) and enemy:GetAttackTarget()==ward and not enemy:IsDisarmed() then return BOT_ACTION_DESIRE_HIGH,ward,'save' end
            end
        end
    end
    local target=bot.pugnaDrainTarget
    if bot:IsChanneling() and bot.pugnaDrainKind=='enemy' and Enemy(target) and not target:HasModifier('modifier_pugna_decrepify')
        and GetUnitToUnitDistance(bot,target)<=range and J.CanCastOnTargetAdvanced(target) then return BOT_ACTION_DESIRE_HIGH,target,'combo' end
    target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and Enemy(target) and not target:HasModifier('modifier_pugna_decrepify')
        and GetUnitToUnitDistance(bot,target)<=range and J.CanCastOnTargetAdvanced(target) then
        local physicalAlly=false
        for _,ally in ipairs(J.GetAlliesNearLoc(target:GetLocation(),800)) do
            if ally~=bot and ally:GetAttackTarget()==target and not ally:IsDisarmed() then physicalAlly=true;break end
        end
        local magicFollow=(J.CanCastAbility(NetherBlast) and bot:GetMana()>=Decrepify:GetManaCost()+NetherBlast:GetManaCost())
            or (J.CanCastAbility(LifeDrain) and bot:GetMana()>=Decrepify:GetManaCost()+LifeDrain:GetManaCost())
        if not physicalAlly and magicFollow then return BOT_ACTION_DESIRE_HIGH,target,'combo' end
    end
    return 0
end
function X.ConsiderNetherBlast()
    if not J.CanCastAbility(NetherBlast) then return 0 end
    local range=ActualRange(NetherBlast);local radius=NetherBlast:GetSpecialValueInt('radius')
    local delay=NetherBlast:GetCastPoint()+NetherBlast:GetSpecialValueFloat('delay');local damage=NetherBlast:GetSpecialValueInt('blast_damage')
    local enemies=J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)
    for _,enemy in ipairs(enemies) do
        if Enemy(enemy) then
            local point=PointFor(enemy,NetherBlast,radius,delay)
            if point~=nil and (J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,delay)
                or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot))
                or (bot:IsChanneling() and enemy==bot.pugnaDrainTarget)
                or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and enemy:GetAttackTarget()==bot)) then return BOT_ACTION_DESIRE_HIGH,point end
            if point~=nil and J.IsInTeamFight(bot,1200) then
                local count=0;for _,other in ipairs(enemies) do if Enemy(other) and (J.GetCorrectLoc(other,delay)-point):Length2D()<=radius then count=count+1 end end
                if count>=2 then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    if J.IsAllowedToSpam(bot,NetherBlast:GetManaCost()) then
        if J.IsLaning(bot) then
            for _,creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range+radius,1600),true)) do
                if Enemy(creep) and string.find(creep:GetUnitName(),'ranged') and GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()
                    and J.WillKillTarget(creep,damage,DAMAGE_TYPE_MAGICAL,delay) then local point=PointFor(creep,NetherBlast,radius,delay);if point~=nil then return BOT_ACTION_DESIRE_HIGH,point end end
            end
        end
        if J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
            local creeps=bot:GetNearbyCreeps(math.min(range+radius,1600),true)
            for _,creep in ipairs(creeps) do
                if Enemy(creep) then
                    local point=PointFor(creep,NetherBlast,radius,delay)
                    if point~=nil then local count=0;for _,other in ipairs(creeps) do if Enemy(other) and not other:HasModifier('modifier_fountain_glyph') and (J.GetCorrectLoc(other,delay)-point):Length2D()<=radius then count=count+1 end end;if count>=3 then return BOT_ACTION_DESIRE_HIGH,point end end
                end
            end
        end
        if J.IsPushing(bot) then
            local buildings=bot:GetNearbyTowers(math.min(range+radius,1600),true)
            for _,unit in ipairs(bot:GetNearbyBarracks(math.min(range+radius,1600),true)) do buildings[#buildings+1]=unit end
            for _,building in ipairs(buildings) do
                if J.IsValidBuilding(building) and not building:IsInvulnerable() and not building:HasModifier('modifier_fountain_glyph')
                    and not building:HasModifier('modifier_backdoor_protection') and not building:HasModifier('modifier_backdoor_protection_active') then
                    local point=PointFor(building,NetherBlast,radius,delay);if point~=nil then return BOT_ACTION_DESIRE_HIGH,point end
                end
            end
        end
    end
    return 0
end
function X.ConsiderNetherWard()
    if not J.CanCastAbility(NetherWard) then return 0 end
    local range=ActualRange(NetherWard);local radius=NetherWard:GetSpecialValueInt('radius')
    local point=bot:GetLocation()+(J.GetEscapeLoc()-bot:GetLocation()):Normalized()*range
    if not IsLocationPassable(point) or J.IsLocHaveTower(700,true,point) or J.IsLocationInChrono(point) or J.IsLocationInBlackHole(point) then return 0 end
    for _,ward in ipairs(NearbyWards()) do if (ward:GetLocation()-point):Length2D()<radius*0.5 then return 0 end end
    local count=0
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do if Enemy(enemy) and GetUnitToLocationDistance(enemy,point)<=radius then count=count+1 end end
    if (J.IsInTeamFight(bot,1200) and count>=2) or ((J.IsGoingOnSomeone(bot) or J.IsRetreating(bot) or J.IsPushing(bot)) and count>=1) then return BOT_ACTION_DESIRE_HIGH,point end
    return 0
end
function X.ConsiderLifeDrain()
    if not J.CanCastAbility(LifeDrain) then return 0 end
    local range=ActualRange(LifeDrain);local tick=LifeDrain:GetSpecialValueFloat('tick_rate');local damage=LifeDrain:GetSpecialValueInt('health_drain')*tick
    if J.GetHP(bot)>0.55 and bot:GetHealth()>LifeDrain:GetSpecialValueInt('ally_healing')+bot:GetMaxHealth()*0.3 then
        for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)) do
            if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not ally:IsInvisible()
                and GetUnitToUnitDistance(bot,ally)<=range and not ally:HasModifier('modifier_ice_blast') and J.GetHP(ally)<0.4
                and (ally:WasRecentlyDamagedByAnyHero(2) or #J.GetNearbyHeroes(bot,1000,true,BOT_MODE_NONE)==0) then return BOT_ACTION_DESIRE_HIGH,ally,'ally' end
        end
    end
    if J.HasAghanimsShard(bot) then
        for _,ward in ipairs(NearbyWards()) do
            if GetUnitToUnitDistance(bot,ward)<=range then
                local count=0;for _,enemy in ipairs(J.GetEnemiesNearLoc(ward:GetLocation(),range)) do if J.IsValidHero(enemy) and Enemy(enemy) and GetUnitToUnitDistance(ward,enemy)<=range then count=count+1 end end
                if count>=2 and (J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot)) then return BOT_ACTION_DESIRE_HIGH,ward,'ward' end
            end
        end
    end
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy) and not enemy:IsInvisible() and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
            if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,LifeDrain:GetCastPoint()+tick)
                or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and #J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)<=#J.GetNearbyHeroes(bot,900,false,BOT_MODE_NONE)+1) then return BOT_ACTION_DESIRE_HIGH,enemy,'enemy' end
        end
    end
    return 0
end
local function CastDrain(target,kind)
    bot.pugnaDrainTarget=target;bot.pugnaDrainKind=kind
    bot:Action_UseAbilityOnEntity(LifeDrain,target)
end
function X.ConsiderLifeDrainContinuation()
    if not bot:IsChanneling() then return false end
    local active=bot:GetCurrentActiveAbility()
    if active==nil or active:GetName()~='pugna_life_drain' or not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:IsSilenced() or bot:IsInvulnerable() or bot:IsCastingAbility() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local target=bot.pugnaDrainTarget
    if bot.pugnaDrainKind=='ally' and (not J.IsValidHero(target) or J.GetHP(bot)<=0.3 or J.GetHP(target)>=0.95 or target:HasModifier('modifier_ice_blast')) then bot:Action_ClearActions(true);return true end
    if bot.pugnaDrainKind=='enemy' and (not Enemy(target) or target:IsInvisible() or not J.CanCastOnTargetAdvanced(target)) then bot:Action_ClearActions(true);return true end
    if bot.pugnaDrainKind=='ward' and not OwnWard(target) then bot:Action_ClearActions(true);return true end
    local innate=bot:GetAbilityByName('pugna_oblivion_savant')
    if innate==nil or not innate:IsTrained() or J.HasBreakModifier(bot) then return false end
    local desire,unit=X.ConsiderDecrepify();if desire>0 then bot:Action_UseAbilityOnEntity(Decrepify,unit);return true end
    local point;desire,point=X.ConsiderNetherBlast();if desire>0 then bot:Action_UseAbilityOnLocation(NetherBlast,point);return true end
    desire,point=X.ConsiderNetherWard();if desire>0 then bot:Action_UseAbilityOnLocation(NetherWard,point);return true end
    return false
end

function X.SkillsComplement()
 Refresh()
 if X.ConsiderLifeDrainContinuation() then return end
 if J.CanNotUseAbility(bot) or J.IsRealInvisible(bot) then return end
 local wd,wt,wkind=X.ConsiderDecrepify()
 if wd>0 and wkind=='save' then bot:Action_UseAbilityOnEntity(Decrepify,wt);return end
 local rd,rt,rkind=X.ConsiderLifeDrain()
 if rd>0 and rkind=='ally' then CastDrain(rt,rkind);return end
 local ed,ep=X.ConsiderNetherWard();if ed>0 then bot:Action_UseAbilityOnLocation(NetherWard,ep);return end
 if wd>0 then bot:Action_UseAbilityOnEntity(Decrepify,wt);return end
 local qd,qp=X.ConsiderNetherBlast();if qd>0 then bot:Action_UseAbilityOnLocation(NetherBlast,qp);return end
 if rd>0 then CastDrain(rt,rkind);return end
end
return X
