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
  and not u:HasModifier('modifier_item_blade_mail_reflect') and not u:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Ally(u)
 return J.IsValidHero(u) and u:GetTeam()==bot:GetTeam() and not u:IsIllusion()
end
local function Safe(p)
 return IsLocationPassable(p) and not J.IsLocationInChrono(p) and not J.IsLocationInBlackHole(p) and not J.IsLocHaveTower(700,true,p)
  and #J.GetEnemiesNearLoc(p,700)<=#J.GetAlliesNearLoc(p,700)
end
local function Reserve(a)
 local toss=bot:GetAbilityByName('tiny_toss')
 return bot:GetMana()>=a:GetManaCost()+(toss~=nil and not toss:IsNull() and toss:IsTrained() and toss:GetManaCost() or 0)
end
local function Point(p,range)
 local delta=p-bot:GetLocation()
 return delta:Length2D()<=range and p or bot:GetLocation()+delta:Normalized()*range
end
function X.ConsiderAvalanche()
 local a=bot:GetAbilityByName('tiny_avalanche')
 if not J.CanCastAbility(a) then return 0 end
 local range,radius=X.Range(a),a:GetSpecialValueInt('radius')
 for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range+radius),true,BOT_MODE_NONE)) do
  if Enemy(u) then
   local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('projectile_speed')
   local p=Point(J.GetCorrectLoc(u,delay),range)
   local hit=GetUnitToLocationDistance(u,p)<=radius and (J.GetCorrectLoc(u,delay)-p):Length2D()<=radius
   local fullDelay=delay+a:GetSpecialValueFloat('total_duration')
   local lethal=(J.GetCorrectLoc(u,fullDelay)-p):Length2D()<=radius and J.WillKillTarget(u,a:GetSpecialValueInt('avalanche_damage'),DAMAGE_TYPE_MAGICAL,fullDelay)
   local victim=u:GetAttackTarget()
   if hit and (u:IsChanneling() or lethal or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
    or J.IsRetreating(bot) and J.IsChasingTarget(u,bot) or Ally(victim)
    or J.IsInTeamFight(bot,1200) and #J.GetEnemiesNearLoc(p,radius)>=2) then return BOT_ACTION_DESIRE_HIGH,p end
  end
 end
 if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and Reserve(a) then
  for _,group in ipairs({bot:GetNearbyLaneCreeps(math.min(1600,range+radius),true),bot:GetNearbyNeutralCreeps(math.min(1600,range+radius))}) do
   if #group>=3 then
    local p=Point(J.GetCenterOfUnits(group),range);local count=0
    for _,u in ipairs(group) do if J.IsValid(u) and J.CanCastOnNonMagicImmune(u) and not u:HasModifier('modifier_fountain_glyph')
     and GetUnitToLocationDistance(u,p)<=radius then count=count+1 end end
    if count>=3 then return BOT_ACTION_DESIRE_HIGH,p end
   end
  end
 end
 return 0
end
-- Toss grabs the nearest eligible unit, not its destination. Include allies and
-- creeps in the competition; uncertain ties decline rather than throwing a human.
function X.NearestPassenger(a)
 local radius=a:GetSpecialValueInt('grab_radius')
 local nearest,distance,tie,seen=nil,nil,false,{}
 for _,group in ipairs({J.GetNearbyHeroes(bot,radius,true,BOT_MODE_NONE),J.GetNearbyHeroes(bot,radius,false,BOT_MODE_NONE),
  bot:GetNearbyCreeps(radius,true),bot:GetNearbyCreeps(radius,false),bot:GetNearbyNeutralCreeps(radius)}) do
  for _,u in ipairs(group) do
   if u~=bot and not seen[u] and J.IsValid(u) and not u:IsBuilding() and not u:IsMagicImmune() and not u:IsInvulnerable()
    and not u:IsAncientCreep() and not J.IsRoshan(u) and not J.IsTormentor(u) then
    seen[u]=true;local d=GetUnitToUnitDistance(bot,u)
    if d<=radius then
     if distance==nil or d<distance-1 then nearest,distance,tie=u,d,false
     elseif math.abs(d-distance)<=1 then tie=true end
    end
   end
  end
 end
 return not tie and nearest or nil
end
local function EscapeAnchor(passenger,range)
 local best,bestDistance=nil,GetUnitToLocationDistance(passenger,J.GetEscapeLoc())-300
 for _,group in ipairs({J.GetNearbyHeroes(bot,math.min(1600,range),false,BOT_MODE_NONE),bot:GetNearbyCreeps(math.min(1600,range),false)}) do
  for _,u in ipairs(group) do
   if u~=passenger and u~=bot and J.IsValid(u) and u:GetTeam()==bot:GetTeam() and not u:IsInvulnerable()
    and GetUnitToUnitDistance(bot,u)<=range and GetUnitToUnitDistance(passenger,u)>350
    and Safe(u:GetLocation()) then
    local d=GetUnitToLocationDistance(u,J.GetEscapeLoc())
    if d<bestDistance then best,bestDistance=u,d end
   end
  end
 end
 return best
end
function X.ConsiderToss()
 local a=bot:GetAbilityByName('tiny_toss')
 if not J.CanCastAbility(a) then return 0 end
 local passenger=X.NearestPassenger(a)
 if passenger==nil then return 0 end
 local unitShape=J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_UNIT_TARGET)
 if not unitShape and not J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_NO_TARGET) then return 0 end
 local enemy=passenger:GetTeam()~=bot:GetTeam()
 if Ally(passenger) then
  if not unitShape or passenger:IsChanneling() or passenger:HasModifier('modifier_bloodseeker_rupture')
   or passenger:HasModifier('modifier_puck_coiled') or passenger:HasModifier('modifier_legion_commander_duel')
   or passenger:HasModifier('modifier_faceless_void_chronosphere_freeze') or passenger:HasModifier('modifier_enigma_black_hole_pull') then return 0 end
  if J.GetHP(passenger)<0.5 and passenger:WasRecentlyDamagedByAnyHero(2) then
   local anchor=EscapeAnchor(passenger,X.Range(a))
   if anchor~=nil then return BOT_ACTION_DESIRE_HIGH,anchor,true end
  end
  return 0
 end
 if enemy and Enemy(passenger) then
  if passenger:IsChanneling() and (not unitShape or J.CanCastOnTargetAdvanced(passenger)) then return BOT_ACTION_DESIRE_HIGH,passenger,true end
  if J.IsRetreating(bot) and J.IsChasingTarget(passenger,bot) then
   local anchor=unitShape and EscapeAnchor(passenger,X.Range(a)) or nil
   if anchor~=nil then return BOT_ACTION_DESIRE_HIGH,anchor,true end
   if not unitShape or J.CanCastOnTargetAdvanced(passenger) then return BOT_ACTION_DESIRE_HIGH,passenger,true end
  end
 end
 local grow=bot:GetAbilityByName('tiny_grow')
 local damage=a:GetSpecialValueInt('toss_damage')+(grow~=nil and not grow:IsNull() and grow:IsTrained() and grow:GetSpecialValueInt('toss_bonus_damage') or 0)
 -- Do not add Shard's landing bonus to the passenger or assume a missing Grow.
 for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),true,BOT_MODE_NONE)) do
  if Enemy(u) and J.CanCastOnTargetAdvanced(u) and (unitShape or u==passenger)
   and (J.WillKillTarget(u,damage,DAMAGE_TYPE_MAGICAL,a:GetCastPoint()+a:GetSpecialValueFloat('duration'))
    or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
    or Ally(u:GetAttackTarget())) then
   if not enemy or u==passenger or GetUnitToUnitDistance(passenger,u)<=a:GetSpecialValueInt('radius') then
    return BOT_ACTION_DESIRE_HIGH,u,false
   end
  end
 end
 return 0
end
function X.ConsiderTreeGrab()
 local a=bot:GetAbilityByName('tiny_tree_grab')
 if not J.CanCastAbility(a) or bot:HasModifier('modifier_tiny_tree_grab') or bot:IsDisarmed() then return 0 end
 local target=J.GetProperTarget(bot)
 local useful=Enemy(target) and J.IsGoingOnSomeone(bot) and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange()+a:GetSpecialValueInt('attack_range')+150
  or (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and #bot:GetNearbyLaneCreeps(800,true)>=2
  or J.IsValidBuilding(target) and J.IsAttacking(bot) and not target:HasModifier('modifier_fountain_glyph')
 if not useful then return 0 end
 local nearest,distance
 for _,tree in ipairs(bot:GetNearbyTrees(X.Range(a))) do
  local d=GetUnitToLocationDistance(bot,GetTreeLocation(tree))
  if d<=X.Range(a) and (distance==nil or d<distance) then nearest,distance=tree,d end
 end
 if nearest~=nil then return BOT_ACTION_DESIRE_HIGH,nearest end
 return 0
end
local function OwnTree()
 if not bot:HasModifier('modifier_tiny_tree_grab') then return false end
 local source=bot:GetModifierSourceAbility(bot:GetModifierByName('modifier_tiny_tree_grab'))
 return source~=nil and not source:IsNull() and source:GetName()=='tiny_tree_grab' and source:GetCaster()==bot
end
function X.ConsiderTreeThrow()
 local a=bot:GetAbilityByName('tiny_toss_tree')
 if not J.CanCastAbility(a) or not OwnTree() then return 0 end
 for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),true,BOT_MODE_NONE)) do
  if Enemy(u) and J.CanBeAttacked(u) and J.CanCastOnTargetAdvanced(u) then
   local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueFloat('speed')
   -- Current attack damage already contains the held tree bonus. Use it as a
   -- conservative lower bound instead of adding that bonus twice.
   local lethal=J.WillKillTarget(u,bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL,delay)
   local preserve=GetUnitToUnitDistance(bot,u)<=bot:GetAttackRange()+80 and bot:GetModifierStackCount(bot:GetModifierByName('modifier_tiny_tree_grab'))>1
   if lethal and not preserve or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)
    or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) and GetUnitToUnitDistance(bot,u)>bot:GetAttackRange()+80 then
    local point=J.GetCorrectLoc(u,delay)
    if J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then return BOT_ACTION_DESIRE_HIGH,u
    elseif J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_POINT) and GetUnitToLocationDistance(bot,point)<=X.Range(a) then return BOT_ACTION_DESIRE_HIGH,point end
   end
  end
 end
 return 0
end
function X.ConsiderTreeVolley()
 local a=bot:GetAbilityByName('tiny_tree_channel')
 if not J.CanCastAbility(a) or bot:WasRecentlyDamagedByAnyHero(2) or J.IsNotAttackProjectileIncoming(bot,500)
  or #J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)>0 then return 0 end
 local trees=bot:GetNearbyTrees(a:GetSpecialValueInt('tree_grab_radius'))
 if #trees<2 then return 0 end
 for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),true,BOT_MODE_NONE)) do
  if J.IsValidHero(u) and J.CanCastOnMagicImmune(u) and J.CanBeAttacked(u) and not J.IsSuspiciousIllusion(u)
   and not J.CannotBeKilled(bot,u) and not u:HasModifier('modifier_item_blade_mail_reflect')
   and (J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or Ally(u:GetAttackTarget()) or J.IsInTeamFight(bot,1200)) then
   local p=J.GetCorrectLoc(u,a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueFloat('speed'))
   if GetUnitToLocationDistance(bot,p)<=X.Range(a) then return BOT_ACTION_DESIRE_HIGH,p end
  end
 end
 return 0
end
local decisions={tiny_avalanche=X.ConsiderAvalanche,tiny_toss=X.ConsiderToss,tiny_tree_grab=X.ConsiderTreeGrab,tiny_toss_tree=X.ConsiderTreeThrow,tiny_tree_channel=X.ConsiderTreeVolley}
local function Cast(a,target)
 J.SetQueuePtToINT(bot,true,a)
 local name=a:GetName()
 if name=='tiny_tree_grab' then bot:ActionQueue_UseAbilityOnTree(a,target)
 elseif name=='tiny_toss' and not J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then bot:ActionQueue_UseAbility(a)
 elseif name=='tiny_toss' or name=='tiny_toss_tree' and J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then bot:ActionQueue_UseAbilityOnEntity(a,target)
 else bot:ActionQueue_UseAbilityOnLocation(a,target) end
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
 local toss=bot:GetAbilityByName('tiny_toss')
 if J.CanCastAbility(toss) then local desire,target,emergency=X.ConsiderToss();if desire>0 and emergency then Cast(toss,target);return true end end
 for _,name in ipairs({'tiny_avalanche','tiny_toss','tiny_tree_grab','tiny_toss_tree','tiny_tree_channel'}) do
  local a=bot:GetAbilityByName(name)
  if J.CanCastAbility(a) then local desire,target=decisions[name]();if desire>0 then Cast(a,target);return true end end
 end
 return false
end
return X
