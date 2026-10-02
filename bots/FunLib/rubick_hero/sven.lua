local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local ItemCastPolicy=require(GetScriptDirectory()..'/FunLib/item_cast_policy')
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
    return J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u)
        and not J.CannotBeKilled(bot,u) and not u:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Travel(a)
    return bot:HasScepter() and a:GetAutoCastState()
end
local function Legal(a,u,range)
    if not J.IsValid(u) or not J.CanCastOnNonMagicImmune(u) or not J.CanCastOnTargetAdvanced(u)
        or GetUnitToUnitDistance(bot,u)>range or u:HasModifier('modifier_fountain_glyph') then return false end
    if Travel(a) then
        local p=u:GetLocation()
        return not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture') and not bot:HasModifier('modifier_puck_coiled')
            and IsLocationPassable(p) and not J.IsLocationInChrono(p) and not J.IsLocationInBlackHole(p)
            and not J.IsLocHaveTower(700,true,p) and #J.GetEnemiesNearLoc(p,1000)<=#J.GetAlliesNearLoc(p,1000)+1
    end
    return true
end
function X.ConsiderQ(a)
    a=a or bot:GetAbilityByName('sven_storm_bolt')
    if not ItemCastPolicy.Ready(a) or not ItemCastPolicy.CanConsider(bot,a) then return 0 end
    local range=X.Range(a)
    local radius=a:GetSpecialValueInt('bolt_aoe')
    local heroes=J.GetNearbyHeroes(bot,math.min(1600,range+radius),true,BOT_MODE_NONE)
    -- Direct channel interruption does not require a guessed damage combo.
    for _,u in pairs(heroes) do
        if Enemy(u) and u:IsChanneling() and Legal(a,u,range) then
            local interrupt=true
            if u:HasModifier('modifier_teleporting') then
                local i=u:GetModifierByName('modifier_teleporting')
                interrupt=i>=0 and u:GetModifierRemainingDuration(i)>a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('bolt_speed')
            end
            if interrupt then return BOT_ACTION_DESIRE_HIGH,u end
        end
    end
    local candidates={}
    for _,u in pairs(heroes) do candidates[#candidates+1]=u end
    for _,u in pairs(bot:GetNearbyLaneCreeps(math.min(1600,range),true)) do candidates[#candidates+1]=u end
    local damage=a:GetAbilityDamage()+(Travel(a) and a:GetSpecialValueInt('scepter_bonus_damage') or 0)
    local best,bestScore
    for _,candidate in ipairs(candidates) do
        if Legal(a,candidate,range) then
            local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,candidate)/a:GetSpecialValueInt('bolt_speed')
            local center=J.GetCorrectLoc(candidate,delay)
            local count,priority=0,0
            for _,u in pairs(heroes) do
                if Enemy(u) and (J.GetCorrectLoc(u,delay)-center):Length2D()<=radius then
                    count=count+1
                    local interrupt=u:IsChanneling()
                    if interrupt and u:HasModifier('modifier_teleporting') then
                        local i=u:GetModifierByName('modifier_teleporting');interrupt=i>=0 and u:GetModifierRemainingDuration(i)>delay
                    end
                    if interrupt then priority=math.max(priority,100) end
                    if J.WillKillTarget(u,damage,DAMAGE_TYPE_MAGICAL,delay) then priority=math.max(priority,90) end
                    if J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) and not J.IsDisabled(u) then priority=math.max(priority,60) end
                    if J.IsRetreating(bot) and J.IsChasingTarget(u,bot) then priority=math.max(priority,80) end
                end
            end
            if count>=2 and J.IsInTeamFight(bot,1200) then priority=math.max(priority,70) end
            if priority>0 and (bestScore==nil or priority*10+count>bestScore) then best,bestScore=candidate,priority*10+count end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    if J.IsLaning(bot) and J.GetMP(bot)>0.35 then
        for _,u in ipairs(candidates) do
            if not u:IsHero() and string.find(u:GetUnitName(),'ranged') and Legal(a,u,range)
                and J.WillKillTarget(u,damage,DAMAGE_TYPE_MAGICAL,a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('bolt_speed')) then return BOT_ACTION_DESIRE_HIGH,u end
        end
    end
    if J.IsFarming(bot) and J.GetMP(bot)>0.45 and #heroes==0 then
        local creeps=bot:GetNearbyNeutralCreeps(math.min(1600,range))
        for _,u in ipairs(creeps) do
            if Legal(a,u,range) then
                local count=0
                for _,other in ipairs(creeps) do if J.IsValid(other) and GetUnitToUnitDistance(u,other)<=radius then count=count+1 end end
                if count>=3 then return BOT_ACTION_DESIRE_HIGH,u end
            end
        end
    end
    return 0
end
function X.ConsiderE(a)
    a=a or bot:GetAbilityByName('sven_warcry')
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_sven_warcry') then return 0 end
    local candidates={bot}
    for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(1600,a:GetSpecialValueInt('radius')),false,BOT_MODE_NONE)) do candidates[#candidates+1]=ally end
    for _,ally in ipairs(candidates) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not ally:HasModifier('modifier_sven_warcry') then
            for _,u in pairs(J.GetNearbyHeroes(ally,900,true,BOT_MODE_NONE)) do
                if J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) and J.CanBeAttacked(u)
                    and (u:GetAttackTarget()==ally or ally:WasRecentlyDamagedByAnyHero(1.5) and J.IsChasingTarget(u,ally)
                        or ally:GetAttackTarget()==u and not ally:IsDisarmed()) then return BOT_ACTION_DESIRE_HIGH end
            end
        end
    end
    return 0
end
function X.ConsiderR(a)
    a=a or bot:GetAbilityByName('sven_gods_strength')
    if not J.CanCastAbility(a) or bot:IsDisarmed() or bot:HasModifier('modifier_sven_gods_strength') then return 0 end
    local target=J.GetProperTarget(bot)
    if Enemy(target) and J.CanBeAttacked(target) and not target:HasModifier('modifier_item_blade_mail_reflect') and J.IsGoingOnSomeone(bot)
        and GetUnitToUnitDistance(bot,target)<=700 and J.GetHP(target)>0.25 then
        local hammer=bot:GetAbilityByName('sven_storm_bolt')
        if GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange()+100 or J.CanCastAbility(hammer) and bot:GetMana()>=a:GetManaCost()+hammer:GetManaCost() then return BOT_ACTION_DESIRE_HIGH end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target) and J.CanBeAttacked(target)
        and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange()+100 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsFarming(bot) and #J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)==0 and J.GetMP(bot)>0.5 then
        local cleave=bot:GetAbilityByName('sven_great_cleave')
        local creeps=bot:GetNearbyNeutralCreeps(500)
        if cleave~=nil and not cleave:IsNull() and cleave:IsTrained() and not J.HasBreakModifier(bot) and #creeps>=4 then
            local hp=0
            for _,u in ipairs(creeps) do if J.IsValid(u) then hp=hp+u:GetHealth() end end
            if hp>bot:GetAttackDamage()*15 then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    return 0
end
local decisions={sven_storm_bolt=X.ConsiderQ,sven_warcry=X.ConsiderE,sven_gods_strength=X.ConsiderR}
function X.ConsiderStolenSpell(a)
    local consider=decisions[a:GetName()]
    if consider==nil then return nil end
    bot=GetBot()
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a) then return false end
    local desire,target=consider(a)
    if desire<=0 then return false end
    J.SetQueuePtToINT(bot,true,a)
    if a:GetName()=='sven_storm_bolt' then bot:ActionQueue_UseAbilityOnEntity(a,target) else bot:ActionQueue_UseAbility(a) end
    return true
end
return X
