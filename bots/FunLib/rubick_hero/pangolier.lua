local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,Swashbuckle,ShieldCrash,RollUp,EndRollUp,RollingThunder,EndRollingThunder
local function Refresh()
    bot=GetBot();Swashbuckle=bot:GetAbilityByName('pangolier_swashbuckle');ShieldCrash=bot:GetAbilityByName('pangolier_shield_crash')
    RollUp=bot:GetAbilityByName('pangolier_rollup');EndRollUp=bot:GetAbilityByName('pangolier_rollup_stop')
    RollingThunder=bot:GetAbilityByName('pangolier_gyroshell');EndRollingThunder=bot:GetAbilityByName('pangolier_gyroshell_stop')
end
local function Facing()
    local radians=bot:GetFacing()*math.pi/180
    return Vector(math.cos(radians),math.sin(radians),0)
end
local function MobilityBlocked()
    return bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture')
        or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled')
        or bot:HasModifier('modifier_grimstroke_soul_chain')
end
local function Enemy(enemy,pierce)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
        and (pierce and J.CanCastOnMagicImmune(enemy) or not pierce and J.CanCastOnNonMagicImmune(enemy))
end
local function SwashLocation(target)
    local dash=math.min(Swashbuckle:GetCastRange(),Swashbuckle:GetSpecialValueInt('dash_range'))
    local slash=Swashbuckle:GetSpecialValueInt('range')
    local direction=Facing()
    local predicted=J.GetCorrectLoc(target,Swashbuckle:GetCastPoint()+Swashbuckle:GetSpecialValueInt('strikes')*Swashbuckle:GetSpecialValueFloat('attack_interval'))
    local delta=predicted-bot:GetLocation()
    local forward=delta.x*direction.x+delta.y*direction.y
    local side=math.abs(delta.x*direction.y-delta.y*direction.x)
    if forward<0 or forward>dash+slash or side>Swashbuckle:GetSpecialValueInt('start_radius') then return nil end
    local step=math.max(0,forward-slash+25)
    if step>dash then step=dash end
    local point=bot:GetLocation()+direction*step
    if IsLocationPassable(point) and not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point)
        and (step==0 or not J.IsLocHaveTower(700,true,point)) then return point end
    return nil
end
function X.ConsiderSwashbuckle()
    if not J.CanCastAbility(Swashbuckle) or MobilityBlocked()
        or bot:HasModifier('modifier_pangolier_gyroshell') or bot:HasModifier('modifier_pangolier_rollup')
        or bot:HasModifier('modifier_pangolier_swashbuckle_stunned') then return 0 end
    local dash=math.min(Swashbuckle:GetCastRange(),Swashbuckle:GetSpecialValueInt('dash_range'))
    if (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) or J.IsStuck(bot) then
        local delta=J.GetEscapeLoc()-bot:GetLocation()
        if delta:Length2D()>0 then
            local p=bot:GetLocation()+delta:Normalized()*dash
            if IsLocationPassable(p) and not J.IsLocationInChrono(p) and not J.IsLocationInBlackHole(p) then return BOT_ACTION_DESIRE_HIGH,p end
        end
    end
    local damage=(Swashbuckle:GetSpecialValueInt('damage')+bot:GetAttackDamage()*Swashbuckle:GetSpecialValueFloat('attack_damage')/100)*Swashbuckle:GetSpecialValueInt('strikes')
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if Enemy(enemy,true) and not J.CannotBeKilled(bot,enemy) and not enemy:HasModifier('modifier_item_blade_mail_reflect')
            and not enemy:HasModifier('modifier_nyx_assassin_spiked_carapace') then
            local p=SwashLocation(enemy)
            if p~=nil and J.WillKillTarget(enemy,damage,DAMAGE_TYPE_PHYSICAL,Swashbuckle:GetCastPoint()+0.3) then return BOT_ACTION_DESIRE_HIGH,p end
        end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target,true) and not J.CannotBeKilled(bot,target)
        and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace') then
        local p=SwashLocation(target)
        if p~=nil then return BOT_ACTION_DESIRE_HIGH,p end
    end
    if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and J.IsAllowedToSpam(bot,Swashbuckle:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(1600,true)
        for _,creep in ipairs(creeps) do
            if J.IsValid(creep) then
                local p=SwashLocation(creep)
                if p~=nil then
                    local hits,kills=0,0
                    for _,other in ipairs(creeps) do
                        if J.IsValid(other) and J.CanCastOnMagicImmune(other) then
                            local delta=J.GetCorrectLoc(other,Swashbuckle:GetCastPoint()+0.3)-p
                            local d=Facing();local forward=delta.x*d.x+delta.y*d.y
                            if forward>=0 and forward<=Swashbuckle:GetSpecialValueInt('range')
                                and math.abs(delta.x*d.y-delta.y*d.x)<=Swashbuckle:GetSpecialValueInt('start_radius') then
                                hits=hits+1
                                if J.WillKillTarget(other,damage,DAMAGE_TYPE_PHYSICAL,Swashbuckle:GetCastPoint()+0.3) and not J.IsOtherAllysTarget(other) then kills=kills+1 end
                            end
                        end
                    end
                    if kills>=2 or not J.IsLaning(bot) and hits>=3 then return BOT_ACTION_DESIRE_HIGH,p end
                end
            end
        end
    end
    return 0
end
local function CrashCenter()
    if bot:HasModifier('modifier_pangolier_gyroshell') then return J.GetCorrectLoc(bot,ShieldCrash:GetSpecialValueFloat('jump_duration_gyroshell')) end
    return bot:GetLocation()+Facing()*ShieldCrash:GetSpecialValueInt('jump_horizontal_distance')
end
function X.ConsiderShieldCrash()
    if not J.CanCastAbility(ShieldCrash) or bot:HasModifier('modifier_bloodseeker_rupture') then return 0 end
    local p=CrashCenter()
    if not IsLocationPassable(p) or J.IsLocationInChrono(p) or J.IsLocationInBlackHole(p) then return 0 end
    local delay=bot:HasModifier('modifier_pangolier_gyroshell') and ShieldCrash:GetSpecialValueFloat('jump_duration_gyroshell') or ShieldCrash:GetSpecialValueFloat('jump_duration')
    local hits=0
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)) do
        if Enemy(enemy,false) and (J.GetCorrectLoc(enemy,delay)-p):Length2D()<=ShieldCrash:GetSpecialValueInt('radius') then
            if not J.CannotBeKilled(bot,enemy) and J.WillKillTarget(enemy,ShieldCrash:GetSpecialValueInt('damage'),DAMAGE_TYPE_PHYSICAL,delay) then return BOT_ACTION_DESIRE_HIGH end
            hits=hits+1
        end
    end
    if hits>=2 or hits>=1 and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot) or bot:HasModifier('modifier_pangolier_gyroshell')) then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot)) and J.IsAllowedToSpam(bot,ShieldCrash:GetManaCost()) then
        local kills,hitsCreep=0,0
        for _,creep in ipairs(bot:GetNearbyCreeps(1200,true)) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and (J.GetCorrectLoc(creep,delay)-p):Length2D()<=ShieldCrash:GetSpecialValueInt('radius') then
                hitsCreep=hitsCreep+1
                if J.WillKillTarget(creep,ShieldCrash:GetSpecialValueInt('damage'),DAMAGE_TYPE_PHYSICAL,delay) and not J.IsOtherAllysTarget(creep) then kills=kills+1 end
            end
        end
        if kills>=2 or not J.IsLaning(bot) and hitsCreep>=3 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function X.ConsiderRollingThunder()
    if not J.CanCastAbility(RollingThunder) or MobilityBlocked() or bot:HasModifier('modifier_pangolier_gyroshell') then return 0 end
    local enemies=J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)
    local hits=0
    for _,enemy in ipairs(enemies) do if Enemy(enemy,false) then hits=hits+1 end end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and J.GetHP(bot)<0.6 and #enemies>0 then return BOT_ACTION_DESIRE_HIGH end
    local target=J.GetProperTarget(bot)
    if J.IsInTeamFight(bot,1200) and hits>=2 or J.IsGoingOnSomeone(bot) and Enemy(target,false)
        and J.IsInRange(bot,target,1000) and J.GetHP(bot)>0.35 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderEndRollingThunder()
    if not J.CanCastAbility(EndRollingThunder) or not bot:HasModifier('modifier_pangolier_gyroshell') then return 0 end
    if bot:HasModifier('modifier_bloodseeker_rupture') then return BOT_ACTION_DESIRE_HIGH end
    -- Keep the escape movement until safe rather than cancelling when pursuers lose vision.
    if not J.IsRetreating(bot) and #J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)==0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderRollUp()
    if not J.CanCastAbility(RollUp) or bot:HasModifier('modifier_pangolier_rollup') then return 0 end
    if J.IsUnitTargetProjectileIncoming(bot,400) or J.IsWillBeCastUnitTargetSpell(bot,1200) then return BOT_ACTION_DESIRE_HIGH end
    if J.CanCastAbility(RollingThunder) and not bot:HasModifier('modifier_pangolier_gyroshell')
        and bot:GetMana()>=RollUp:GetManaCost()+RollingThunder:GetManaCost() and X.ConsiderRollingThunder()>0
        and #J.GetNearbyHeroes(bot,700,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
    local target=J.GetProperTarget(bot)
    if bot:HasModifier('modifier_pangolier_gyroshell') and Enemy(target,false)
        and J.IsInRange(bot,target,800) and not bot:IsFacingLocation(target:GetLocation(),90) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderEndRollUp()
    if not J.CanCastAbility(EndRollUp) or not bot:HasModifier('modifier_pangolier_rollup') then return 0 end
    if J.IsUnitTargetProjectileIncoming(bot,400) or J.IsWillBeCastUnitTargetSpell(bot,1200) then return 0 end
    local target=J.GetProperTarget(bot)
    if bot:HasModifier('modifier_pangolier_gyroshell') and Enemy(target,false)
        and bot:IsFacingLocation(target:GetLocation(),15) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsRetreating(bot) and #J.GetNearbyHeroes(bot,500,true,BOT_MODE_NONE)==0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    if name~='pangolier_swashbuckle' and name~='pangolier_shield_crash' and name~='pangolier_rollup'
        and name~='pangolier_rollup_stop' and name~='pangolier_gyroshell' and name~='pangolier_gyroshell_stop' then return nil end
    Refresh()
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
    local choices={pangolier_swashbuckle=X.ConsiderSwashbuckle,pangolier_shield_crash=X.ConsiderShieldCrash,
        pangolier_rollup=X.ConsiderRollUp,pangolier_rollup_stop=X.ConsiderEndRollUp,
        pangolier_gyroshell=X.ConsiderRollingThunder,pangolier_gyroshell_stop=X.ConsiderEndRollingThunder}
    local desire,point=choices[name]()
    if desire<=0 then return false end
    if name=='pangolier_swashbuckle' then bot:Action_UseAbilityOnLocation(ability,point)
    else bot:Action_UseAbility(ability) end
    return true
end
return X
