local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot
local ShackleShot,Powershot,Windrun,FocusFire,FocusCancel
local function Refresh()
 bot=GetBot();ShackleShot=bot:GetAbilityByName('windrunner_shackleshot');Powershot=bot:GetAbilityByName('windrunner_powershot');Windrun=bot:GetAbilityByName('windrunner_windrun');FocusFire=bot:GetAbilityByName('windrunner_focusfire');FocusCancel=bot:GetAbilityByName('windrunner_focusfire_cancel')
end
local function Range(a)
 local range=a:GetCastRange()
 for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
 local passive=bot:GetAbilityByName('rubick_arcane_supremacy')
 if passive~=nil and not passive:IsNull() and passive:IsTrained() and not J.HasBreakModifier(bot) then range=range+passive:GetSpecialValueInt('cast_range') end
 return range
end
local function Enemy(unit,pierce)
 return J.IsValid(unit) and (pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit)) and not J.IsSuspiciousIllusion(unit)
end
local function Useful(enemy)
 if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then return true end
 if J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then return true end
 for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,ally) then return true end
 end
 return false
end
local function Behind(primary,anchor,radius,angle)
 local toward=primary-bot:GetLocation();local delta=anchor-primary;local a,b=toward:Length2D(),delta:Length2D()
 if a<1 or b<1 or b>radius then return false end
 return (toward.x*delta.x+toward.y*delta.y)/(a*b)>=math.cos(angle*math.pi/180)
end
local function Units()
 local units=GetUnitList(UNIT_LIST_ENEMIES);local seen={};for _,unit in ipairs(units) do seen[unit]=true end
 for _,unit in ipairs(bot:GetNearbyNeutralCreeps(1600)) do if not seen[unit] then units[#units+1]=unit;seen[unit]=true end end
 return units
end
local function ShacklePrimary(target)
 local range=Range(ShackleShot);local radius=ShackleShot:GetSpecialValueInt('shackle_distance');local angle=ShackleShot:GetSpecialValueInt('shackle_angle')
 local units=Units()
 for _,primary in ipairs(units) do
  if J.IsValid(primary) and J.CanCastOnNonMagicImmune(primary) and J.CanCastOnTargetAdvanced(primary) and GetUnitToUnitDistance(bot,primary)<=range then
   local eta=ShackleShot:GetCastPoint()+GetUnitToUnitDistance(bot,primary)/ShackleShot:GetSpecialValueInt('arrow_speed')
   local point=J.GetCorrectLoc(primary,eta)
   if primary~=target then
    if Behind(point,J.GetCorrectLoc(target,eta),radius,angle) then return primary end
   else
    for _,anchor in ipairs(units) do if anchor~=primary and J.IsValid(anchor) and Behind(point,J.GetCorrectLoc(anchor,eta),radius,angle) then return primary end end
    for _,tree in ipairs(target:GetNearbyTrees(radius)) do local location=GetTreeLocation(tree);if location~=nil and Behind(point,location,radius,angle) then return primary end end
   end
  end
 end
 return nil
end
function X.ConsiderShackleShot()
 if not J.CanCastAbility(ShackleShot) then return 0 end
 local range=Range(ShackleShot);local choice,best=nil,0
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range+ShackleShot:GetSpecialValueInt('shackle_distance'),1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) then
   if enemy:IsChanneling() and GetUnitToUnitDistance(bot,enemy)<=range and J.CanCastOnTargetAdvanced(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end
   if Useful(enemy) or J.IsInTeamFight(bot,1200) or enemy:IsChanneling() then
    local primary=ShacklePrimary(enemy)
    if primary~=nil and J.GetRemainStunTime(enemy)<=ShackleShot:GetCastPoint()+GetUnitToUnitDistance(bot,primary)/ShackleShot:GetSpecialValueInt('arrow_speed')+0.15 then
     local score=enemy:GetEstimatedDamageToTarget(false,bot,3,DAMAGE_TYPE_PHYSICAL)+(enemy==J.GetProperTarget(bot) and 100 or 0)
     if score>=best then choice,best=primary,score end
    elseif GetUnitToUnitDistance(bot,enemy)<=range and J.CanCastOnTargetAdvanced(enemy) and J.GetRemainStunTime(enemy)<=0.2
     and (J.IsChasingTarget(enemy,bot) or (Useful(enemy) and not (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)))) then return BOT_ACTION_DESIRE_HIGH,enemy end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 return 0
end
local function Shot(target)
 local range=math.min(Range(Powershot),Powershot:GetSpecialValueInt('arrow_range'))
 local eta=Powershot:GetCastPoint()+Powershot:GetChannelTime()+GetUnitToUnitDistance(bot,target)/Powershot:GetSpecialValueInt('arrow_speed')
 local point=J.GetCorrectLoc(target,eta);local delta=point-bot:GetLocation();local length=delta:Length2D()
 if length<1 or length>range then return nil end
 local direction=delta:Normalized();local blockers=0;local hits=0
 for _,unit in ipairs(Units()) do
  if J.IsValid(unit) then
   local offset=J.GetCorrectLoc(unit,eta)-bot:GetLocation();local along=offset.x*direction.x+offset.y*direction.y
   if along>=0 and along<=length and math.abs(offset.x*direction.y-offset.y*direction.x)<=Powershot:GetSpecialValueInt('arrow_width') then
    hits=hits+1;if unit~=target and along<length-1 then blockers=blockers+1 end
   end
  end
 end
 -- Flat attenuation is conservative when the engine compounds reductions.
 local fraction=math.max(0,1-blockers*Powershot:GetSpecialValueInt('damage_reduction')/100)
 return point,Powershot:GetSpecialValueInt('powershot_damage')*fraction,eta,hits
end
function X.ConsiderPowershot()
 if not J.CanCastAbility(Powershot) or (J.GetHP(bot)<0.45 and bot:WasRecentlyDamagedByAnyHero(2)) then return 0 end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,450,true,BOT_MODE_NONE)) do if Enemy(enemy,true) and enemy:GetAttackTarget()==bot then return 0 end end
 local choice,best=nil,0
 for _,enemy in ipairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
  if Enemy(enemy,false) and not J.CannotBeKilled(bot,enemy) and not enemy:HasModifier('modifier_item_blade_mail_reflect') and not enemy:HasModifier('modifier_nyx_assassin_spiked_carapace') then
   local point,damage,eta,hits=Shot(enemy)
   if point~=nil then
    if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,point end
    if (Useful(enemy) or J.IsInTeamFight(bot,1200)) and GetUnitToUnitDistance(bot,enemy)>bot:GetAttackRange() and hits>best then choice,best=point,hits end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 if J.IsAllowedToSpam(bot,Powershot:GetManaCost()) then
  local units={};if J.IsFarming(bot) then units=bot:GetNearbyNeutralCreeps(1600) elseif J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot) then units=bot:GetNearbyLaneCreeps(1600,true) end
  for _,creep in ipairs(units) do
   if Enemy(creep,false) then
    local point,damage,eta,hits=Shot(creep)
    if point~=nil and ((not J.IsLaning(bot) and hits>=3) or (J.IsLaning(bot) and J.IsKeyWordUnit('ranged',creep) and J.WillKillTarget(creep,damage,DAMAGE_TYPE_MAGICAL,eta))) then return BOT_ACTION_DESIRE_HIGH,point end
   end
  end
 end
 return 0
end
function X.ConsiderWindrun()
 if not J.CanCastAbility(Windrun) or bot:HasModifier('modifier_windrunner_windrun') then return 0 end
 if J.GetAttackProjectileDamageByRange(bot,1000)>0 then return BOT_ACTION_DESIRE_HIGH end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,1000,true,BOT_MODE_NONE)) do
  if Enemy(enemy,true) and enemy:GetAttackTarget()==bot and GetUnitToUnitDistance(bot,enemy)<=enemy:GetAttackRange()+100 then return BOT_ACTION_DESIRE_HIGH end
 end
 if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and not bot:HasModifier('modifier_bloodseeker_rupture') then return BOT_ACTION_DESIRE_HIGH end
 local target=J.GetProperTarget(bot)
 if J.IsGoingOnSomeone(bot) and Enemy(target,true) and GetUnitToUnitDistance(bot,target)>bot:GetAttackRange() and not bot:IsRooted()
  and not bot:HasModifier('modifier_bloodseeker_rupture') and not bot:HasModifier('modifier_puck_coiled') and not bot:HasModifier('modifier_slark_pounce_leash') then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderFocusFire()
 if not J.CanCastAbility(FocusFire) or bot:IsDisarmed() or bot:HasModifier('modifier_windrunner_focusfire') then return 0 end
 local target=J.GetProperTarget(bot)
 if J.IsPushing(bot) then target=bot:GetAttackTarget() end
 if (J.IsValid(target) or J.IsValidBuilding(target)) and target:GetTeam()~=bot:GetTeam() and J.CanBeAttacked(target) and J.CanCastOnTargetAdvanced(target)
  and GetUnitToUnitDistance(bot,target)<=Range(FocusFire) and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange()+100
  and not J.CannotBeKilled(bot,target) and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace') and not target:HasModifier('modifier_fountain_glyph') then
  if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) then return BOT_ACTION_DESIRE_HIGH,target end
  if (J.IsPushing(bot) and J.IsValidBuilding(target) or J.IsDoingRoshan(bot)) and J.IsAttacking(bot) and target:GetHealth()>bot:GetAttackDamage()*3 then return BOT_ACTION_DESIRE_HIGH,target end
 end
 return 0
end
function X.ConsiderFocusFireCancel()
 if not J.CanCastAbility(FocusCancel) or not bot:HasModifier('modifier_windrunner_focusfire') then return 0 end
 local target=bot:GetAttackTarget()
 if target~=nil and (not J.CanBeAttacked(target) or target:HasModifier('modifier_item_blade_mail_reflect') or target:HasModifier('modifier_nyx_assassin_spiked_carapace') or J.CannotBeKilled(bot,target)) then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderGaleForce()
 -- Vector direction cannot be expressed by the documented bot API. Do not issue blind displacement.
 return 0
end
function X.ConsiderStolenPowershotSafety()
 local current=GetBot();if not current:IsChanneling() then return false end
 local active=current:GetCurrentActiveAbility();if active==nil or active:IsNull() or active:GetName()~='windrunner_powershot' then return false end
 if not current:IsAlive() or current:NumQueuedActions()>0 or current:IsStunned() or current:IsHexed() or current:IsNightmared() or current:IsSilenced()
  or current:HasModifier('modifier_ringmaster_the_box_buff') or current:HasModifier('modifier_doom_bringer_doom') or current:HasModifier('modifier_item_forcestaff_active') then return false end
 if J.GetHP(current)<0.4 and (current:WasRecentlyDamagedByAnyHero(1) or J.GetAttackProjectileDamageByRange(current,1000)>current:GetHealth()*0.2) then
  -- Cancelling can release a partial arrow; never count it as a full-charge lethal.
  current:Action_ClearActions(true);current:Action_MoveToLocation(J.GetEscapeLoc());return true
 end
 return false
end
function X.ConsiderStolenSpell(ability)
 local name=ability:GetName()
 if name~='windrunner_shackleshot' and name~='windrunner_powershot' and name~='windrunner_windrun' and name~='windrunner_focusfire' and name~='windrunner_focusfire_cancel' and name~='windrunner_gale_force' then return nil end
 Refresh();if J.CanNotUseAbility(bot) or bot:NumQueuedActions()>0 or not J.CanCastAbility(ability) then return false end
 local choices={windrunner_shackleshot=X.ConsiderShackleShot,windrunner_powershot=X.ConsiderPowershot,windrunner_windrun=X.ConsiderWindrun,windrunner_focusfire=X.ConsiderFocusFire,windrunner_focusfire_cancel=X.ConsiderFocusFireCancel,windrunner_gale_force=X.ConsiderGaleForce}
 local desire,target=choices[name]()
 if desire<=0 then return false end
 if name=='windrunner_shackleshot' then J.SetQueuePtToINT(bot,false);bot:ActionQueue_UseAbilityOnEntity(ability,target)
 elseif name=='windrunner_powershot' then J.SetQueuePtToINT(bot,false);bot:ActionQueue_UseAbilityOnLocation(ability,target)
 elseif name=='windrunner_focusfire' then bot:Action_UseAbilityOnEntity(ability,target)
 else bot:Action_UseAbility(ability) end
 return true
end
return X
