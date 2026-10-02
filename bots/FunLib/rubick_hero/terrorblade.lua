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
 return J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) and J.CanCastOnNonMagicImmune(u) and not J.CannotBeKilled(bot,u)
end
local function Attack(u)
 return (J.IsValid(u) or J.IsValidBuilding(u)) and J.CanBeAttacked(u) and not J.CannotBeKilled(bot,u) and not u:HasModifier('modifier_item_blade_mail_reflect')
end
local function Meta()
 return bot:HasModifier('modifier_terrorblade_metamorphosis') or bot:HasModifier('modifier_terrorblade_metamorphosis_transform')
end
local function Reserve(a)
 local sunder=bot:GetAbilityByName('terrorblade_sunder')
 return bot:GetMana()>=a:GetManaCost()+(sunder~=nil and not sunder:IsNull() and sunder:IsTrained() and sunder:GetManaCost() or 0)
end
function X.ConsiderSunder()
 local a=bot:GetAbilityByName('terrorblade_sunder')
 if not J.CanCastAbility(a) then return 0 end
 local range=X.Range(a)
 local myHP=J.GetHP(bot)
 local floor=math.max(0,a:GetSpecialValueInt('hit_point_minimum_pct'))/100
 local best,gain
 for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
  if Enemy(u) and J.CanCastOnTargetAdvanced(u) and GetUnitToUnitDistance(bot,u)<=range then
   local hp=J.GetHP(u)
   if (myHP<0.35 or myHP<0.6 and J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)) and math.max(floor,hp)>myHP+0.2
    and (gain==nil or hp>gain) then best,gain=u,hp end
  end
 end
 -- Own real illusions are safe donors; never drain a teammate simply to farm.
 for _,u in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
  if u~=bot and J.IsValidHero(u) and u:IsIllusion() and u:GetPlayerID()==bot:GetPlayerID() and u:GetTeam()==bot:GetTeam()
   and not u:IsMagicImmune() and not u:IsInvulnerable() and GetUnitToUnitDistance(bot,u)<=range
   and myHP<0.35 and J.GetHP(u)>myHP+0.2 and (gain==nil or J.GetHP(u)>gain) then best,gain=u,J.GetHP(u) end
 end
 if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
 for _,ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
  if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsMagicImmune() and not ally:IsInvulnerable()
   and GetUnitToUnitDistance(bot,ally)<=range then
   -- A recipient's actual danger justifies giving health only if our post-swap health is safe.
   local after=math.max(floor,J.GetHP(ally))*bot:GetMaxHealth()
   if myHP>0.7 and J.GetHP(ally)<0.25 and ally:WasRecentlyDamagedByAnyHero(2)
    and #J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)==0 and after>J.GetAttackProjectileDamageByRange(bot,1200)+bot:GetMaxHealth()*0.3 then
    return BOT_ACTION_DESIRE_HIGH,ally
   end
   if myHP<0.2 and bot:WasRecentlyDamagedByAnyHero(2) and J.GetHP(ally)>0.8
    and not ally:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(ally,700,true,BOT_MODE_NONE)==0 then return BOT_ACTION_DESIRE_HIGH,ally end
  end
 end
 return 0
end
function X.ConsiderReflection()
 local a=bot:GetAbilityByName('terrorblade_reflection')
 if not J.CanCastAbility(a) then return 0 end
 local range,radius=X.Range(a),a:GetSpecialValueInt('range')
 for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
  if Enemy(u) and not u:HasModifier('modifier_terrorblade_reflection_slow') then
   local p=J.GetCorrectLoc(u,a:GetCastPoint())
   local useful=J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)
   local count=0
   for _,other in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do if Enemy(other) and GetUnitToLocationDistance(other,p)<=radius then count=count+1 end end
   for _,ally in pairs(J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)) do
    if J.IsValidHero(ally) and not ally:IsIllusion() and (ally:GetAttackTarget()==u or u:GetAttackTarget()==ally) then useful=true end
   end
   if (useful or J.IsInTeamFight(bot,1200) and count>=2) and GetUnitToLocationDistance(bot,p)<=range then return BOT_ACTION_DESIRE_HIGH,p end
  end
 end
 return 0
end
function X.ConsiderConjureImage()
 local a=bot:GetAbilityByName('terrorblade_conjure_image')
 if not J.CanCastAbility(a) or not Reserve(a) or J.GetHP(bot)<0.4 then return 0 end
 if a:GetSpecialValueInt('hp_cost_perc')>0 and J.GetHP(bot)*(1-a:GetSpecialValueInt('hp_cost_perc')/100)<0.4 then return 0 end
 local target=bot:GetAttackTarget() or J.GetProperTarget(bot)
 if Attack(target) and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange()+200
  and (J.IsGoingOnSomeone(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) then return BOT_ACTION_DESIRE_HIGH end
 if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,700,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderMetamorphosis()
 local a=bot:GetAbilityByName('terrorblade_metamorphosis')
 if not J.CanCastAbility(a) or Meta() or bot:IsDisarmed() or not Reserve(a) then return 0 end
 local target=bot:GetAttackTarget() or J.GetProperTarget(bot)
 local range=bot:GetAttackRange()+a:GetSpecialValueInt('bonus_range')
 if not Attack(target) or GetUnitToLocationDistance(bot,J.GetCorrectLoc(target,a:GetSpecialValueFloat('transformation_time')))>range then return 0 end
 if J.IsGoingOnSomeone(bot) and J.IsValidHero(target)
  and (target:GetAttackTarget()==bot or J.IsDisabled(target) or bot:GetAttackTarget()==target) then return BOT_ACTION_DESIRE_HIGH end
 if (J.IsPushing(bot) or J.IsDefending(bot)) and target:IsBuilding() and not target:HasModifier('modifier_fountain_glyph')
  and target:GetHealth()>bot:GetAttackDamage()*4 then return BOT_ACTION_DESIRE_HIGH end
 if J.IsDoingRoshan(bot) and J.IsRoshan(target) and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderDemonZeal()
 local a=bot:GetAbilityByName('terrorblade_demon_zeal')
 if not J.CanCastAbility(a) or Meta() or bot:HasModifier('modifier_terrorblade_demon_zeal') then return 0 end
 local after=bot:GetHealth()*(1-a:GetSpecialValueInt('health_cost_pct')/100)
 if after<bot:GetMaxHealth()*0.45 or after<=J.GetAttackProjectileDamageByRange(bot,1200) then return 0 end
 local target=bot:GetAttackTarget() or J.GetProperTarget(bot)
 if not bot:IsDisarmed() and Attack(target) and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange()+150
  and (J.IsGoingOnSomeone(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) then return BOT_ACTION_DESIRE_HIGH end
 if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,700,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderTerrorWave()
 local a=bot:GetAbilityByName('terrorblade_terror_wave')
 if not J.CanCastAbility(a) then return 0 end
 local radius=a:GetSpecialValueInt('scepter_radius')
 local count=0
 for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,radius),true,BOT_MODE_NONE)) do
  if Enemy(u) and not u:HasModifier('modifier_item_blade_mail_reflect') then
   local delay=a:GetCastPoint()+a:GetSpecialValueFloat('scepter_spawn_delay')+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('scepter_speed')
   if GetUnitToLocationDistance(bot,J.GetCorrectLoc(u,delay))<=radius then
    if J.WillKillTarget(u,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,delay)
     or J.IsRetreating(bot) and J.IsChasingTarget(u,bot) and not J.IsDisabled(u) then return BOT_ACTION_DESIRE_HIGH end
    if not J.IsDisabled(u) then count=count+1 end
   end
  end
 end
 if count>=2 and J.IsInTeamFight(bot,1200) then return BOT_ACTION_DESIRE_HIGH end
 if not Meta() and not bot:IsDisarmed() and J.IsGoingOnSomeone(bot) then
  local target=J.GetProperTarget(bot)
  if Enemy(target) and Attack(target) and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange() then return BOT_ACTION_DESIRE_HIGH end
 end
 return 0
end
local decisions={terrorblade_sunder=X.ConsiderSunder,terrorblade_reflection=X.ConsiderReflection,terrorblade_conjure_image=X.ConsiderConjureImage,
 terrorblade_metamorphosis=X.ConsiderMetamorphosis,terrorblade_demon_zeal=X.ConsiderDemonZeal,terrorblade_terror_wave=X.ConsiderTerrorWave}
local function Cast(a,target)
 -- Emergency Sunder should not wait behind an item toggle.
 if a:GetName()=='terrorblade_sunder' then bot:Action_UseAbilityOnEntity(a,target);return end
 J.SetQueuePtToINT(bot,true,a)
 if a:GetName()=='terrorblade_reflection' then bot:ActionQueue_UseAbilityOnLocation(a,target) else bot:ActionQueue_UseAbility(a) end
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
 for _,name in ipairs({'terrorblade_sunder','terrorblade_reflection','terrorblade_terror_wave','terrorblade_metamorphosis','terrorblade_demon_zeal','terrorblade_conjure_image'}) do
  local a=bot:GetAbilityByName(name)
  if J.CanCastAbility(a) then local desire,target=decisions[name]();if desire>0 then Cast(a,target);return true end end
 end
 return false
end
return X
