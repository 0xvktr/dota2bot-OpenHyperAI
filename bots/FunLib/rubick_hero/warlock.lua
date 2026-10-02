local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot
local FatalBonds,ShadowWord,Upheaval,Offering
local function Refresh()
 bot=GetBot();FatalBonds=bot:GetAbilityByName('warlock_fatal_bonds');ShadowWord=bot:GetAbilityByName('warlock_shadow_word');Upheaval=bot:GetAbilityByName('warlock_upheaval');Offering=bot:GetAbilityByName('warlock_rain_of_chaos')
end
local function Range(a)
 local range=a:GetCastRange()
 for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
 local passive=bot:GetAbilityByName('rubick_arcane_supremacy')
 if passive~=nil and not passive:IsNull() and passive:IsTrained() and not J.HasBreakModifier(bot) then range=range+passive:GetSpecialValueInt('cast_range') end
 return range
end
local function Enemy(unit,pierce)
 return J.IsValid(unit) and (pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit))
end
local function Point(location,range)
 local delta=location-bot:GetLocation();if delta:Length2D()>range then return bot:GetLocation()+delta:Normalized()*range end;return location
end
local function Useful(enemy)
 if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then return true end
 if J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then return true end
 for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,ally) then return true end
 end
 return false
end
function X.ConsiderShadowWord()
 if not J.CanCastAbility(ShadowWord) then return 0 end
 local range=Range(ShadowWord);local radius=ShadowWord:GetSpecialValueInt('spell_aoe');local choice,best=nil,0
 local friends=J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE);friends[#friends+1]=bot
 for _,host in ipairs(friends) do
  if J.IsValidHero(host) and not host:IsIllusion() and not host:IsInvulnerable() and GetUnitToUnitDistance(bot,host)<=range
   and not host:HasModifier('modifier_warlock_shadow_word') then
   local score=0;local seen={}
   local group=J.GetAlliesNearLoc(host:GetLocation(),radius);group[#group+1]=host
   if GetUnitToLocationDistance(bot,host:GetLocation())<=radius then group[#group+1]=bot end
   for _,ally in ipairs(group) do
    if not seen[ally] and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:HasModifier('modifier_ice_blast') and J.GetHP(ally)<0.8 then
     seen[ally]=true;score=score+math.min(ally:GetMaxHealth()-ally:GetHealth(),ShadowWord:GetSpecialValueInt('damage')*ShadowWord:GetSpecialValueFloat('duration'))
     if ally:WasRecentlyDamagedByAnyHero(2) then score=score+100 end
    end
   end
   if score>best and (score>=100 or J.GetHP(host)<0.5) then choice,best=host,score end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) and J.CanCastOnTargetAdvanced(enemy) and not J.CannotBeKilled(bot,enemy) and GetUnitToUnitDistance(bot,enemy)<=range
   and not enemy:HasModifier('modifier_warlock_shadow_word') and not enemy:HasModifier('modifier_item_blade_mail_reflect') then
   if J.WillKillTarget(enemy,ShadowWord:GetSpecialValueInt('damage')*ShadowWord:GetSpecialValueFloat('tick_interval'),DAMAGE_TYPE_MAGICAL,ShadowWord:GetCastPoint()+ShadowWord:GetSpecialValueFloat('tick_interval')) then return BOT_ACTION_DESIRE_HIGH,enemy end
   if Useful(enemy) and J.IsAllowedToSpam(bot,ShadowWord:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH,enemy end
  end
 end
 return 0
end
function X.ConsiderFatalBonds()
 if not J.CanCastAbility(FatalBonds) then return 0 end
 local range=Range(FatalBonds);local radius=FatalBonds:GetSpecialValueInt('search_aoe');local cap=FatalBonds:GetSpecialValueInt('count')
 local units={}
 for _,unit in ipairs(GetUnitList(UNIT_LIST_ENEMIES)) do if Enemy(unit,false) and GetUnitToUnitDistance(bot,unit)<=range+radius then units[#units+1]=unit end end
 local choice,best=nil,0
 for _,host in ipairs(units) do
  if GetUnitToUnitDistance(bot,host)<=range and J.CanCastOnTargetAdvanced(host) and not host:HasModifier('modifier_warlock_fatal_bonds') then
   local count,heroes,useful=0,0,false
   for _,unit in ipairs(units) do
    if GetUnitToUnitDistance(host,unit)<=radius and count<cap then
     count=count+1;if J.IsValidHero(unit) then heroes=heroes+1;useful=useful or Useful(unit) or J.IsInTeamFight(bot,1200) end
    end
   end
   local score=heroes*100+count
   if ((heroes>=2 and useful) or (heroes>=1 and count>=4 and (useful or J.IsLaning(bot)))) and score>best then choice,best=host,score end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 return 0
end
local function OfferingPoint()
 if Offering==nil or Offering:IsNull() or not Offering:IsTrained() or Offering:IsHidden() or not Offering:IsActivated() then return 0 end
 local range=Range(Offering);local radius=Offering:GetSpecialValueInt('aoe');local eta=Offering:GetCastPoint()+Offering:GetSpecialValueFloat('stun_delay')
 local enemies=J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE);local choice,best=nil,0
 for _,host in ipairs(enemies) do
  if Enemy(host,true) then
   local prediction=J.GetCorrectLoc(host,eta);local point=Point(prediction,range)
   if (prediction-point):Length2D()<=radius then
    local count=0;for _,enemy in ipairs(enemies) do if Enemy(enemy,true) and (J.GetCorrectLoc(enemy,eta)-point):Length2D()<=radius then count=count+1 end end
    if host:IsChanneling() then return BOT_ACTION_DESIRE_HIGH,point,count,true end
    local save=Useful(host) and (J.IsRetreating(bot) or J.GetHP(bot)<0.4)
    if (count>=2 and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200))) or save then
     if count>best then choice,best=point,count end
    end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice,best,false end
 return 0
end
function X.ConsiderOffering()
 if not J.CanCastAbility(Offering) then return 0 end
 return OfferingPoint()
end
function X.ConsiderUpheaval()
 if not J.CanCastAbility(Upheaval) or J.GetHP(bot)<0.45 or J.IsLocHaveTower(700,true,bot:GetLocation()) or J.IsLocationInChrono(bot:GetLocation()) or J.IsLocationInBlackHole(bot:GetLocation()) then return 0 end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,500,true,BOT_MODE_NONE)) do
  if Enemy(enemy,true) and (enemy:GetAttackTarget()==bot or J.IsChasingTarget(enemy,bot)) then return 0 end
 end
 local range=Range(Upheaval);local radius=Upheaval:GetSpecialValueInt('aoe')
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) and (Useful(enemy) or J.IsInTeamFight(bot,1200)) then
   local prediction=J.GetCorrectLoc(enemy,Upheaval:GetCastPoint()+1);local point=Point(prediction,range)
   if (prediction-point):Length2D()<=radius*0.75 then return BOT_ACTION_DESIRE_HIGH,point end
  end
 end
 if bot:HasModifier('modifier_item_aghanims_shard') and J.IsAllowedToSpam(bot,Upheaval:GetManaCost()) and #J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)==0 then
  local units={};if J.IsFarming(bot) then units=bot:GetNearbyNeutralCreeps(range+radius) elseif J.IsPushing(bot) or J.IsDefending(bot) then units=bot:GetNearbyLaneCreeps(range+radius,true) end
  for _,host in ipairs(units) do
   local point=Point(host:GetLocation(),range);local count=0
   for _,unit in ipairs(units) do if Enemy(unit,false) and GetUnitToLocationDistance(unit,point)<=radius*0.75 then count=count+1 end end
   if count>=3 then return BOT_ACTION_DESIRE_HIGH,point end
  end
 end
 return 0
end
function X.ConsiderStolenUpheavalSafety()
 local current=GetBot();if not current:IsChanneling() then return false end
 local active=current:GetCurrentActiveAbility()
 if active==nil or active:IsNull() or active:GetName()~='warlock_upheaval' then return false end
 if not current:IsAlive() or current:NumQueuedActions()>0 or current:IsStunned() or current:IsHexed() or current:IsNightmared()
  or current:IsSilenced() or current:HasModifier('modifier_doom_bringer_doom') or current:HasModifier('modifier_ringmaster_the_box_buff') or current:HasModifier('modifier_item_forcestaff_active') then return false end
 if J.GetHP(current)<0.4 and (current:WasRecentlyDamagedByAnyHero(2) or J.GetAttackProjectileDamageByRange(current,1000)>current:GetHealth()*0.2) then
  current:Action_ClearActions(true);current:Action_MoveToLocation(J.GetEscapeLoc());return true
 end
 return false
end
function X.ConsiderStolenSpell(ability)
 local name=ability:GetName()
 if name~='warlock_fatal_bonds' and name~='warlock_shadow_word' and name~='warlock_upheaval' and name~='warlock_rain_of_chaos' then return nil end
 Refresh();if J.CanNotUseAbility(bot) or bot:NumQueuedActions()>0 or not J.CanCastAbility(ability) then return false end
 local choices={warlock_fatal_bonds=X.ConsiderFatalBonds,warlock_shadow_word=X.ConsiderShadowWord,warlock_upheaval=X.ConsiderUpheaval,warlock_rain_of_chaos=X.ConsiderOffering}
 local desire,target=choices[name]()
 if desire<=0 then return false end
 J.SetQueuePtToINT(bot,true)
 if name=='warlock_fatal_bonds' or name=='warlock_shadow_word' then bot:ActionQueue_UseAbilityOnEntity(ability,target) else bot:ActionQueue_UseAbilityOnLocation(ability,target) end
 return true
end
return X
