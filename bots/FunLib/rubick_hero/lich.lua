local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local function Range(a)
    local r = a:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then r = r + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then r = r + supremacy:GetSpecialValueInt('cast_range') end
    return r
end
local function Enemy(u,a,point)
    return J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) and J.CanCastOnNonMagicImmune(u)
        and J.IsInRange(bot,u,Range(a)) and (point or J.CanCastOnTargetAdvanced(u))
end
function X.ShieldTarget(a)
    if not J.CanCastAbility(a) then return nil end
    local candidates={bot}
    for _,u in pairs(J.GetNearbyHeroes(bot,Range(a),false,BOT_MODE_NONE)) do candidates[#candidates+1]=u end
    local best,score=nil,0
    for _,u in pairs(candidates) do
        if J.IsValidHero(u) and not u:IsIllusion() and not u:HasModifier('modifier_lich_frost_shield') then
            local pressure=0
            for _,e in pairs(J.GetNearbyHeroes(u,1000,true,BOT_MODE_NONE)) do
                if J.IsValidHero(e) and e:GetAttackTarget()==u then pressure=pressure+1 end
            end
            local value=pressure*(2-J.GetHP(u))
            if value>score then best,score=u,value end
        end
    end
    return best
end
function X.ChainTarget(a)
    if not J.CanCastAbility(a) then return nil end
    local target=J.GetProperTarget(bot)
    local best,score=nil,0
    for _,e in pairs(J.GetNearbyHeroes(bot,math.min(1600,Range(a)),true,BOT_MODE_NONE)) do
        if Enemy(e,a,false) and not J.CannotBeKilled(bot,e) then
            local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,e)/a:GetSpecialValueInt('initial_projectile_speed')
            if J.WillKillTarget(e,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,delay) then return e end
            local count=0
            for _,other in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
                if other~=e and J.IsValidHero(other) and J.CanCastOnNonMagicImmune(other)
                    and J.IsInRange(e,other,a:GetSpecialValueInt('jump_range')) then count=count+1 end
            end
            for _,creep in pairs(bot:GetNearbyCreeps(1600,true)) do
                if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep)
                    and J.IsInRange(e,creep,a:GetSpecialValueInt('jump_range')) then count=count+0.25 end
            end
            for _,spire in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
                if J.IsValid(spire) and spire:GetUnitName()=='npc_dota_lich_ice_spire'
                    and J.IsInRange(e,spire,a:GetSpecialValueInt('jump_range')) then count=count+1 end
            end
            if count>score and (J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot) and e==target) then best,score=e,count end
        end
    end
    return best
end
function X.UseDuringGaze()
    if not bot:IsChanneling() or not bot:HasScepter() then return false end
    local active=bot:GetCurrentActiveAbility()
    if active==nil
        or active:GetName()~='lich_sinister_gaze' or bot:IsSilenced()
        or not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:IsInvulnerable() or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active')
        or J.HasQueuedAction(bot) then return false end
    local shield=bot:GetAbilityByName('lich_frost_shield')
    local target=X.ShieldTarget(shield)
    if target~=nil then bot:Action_UseAbilityOnEntity(shield,target);return true end
    local chain=bot:GetAbilityByName('lich_chain_frost')
    target=X.ChainTarget(chain)
    if target~=nil then bot:Action_UseAbilityOnEntity(chain,target);return true end
    return false
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='lich_frost_nova' and name~='lich_frost_shield' and name~='lich_sinister_gaze'
        and name~='lich_chain_frost' and name~='lich_ice_spire' then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a) then return false end
    local target
    if name=='lich_frost_shield' then target=X.ShieldTarget(a)
    elseif name=='lich_chain_frost' then target=X.ChainTarget(a)
    else
        for _,e in pairs(J.GetNearbyHeroes(bot,math.min(1600,Range(a)),true,BOT_MODE_NONE)) do
            if Enemy(e,a,name=='lich_ice_spire' or name=='lich_sinister_gaze' and bot:HasScepter())
                and (e:IsChanneling() and name=='lich_sinister_gaze'
                    or J.IsGoingOnSomeone(bot) and e==J.GetProperTarget(bot)
                    or J.IsRetreating(bot) and J.IsChasingTarget(e,bot)) then target=e;break end
        end
    end
    if target==nil then return false end
    J.SetQueuePtToINT(bot,true,a)
    if name=='lich_ice_spire' or name=='lich_sinister_gaze' and bot:HasScepter() then
        bot:ActionQueue_UseAbilityOnLocation(a,target:GetLocation())
    else bot:ActionQueue_UseAbilityOnEntity(a,target) end
    return true
end
return X
