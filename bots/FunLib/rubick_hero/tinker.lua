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
local function Safe(p)
 return IsLocationPassable(p) and not J.IsLocationInChrono(p) and not J.IsLocationInBlackHole(p) and not J.IsLocHaveTower(700,true,p)
  and #J.GetEnemiesNearLoc(p,800)<=#J.GetAlliesNearLoc(p,800)
end
local function Point(p,range)
 local delta=p-bot:GetLocation()
 return delta:Length2D()<=range and p or bot:GetLocation()+delta:Normalized()*range
end
local function Reserve(a)
 local tp=bot:GetAbilityByName('tinker_keen_teleport')
 return bot:GetMana()>=a:GetManaCost()+(tp~=nil and not tp:IsNull() and tp:IsTrained() and tp:GetManaCost() or 0)
end
local function Busy()
 for _,name in ipairs({'tinker_rearm','tinker_keen_teleport'}) do
  local a=bot:GetAbilityByName(name)
  if a~=nil and not a:IsNull() and a:IsInAbilityPhase() then return true end
 end
 return bot:HasModifier('modifier_tinker_rearm') or bot:HasModifier('modifier_teleporting')
end
function X.ObserveMarch()
 local pending=bot.tinkerMarchPending
 if pending~=nil then
  local a=bot:GetAbilityByName('tinker_march_of_the_machines')
  if a==nil or a:IsNull() or a~=pending.ability then bot.tinkerMarchPending=nil
  elseif a:GetCooldownTimeRemaining()>pending.cooldown then
   bot.tinkerMarchZones=bot.tinkerMarchZones or {}
   bot.tinkerMarchZones[#bot.tinkerMarchZones+1]={point=pending.point,expires=DotaTime()+a:GetSpecialValueFloat('duration')}
   bot.tinkerMarchPending=nil
  elseif DotaTime()>pending.expires then bot.tinkerMarchPending=nil end
 end
 local zones={}
 for _,zone in ipairs(bot.tinkerMarchZones or {}) do if DotaTime()<zone.expires then zones[#zones+1]=zone end end
 bot.tinkerMarchZones=zones
end
local function Covered(p,radius)
 local pending=bot.tinkerMarchPending
 if pending~=nil and DotaTime()<=pending.expires and (p-pending.point):Length2D()<radius*0.5 then return true end
 for _,zone in ipairs(bot.tinkerMarchZones or {}) do if (p-zone.point):Length2D()<radius*0.5 then return true end end
 return false
end
function X.ConsiderLaser()
 local a=bot:GetAbilityByName('tinker_laser')
 if not J.CanCastAbility(a) then return 0 end
 local best,threat
 for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),true,BOT_MODE_NONE)) do
  if Enemy(u) and J.CanCastOnTargetAdvanced(u) then
   if J.WillKillTarget(u,a:GetSpecialValueInt('laser_damage'),DAMAGE_TYPE_PURE,a:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,u end
   local attacking=J.IsValidHero(u:GetAttackTarget()) and u:GetAttackTarget():GetTeam()==bot:GetTeam()
   local useful=J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsRetreating(bot) and J.IsChasingTarget(u,bot) or attacking
   if useful and not u:HasModifier('modifier_tinker_laser_blind') then
    local dps=u:GetAttackDamage()/math.max(0.1,u:GetSecondsPerAttack())
    if threat==nil or dps>threat then best,threat=u,dps end
   end
  end
 end
 if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
 if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and Reserve(a) then
  local groups={bot:GetNearbyLaneCreeps(math.min(1600,X.Range(a)),true),bot:GetNearbyNeutralCreeps(math.min(1600,X.Range(a)))}
  for _,group in ipairs(groups) do for _,u in ipairs(group) do
   if J.IsValid(u) and J.CanCastOnNonMagicImmune(u) and not u:HasModifier('modifier_fountain_glyph') then
    local kills=0
    for _,other in ipairs(group) do
     if J.IsValid(other) and J.CanCastOnNonMagicImmune(other) and GetUnitToUnitDistance(u,other)<=a:GetSpecialValueInt('radius_explosion')
      and J.WillKillTarget(other,a:GetSpecialValueInt('laser_damage'),DAMAGE_TYPE_PURE,a:GetCastPoint()) then kills=kills+1 end
    end
    if kills>=2 or string.find(u:GetUnitName(),'ranged') and J.WillKillTarget(u,a:GetSpecialValueInt('laser_damage'),DAMAGE_TYPE_PURE,a:GetCastPoint())
     and not J.WillKillTarget(u,bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL,a:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,u end
   end
  end end
 end
 local target=J.GetProperTarget(bot)
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target) and J.CanCastOnNonMagicImmune(target)
  and J.CanCastOnTargetAdvanced(target) and GetUnitToUnitDistance(bot,target)<=X.Range(a) and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH,target end
 return 0
end
function X.ConsiderMarch()
 local a=bot:GetAbilityByName('tinker_march_of_the_machines')
 if not J.CanCastAbility(a) or not Reserve(a) then return 0 end
 local range,radius=X.Range(a),a:GetSpecialValueInt('radius')
 local function Aim(u)
  local p=Point(J.GetCorrectLoc(u,a:GetCastPoint()),range)
  if IsLocationPassable(p) and GetUnitToLocationDistance(u,p)<=radius and not Covered(p,radius) then return p end
 end
 if bot:HasScepter() and a:GetSpecialValueInt('heal_per_second')>0 then
  for _,ally in ipairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
   if J.IsValidHero(ally) and not ally:IsIllusion() and J.GetHP(ally)<0.65 and not ally:HasModifier('modifier_ice_blast') then
    local p=Aim(ally);if p~=nil then return BOT_ACTION_DESIRE_HIGH,p end
   end
  end
 end
 local target=J.GetProperTarget(bot)
 if Enemy(target) and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot) and J.IsChasingTarget(target,bot)) then
  local p=Aim(target);if p~=nil then return BOT_ACTION_DESIRE_HIGH,p end
 end
 if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then
  for _,group in ipairs({bot:GetNearbyLaneCreeps(1600,true),bot:GetNearbyNeutralCreeps(1200)}) do
   if #group>=2 then
    local p=Point(J.GetCenterOfUnits(group),range)
    local count=0
    for _,u in ipairs(group) do if J.IsValid(u) and J.CanCastOnNonMagicImmune(u) and not u:HasModifier('modifier_fountain_glyph') and GetUnitToLocationDistance(u,p)<=radius then count=count+1 end end
    if count>=2 and IsLocationPassable(p) and not Covered(p,radius) then return BOT_ACTION_DESIRE_HIGH,p end
   end
  end
 end
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target) and J.CanCastOnNonMagicImmune(target) and J.IsAttacking(bot) then
  local p=Aim(target);if p~=nil then return BOT_ACTION_DESIRE_HIGH,p end
 end
 return 0
end
function X.ConsiderTurrets()
 local a=bot:GetAbilityByName('tinker_deploy_turrets')
 if not J.CanCastAbility(a) then return 0 end
 local radius=a:GetSpecialValueInt('drop_aoe_radius')
 local delay=a:GetCastPoint()+a:GetSpecialValueFloat('drop_delay')
 if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and not bot:IsRooted()
  and not bot:HasModifier('modifier_bloodseeker_rupture') and not bot:HasModifier('modifier_puck_coiled') then
  local escape=(J.GetEscapeLoc()-bot:GetLocation()):Normalized()
  local p=bot:GetLocation()-escape*math.min(radius*0.6,X.Range(a))
  local landing=bot:GetLocation()+escape*a:GetSpecialValueInt('drop_knockback_distance_tinker')
  if Safe(landing) and #J.GetNearbyHeroes(bot,700,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH,p end
 end
 for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
  if Enemy(u) then
   local aim=J.GetCorrectLoc(u,delay)
   local p=Point(aim,X.Range(a))
   local distance=(p-aim):Length2D()
   local impact=distance<=radius and J.WillKillTarget(u,a:GetSpecialValueInt('drop_damage'),DAMAGE_TYPE_MAGICAL,delay)
   local useful=J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or u:GetAttackTarget()==bot
   for _,ally in pairs(J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)) do if J.IsValidHero(ally) and not ally:IsIllusion() and (u:GetAttackTarget()==ally or ally:GetAttackTarget()==u) then useful=true end end
   if (impact or useful and Reserve(a)) and distance<=a:GetSpecialValueInt('missile_target_range')
    and IsLocationPassable(p) and (GetUnitToLocationDistance(bot,p)>radius or not bot:IsRooted()
     and not bot:HasModifier('modifier_bloodseeker_rupture') and not bot:HasModifier('modifier_puck_coiled')
     and Safe(bot:GetLocation()+(bot:GetLocation()-p):Normalized()*a:GetSpecialValueInt('drop_knockback_distance_tinker'))) then return BOT_ACTION_DESIRE_HIGH,p end
  end
 end
 return 0
end
function X.ConsiderWarp()
 local a=bot:GetAbilityByName('tinker_warp_grenade')
 if not J.CanCastAbility(a) then return 0 end
 for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),true,BOT_MODE_NONE)) do
  if Enemy(u) and J.CanCastOnTargetAdvanced(u) and not u:HasModifier('modifier_tinker_warp_grenade') then
   if J.WillKillTarget(u,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,a:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,u end
   if not J.IsDisabled(u) and (J.IsChasingTarget(u,bot) or u:GetAttackTarget()==bot) then return BOT_ACTION_DESIRE_HIGH,u end
   local victim=u:GetAttackTarget()
   if J.IsValidHero(victim) and victim:GetTeam()==bot:GetTeam() and J.GetHP(victim)<0.5
    and victim:WasRecentlyDamagedByAnyHero(2) and not J.IsDisabled(u) then return BOT_ACTION_DESIRE_HIGH,u end
  end
 end
 return 0
end
function X.ConsiderRearm()
 local a=bot:GetAbilityByName('tinker_rearm')
 if not J.CanCastAbility(a) or bot:WasRecentlyDamagedByAnyHero(2) or #J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)>0
  or J.IsNotAttackProjectileIncoming(bot,1200) or J.GetAttackProjectileDamageByRange(bot,1200)>0 then return 0 end
 local channel=a:GetChannelTime()
 local cheapest
 for _,name in ipairs({'tinker_laser','tinker_march_of_the_machines','tinker_deploy_turrets','tinker_warp_grenade','tinker_keen_teleport'}) do
  local spell=bot:GetAbilityByName(name)
  if spell~=nil and not spell:IsNull() and spell:IsTrained() and not spell:IsHidden() and not spell:IsPassive() and spell:IsActivated()
   and spell:GetCooldownTimeRemaining()>channel then
   if cheapest==nil or spell:GetManaCost()<cheapest then cheapest=spell:GetManaCost() end
  end
 end
 if cheapest==nil or not Reserve(a) or bot:GetMana()<a:GetManaCost()+cheapest then return 0 end
 if bot.healInBase or J.IsGoingOnSomeone(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot) then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderTeleport()
 local a=bot:GetAbilityByName('tinker_keen_teleport')
 if not J.CanCastAbility(a) or not (J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_POINT) or J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_UNIT_TARGET))
  or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_puck_coiled')
  or bot:HasModifier('modifier_kunkka_x_marks_the_spot') or bot:WasRecentlyDamagedByAnyHero(2)
  or #J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)>0 or J.IsNotAttackProjectileIncoming(bot,1200) then return 0 end
 local desired
 if bot.healInBase or J.GetMP(bot)<0.3 or J.GetHP(bot)<0.35 then desired=J.GetTeamFountain()
 else
  for _,ally in ipairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
   if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and Enemy(ally:GetAttackTarget()) and GetUnitToUnitDistance(bot,ally)>3000 then desired=ally:GetLocation();break end
  end
  if desired==nil and J.IsLaning(bot) then desired=GetLaneFrontLocation(bot:GetTeam(),LANE_MID,-300) end
  if desired==nil and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then
   local farmLane,desire=J.GetMostFarmLaneDesire()
   if desire>0.75 then desired=GetLaneFrontLocation(bot:GetTeam(),farmLane,0) end
  end
 end
 if desired==nil or GetUnitToLocationDistance(bot,desired)<2500 then return 0 end
 local best,distance
 for _,anchor in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
  if anchor~=bot and anchor~=nil and not anchor:IsNull() and anchor:IsAlive() and anchor:GetTeam()==bot:GetTeam()
   and (anchor:IsBuilding() or a:GetLevel()>=3 and anchor:IsHero() and not anchor:IsIllusion() or a:GetLevel()>=2 and anchor:IsCreep()) then
   local arrival=J.GetCorrectLoc(anchor,a:GetChannelTime())
   local d=(arrival-desired):Length2D()
   if GetUnitToLocationDistance(bot,arrival)>2500 and d<1200 and #J.GetEnemiesNearLoc(arrival,700)==0
    and not J.IsLocationInChrono(arrival) and not J.IsLocationInBlackHole(arrival) and (distance==nil or d<distance) then best,distance=anchor,d end
  end
 end
 if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
 return 0
end
local decisions={tinker_laser=X.ConsiderLaser,tinker_march_of_the_machines=X.ConsiderMarch,tinker_deploy_turrets=X.ConsiderTurrets,
 tinker_warp_grenade=X.ConsiderWarp,tinker_rearm=X.ConsiderRearm,tinker_keen_teleport=X.ConsiderTeleport}
local function Cast(a,target)
 J.SetQueuePtToINT(bot,true,a)
 local name=a:GetName()
 if name=='tinker_laser' or name=='tinker_warp_grenade' then bot:ActionQueue_UseAbilityOnEntity(a,target)
 elseif name=='tinker_rearm' then bot:ActionQueue_UseAbility(a)
 elseif name=='tinker_keen_teleport' then
  if J.CheckBitfieldFlag(a:GetBehavior(),DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then bot:ActionQueue_UseAbilityOnEntity(a,target)
  else bot:ActionQueue_UseAbilityOnLocation(a,target:GetLocation()) end
 else bot:ActionQueue_UseAbilityOnLocation(a,target) end
 if name=='tinker_march_of_the_machines' then bot.tinkerMarchPending={ability=a,point=target,cooldown=a:GetCooldownTimeRemaining(),expires=DotaTime()+3} end
end
function X.ConsiderStolenSpell(a)
 local consider=decisions[a:GetName()]
 if consider==nil then return nil end
 bot=GetBot();X.ObserveMarch()
 if J.CanNotUseAbility(bot) or Busy() or not J.CanCastAbility(a) then return false end
 local desire,target=consider()
 if desire<=0 then return false end
 Cast(a,target);return true
end
function X.UseNative()
 bot=GetBot();X.ObserveMarch()
 if J.CanNotUseAbility(bot) or Busy() or J.IsRealInvisible(bot) then return false end
 if J.GetMP(bot)>0.8 and J.GetHP(bot)>0.5 or bot:HasModifier('modifier_fountain_invulnerability') then bot.healInBase=false
 elseif not J.IsGoingOnSomeone(bot) and (J.GetMP(bot)<0.3 or J.GetHP(bot)<0.35) then bot.healInBase=true end
 local order=bot.healInBase and {'tinker_keen_teleport','tinker_warp_grenade','tinker_laser','tinker_deploy_turrets','tinker_march_of_the_machines','tinker_rearm'}
  or {'tinker_warp_grenade','tinker_laser','tinker_deploy_turrets','tinker_march_of_the_machines','tinker_rearm','tinker_keen_teleport'}
 for _,name in ipairs(order) do
  local a=bot:GetAbilityByName(name)
  if J.CanCastAbility(a) then local desire,target=decisions[name]();if desire>0 then Cast(a,target);return true end end
 end
 return false
end
return X
