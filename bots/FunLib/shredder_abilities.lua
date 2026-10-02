local M={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bladeIntent={}
local function distance(a,b) return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end
function M.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and not item:IsNull() and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
local function enemy(unit)
    return J.IsValid(unit) and unit:CanBeSeen() and J.CanCastOnNonMagicImmune(unit)
        and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave')
        and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace') and not unit:HasModifier('modifier_item_blade_mail_reflect')
end
local function peel(bot,unit)
    for _,ally in pairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do if J.IsValidHero(ally) and unit:GetAttackTarget()==ally and J.GetHP(ally)<.5 then return true end end
    return J.IsRetreating(bot) and unit:GetAttackTarget()==bot
end
local function creeps(bot,range)
    local list,seen={},{}
    for _,unit in pairs(bot:GetNearbyCreeps(math.min(range,1600),true)) do list[#list+1]=unit;seen[unit]=true end
    if J.IsFarming(bot) then for _,unit in pairs(bot:GetNearbyNeutralCreeps(math.min(range,1600))) do if not seen[unit] then list[#list+1]=unit end end end
    return list
end
function M.Whirl(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0 end
    local radius=ability:GetSpecialValueInt('whirling_radius');local trees=0
    for _,id in pairs(bot:GetNearbyTrees(radius)) do if distance(bot:GetLocation(),GetTreeLocation(id))<=radius then trees=trees+1 end end
    local damage=ability:GetSpecialValueInt('whirling_damage')+trees*ability:GetSpecialValueInt('tree_damage_scale')
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and (J.WillKillTarget(unit,damage,DAMAGE_TYPE_PURE,ability:GetCastPoint()) or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
            or J.IsInTeamFight(bot,1200) or peel(bot,unit)) then return BOT_ACTION_DESIRE_HIGH end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        local count=0;for _,unit in pairs(creeps(bot,radius)) do if enemy(unit) and not unit:HasModifier('modifier_fountain_glyph') then
            count=count+1
            if J.IsLaning(bot) and string.find(unit:GetUnitName(),'ranged') and J.WillKillTarget(unit,damage,DAMAGE_TYPE_PURE,ability:GetCastPoint()) and not J.IsAllysTarget(unit) then return BOT_ACTION_DESIRE_HIGH end
        end end
        if count>=3 and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then return BOT_ACTION_DESIRE_HIGH end
        local target=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target)) and enemy(target) and J.IsInRange(bot,target,radius) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
local function canMove(bot)
    return not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture') and not bot:HasModifier('modifier_slark_pounce_leash')
        and not bot:HasModifier('modifier_puck_coiled') and not bot:HasModifier('modifier_grimstroke_soul_chain')
end
local function safe(bot,point)
    if not IsLocationPassable(point) then return false end
    local foes,friends=0,1
    for _,unit in pairs(J.GetEnemiesNearLoc(point,650)) do if J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit) then foes=foes+1 end end
    for _,unit in pairs(J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)) do if J.IsValidHero(unit) and not unit:IsIllusion() and GetUnitToLocationDistance(unit,point)<=900 then friends=friends+1 end end
    for _,tower in pairs(bot:GetNearbyTowers(1600,true)) do if J.IsValid(tower) and GetUnitToLocationDistance(tower,point)<=tower:GetAttackRange()+100 then return false end end
    return foes<=friends+1
end
local function segmentDistance(point,origin,endpoint)
    local dx,dy=endpoint.x-origin.x,endpoint.y-origin.y;local length2=dx*dx+dy*dy
    if length2==0 then return distance(point,origin),0 end
    local fraction=math.max(0,math.min(1,((point.x-origin.x)*dx+(point.y-origin.y)*dy)/length2))
    return distance(point,Vector(origin.x+dx*fraction,origin.y+dy*fraction,0)),fraction
end
function M.Chain(bot,ability)
    if not J.CanCastAbility(ability) or not canMove(bot) then return 0,nil end
    local range=ability:GetCastRange();local trees=bot:GetNearbyTrees(range);local origin=bot:GetLocation()
    local escape=J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) or J.IsStuck(bot)
    local best,score=nil,-1
    for _,id in pairs(trees) do
        local requested=GetTreeLocation(id);local length=distance(origin,requested)
        if length>200 and length<=range then
            local first,firstDistance=requested,length
            for _,other in pairs(trees) do
                local location=GetTreeLocation(other);local separation,fraction=segmentDistance(location,origin,requested)
                local along=fraction*length
                if separation<=ability:GetSpecialValueInt('chain_radius') and along>0 and along<firstDistance then first=location;firstDistance=along end
            end
            if safe(bot,first) then
                if escape then
                    local gain=GetUnitToUnitDistance(bot,GetAncient(GetTeam()))-GetUnitToLocationDistance(GetAncient(GetTeam()),first)
                    if gain>200 and gain>score then best=requested;score=gain end
                elseif J.GetHP(bot)>.35 then
                    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range+ability:GetSpecialValueInt('radius'),1600),true,BOT_MODE_NONE)) do
                        if enemy(unit) then
                            local delay=ability:GetCastPoint()+distance(origin,first)/ability:GetSpecialValueInt('speed')+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('speed')
                            local separation=segmentDistance(unit:GetExtrapolatedLocation(delay),origin,first)
                            if separation<=ability:GetSpecialValueInt('radius') and (J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                                or J.IsInTeamFight(bot,1200) or peel(bot,unit) or J.WillKillTarget(unit,ability:GetSpecialValueInt('damage'),DAMAGE_TYPE_PURE,delay)) then
                                local value=range-distance(first,unit:GetLocation())
                                if value>score then best=requested;score=value end
                            end
                        end
                    end
                end
            end
        end
    end
    if best then return BOT_ACTION_DESIRE_HIGH,best end
    return 0,nil
end
function M.Armor(bot,ability)
    if not J.CanCastAbility(ability) or ability:IsPassive() or ability:GetSpecialValueInt('initial_shield')<=0 or bot:HasModifier('modifier_shredder_reactive_armor_bomb') then return 0 end
    for _,unit in pairs(J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)) do
        if J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit) and (unit:GetAttackTarget()==bot
            or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) and J.IsInRange(bot,unit,ability:GetSpecialValueInt('radius'))) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function M.Chakram(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability);local speed=ability:GetSpecialValueInt('speed')
    local twisted=ability:GetName()=='shredder_twisted_chakram'
    for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if enemy(unit) and J.IsInRange(bot,unit,range) then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/speed
            local point=unit:GetExtrapolatedLocation(delay)
            if GetUnitToLocationDistance(bot,point)<=range and (J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                or J.IsInTeamFight(bot,1200) or peel(bot,unit)
                or not twisted and J.WillKillTarget(unit,ability:GetSpecialValueInt('pass_damage'),DAMAGE_TYPE_PURE,delay)) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        local list=creeps(bot,range)
        if #list>=3 and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and enemy(list[1]) and not list[1]:HasModifier('modifier_fountain_glyph') then return BOT_ACTION_DESIRE_HIGH,list[1]:GetLocation() end
        for _,unit in pairs(list) do if not twisted and J.IsLaning(bot) and enemy(unit) and string.find(unit:GetUnitName(),'ranged') and not unit:HasModifier('modifier_fountain_glyph') and not J.IsAllysTarget(unit)
            and J.WillKillTarget(unit,ability:GetSpecialValueInt('pass_damage'),DAMAGE_TYPE_PURE,ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/speed) then return BOT_ACTION_DESIRE_HIGH,unit:GetLocation() end end
    end
    return 0,nil
end
function M.RecordChakram(bot,source,point)
    bladeIntent[source:GetName()]={bot=bot,source=source,point=point,time=DotaTime()}
end
function M.Return(bot,ability)
    if not J.CanCastAbility(ability) then return 0 end
    local name=ability:GetName()=='shredder_return_chakram_2' and 'shredder_chakram_2' or 'shredder_chakram'
    local source=bot:GetAbilityByName(name)
    if not source or source:IsNull() or not source:IsTrained() then return 0 end
    for _,projectile in pairs(GetLinearProjectiles()) do if projectile.ability==source and projectile.caster==bot then return 0 end end
    local point=nil
    for _,zone in pairs(GetAvoidanceZones()) do if zone.ability==source and zone.caster==bot then point=zone.location;break end end
    if not point then
        local intent=bladeIntent[name];local index=bot:GetModifierByName('modifier_shredder_chakram_disarm')
        if not intent or intent.bot~=bot or intent.source~=source or index<0 or bot:GetModifierSourceAbility(index)~=source
            or not source:IsHidden() or DotaTime()<intent.time+source:GetCastPoint()+distance(bot:GetLocation(),intent.point)/source:GetSpecialValueInt('speed') then return 0 end
        point=intent.point
    end
    local count=0
    for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do if enemy(unit) and GetUnitToLocationDistance(unit,point)<=source:GetSpecialValueInt('radius') then count=count+1 end end
    for _,unit in pairs(bot:GetNearbyNeutralCreeps(1600)) do if enemy(unit) and GetUnitToLocationDistance(unit,point)<=source:GetSpecialValueInt('radius') then count=count+1 end end
    local reserve=source:GetSpecialValueInt('mana_per_second')*2
    local chain=bot:GetAbilityByName('shredder_timber_chain');if chain and not chain:IsNull() and chain:IsTrained() and not chain:IsHidden() and chain:IsActivated() then reserve=reserve+chain:GetManaCost() end
    if count==0 or bot:GetMana()<=reserve or GetUnitToLocationDistance(bot,point)>source:GetSpecialValueInt('break_distance')-100 then bladeIntent[name]=nil;return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local function inFlame(bot,unit,ability)
    local origin=bot:GetLocation();local point=unit:GetLocation();local facing=bot:GetFacing()*math.pi/180
    local dx,dy=point.x-origin.x,point.y-origin.y;local along=dx*math.cos(facing)+dy*math.sin(facing)
    return along>=0 and along<=ability:GetSpecialValueInt('length') and math.abs(dx*math.sin(facing)-dy*math.cos(facing))<=ability:GetSpecialValueInt('width')*.5
end
function M.Flame(bot,ability,native)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_shredder_flamethrower') then return 0 end
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(ability:GetSpecialValueInt('length')+ability:GetSpecialValueInt('width'),1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and inFlame(bot,unit,ability) and (J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200) or peel(bot,unit)) then return BOT_ACTION_DESIRE_HIGH end
    end
    if native then
        if (J.IsFarming(bot) or J.IsDefending(bot) or J.IsPushing(bot)) and J.IsAllowedToSpam(bot,ability:GetManaCost()) then local count=0;for _,unit in pairs(creeps(bot,700)) do if enemy(unit) and inFlame(bot,unit,ability) and not unit:HasModifier('modifier_fountain_glyph') then count=count+1 end end;if count>=3 then return BOT_ACTION_DESIRE_HIGH end end
        if J.IsPushing(bot) then for _,tower in pairs(bot:GetNearbyTowers(700,true)) do if J.IsValidBuilding(tower) and inFlame(bot,tower,ability) and not tower:HasModifier('modifier_fountain_glyph') and not tower:HasModifier('modifier_backdoor_protection') and not tower:HasModifier('modifier_backdoor_protection_active') then return BOT_ACTION_DESIRE_HIGH end end end
    end
    return 0
end
function M.UseDuringChain(bot,native)
    if not bot:IsAlive() or bot:IsInvulnerable() or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsCastingAbility()
        or bot:IsChanneling() or bot:NumQueuedActions()>0 or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local chain=bot:GetAbilityByName('shredder_timber_chain');local index=bot:GetModifierByName('modifier_shredder_timber_chain')
    if not chain or chain:IsNull() or not chain:IsTrained() or chain:IsHidden() or not chain:IsActivated() or index<0 or bot:GetModifierSourceAbility(index)~=chain then return false end
    local active=bot:GetCurrentActiveAbility();if active and active~=chain then return false end
    local whirl=bot:GetAbilityByName('shredder_whirling_death')
    if M.Whirl(bot,whirl,native)>0 then bot:Action_UseAbility(whirl);return true end
    local flame=bot:GetAbilityByName('shredder_flamethrower')
    if M.Flame(bot,flame,native)>0 then bot:Action_UseAbility(flame);return true end
    return false
end
return M
