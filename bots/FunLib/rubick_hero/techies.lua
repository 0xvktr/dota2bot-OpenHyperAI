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
        and not u:HasModifier('modifier_nyx_assassin_spiked_carapace') and not u:HasModifier('modifier_item_blade_mail_reflect')
end
local function Safe(p)
    return IsLocationPassable(p) and not J.IsLocationInChrono(p) and not J.IsLocationInBlackHole(p)
        and not J.IsLocHaveTower(700,true,p) and #J.GetEnemiesNearLoc(p,1000)<=#J.GetAlliesNearLoc(p,1000)+1
end
local function Clamp(p,range)
    if GetUnitToLocationDistance(bot,p)>range then return bot:GetLocation()+(p-bot:GetLocation()):Normalized()*range end
    return p
end
local function OwnUnits(name)
    local result={}
    for _,u in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if u~=nil and not u:IsNull() and u:IsAlive() and u:GetTeam()==bot:GetTeam()
            and u:GetUnitName()==name and u:GetPlayerID()==bot:GetPlayerID() then result[#result+1]=u end
    end
    return result
end
function X.ConsiderStickyBomb()
    local a=bot:GetAbilityByName('techies_sticky_bomb')
    if not J.CanCastAbility(a) then return 0 end
    local range=X.Range(a)
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range+a:GetSpecialValueInt('radius')),true,BOT_MODE_NONE)) do
        if Enemy(u) then
            local travel=J.GetETAWithAcceleration(GetUnitToUnitDistance(bot,u),a:GetSpecialValueInt('speed'),a:GetSpecialValueInt('acceleration'))
            local delay=a:GetCastPoint()+travel+a:GetSpecialValueFloat('countdown')
            local p=Clamp(J.GetCorrectLoc(u,a:GetCastPoint()+travel),range)
            local predicted=J.GetCorrectLoc(u,a:GetCastPoint()+travel)
            local helpful=J.WillKillTarget(u,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,delay)
                or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)
            if not helpful then
                local ally=u:GetAttackTarget()
                helpful=J.IsValidHero(ally) and ally:GetTeam()==bot:GetTeam() and ally:WasRecentlyDamagedByAnyHero(1.5)
            end
            if helpful and (predicted-p):Length2D()<=a:GetSpecialValueInt('radius') then return BOT_ACTION_DESIRE_HIGH,p end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.GetMP(bot)>0.35 then
        local creeps=bot:GetNearbyLaneCreeps(math.min(1600,range),true)
        if #creeps<3 and J.IsFarming(bot) then creeps=bot:GetNearbyNeutralCreeps(math.min(1600,range)) end
        for _,u in ipairs(creeps) do
            if J.IsValid(u) and J.CanCastOnNonMagicImmune(u) and not u:HasModifier('modifier_fountain_glyph') then
                local hits=0
                for _,other in ipairs(creeps) do if J.IsValid(other) and GetUnitToUnitDistance(u,other)<=a:GetSpecialValueInt('explosion_radius') then hits=hits+1 end end
                if hits>=3 or hits>=2 and J.IsFarming(bot) then return BOT_ACTION_DESIRE_HIGH,u:GetLocation() end
            end
        end
    end
    return 0
end
function X.ConsiderReactiveTazer()
    local a=bot:GetAbilityByName('techies_reactive_tazer')
    if not J.CanCastAbility(a) then return 0 end
    local candidates={bot}
    for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),false,BOT_MODE_NONE)) do candidates[#candidates+1]=ally end
    for _,ally in ipairs(candidates) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and GetUnitToUnitDistance(bot,ally)<=X.Range(a)
            and not ally:HasModifier('modifier_techies_reactive_tazer') then
            for _,u in pairs(J.GetNearbyHeroes(ally,900,true,BOT_MODE_NONE)) do
                if Enemy(u) and not u:IsDisarmed() and (u:GetAttackTarget()==ally or J.IsChasingTarget(u,ally) and ally:WasRecentlyDamagedByAnyHero(1.5)) then return BOT_ACTION_DESIRE_HIGH,ally end
            end
        end
    end
    return 0
end
function X.ConsiderReactiveTazerStop()
    local stop=bot:GetAbilityByName('techies_reactive_tazer_stop')
    local a=bot:GetAbilityByName('techies_reactive_tazer')
    if not J.CanCastAbility(stop) or a==nil or a:IsNull() then return 0 end
    local candidates={bot}
    for _,ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do candidates[#candidates+1]=ally end
    for _,ally in ipairs(candidates) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and ally:HasModifier('modifier_techies_reactive_tazer') then
            local i=ally:GetModifierByName('modifier_techies_reactive_tazer')
            local source=i>=0 and ally:GetModifierSourceAbility(i) or nil
            if source==a and source:GetCaster()==bot then
                for _,u in pairs(J.GetNearbyHeroes(ally,math.min(1600,a:GetSpecialValueInt('explosion_radius')),true,BOT_MODE_NONE)) do
                    if Enemy(u) and not u:IsDisarmed() then return BOT_ACTION_DESIRE_HIGH end
                end
            end
        end
    end
    return 0
end
function X.ConsiderBlastOff()
    local a=bot:GetAbilityByName('techies_suicide')
    if not J.CanCastAbility(a) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_puck_coiled') then return 0 end
    local range=X.Range(a)
    local delay=a:GetCastPoint()+a:GetSpecialValueFloat('duration')
    if J.IsStuck(bot) or J.IsRetreating(bot) and #J.GetNearbyHeroes(bot,600,true,BOT_MODE_NONE)>0 and bot:WasRecentlyDamagedByAnyHero(2) then
        local p=Clamp(J.GetEscapeLoc(),range)
        if Safe(p) then return BOT_ACTION_DESIRE_HIGH,p end
    end
    if bot:GetHealth()*(1-a:GetSpecialValueInt('hp_cost')/100)<bot:GetMaxHealth()*0.25 then return 0 end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range+a:GetSpecialValueInt('radius')),true,BOT_MODE_NONE)) do
        if Enemy(u) then
            local p=Clamp(J.GetCorrectLoc(u,delay),range)
            local interrupt=u:IsChanneling()
            if interrupt and u:HasModifier('modifier_teleporting') then
                local i=u:GetModifierByName('modifier_teleporting');interrupt=i>=0 and u:GetModifierRemainingDuration(i)>delay
            end
            if (J.GetCorrectLoc(u,delay)-p):Length2D()<=a:GetSpecialValueInt('radius') and Safe(p)
                and (interrupt or J.WillKillTarget(u,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,delay)
                    or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)) then return BOT_ACTION_DESIRE_HIGH,p end
        end
    end
    return 0
end
function X.MinePoint(a,target)
    local radius=a:GetSpecialValueInt('placement_radius')
    local pending=bot.techiesMinePending or {}
    for i=#pending,1,-1 do if DotaTime()>pending[i].expires then table.remove(pending,i) end end
    bot.techiesMinePending=pending
    local offsets={Vector(0,0),Vector(radius+10,0),Vector(-radius-10,0),Vector(0,radius+10),Vector(0,-radius-10)}
    for _,offset in ipairs(offsets) do
        local p=Clamp(target+offset,X.Range(a))
        local legal=IsLocationPassable(p) and (p-target):Length2D()<a:GetSpecialValueInt('radius')
        for _,request in ipairs(pending) do if (p-request.point):Length2D()<=radius then legal=false end end
        for _,mine in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
            if mine~=nil and not mine:IsNull() and mine:IsAlive() and mine:GetTeam()==bot:GetTeam() and mine:GetUnitName()=='npc_dota_techies_land_mine'
                and GetUnitToLocationDistance(mine,p)<=radius then legal=false end
        end
        if legal then return p end
    end
    return nil
end
function X.ConsiderProximityMines()
    local a=bot:GetAbilityByName('techies_land_mines')
    if not J.CanCastAbility(a) or a:GetCurrentCharges()<=0 then return 0 end
    local delay=a:GetCastPoint()+a:GetSpecialValueFloat('activation_delay')+a:GetSpecialValueFloat('proximity_threshold')
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)+a:GetSpecialValueInt('radius')),true,BOT_MODE_NONE)) do
        if Enemy(u) and (J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)) then
            local predicted=J.GetCorrectLoc(u,delay)
            local p=X.MinePoint(a,predicted)
            if p~=nil then
                local damage=a:GetSpecialValueInt('damage')
                if (predicted-p):Length2D()>a:GetSpecialValueInt('min_distance') then damage=damage*a:GetSpecialValueInt('outer_damage')/100 end
                if J.IsDisabled(u) or u:IsDisarmed() or J.WillKillTarget(u,damage,DAMAGE_TYPE_MAGICAL,delay) then return BOT_ACTION_DESIRE_HIGH,p end
            end
        end
    end
    local reserve=0
    for _,name in ipairs({'techies_reactive_tazer','techies_suicide'}) do
        local other=bot:GetAbilityByName(name)
        if other~=nil and not other:IsNull() and other:IsTrained() then reserve=reserve+other:GetManaCost() end
    end
    if J.IsFarming(bot) and a:GetCurrentCharges()>1 and bot:GetMana()>a:GetManaCost()+reserve and #J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)==0 then
        local creeps=bot:GetNearbyNeutralCreeps(math.min(1600,X.Range(a)))
        if #creeps<3 then creeps=bot:GetNearbyLaneCreeps(math.min(1600,X.Range(a)),true) end
        if #creeps>=3 and J.IsValid(creeps[1]) and not creeps[1]:HasModifier('modifier_fountain_glyph') then
            local p=X.MinePoint(a,creeps[1]:GetLocation())
            if p~=nil then return BOT_ACTION_DESIRE_HIGH,p end
        end
    end
    if J.IsDefending(bot) and a:GetCurrentCharges()>1 and bot:GetMana()>a:GetManaCost()+reserve then
        local p=X.MinePoint(a,bot:GetLocation())
        if p~=nil then return BOT_ACTION_DESIRE_HIGH,p end
    end
    return 0
end
function X.ConsiderMineFieldSign()
    local a=bot:GetAbilityByName('techies_minefield_sign')
    if not J.CanCastAbility(a) or not Safe(bot:GetLocation()) or bot:HasModifier('modifier_techies_minefield_sign_aura') then return 0 end
    local count=0
    for _,mine in pairs(OwnUnits('npc_dota_techies_land_mine')) do if GetUnitToUnitDistance(bot,mine)<=a:GetSpecialValueInt('aura_radius') then count=count+1 end end
    if count>=2 then return BOT_ACTION_DESIRE_HIGH,bot:GetLocation() end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,a:GetSpecialValueInt('trigger_radius')),true,BOT_MODE_NONE)) do
        if Enemy(u) and J.IsDisabled(u) then return BOT_ACTION_DESIRE_HIGH,bot:GetLocation() end
    end
    return 0
end
function X.ConsiderMAD()
    local a=bot:GetAbilityByName('techies_mutually_assured_destruction')
    if not J.CanCastAbility(a) or #OwnUnits('npc_dota_techies_innate_mine')>0 then return 0 end
    if bot.techiesMADPending~=nil and DotaTime()<bot.techiesMADPending then return 0 end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)+a:GetSpecialValueInt('radius')),true,BOT_MODE_NONE)) do
        if Enemy(u) and J.IsDisabled(u) and J.IsGoingOnSomeone(bot) then
            local p=Clamp(J.GetCorrectLoc(u,a:GetCastPoint()),X.Range(a))
            if (u:GetLocation()-p):Length2D()<=a:GetSpecialValueInt('radius') then return BOT_ACTION_DESIRE_HIGH,p end
        end
    end
    return 0
end
function X.ConsiderMADDetonate()
    local detonate=bot:GetAbilityByName('techies_focused_detonate')
    local a=bot:GetAbilityByName('techies_mutually_assured_destruction')
    if not J.CanCastAbility(detonate) or a==nil or a:IsNull() or not a:IsTrained() or a:IsPassive() then return 0 end
    for _,mine in pairs(OwnUnits('npc_dota_techies_innate_mine')) do
        for _,u in pairs(J.GetNearbyHeroes(mine,math.min(1600,a:GetSpecialValueInt('radius')),true,BOT_MODE_NONE)) do
            local p=J.GetCorrectLoc(u,a:GetSpecialValueFloat('explosion_delay'))
            if Enemy(u) and GetUnitToLocationDistance(mine,p)<=a:GetSpecialValueInt('radius') then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    return 0
end
local decisions={techies_sticky_bomb=X.ConsiderStickyBomb,techies_reactive_tazer=X.ConsiderReactiveTazer,techies_reactive_tazer_stop=X.ConsiderReactiveTazerStop,
    techies_suicide=X.ConsiderBlastOff,techies_land_mines=X.ConsiderProximityMines,techies_minefield_sign=X.ConsiderMineFieldSign,
    techies_mutually_assured_destruction=X.ConsiderMAD,techies_focused_detonate=X.ConsiderMADDetonate}
local function Cast(a,target)
    J.SetQueuePtToINT(bot,true,a)
    if a:GetName()=='techies_reactive_tazer' then bot:ActionQueue_UseAbilityOnEntity(a,target)
    elseif a:GetName()=='techies_reactive_tazer_stop' or a:GetName()=='techies_focused_detonate' then bot:ActionQueue_UseAbility(a)
    else bot:ActionQueue_UseAbilityOnLocation(a,target) end
    if a:GetName()=='techies_land_mines' then
        bot.techiesMinePending=bot.techiesMinePending or {}
        table.insert(bot.techiesMinePending,{point=target,expires=DotaTime()+3})
    end
    if a:GetName()=='techies_mutually_assured_destruction' then bot.techiesMADPending=DotaTime()+a:GetCastPoint()+2 end
end
function X.ConsiderStolenSpell(a)
    local consider=decisions[a:GetName()]
    if consider==nil then return nil end
    bot=GetBot()
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a) then return false end
    local desire,target=consider()
    if desire<=0 then return false end
    Cast(a,target);return true
end
function X.UseNative()
    bot=GetBot()
    if J.CanNotUseAbility(bot) then return false end
    for _,name in ipairs({'techies_focused_detonate','techies_reactive_tazer_stop','techies_reactive_tazer','techies_suicide','techies_sticky_bomb','techies_mutually_assured_destruction','techies_land_mines','techies_minefield_sign'}) do
        local a=bot:GetAbilityByName(name)
        if J.CanCastAbility(a) then
            local desire,target=decisions[name]()
            if desire>0 then
                if name=='techies_suicide' and not J.IsRetreating(bot) then
                    local tazer=bot:GetAbilityByName('techies_reactive_tazer')
                    if J.CanCastAbility(tazer) and not bot:HasModifier('modifier_techies_reactive_tazer') and bot:GetMana()>=a:GetManaCost()+tazer:GetManaCost() then Cast(tazer,bot);return true end
                end
                Cast(a,target);return true
            end
        end
    end
    return false
end
return X
