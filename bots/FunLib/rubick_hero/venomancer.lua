local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot
local VenomousGale,Snakebite,PlagueWard,NoxiousPlague
local function Refresh()
 bot=GetBot();VenomousGale=bot:GetAbilityByName('venomancer_venomous_gale');Snakebite=bot:GetAbilityByName('venomancer_snakebite');PlagueWard=bot:GetAbilityByName('venomancer_plague_ward');NoxiousPlague=bot:GetAbilityByName('venomancer_noxious_plague')
end
local function Range(ability)
 local range=ability:GetCastRange()
 for slot=0,5 do
  local item=bot:GetItemInSlot(slot)
  if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end
 end
 local passive=bot:GetAbilityByName('rubick_arcane_supremacy')
 if passive~=nil and not passive:IsNull() and passive:IsTrained() and not J.HasBreakModifier(bot) then range=range+passive:GetSpecialValueInt('cast_range') end
 return range
end
local function Enemy(unit)
 return J.IsValid(unit) and J.CanCastOnNonMagicImmune(unit) and not J.CannotBeKilled(bot,unit)
  and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Infected(unit,name)
 for index=0,unit:NumModifiers()-1 do
  local source=unit:GetModifierSourceAbility(index)
  if source~=nil and not source:IsNull() and source:GetName()==name then return true end
 end
 return false
end
local function Clamp(point,range)
 local offset=point-bot:GetLocation()
 if offset:Length2D()>range then return bot:GetLocation()+offset:Normalized()*range end
 return point
end
local function Useful(enemy)
 if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then return true end
 if J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then return true end
 for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,ally) then return true end
 end
 return false
end
local function GalePoint(unit,range,speed)
 return Clamp(J.GetCorrectLoc(unit,VenomousGale:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/speed),range)
end
local function Hits(unit,point,range,width,speed)
 local position=J.GetCorrectLoc(unit,VenomousGale:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/speed)-bot:GetLocation()
 local direction=(point-bot:GetLocation()):Normalized();local along=position.x*direction.x+position.y*direction.y
 return along>=0 and along<=range and (position-direction*along):Length2D()<=width
end
function X.ConsiderVenomousGale()
 if not J.CanCastAbility(VenomousGale) then return 0 end
 local range=Range(VenomousGale);local speed=VenomousGale:GetSpecialValueInt('speed');local width=VenomousGale:GetSpecialValueInt('radius')
 local heroes=J.GetNearbyHeroes(bot,math.min(range+width,1600),true,BOT_MODE_NONE);local choice,best=nil,0
 for _,enemy in ipairs(heroes) do
  if Enemy(enemy) then
   local point=GalePoint(enemy,range,speed)
   if Hits(enemy,point,range,width,speed) then
    local eta=VenomousGale:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/speed
    if J.WillKillTarget(enemy,VenomousGale:GetSpecialValueInt('strike_damage'),DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,point end
    if (Useful(enemy) or J.IsInTeamFight(bot,1200)) and not Infected(enemy,'venomancer_venomous_gale') then
     local count=0;for _,other in ipairs(heroes) do if Enemy(other) and Hits(other,point,range,width,speed) then count=count+1 end end
     if count>best then choice,best=point,count end
    end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 local target=J.GetProperTarget(bot)
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(target) and J.IsAttacking(bot) and not Infected(target,'venomancer_venomous_gale')
  and J.IsAllowedToSpam(bot,VenomousGale:GetManaCost()) then
  local point=GalePoint(target,range,speed);if Hits(target,point,range,width,speed) then return BOT_ACTION_DESIRE_HIGH,point end
 end
 if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot)) and J.IsAllowedToSpam(bot,VenomousGale:GetManaCost()) then
  local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
  for _,creep in ipairs(creeps) do
   if Enemy(creep) then
    local point=GalePoint(creep,range,speed);local count,kills=0,0
    for _,other in ipairs(creeps) do
     if Enemy(other) and not other:HasModifier('modifier_fountain_glyph') and Hits(other,point,range,width,speed) then
      count=count+1
      if J.WillKillTarget(other,VenomousGale:GetSpecialValueInt('strike_damage'),DAMAGE_TYPE_MAGICAL,VenomousGale:GetCastPoint()+GetUnitToUnitDistance(bot,other)/speed) then kills=kills+1 end
     end
    end
    if (not J.IsLaning(bot) and count>=3) or (J.IsLaning(bot) and kills>=2) then return BOT_ACTION_DESIRE_HIGH,point end
   end
  end
 end
 return 0
end
function X.ConsiderSnakebite()
 if not J.CanCastAbility(Snakebite) then return 0 end
 local range=Range(Snakebite)
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
   if J.WillKillTarget(enemy,Snakebite:GetSpecialValueInt('base_damage'),DAMAGE_TYPE_MAGICAL,Snakebite:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,enemy end
   local attacking=enemy:GetAttackTarget()
   if not Infected(enemy,'venomancer_snakebite') and (Useful(enemy) or (J.IsValidHero(attacking) and attacking:GetTeam()==bot:GetTeam() and GetUnitToUnitDistance(enemy,attacking)<=enemy:GetAttackRange()+100)
    or (J.IsLaning(bot) and J.IsAllowedToSpam(bot,Snakebite:GetManaCost()) and not J.IsLocHaveTower(700,true,bot:GetLocation()))) then return BOT_ACTION_DESIRE_HIGH,enemy end
  end
 end
 return 0
end
function X.ConsiderNoxiousPlague()
 if not J.CanCastAbility(NoxiousPlague) then return 0 end
 local range=Range(NoxiousPlague);local spread=NoxiousPlague:GetSpecialValueInt('debuff_radius');local choice,best=nil,0
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range and not Infected(enemy,'venomancer_noxious_plague') then
   local nearby=0;for _,other in ipairs(J.GetEnemiesNearLoc(enemy:GetLocation(),spread)) do if other~=enemy and J.IsValidHero(other) and Enemy(other) then nearby=nearby+1 end end
   if Useful(enemy) or (J.IsInTeamFight(bot,1200) and nearby>=1) then
    local score=nearby*100+(enemy:GetMaxHealth()*NoxiousPlague:GetSpecialValueInt('damage_per_second')*0.01)
    if Infected(enemy,'venomancer_snakebite') or Infected(enemy,'venomancer_venomous_gale') then score=score+100 end
    if enemy:WasRecentlyDamagedByAnyHero(2) and J.GetHP(enemy)<0.4 then score=score+100 end
    if score>best then choice,best=enemy,score end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 return 0
end
function X.ConsiderPlagueWard()
 if not J.CanCastAbility(PlagueWard) or not J.IsAllowedToSpam(bot,PlagueWard:GetManaCost()) then return 0 end
 local range=Range(PlagueWard);local target=J.GetProperTarget(bot);local point
 if J.IsValidHero(target) and J.CanBeAttacked(target) and Useful(target) and GetUnitToUnitDistance(bot,target)<=range+400 then
  point=Clamp(target:GetLocation()+(bot:GetLocation()-target:GetLocation()):Normalized()*150,range)
 elseif J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
  for _,enemy in ipairs(J.GetNearbyHeroes(bot,1000,true,BOT_MODE_NONE)) do
   if J.IsValidHero(enemy) and J.IsChasingTarget(enemy,bot) then point=Clamp(bot:GetLocation()+(enemy:GetLocation()-bot:GetLocation())*0.5,range);break end
  end
 elseif (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and (J.IsValid(target) or J.IsValidBuilding(target))
  and J.CanBeAttacked(target) and J.IsAttacking(bot) and not target:HasModifier('modifier_fountain_glyph') and GetUnitToUnitDistance(bot,target)<=range+400 then
  point=Clamp(target:GetLocation()+(bot:GetLocation()-target:GetLocation()):Normalized()*300,range)
 end
 if point==nil then
  for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range+400,1600),true,BOT_MODE_NONE)) do
   if J.IsValidHero(enemy) and J.CanBeAttacked(enemy) and Useful(enemy) then point=Clamp(enemy:GetLocation()+(bot:GetLocation()-enemy:GetLocation()):Normalized()*150,range);break end
  end
 end
 if point==nil or not IsLocationPassable(point) or J.IsLocationInChrono(point) or J.IsLocationInBlackHole(point) then return 0 end
 local count=0
 -- Wards are excluded from the nearby-creep API; inspect actual allied ward handles only when a useful cast is ready.
 for _,unit in ipairs(GetUnitList(UNIT_LIST_ALLIES)) do
  if unit~=nil and not unit:IsNull() and unit:IsAlive() and unit:GetPlayerID()==bot:GetPlayerID() and string.find(unit:GetUnitName(),'npc_dota_venomancer_plague_ward')
   and GetUnitToLocationDistance(unit,point)<=250 then count=count+1 end
 end
 if count<2 then return BOT_ACTION_DESIRE_HIGH,point end
 return 0
end
function X.ConsiderPlagueWardMinion(unit)
 local owner=GetBot()
 if unit==nil or unit:IsNull() or not unit:IsAlive() or unit:GetTeam()~=owner:GetTeam() or unit:GetPlayerID()~=owner:GetPlayerID()
  or not string.find(unit:GetUnitName(),'npc_dota_venomancer_plague_ward') then return false end
 if unit:IsInvulnerable() or unit:IsStunned() or unit:IsHexed() or unit:IsDisarmed() or unit:IsChanneling() or unit:IsUsingAbility() or unit:IsCastingAbility() or unit:NumQueuedActions()>0 then return true end
 local target,best=nil,-1;local range=unit:GetAttackRange()
 for _,enemy in ipairs(unit:GetNearbyHeroes(math.min(range,1600),true,BOT_MODE_NONE)) do
  if J.IsValidHero(enemy) and J.CanBeAttacked(enemy) and GetUnitToUnitDistance(unit,enemy)<=range then
   local score=1-enemy:GetHealth()/enemy:GetMaxHealth()
   if not enemy:HasModifier('modifier_venomancer_poison_sting') then score=score+1 end
   if score>best then target,best=enemy,score end
  end
 end
 if target==nil then
  for _,creep in ipairs(unit:GetNearbyCreeps(math.min(range,1600),true)) do if J.IsValid(creep) and J.CanBeAttacked(creep) and not creep:HasModifier('modifier_fountain_glyph') then target=creep;break end end
 end
 if target==nil then
  for _,tower in ipairs(unit:GetNearbyTowers(math.min(range,1600),true)) do if J.IsValidBuilding(tower) and J.CanBeAttacked(tower) and not tower:HasModifier('modifier_fountain_glyph') then target=tower;break end end
 end
 if target~=nil and target~=unit:GetAttackTarget() then unit:Action_AttackUnit(target,true) end
 return true
end
function X.ConsiderStolenPlagueWardMinion(unit) return X.ConsiderPlagueWardMinion(unit) end
function X.ConsiderStolenSpell(ability)
 local name=ability:GetName()
 if name~='venomancer_venomous_gale' and name~='venomancer_snakebite' and name~='venomancer_plague_ward' and name~='venomancer_noxious_plague' then return nil end
 Refresh();if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
 local choices={venomancer_venomous_gale=X.ConsiderVenomousGale,venomancer_snakebite=X.ConsiderSnakebite,venomancer_plague_ward=X.ConsiderPlagueWard,venomancer_noxious_plague=X.ConsiderNoxiousPlague}
 local desire,target=choices[name]()
 if desire>0 then
  if name=='venomancer_venomous_gale' or name=='venomancer_plague_ward' then bot:Action_UseAbilityOnLocation(ability,target) else bot:Action_UseAbilityOnEntity(ability,target) end
  return true
 end
 return false
end
return X
