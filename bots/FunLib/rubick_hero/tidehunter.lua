local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot=GetBot()
function X.Range(a)
 local range=a:GetCastRange()
 if a:GetName()=='tidehunter_gush' and bot:HasScepter() then range=math.max(range,a:GetSpecialValueInt('cast_range_scepter')) end
 local lens=J.IsItemAvailable('item_aether_lens')
 if lens~=nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
 local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
 if supremacy~=nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
 return range
end
local function Enemy(u)
 return J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u) and not J.CannotBeKilled(bot,u)
end
local function Follow(u)
 for _,ally in pairs(J.GetNearbyHeroes(u,1000,false,BOT_MODE_NONE)) do
  if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsDisarmed()
   and (ally:GetAttackTarget()==u and GetUnitToUnitDistance(ally,u)<=ally:GetAttackRange()+200 or u:GetAttackTarget()==ally) then return true end
 end
 return false
end
local function Useful(u)
 return J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsRetreating(bot) and J.IsChasingTarget(u,bot) or Follow(u)
end
local function Reserve(a)
 local ravage=bot:GetAbilityByName('tidehunter_ravage')
 return bot:GetMana()>=a:GetManaCost()+(ravage~=nil and not ravage:IsNull() and ravage:IsTrained() and ravage:GetManaCost() or 0)
end
function X.ConsiderQ()
 local a=bot:GetAbilityByName('tidehunter_gush')
 if not J.CanCastAbility(a) then return 0 end
 local range=X.Range(a)
 local upgraded=bot:HasScepter()
 local speed=upgraded and a:GetSpecialValueInt('speed_scepter') or a:GetSpecialValueInt('projectile_speed')
 for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
  if Enemy(u) and GetUnitToUnitDistance(bot,u)<=range and (upgraded or J.CanCastOnTargetAdvanced(u)) then
   local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/speed
   local p=J.GetCorrectLoc(u,delay)
   if GetUnitToLocationDistance(bot,p)<=range and (J.WillKillTarget(u,a:GetSpecialValueInt('gush_damage'),DAMAGE_TYPE_MAGICAL,delay)
    or Useful(u) and not u:HasModifier('modifier_tidehunter_gush')) then return BOT_ACTION_DESIRE_HIGH,upgraded and p or u end
  end
 end
 if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and Reserve(a) then
  local creeps=bot:GetNearbyLaneCreeps(math.min(1600,range),true)
  if upgraded then
   for _,u in ipairs(creeps) do
    local p=J.GetCorrectLoc(u,a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/speed)
    local dir=(p-bot:GetLocation()):Normalized()
    local count=0
    for _,c in ipairs(creeps) do
     local q=J.GetCorrectLoc(c,a:GetCastPoint()+GetUnitToUnitDistance(bot,c)/speed)-bot:GetLocation()
     local forward=q.x*dir.x+q.y*dir.y
     local side=math.abs(q.x*dir.y-q.y*dir.x)
     if J.IsValid(c) and J.CanCastOnNonMagicImmune(c) and not c:HasModifier('modifier_fountain_glyph') and forward>=0 and forward<=range and side<=a:GetSpecialValueInt('aoe_scepter') then count=count+1 end
    end
    if count>=3 and GetUnitToLocationDistance(bot,p)<=range then return BOT_ACTION_DESIRE_HIGH,p end
   end
  else
   for _,u in ipairs(creeps) do
    local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/speed
    if J.IsValid(u) and J.CanCastOnNonMagicImmune(u) and not u:HasModifier('modifier_fountain_glyph') and string.find(u:GetUnitName(),'ranged')
     and J.WillKillTarget(u,a:GetSpecialValueInt('gush_damage'),DAMAGE_TYPE_MAGICAL,delay)
     and not J.WillKillTarget(u,bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL,delay) then return BOT_ACTION_DESIRE_HIGH,u end
   end
  end
 end
 local target=J.GetProperTarget(bot)
 if J.IsDoingRoshan(bot) and J.IsRoshan(target) and J.CanCastOnNonMagicImmune(target) and GetUnitToUnitDistance(bot,target)<=range
  and (upgraded or J.CanCastOnTargetAdvanced(target)) and not target:HasModifier('modifier_tidehunter_gush') then
  return BOT_ACTION_DESIRE_HIGH,upgraded and target:GetLocation() or target
 end
 return 0
end
function X.ConsiderE()
 local a=bot:GetAbilityByName('tidehunter_anchor_smash')
 if not J.CanCastAbility(a) then return 0 end
 local radius=bot:GetAttackRange()+a:GetSpecialValueInt('additional_range')
 local damage=bot:GetAttackDamage()+a:GetSpecialValueInt('attack_damage')
 for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,radius),true,BOT_MODE_NONE)) do
  if J.IsValidHero(u) and J.CanBeAttacked(u) and not J.IsSuspiciousIllusion(u) and not J.CannotBeKilled(bot,u)
   and not u:HasModifier('modifier_item_blade_mail_reflect') and GetUnitToLocationDistance(bot,J.GetCorrectLoc(u,a:GetCastPoint()))<=radius
   and (Useful(u) or J.WillKillTarget(u,damage,DAMAGE_TYPE_PHYSICAL,a:GetCastPoint()) or u:GetAttackTarget()==bot) then return BOT_ACTION_DESIRE_HIGH end
 end
 local target=bot:GetAttackTarget()
 if J.IsValidBuilding(target) and a:GetSpecialValueInt('targets_buildings')>0 and J.CanBeAttacked(target)
  and not target:HasModifier('modifier_fountain_glyph') and GetUnitToUnitDistance(bot,target)<=radius then return BOT_ACTION_DESIRE_HIGH end
 if (J.IsFarming(bot) or J.IsLaning(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and Reserve(a) then
  local count,kills=0,0
  local groups={bot:GetNearbyLaneCreeps(math.min(1600,radius),true),bot:GetNearbyNeutralCreeps(math.min(1600,radius))}
  for _,group in ipairs(groups) do for _,u in ipairs(group) do
   if J.IsValid(u) and J.CanBeAttacked(u) and not J.IsRoshan(u) and not u:HasModifier('modifier_fountain_glyph')
    and GetUnitToLocationDistance(bot,J.GetCorrectLoc(u,a:GetCastPoint()))<=radius then
    count=count+1;if J.WillKillTarget(u,damage,DAMAGE_TYPE_PHYSICAL,a:GetCastPoint()) then kills=kills+1 end
   end
  end end
  if count>=2 and (not J.IsLaning(bot) or kills>=2) then return BOT_ACTION_DESIRE_HIGH end
 end
 return 0
end
function X.ConsiderW()
 local a=bot:GetAbilityByName('tidehunter_kraken_shell')
 if not J.CanCastAbility(a) or J.HasBreakModifier(bot) or bot:HasModifier('modifier_tidehunter_kraken_shell') then return 0 end
 local threats=0
 for _,u in pairs(J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)) do
  if J.IsValidHero(u) and not u:IsDisarmed() and u:GetAttackTarget()==bot and GetUnitToUnitDistance(bot,u)<=u:GetAttackRange()+100 then threats=threats+1 end
 end
 local target=bot:GetAttackTarget()
 local boss=(J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target))
 if (threats>=1 or J.GetAttackProjectileDamageByRange(bot,1200)>0) and (not J.IsRetreating(bot) or bot:IsRooted() or J.IsStuck(bot) or threats>=2) then return BOT_ACTION_DESIRE_HIGH end
 if boss and J.IsAttacking(bot) and J.GetHP(bot)<0.4 then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderR()
 local a=bot:GetAbilityByName('tidehunter_ravage')
 if not J.CanCastAbility(a) then return 0 end
 local radius=a:GetSpecialValueInt('radius')
 local count=0
 for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,radius),true,BOT_MODE_NONE)) do
  if Enemy(u) and not u:HasModifier('modifier_item_blade_mail_reflect') and not J.IsDisabled(u) then
   local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('speed')
   if GetUnitToLocationDistance(bot,J.GetCorrectLoc(u,delay))<=radius then
    if u:IsChanneling() and (not u:HasModifier('modifier_teleporting') or J.GetModifierTime(u,'modifier_teleporting')>delay)
     or J.WillKillTarget(u,a:GetAbilityDamage(),DAMAGE_TYPE_MAGICAL,delay) then return BOT_ACTION_DESIRE_HIGH end
    if Follow(u) or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) and bot:GetAttackTarget()==u
     and GetUnitToUnitDistance(bot,u)<=bot:GetAttackRange()+100 then count=count+1 end
   end
  end
 end
 if count>=2 or count==1 and J.IsGoingOnSomeone(bot) then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderDeadInTheWater()
 local a=bot:GetAbilityByName('tidehunter_dead_in_the_water')
 if not J.CanCastAbility(a) then return 0 end
 for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),true,BOT_MODE_NONE)) do
  if Enemy(u) and J.CanCastOnTargetAdvanced(u) and not u:HasModifier('modifier_tidehunter_dead_in_the_water')
   and not J.IsDisabled(u) and Useful(u) then return BOT_ACTION_DESIRE_HIGH,u end
 end
 return 0
end
function X.ConsiderArm()
 local a=bot:GetAbilityByName('tidehunter_arm_of_the_deep')
 local ravage=bot:GetAbilityByName('tidehunter_ravage')
 if not J.CanCastAbility(a) or a:GetCastRange()<=0 or ravage==nil or ravage:IsNull() or not ravage:IsTrained() then return 0 end
 local range=math.min(X.Range(a),ravage:GetSpecialValueInt('radius')*a:GetSpecialValueInt('range_pct')/100)
 local target=J.GetProperTarget(bot)
 if Enemy(target) and Useful(target) and not J.IsDisabled(target) then
  local p=J.GetCorrectLoc(target,a:GetCastPoint()+GetUnitToUnitDistance(bot,target)/ravage:GetSpecialValueInt('speed'))
  if GetUnitToLocationDistance(bot,p)<=range then return BOT_ACTION_DESIRE_HIGH,p end
 end
 return 0
end
local decisions={tidehunter_gush=X.ConsiderQ,tidehunter_kraken_shell=X.ConsiderW,tidehunter_anchor_smash=X.ConsiderE,tidehunter_ravage=X.ConsiderR,
 tidehunter_dead_in_the_water=X.ConsiderDeadInTheWater,tidehunter_arm_of_the_deep=X.ConsiderArm}
local function Cast(a,target)
 J.SetQueuePtToINT(bot,true,a)
 if a:GetName()=='tidehunter_gush' then
  if bot:HasScepter() then bot:ActionQueue_UseAbilityOnLocation(a,target) else bot:ActionQueue_UseAbilityOnEntity(a,target) end
 elseif a:GetName()=='tidehunter_dead_in_the_water' then bot:ActionQueue_UseAbilityOnEntity(a,target)
 elseif a:GetName()=='tidehunter_arm_of_the_deep' then bot:ActionQueue_UseAbilityOnLocation(a,target)
 else bot:ActionQueue_UseAbility(a) end
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
 if J.CanNotUseAbility(bot) or J.IsRealInvisible(bot) then return false end
 for _,name in ipairs({'tidehunter_ravage','tidehunter_dead_in_the_water','tidehunter_gush','tidehunter_anchor_smash','tidehunter_kraken_shell','tidehunter_arm_of_the_deep'}) do
  local a=bot:GetAbilityByName(name)
  if J.CanCastAbility(a) then local desire,target=decisions[name]();if desire>0 then Cast(a,target);return true end end
 end
 return false
end
return X
