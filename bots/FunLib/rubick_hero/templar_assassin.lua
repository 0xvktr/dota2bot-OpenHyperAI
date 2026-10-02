local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot=GetBot()
function X.Range(a)
    local range=a:GetCastRange()
    local lens=J.IsItemAvailable('item_aether_lens')
    if lens~=nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(u)
    return J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u) and not J.CannotBeKilled(bot,u)
end
local function Safe(p)
    return IsLocationPassable(p) and not J.IsLocationInChrono(p) and not J.IsLocationInBlackHole(p)
        and not J.IsLocHaveTower(700,true,p) and #J.GetEnemiesNearLoc(p,1000)<=#J.GetAlliesNearLoc(p,1000)+1
end
function X.OwnTraps()
    local result={}
    bot.taTrapSeen=bot.taTrapSeen or {}
    for _,u in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if u~=nil and not u:IsNull() and u:IsAlive() and u:GetTeam()==bot:GetTeam() and u:GetPlayerID()==bot:GetPlayerID()
            and u:GetUnitName()=='npc_dota_templar_assassin_psionic_trap' then
            result[#result+1]=u
            if bot.taTrapSeen[u]==nil then bot.taTrapSeen[u]=DotaTime() end
        end
    end
    for trap in pairs(bot.taTrapSeen) do
        local found=false
        for _,u in ipairs(result) do if u==trap then found=true;break end end
        if not found then bot.taTrapSeen[trap]=nil end
    end
    return result
end
local function ReadyTrap(trap)
    local a=bot:GetAbilityByName('templar_assassin_psionic_trap')
    local radius=a~=nil and not a:IsNull() and a:GetSpecialValueInt('trap_radius') or 400
    local full=a~=nil and not a:IsNull() and a:GetSpecialValueFloat('trap_max_charge_duration') or 3.5
    local mature=bot.taTrapSeen~=nil and bot.taTrapSeen[trap]~=nil and DotaTime()-bot.taTrapSeen[trap]>=full
    for _,u in pairs(J.GetNearbyHeroes(trap,math.min(1600,radius),true,BOT_MODE_NONE)) do
        if Enemy(u) and not u:HasModifier('modifier_templar_assassin_trap_slow') then
            local useful=bot:IsAlive() and J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)
            for _,ally in pairs(J.GetNearbyHeroes(trap,1000,false,BOT_MODE_NONE)) do
                if J.IsValidHero(ally) and not ally:IsIllusion() and ally:GetAttackTarget()==u then useful=true end
            end
            if useful or mature and a~=nil and not a:IsNull()
                and J.WillKillTarget(u,a:GetSpecialValueInt('trap_bonus_damage'),DAMAGE_TYPE_MAGICAL,a:GetSpecialValueFloat('trap_duration')) then return true end
        end
    end
    return false
end
function X.UseTrapMinion(trap)
    bot=GetBot()
    if trap==nil or trap:IsNull() or not trap:IsAlive() or trap:GetTeam()~=bot:GetTeam() or trap:GetPlayerID()~=bot:GetPlayerID()
        or trap:GetUnitName()~='npc_dota_templar_assassin_psionic_trap' then return false end
    -- Owned traps are stationary; claim them even when idle or locked so generic
    -- minion fallback cannot issue movement or ordinary attack commands.
    if J.CanNotUseAbility(trap) then return true end
    X.OwnTraps()
    local a=trap:GetAbilityByName('templar_assassin_self_trap')
    if not J.CanCastAbility(a) then return true end
    local danger=false
    for _,p in pairs(trap:GetIncomingTrackingProjectiles()) do if p.is_attack then danger=true end end
    local valuable=false
    if danger then
        for _,enemy in pairs(J.GetNearbyHeroes(trap,400,true,BOT_MODE_NONE)) do if Enemy(enemy) then valuable=true;break end end
    end
    if ReadyTrap(trap) or valuable then
        trap:Action_UseAbility(a);return true
    end
    return true
end
function X.ConsiderQ()
    local a=bot:GetAbilityByName('templar_assassin_refraction')
    if not J.CanCastAbility(a) then return 0 end
    local defense=not bot:HasModifier('modifier_templar_assassin_refraction_absorb')
        and (bot:WasRecentlyDamagedByAnyHero(1.5) or J.IsNotAttackProjectileIncoming(bot,1200) or J.GetAttackProjectileDamageByRange(bot,1200)>0)
    if defense then return BOT_ACTION_DESIRE_HIGH end
    local target=bot:GetAttackTarget()
    if not bot:HasModifier('modifier_templar_assassin_refraction_damage') and not bot:IsDisarmed() and J.IsValid(target) and J.CanBeAttacked(target)
        and not J.CannotBeKilled(bot,target) and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange()
        and (J.IsValidHero(target) or (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot))
            and J.GetMP(bot)>0.3 and target:GetHealth()>bot:GetAttackDamage()*2) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.UseDisabledRefraction()
    bot=GetBot()
    if not (bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()) then return false end
    local a=bot:GetAbilityByName('templar_assassin_refraction')
    if not J.CanCastAbility(a) or a:GetSpecialValueInt('cast_while_disabled')<=0 or not bot:IsAlive() or bot:IsSilenced()
        or bot:IsInvulnerable() or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_templar_assassin_meld') or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    if X.ConsiderQ()>0 then bot:Action_UseAbility(a);return true end
    return false
end
function X.ConsiderW()
    local a=bot:GetAbilityByName('templar_assassin_meld')
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_templar_assassin_meld') then return 0 end
    local target=bot:GetAttackTarget() or J.GetProperTarget(bot)
    local range=bot:GetAttackRange()+a:GetSpecialValueInt('attack_range_bonus')
    if not bot:IsDisarmed() and J.IsValid(target) and J.CanBeAttacked(target) and not target:IsBuilding()
        and not J.CannotBeKilled(bot,target) and not target:HasModifier('modifier_item_blade_mail_reflect')
        and GetUnitToUnitDistance(bot,target)<=range
        and (J.IsGoingOnSomeone(bot) and J.IsValidHero(target) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
            or J.IsFarming(bot) and J.GetMP(bot)>0.3 and target:GetHealth()>bot:GetAttackDamage()*2
            or J.IsLaning(bot) and not target:IsHero() and string.find(target:GetUnitName(),'ranged')
                and not J.WillKillTarget(target,bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL,0)
                and J.WillKillTarget(target,bot:GetAttackDamage()+a:GetSpecialValueInt('bonus_damage'),DAMAGE_TYPE_PHYSICAL,0)) then return BOT_ACTION_DESIRE_HIGH,target end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and not bot:HasModifier('modifier_item_dustofappearance')
        and not J.IsLocHaveTower(900,true,bot:GetLocation()) and J.GetAttackProjectileDamageByRange(bot,1200)>0 then return BOT_ACTION_DESIRE_HIGH,nil end
    return 0
end
local function Covered(p,traps)
    for _,trap in ipairs(traps) do if GetUnitToLocationDistance(trap,p)<400 then return true end end
    local pending=bot.taTrapPending
    return pending~=nil and DotaTime()<pending.expires and (pending.point-p):Length2D()<400
end
function X.ConsiderR()
    local a=bot:GetAbilityByName('templar_assassin_psionic_trap')
    if not J.CanCastAbility(a) then return 0 end
    local traps=X.OwnTraps()
    if #traps>=a:GetSpecialValueInt('max_traps') then return 0 end
    local range=X.Range(a)
    for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(u) and GetUnitToUnitDistance(bot,u)<=range then
            local useful=J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)
            for _,ally in pairs(J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)) do
                if J.IsValidHero(ally) and not ally:IsIllusion() and ally:GetAttackTarget()==u then useful=true end
            end
            local p=J.GetCorrectLoc(u,a:GetCastPoint()+1)
            if useful and GetUnitToLocationDistance(bot,p)<=range and IsLocationPassable(p) and not Covered(p,traps) then return BOT_ACTION_DESIRE_HIGH,p end
        end
    end
    if #J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)==0 and J.GetMP(bot)>0.35 and not J.IsRetreating(bot) then
        for _,rune in ipairs({RUNE_BOUNTY_1,RUNE_BOUNTY_2,RUNE_BOUNTY_3,RUNE_BOUNTY_4,RUNE_POWERUP_1,RUNE_POWERUP_2}) do
            local p=GetRuneSpawnLocation(rune)
            if GetUnitToLocationDistance(bot,p)<=range and IsLocationPassable(p) and not Covered(p,traps) then return BOT_ACTION_DESIRE_HIGH,p end
        end
    end
    return 0
end
function X.ConsiderTrap()
    local a=bot:GetAbilityByName('templar_assassin_trap')
    if not J.CanCastAbility(a) or a:GetAutoCastState() then return 0 end
    local nearest,distance
    for _,trap in ipairs(X.OwnTraps()) do
        local d=GetUnitToUnitDistance(bot,trap)
        if distance==nil or d<distance then nearest,distance=trap,d end
    end
    if nearest~=nil and ReadyTrap(nearest) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderProjection()
    local a=bot:GetAbilityByName('templar_assassin_trap_teleport')
    if not J.CanCastAbility(a) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_puck_coiled') then return 0 end
    if bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)>0 then return 0 end
    local best,distance
    for _,trap in ipairs(X.OwnTraps()) do
        if Safe(trap:GetLocation()) and GetUnitToUnitDistance(bot,trap)>1000 then
            if J.IsRetreating(bot) then
                local d=GetUnitToLocationDistance(trap,J.GetEscapeLoc())
                if d+1000<GetUnitToLocationDistance(bot,J.GetEscapeLoc()) and (distance==nil or d<distance) then best,distance=trap,d end
            elseif J.IsGoingOnSomeone(bot) and J.GetHP(bot)>0.5 then
                local target=J.GetProperTarget(bot)
                if Enemy(target) and J.CanBeAttacked(target) then
                    local d=GetUnitToLocationDistance(trap,J.GetCorrectLoc(target,a:GetCastPoint()+a:GetChannelTime()))
                    if d<=400 and (distance==nil or d<distance) then best,distance=trap,d end
                end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best:GetLocation() end
    return 0
end
local decisions={templar_assassin_refraction=X.ConsiderQ,templar_assassin_meld=X.ConsiderW,templar_assassin_psionic_trap=X.ConsiderR,
    templar_assassin_trap=X.ConsiderTrap,templar_assassin_trap_teleport=X.ConsiderProjection}
local function Cast(a,target)
    local name=a:GetName()
    -- Projection itself preserves Meld; an item toggle during preparation does not.
    if not (name=='templar_assassin_trap_teleport' and bot:HasModifier('modifier_templar_assassin_meld')) then J.SetQueuePtToINT(bot,true,a) end
    if name=='templar_assassin_psionic_trap' or name=='templar_assassin_trap_teleport' then bot:ActionQueue_UseAbilityOnLocation(a,target)
    else bot:ActionQueue_UseAbility(a) end
    if name=='templar_assassin_meld' and target~=nil then bot:ActionQueue_AttackUnit(target,true) end
    if name=='templar_assassin_psionic_trap' then bot.taTrapPending={point=target,expires=DotaTime()+a:GetCastPoint()+2} end
end
function X.ConsiderStolenSpell(a)
    local consider=decisions[a:GetName()]
    if consider==nil then return nil end
    bot=GetBot()
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a) or bot:HasModifier('modifier_templar_assassin_meld') and a:GetName()~='templar_assassin_trap_teleport' then return false end
    local desire,target=consider()
    if desire<=0 then return false end
    Cast(a,target);return true
end
function X.UseNative()
    bot=GetBot()
    X.OwnTraps()
    if X.UseDisabledRefraction() then return true end
    if J.CanNotUseAbility(bot) then return false end
    local order=bot:HasModifier('modifier_templar_assassin_meld') and {'templar_assassin_trap_teleport'}
        or {'templar_assassin_refraction','templar_assassin_meld','templar_assassin_trap','templar_assassin_psionic_trap','templar_assassin_trap_teleport'}
    for _,name in ipairs(order) do
        local a=bot:GetAbilityByName(name)
        if J.CanCastAbility(a) then
            local desire,target=decisions[name]()
            if desire>0 then Cast(a,target);return true end
        end
    end
    return false
end
return X
