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
local function Ally(u)
 return J.IsValidHero(u) and u:GetTeam()==bot:GetTeam() and not u:IsIllusion() and not J.IsMeepoClone(u)
  and not u:HasModifier('modifier_arc_warden_tempest_double')
end
local function Enemy(u)
 return J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u) and not J.CannotBeKilled(bot,u)
  and not u:HasModifier('modifier_item_blade_mail_reflect') and not u:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Reserve(a)
 local r=bot:GetAbilityByName('treant_overgrowth')
 return bot:GetMana()>=a:GetManaCost()+(r~=nil and not r:IsNull() and r:IsTrained() and r:GetManaCost() or 0)
end
local function AlliedEyes()
 local eyes={}
 for _,u in ipairs(GetUnitList(UNIT_LIST_ALLIES)) do
  if u~=nil and not u:IsNull() and u:IsAlive() and u:GetUnitName()=='npc_dota_treant_eyes'
   and u:GetTeam()==bot:GetTeam() then eyes[#eyes+1]=u end
 end
 return eyes
end
function X.OwnEyes()
 local eyes={}
 for _,u in ipairs(AlliedEyes()) do
  if u:GetPlayerID()==bot:GetPlayerID() and u:GetPlayerID()>=0 then eyes[#eyes+1]=u end
 end
 return eyes
end
local function Threat(u,enemies)
 if u:WasRecentlyDamagedByAnyHero(2) or J.GetAttackProjectileDamageByRange(u,600)>0 then return true end
 for _,enemy in ipairs(enemies) do
  if J.IsValidHero(enemy) and enemy:GetAttackTarget()==u then return true end
 end
 return false
end
function X.ConsiderLivingArmor()
 local a=bot:GetAbilityByName('treant_living_armor')
 if not J.CanCastAbility(a) then return 0 end
 local best,score=nil,0
 local enemies=GetUnitList(UNIT_LIST_ENEMY_HEROES)
 local candidates={bot}
 for _,u in ipairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do if u~=bot then candidates[#candidates+1]=u end end
 for _,u in ipairs(GetUnitList(UNIT_LIST_ALLIED_BUILDINGS)) do candidates[#candidates+1]=u end
 for _,u in ipairs(candidates) do
  if (Ally(u) or J.IsValidBuilding(u) and u:GetTeam()==bot:GetTeam()) and not u:IsInvulnerable()
   and not u:HasModifier('modifier_fountain_aura') and not u:HasModifier('modifier_treant_living_armor') then
   local hp=J.GetHP(u);local threat=Threat(u,enemies)
   local healing=not u:HasModifier('modifier_ice_blast') and u:GetMaxHealth()-u:GetHealth()>=a:GetSpecialValueInt('heal_per_second')*a:GetSpecialValueFloat('duration')*0.65
   local value=0
   if threat and hp<0.85 then value=1000+(1-hp)*1000+(Ally(u) and 500 or 0)
   elseif healing and hp<0.8 and Reserve(a) then value=(1-hp)*400+(Ally(u) and 100 or 0) end
   -- Ice Blast blocks healing, but actual incoming player damage still gives
   -- the diminishing block a useful job; do not invent armor or full healing.
   if value>score then best,score=u,value end
  end
 end
 if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
 return 0
end
function X.ConsiderLeechSeed()
 local a=bot:GetAbilityByName('treant_leech_seed')
 if not J.CanCastAbility(a) or bot:IsDisarmed() or J.HasBreakModifier(bot) then return 0 end
 for _,u in ipairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),true,BOT_MODE_NONE)) do
  if Enemy(u) and J.CanBeAttacked(u) and J.CanCastOnTargetAdvanced(u) and not u:HasModifier('modifier_treant_leech_seed') then
   local physical=u:GetActualIncomingDamage(bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL)
   local magical=u:GetActualIncomingDamage(a:GetSpecialValueInt('leech_damage'),DAMAGE_TYPE_MAGICAL)
   local lethal=physical+magical>=u:GetHealth()+u:GetHealthRegen()*a:GetCastPoint()
   if lethal or u:IsChanneling() or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
    or J.IsRetreating(bot) and J.IsChasingTarget(u,bot) or Ally(u:GetAttackTarget()) then return BOT_ACTION_DESIRE_HIGH,u end
  end
 end
 -- Current Seed can heal nearby human allies from a creep attack. It is not a
 -- ground spell and never assumes the obsolete continuous area damage.
 for _,group in ipairs({bot:GetNearbyLaneCreeps(math.min(1600,X.Range(a)),true),bot:GetNearbyNeutralCreeps(math.min(1600,X.Range(a)))}) do
  for _,u in ipairs(group) do
   if J.IsValid(u) and J.CanCastOnNonMagicImmune(u) and J.CanBeAttacked(u) and not u:HasModifier('modifier_fountain_glyph') then
    for _,ally in ipairs(J.GetAlliesNearLoc(u:GetLocation(),a:GetSpecialValueInt('radius'))) do
     if Ally(ally) and J.GetHP(ally)<0.7 and not ally:HasModifier('modifier_ice_blast')
      and ally:GetMaxHealth()-ally:GetHealth()>=a:GetSpecialValueInt('flat_heal') then return BOT_ACTION_DESIRE_HIGH,u end
    end
    if (J.IsFarming(bot) or J.IsDoingRoshan(bot)) and J.IsAttacking(bot) and u==J.GetProperTarget(bot)
     and J.GetHP(bot)<0.7 and not bot:HasModifier('modifier_ice_blast') then return BOT_ACTION_DESIRE_HIGH,u end
   end
  end
 end
 local target=J.GetProperTarget(bot)
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target) and J.CanCastOnNonMagicImmune(target)
  and J.CanBeAttacked(target) and J.CanCastOnTargetAdvanced(target) and GetUnitToUnitDistance(bot,target)<=X.Range(a)
  and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH,target end
 return 0
end
local function OnLine(p,start,finish,radius)
 local line=finish-start;local len=line:Length2D()
 if len==0 then return (p-start):Length2D()<=radius end
 local delta=p-start;local t=math.max(0,math.min(1,(delta.x*line.x+delta.y*line.y)/(len*len)))
 return (p-(start+line*t)):Length2D()<=radius
end
function X.ConsiderNaturesGrasp()
 local a=bot:GetAbilityByName('treant_natures_grasp')
 if not J.CanCastAbility(a) then return 0 end
 local range,latch=X.Range(a),a:GetSpecialValueInt('latch_range')
 local function Aim(u)
  local delay=a:GetCastPoint()+a:GetSpecialValueFloat('initial_latch_delay')
   +math.ceil(GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('vine_spawn_interval'))*a:GetSpecialValueFloat('creation_interval')
  local point=J.GetCorrectLoc(u,delay+1);local delta=point-bot:GetLocation()
  if delta:Length2D()>range then point=bot:GetLocation()+delta:Normalized()*range end
  if OnLine(J.GetCorrectLoc(u,delay),bot:GetLocation(),point,latch) then return point end
 end
 for _,u in ipairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
  if Enemy(u) and GetUnitToUnitDistance(bot,u)<=range+latch and not u:HasModifier('modifier_treant_natures_grasp_damage') then
   if J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)
    or Ally(u:GetAttackTarget()) or J.IsInTeamFight(bot,1200) then
    local point=Aim(u);if point~=nil then return BOT_ACTION_DESIRE_HIGH,point end
   end
  end
 end
 if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and Reserve(a) then
  for _,group in ipairs({bot:GetNearbyLaneCreeps(1600,true),bot:GetNearbyNeutralCreeps(1200)}) do
   for _,u in ipairs(group) do
    local point=Aim(u);local count=0
    if point~=nil then
     for _,other in ipairs(group) do if J.IsValid(other) and J.CanCastOnNonMagicImmune(other) and not other:HasModifier('modifier_fountain_glyph')
      and OnLine(other:GetLocation(),bot:GetLocation(),point,latch) then count=count+1 end end
     if count>=3 then return BOT_ACTION_DESIRE_HIGH,point end
    end
   end
  end
 end
 return 0
end
function X.ConsiderOvergrowth()
 local a=bot:GetAbilityByName('treant_overgrowth')
 if not J.CanCastAbility(a) then return 0 end
 local centers={bot:GetLocation()}
 for _,eye in ipairs(X.OwnEyes()) do centers[#centers+1]=eye:GetLocation() end
 local count,follow=0,false
 for _,u in ipairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
  if J.IsValidHero(u) and J.CanCastOnMagicImmune(u) and not J.IsSuspiciousIllusion(u)
   and not u:HasModifier('modifier_treant_overgrowth') then
   local covered=false
   for _,p in ipairs(centers) do if (J.GetCorrectLoc(u,a:GetCastPoint())-p):Length2D()<=a:GetSpecialValueInt('radius') then covered=true;break end end
   if covered then
    if u:IsChanneling() then return BOT_ACTION_DESIRE_HIGH end
    local victim=u:GetAttackTarget()
    if Ally(victim) and J.GetHP(victim)<0.5 and victim:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH end
    if not J.IsDisabled(u) then
     count=count+1
     if Ally(victim) or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or #J.GetAlliesNearLoc(u:GetLocation(),800)>0 then follow=true end
     if J.IsRetreating(bot) and J.IsChasingTarget(u,bot) and bot:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH end
    end
   end
  end
 end
 if count>=2 and follow or count>=1 and J.IsGoingOnSomeone(bot) and follow then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderEyesInTheForest()
 local a=bot:GetAbilityByName('treant_eyes_in_the_forest')
 if not J.CanCastAbility(a) or a:GetCurrentCharges()<1 or not Reserve(a) or bot:WasRecentlyDamagedByAnyHero(2)
  or #J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)>0 then return 0 end
 local pending=bot.treantEyePending
 if pending~=nil and DotaTime()<=pending.expires then return 0 end
 bot.treantEyePending=nil
 if GetUnitToLocationDistance(bot,J.GetTeamFountain())<1800 then return 0 end
 local eyes=AlliedEyes();local best,distance
 for _,tree in ipairs(bot:GetNearbyTrees(X.Range(a))) do
  local point=GetTreeLocation(tree);local d=GetUnitToLocationDistance(bot,point);local covered=false
  for _,eye in ipairs(eyes) do if GetUnitToLocationDistance(eye,point)<a:GetSpecialValueInt('vision_aoe')*0.75 then covered=true;break end end
  if d<=X.Range(a) and not covered and not J.IsLocHaveTower(700,true,point) and not J.IsLocationInChrono(point)
   and not J.IsLocationInBlackHole(point) and (distance==nil or d>distance) then best,distance=tree,d end
 end
 if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
 return 0
end
function X.ConsiderNaturesGuise()
 local a=bot:GetAbilityByName('treant_natures_guise')
 if not J.CanCastAbility(a) or not J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_NO_TARGET) or bot:IsInvisible() then return 0 end
 -- The engine's active shape and activation gate prove availability near
 -- real trees or Grasp vines; static passive metadata alone never authorizes it.
 if J.IsRetreating(bot) or J.IsGoingOnSomeone(bot) or J.IsPushing(bot) or J.IsFarming(bot) then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderSuperBloom()
 local a=bot:GetAbilityByName('treant_super_bloom')
 if not J.CanCastAbility(a) or bot:HasModifier('modifier_treant_super_bloom') then return 0 end
 local target=J.GetProperTarget(bot)
 if Enemy(target) and J.IsGoingOnSomeone(bot) and not bot:IsDisarmed() and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange()+300
  or J.IsRetreating(bot) and J.GetHP(bot)<0.45 and bot:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
local decisions={treant_living_armor=X.ConsiderLivingArmor,treant_leech_seed=X.ConsiderLeechSeed,treant_natures_grasp=X.ConsiderNaturesGrasp,
 treant_overgrowth=X.ConsiderOvergrowth,treant_eyes_in_the_forest=X.ConsiderEyesInTheForest,treant_natures_guise=X.ConsiderNaturesGuise,treant_super_bloom=X.ConsiderSuperBloom}
local function Cast(a,target)
 J.SetQueuePtToINT(bot,true,a)
 local name=a:GetName()
 if name=='treant_eyes_in_the_forest' then
  bot:ActionQueue_UseAbilityOnTree(a,target);bot.treantEyePending={tree=target,expires=DotaTime()+3}
 elseif name=='treant_living_armor' and not J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then bot:ActionQueue_UseAbilityOnLocation(a,target:GetLocation())
 elseif name=='treant_living_armor' or name=='treant_leech_seed' then bot:ActionQueue_UseAbilityOnEntity(a,target)
 elseif name=='treant_natures_grasp' then bot:ActionQueue_UseAbilityOnLocation(a,target)
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
 if J.CanNotUseAbility(bot) then return false end
 -- Guise lasts until an attack or leaving trees; ordinary spells remain legal.
 for _,name in ipairs({'treant_overgrowth','treant_living_armor','treant_leech_seed','treant_natures_grasp','treant_super_bloom','treant_natures_guise','treant_eyes_in_the_forest'}) do
  local a=bot:GetAbilityByName(name)
  if J.CanCastAbility(a) then local desire,target=decisions[name]();if desire>0 then Cast(a,target);return true end end
 end
 return false
end
return X
