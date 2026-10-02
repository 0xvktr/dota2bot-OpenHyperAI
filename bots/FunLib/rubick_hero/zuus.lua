local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot = GetBot()

local function Available(a)
    return a~=nil and not a:IsNull() and a:IsTrained() and not a:IsHidden() and a:IsActivated() and not a:IsPassive()
end
local function Interrupt(unit,eta)
    if not unit:IsChanneling() then return false end
    local index=unit:GetModifierByName('modifier_teleporting')
    return index<0 or unit:GetModifierRemainingDuration(index)>eta+0.05
end
local function Range(a)
    local range=a:GetCastRange()
    for slot=0,5 do
        local item=bot:GetItemInSlot(slot)
        if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then
            range=range+item:GetSpecialValueInt('cast_range_bonus');break
        end
    end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range=range+supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end
local function Enemy(u)
    return J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) and J.CanCastOnNonMagicImmune(u)
        and not J.CannotBeKilled(bot,u) and not u:HasModifier('modifier_item_blade_mail_reflect')
        and not u:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function AllyEngaged(enemy)
    for _,ally in pairs(J.GetAlliesNearLoc(enemy:GetLocation(),800)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and ally:GetAttackTarget()==enemy then return true end
    end
    return false
end
local function Threat(enemy)
    local victim=enemy:GetAttackTarget()
    return J.IsValidHero(victim) and victim:GetTeam()==bot:GetTeam()
        and victim:WasRecentlyDamagedByAnyHero(2) and not J.IsDisabled(enemy)
end
local function Combat(enemy)
    return J.IsGoingOnSomeone(bot) and J.GetProperTarget(bot)==enemy or AllyEngaged(enemy)
        or J.IsRetreating(bot) and enemy:GetAttackTarget()==bot or Threat(enemy)
end
function X.ConsiderArc()
    local a=bot:GetAbilityByName('zuus_arc_lightning')
    if not J.CanCastAbility(a) then return 0 end
    local range=Range(a)
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy) and GetUnitToUnitDistance(bot,enemy)<=range and J.CanCastOnTargetAdvanced(enemy)
            and (J.WillKillTarget(enemy,a:GetSpecialValueInt('arc_damage'),DAMAGE_TYPE_MAGICAL,a:GetCastPoint())
                or Combat(enemy) and J.IsAllowedToSpam(bot,a:GetManaCost())) then return BOT_ACTION_DESIRE_HIGH,enemy end
    end
    if not J.IsAllowedToSpam(bot,a:GetManaCost()) then return 0 end
    local creeps=bot:GetNearbyLaneCreeps(math.min(range,1600),true)
    if J.IsLaning(bot) then
        for _,creep in pairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and not creep:HasModifier('modifier_fountain_glyph')
                and string.find(creep:GetUnitName(),'ranged',1,true) and GetUnitToUnitDistance(bot,creep)<=range
                and J.WillKillTarget(creep,a:GetSpecialValueInt('arc_damage'),DAMAGE_TYPE_MAGICAL,a:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,creep end
        end
    elseif J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        if #creeps<3 then creeps=bot:GetNearbyNeutralCreeps(math.min(range,1600)) end
        for _,creep in pairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and GetUnitToUnitDistance(bot,creep)<=range
                and not creep:HasModifier('modifier_fountain_glyph') then
                local count=0
                for _,other in pairs(creeps) do
                    if J.IsValid(other) and J.CanCastOnNonMagicImmune(other)
                        and GetUnitToUnitDistance(creep,other)<=a:GetSpecialValueInt('radius') then count=count+1 end
                end
                if count>=3 then return BOT_ACTION_DESIRE_HIGH,creep end
            end
        end
    end
    local target=J.GetProperTarget(bot)
    if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target))
        and J.IsValid(target) and J.CanCastOnNonMagicImmune(target) and GetUnitToUnitDistance(bot,target)<=range then return BOT_ACTION_DESIRE_HIGH,target end
    return 0
end
local function BoltTarget(enemy,a)
    local range=Range(a);local radius=a:GetSpecialValueInt('aoe_radius')
    if GetUnitToUnitDistance(bot,enemy)<=range and radius<=0 then return enemy,'unit' end
    local predicted=J.GetCorrectLoc(enemy,a:GetCastPoint())
    local delta=predicted-bot:GetLocation()
    local spread=math.max(radius,a:GetSpecialValueInt('spread_aoe'))
    if delta:Length2D()>range+spread then return nil end
    local point=delta:Length2D()>range and bot:GetLocation()+delta:Normalized()*range or predicted
    if radius<=0 then
        local distance=(predicted-point):Length2D()
        for _,other in pairs(J.GetNearbyHeroes(bot,math.min(range+spread,1600),true,BOT_MODE_NONE)) do
            if other~=enemy and J.IsValidHero(other) and J.CanCastOnNonMagicImmune(other)
                and (J.GetCorrectLoc(other,a:GetCastPoint())-point):Length2D()<distance then return nil end
        end
    end
    return point,'point'
end
function X.ConsiderBolt()
    local a=bot:GetAbilityByName('zuus_lightning_bolt')
    if not J.CanCastAbility(a) then return 0 end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(Range(a)+math.max(a:GetSpecialValueInt('spread_aoe'),a:GetSpecialValueInt('aoe_radius')),1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy) and J.CanCastOnTargetAdvanced(enemy) then
            local target,kind=BoltTarget(enemy,a)
            if target~=nil and (Interrupt(enemy,a:GetCastPoint())
                or J.WillKillTarget(enemy,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,a:GetCastPoint())
                or Combat(enemy)) then return BOT_ACTION_DESIRE_HIGH,target,kind end
        end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
            if IsHeroAlive(id) then
                local info=GetHeroLastSeenInfo(id)
                local seen=info~=nil and info[1] or nil
                if seen~=nil and seen.time_since_seen<1 and GetUnitToLocationDistance(bot,seen.location)<=Range(a) then
                    local visible=false
                    for _,enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
                        if enemy:GetPlayerID()==id and enemy:CanBeSeen() then visible=true;break end
                    end
                    if not visible then return BOT_ACTION_DESIRE_HIGH,seen.location,'point' end
                end
            end
        end
    end
    local target=J.GetProperTarget(bot)
    if J.IsValid(target) and (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target))
        and J.CanCastOnNonMagicImmune(target) and GetUnitToUnitDistance(bot,target)<=Range(a) then return BOT_ACTION_DESIRE_HIGH,target,'unit' end
    return 0
end
local function GlobalSafe(a)
    local reflected=0
    for _,enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and J.CanCastOnNonMagicImmune(enemy) then
            if enemy:HasModifier('modifier_nyx_assassin_spiked_carapace') then return false end
            if enemy:HasModifier('modifier_item_blade_mail_reflect') then
                reflected=reflected+bot:GetActualIncomingDamage(a:GetSpecialValueInt('damage')*(1+bot:GetSpellAmp()),DAMAGE_TYPE_MAGICAL)
            end
        end
    end
    return bot:GetHealth()-reflected>bot:GetMaxHealth()*0.2
end
function X.ConsiderWrath()
    local a=bot:GetAbilityByName('zuus_thundergods_wrath')
    if not J.CanCastAbility(a) or not GlobalSafe(a) then return 0 end
    local engaged=0
    for _,enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        -- Hidden health is stale. Only observed enemies justify damage decisions.
        if Enemy(enemy) then
            if J.WillKillTarget(enemy,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,a:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH end
            if AllyEngaged(enemy) and (J.GetHP(enemy)<0.65 or J.IsDisabled(enemy)) then engaged=engaged+1 end
        end
    end
    if engaged>=2 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderCloud()
    local a=bot:GetAbilityByName('zuus_cloud');local bolt=bot:GetAbilityByName('zuus_lightning_bolt')
    if not J.CanCastAbility(a) or not Available(bolt) then return 0 end
    for _,enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(enemy) and (AllyEngaged(enemy) and (J.IsDisabled(enemy) or J.GetHP(enemy)<0.65)
            or enemy:IsChanneling() and J.IsDisabled(enemy)) then
            local point=J.GetCorrectLoc(enemy,a:GetCastPoint()+a:GetSpecialValueFloat('cloud_bolt_interval'))
            local duplicate=false
            for _,unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
                if unit~=nil and not unit:IsNull() and unit:IsAlive() and unit:GetUnitName()=='npc_dota_zeus_cloud'
                    and unit:GetPlayerID()==bot:GetPlayerID() and GetUnitToLocationDistance(unit,point)<=a:GetSpecialValueInt('cloud_radius') then duplicate=true;break end
            end
            if not duplicate and IsLocationPassable(point) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0
end
function X.ConsiderJump()
    local a=bot:GetAbilityByName('zuus_heavenly_jump')
    if not J.CanCastAbility(a) or bot:IsRooted() or bot:HasModifier('modifier_slark_pounce_leash')
        or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_puck_coiled') then return 0 end
    local landing=J.GetFaceTowardDistanceLocation(bot,a:GetSpecialValueInt('hop_distance'))
    if not IsLocationPassable(landing) or J.IsLocationInChrono(landing) or J.IsLocationInBlackHole(landing) then return 0 end
    for _,tower in pairs(bot:GetNearbyTowers(1600,true)) do
        if J.IsValidBuilding(tower) and GetUnitToLocationDistance(tower,landing)<880 then return 0 end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and bot:IsFacingLocation(J.GetEscapeLoc(),25)
        and #J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
    local target=J.GetProperTarget(bot)
    if Enemy(target) and J.IsGoingOnSomeone(bot) and not J.IsDisabled(target)
        and GetUnitToUnitDistance(bot,target)>bot:GetAttackRange()
        and (J.GetCorrectLoc(target,a:GetSpecialValueFloat('hop_duration'))-landing):Length2D()<=a:GetSpecialValueInt('range')
        and GetUnitToLocationDistance(target,landing)<GetUnitToUnitDistance(bot,target)
        and #J.GetAlliesNearLoc(landing,800)+1>=#J.GetEnemiesNearLoc(landing,800) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.UseLightningHands()
    bot=GetBot();local a=bot:GetAbilityByName('zuus_lightning_hands')
    if not Available(a) or not a:IsFullyCastable() or a:GetToggleState() or not bot:IsAlive() or bot:IsInvulnerable()
        or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsChanneling() or bot:IsUsingAbility()
        or bot:IsCastingAbility() or J.HasQueuedAction(bot) or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    bot:Action_UseAbility(a);return true
end
local decisions={zuus_arc_lightning=X.ConsiderArc,zuus_lightning_bolt=X.ConsiderBolt,
    zuus_heavenly_jump=X.ConsiderJump,zuus_cloud=X.ConsiderCloud,zuus_thundergods_wrath=X.ConsiderWrath}
local function Cast(a,target,kind,queue)
    if queue then J.SetQueuePtToINT(bot,true,a) end
    if a:GetName()=='zuus_lightning_bolt' and kind=='unit' or a:GetName()=='zuus_arc_lightning' then
        if queue then bot:ActionQueue_UseAbilityOnEntity(a,target) else bot:Action_UseAbilityOnEntity(a,target) end
    elseif a:GetName()=='zuus_cloud' or a:GetName()=='zuus_lightning_bolt' then
        if queue then bot:ActionQueue_UseAbilityOnLocation(a,target) else bot:Action_UseAbilityOnLocation(a,target) end
    else
        if queue then bot:ActionQueue_UseAbility(a) else bot:Action_UseAbility(a) end
    end
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName();local decide=decisions[name]
    if decide==nil and name~='zuus_lightning_hands' then return nil end
    bot=GetBot()
    if X.UseLightningHands() then return true end
    if name=='zuus_lightning_hands' or J.CanNotUseAbility(bot) or bot:IsInvisible() or not J.CanCastAbility(a) then return false end
    local desire,target,kind=decide()
    if desire<=0 then return false end
    Cast(a,target,kind,false);return true
end
function X.UseNative()
    bot=GetBot()
    if X.UseLightningHands() then return true end
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return false end
    for _,name in ipairs({'zuus_heavenly_jump','zuus_thundergods_wrath','zuus_lightning_bolt','zuus_cloud','zuus_arc_lightning'}) do
        local desire,target,kind=decisions[name]()
        if desire>0 then Cast(bot:GetAbilityByName(name),target,kind,true);return true end
    end
    return false
end
return X
