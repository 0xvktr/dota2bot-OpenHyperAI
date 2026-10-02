local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot
local ArcticBurn,SplinterBlast,ColdEmbrace,WintersCurse
local function Refresh()
 bot=GetBot();ArcticBurn=bot:GetAbilityByName('winter_wyvern_arctic_burn');SplinterBlast=bot:GetAbilityByName('winter_wyvern_splinter_blast');ColdEmbrace=bot:GetAbilityByName('winter_wyvern_cold_embrace');WintersCurse=bot:GetAbilityByName('winter_wyvern_winters_curse')
end
local function Handle(a)
 return a~=nil and not a:IsNull() and not a:IsHidden() and a:IsActivated() and a:IsTrained()
end
local function Range(a)
 local range=a:GetCastRange()
 for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
 local passive=bot:GetAbilityByName('rubick_arcane_supremacy')
 if passive~=nil and not passive:IsNull() and passive:IsTrained() and not J.HasBreakModifier(bot) then range=range+passive:GetSpecialValueInt('cast_range') end
 return range
end
local function OwnedCurse(unit)
 local found=false
 for _,name in ipairs({'modifier_winter_wyvern_winters_curse','modifier_winter_wyvern_winters_curse_aura'}) do
  if unit:HasModifier(name) then
   found=true;local index=unit:GetModifierByName(name);if index<0 then return false end
   local source=unit:GetModifierSourceAbility(index)
   if source==nil or source:IsNull() or source:GetName()~='winter_wyvern_winters_curse' or source:GetCaster()~=bot then return false end
  end
 end
 return found
end
local function Enemy(unit,pierce)
 if not J.IsValid(unit) or J.IsSuspiciousIllusion(unit) then return false end
 if unit:HasModifier('modifier_winter_wyvern_winters_curse') or unit:HasModifier('modifier_winter_wyvern_winters_curse_aura') then
  return OwnedCurse(unit) and unit:CanBeSeen() and not unit:IsInvulnerable() and (pierce or not unit:IsMagicImmune())
   and not unit:HasModifier('modifier_necrolyte_reapers_scythe') and not unit:HasModifier('modifier_troll_warlord_battle_trance')
 end
 return pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit)
end
local function Useful(enemy)
 if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then return true end
 if J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then return true end
 for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and (J.IsChasingTarget(enemy,ally) or enemy:GetAttackTarget()==ally) then return true end
 end
 return false
end
function X.ConsiderArcticBurn()
 if not Handle(ArcticBurn) then return 0 end
 local toggled=bot:HasScepter() and ArcticBurn:GetToggleState()
 local active=toggled or bot:HasModifier('modifier_winter_wyvern_arctic_burn_flight')
 local range=bot:GetAttackRange()+(active and 0 or ArcticBurn:GetSpecialValueInt('attack_range_bonus'))
 local wanted=J.IsStuck(bot) or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and not bot:HasModifier('modifier_bloodseeker_rupture'))
 if not bot:IsDisarmed() then
  for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
   if Enemy(enemy,false) and (Useful(enemy) or J.IsInTeamFight(bot,1200)) and not J.CannotBeKilled(bot,enemy)
    and not enemy:HasModifier('modifier_item_blade_mail_reflect') and not enemy:HasModifier('modifier_nyx_assassin_spiked_carapace') then wanted=true;break end
  end
 end
 if bot:HasScepter() then
  local reserve=Handle(ColdEmbrace) and ColdEmbrace:GetManaCost() or 0
  if bot:GetMana()<ArcticBurn:GetSpecialValueFloat('mana_cost_scepter')*2+reserve then wanted=false end
  if toggled and not wanted then return BOT_ACTION_DESIRE_HIGH end
  if not toggled and wanted and ArcticBurn:IsFullyCastable() then return BOT_ACTION_DESIRE_HIGH end
 elseif not active and wanted and ArcticBurn:IsFullyCastable() then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
local function Hosts()
 local units={};local seen={}
 for _,kind in ipairs({UNIT_LIST_ENEMIES,UNIT_LIST_ALLIES}) do for _,unit in ipairs(GetUnitList(kind)) do if not seen[unit] then units[#units+1]=unit;seen[unit]=true end end end
 for _,unit in ipairs(bot:GetNearbyNeutralCreeps(1600)) do if not seen[unit] then units[#units+1]=unit;seen[unit]=true end end
 return units
end
local function BlastHost(target)
 local choice,best=nil,math.huge;local range=Range(SplinterBlast);local radius=SplinterBlast:GetSpecialValueInt('split_radius')
 for _,host in ipairs(Hosts()) do
  if host~=bot and host~=target and J.IsValid(host) and GetUnitToUnitDistance(bot,host)<=range
   and (host:GetTeam()==bot:GetTeam() or (Enemy(host,false) and J.CanCastOnTargetAdvanced(host))) then
   local eta=SplinterBlast:GetCastPoint()+math.min(SplinterBlast:GetSpecialValueFloat('projectile_max_time'),GetUnitToUnitDistance(bot,host)/SplinterBlast:GetSpecialValueInt('projectile_speed'))
   local point=J.GetCorrectLoc(host,eta);local targetPoint=J.GetCorrectLoc(target,eta)
   if (targetPoint-point):Length2D()<=radius then
    eta=eta+(targetPoint-point):Length2D()/SplinterBlast:GetSpecialValueInt('secondary_projectile_speed')
    if (J.GetCorrectLoc(target,eta)-point):Length2D()<=radius and eta<best then choice,best=host,eta end
   end
  end
 end
 return choice,best
end
function X.ConsiderSplinterBlast()
 if not J.CanCastAbility(SplinterBlast) then return 0 end
 local damage=SplinterBlast:GetSpecialValueInt('damage');local choice,best=nil,0
 for _,enemy in ipairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
  if Enemy(enemy,false) and not J.CannotBeKilled(bot,enemy) and not enemy:HasModifier('modifier_item_blade_mail_reflect') and not enemy:HasModifier('modifier_nyx_assassin_spiked_carapace') then
   local host,eta=BlastHost(enemy)
   if host~=nil then
    if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,host end
    if Useful(enemy) or J.IsInTeamFight(bot,1200) then
     local score=enemy:GetMaxHealth()-enemy:GetHealth()+100
     if score>best then choice,best=host,score end
    end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 if J.IsAllowedToSpam(bot,SplinterBlast:GetManaCost()) and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot)) then
  local creeps=J.IsFarming(bot) and bot:GetNearbyNeutralCreeps(1600) or bot:GetNearbyLaneCreeps(1600,true)
  for _,host in ipairs(creeps) do
   if Enemy(host,false) and GetUnitToUnitDistance(bot,host)<=Range(SplinterBlast) and J.CanCastOnTargetAdvanced(host) then
    local eta=SplinterBlast:GetCastPoint()+math.min(SplinterBlast:GetSpecialValueFloat('projectile_max_time'),GetUnitToUnitDistance(bot,host)/SplinterBlast:GetSpecialValueInt('projectile_speed'));local point=J.GetCorrectLoc(host,eta);local count=0
    for _,creep in ipairs(creeps) do
     if creep~=host and Enemy(creep,false) and (J.GetCorrectLoc(creep,eta)-point):Length2D()<=SplinterBlast:GetSpecialValueInt('split_radius') then
      local arrival=eta+GetUnitToUnitDistance(host,creep)/SplinterBlast:GetSpecialValueInt('secondary_projectile_speed')
      if not J.IsLaning(bot) or J.WillKillTarget(creep,damage,DAMAGE_TYPE_MAGICAL,arrival) then count=count+1 end
     end
    end
    if count>=3 then return BOT_ACTION_DESIRE_HIGH,host end
   end
  end
 end
 return 0
end
local function Threat(ally,duration)
 local physical=J.GetAttackProjectileDamageByRange(ally,1000);local other=0
 for _,enemy in ipairs(J.GetNearbyHeroes(ally,1200,true,BOT_MODE_NONE)) do
  if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) then
   local p=enemy:GetEstimatedDamageToTarget(false,ally,duration,DAMAGE_TYPE_PHYSICAL)
   other=other+math.max(0,enemy:GetEstimatedDamageToTarget(false,ally,duration,DAMAGE_TYPE_ALL)-p)
   if enemy:GetAttackTarget()==ally and not enemy:IsDisarmed() and GetUnitToUnitDistance(enemy,ally)<=enemy:GetAttackRange()+150 then physical=physical+p end
  end
 end
 return physical,other
end
function X.ConsiderColdEmbrace()
 if not J.CanCastAbility(ColdEmbrace) then return 0 end
 local friends={bot};for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(Range(ColdEmbrace),1600),false,BOT_MODE_NONE)) do friends[#friends+1]=ally end
 local choice,best=nil,0;local duration=ColdEmbrace:GetSpecialValueFloat('duration')
 for _,ally in ipairs(friends) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and GetUnitToUnitDistance(bot,ally)<=Range(ColdEmbrace)
   and not ally:HasModifier('modifier_winter_wyvern_cold_embrace') and not ally:HasModifier('modifier_necrolyte_reapers_scythe') then
   local physical,other=Threat(ally,duration)
   local heal=(ColdEmbrace:GetSpecialValueInt('heal_additive')+ally:GetMaxHealth()*ColdEmbrace:GetSpecialValueFloat('heal_percentage')/100)*duration
   if ally:HasModifier('modifier_ice_blast') then heal=0 end
   local need=ally:GetMaxHealth()-ally:GetHealth();local lethalPhysical=physical>=ally:GetHealth()
   local save=physical>0 and (J.GetHP(ally)<0.45 or lethalPhysical) and (physical>other or lethalPhysical) and not J.IsInEtherealForm(ally)
   local recovery=other==0 and physical==0 and need>=math.max(150,heal*0.8) and J.GetHP(ally)<0.65 and heal>0
   if (save or recovery) and (not ally:IsChanneling() or lethalPhysical)
    and not (J.IsGoingOnSomeone(ally) and recovery and J.GetHP(ally)>0.35) then
    local score=math.min(need,heal)+physical-other+(lethalPhysical and 1000 or 0)
    if score>best then choice,best=ally,score end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 return 0
end
function X.ConsiderWintersCurse()
 if not J.CanCastAbility(WintersCurse) then return 0 end
 local range=Range(WintersCurse);local radius=WintersCurse:GetSpecialValueInt('radius');local choice,best=nil,0
 for _,target in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(target,true) and J.CanCastOnTargetAdvanced(target) and not J.CannotBeKilled(bot,target)
   and not target:HasModifier('modifier_winter_wyvern_winters_curse') and not target:HasModifier('modifier_winter_wyvern_winters_curse_aura') then
   if target:IsChanneling() then return BOT_ACTION_DESIRE_HIGH,target end
   local escape=J.IsRetreating(bot) and J.IsChasingTarget(target,bot) and bot:WasRecentlyDamagedByAnyHero(2)
   local disable=target:HasModifier('modifier_faceless_void_chronosphere_freeze') or target:HasModifier('modifier_enigma_black_hole_pull')
   if escape then return BOT_ACTION_DESIRE_HIGH,target end
   if not disable and (Useful(target) or J.IsInTeamFight(bot,1200)) then
    local point=J.GetCorrectLoc(target,WintersCurse:GetCastPoint());local count,damage=0,0
    for _,attacker in ipairs(GetUnitList(UNIT_LIST_ENEMIES)) do
     if attacker~=target and Enemy(attacker,false) and not attacker:IsDisarmed() and not J.IsDisabled(attacker)
      and (J.GetCorrectLoc(attacker,WintersCurse:GetCastPoint())-point):Length2D()<=radius then
      if J.IsValidHero(attacker) then count=count+1 end
      damage=damage+attacker:GetEstimatedDamageToTarget(false,target,WintersCurse:GetSpecialValueFloat('duration'),DAMAGE_TYPE_PHYSICAL)
     end
    end
    if count>=1 and damage>0 then
     local score=damage/math.max(1,target:GetHealth())+count
     if score>best then choice,best=target,score end
    end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 return 0
end

function X.ConsiderStolenArcticBurnToggle()
 local current=GetBot();local ability=current:GetAbilityByName('winter_wyvern_arctic_burn')
 if not Handle(ability) or not current:HasScepter() or J.CanNotUseAbility(current) or current:NumQueuedActions()>0 then return false end
 Refresh();if X.ConsiderArcticBurn()>0 then current:Action_UseAbility(ability);return true end
 return false
end
function X.ConsiderStolenSpell(ability)
 if ability==nil then return nil end
 local name=ability:GetName()
 if name~='winter_wyvern_arctic_burn' and name~='winter_wyvern_splinter_blast' and name~='winter_wyvern_cold_embrace' and name~='winter_wyvern_winters_curse' then return nil end
 Refresh();if J.CanNotUseAbility(bot) or J.HasQueuedAction(bot) or not Handle(ability) then return false end
 local desire,target=0,nil
 if name=='winter_wyvern_arctic_burn' then ArcticBurn=ability;desire=X.ConsiderArcticBurn()
 elseif name=='winter_wyvern_splinter_blast' then SplinterBlast=ability;desire,target=X.ConsiderSplinterBlast()
 elseif name=='winter_wyvern_cold_embrace' then ColdEmbrace=ability;desire,target=X.ConsiderColdEmbrace()
 else WintersCurse=ability;desire,target=X.ConsiderWintersCurse() end
 if desire<=0 then return false end
 if name=='winter_wyvern_arctic_burn' then bot:Action_UseAbility(ability) else bot:Action_UseAbilityOnEntity(ability,target) end
 return true
end
return X
