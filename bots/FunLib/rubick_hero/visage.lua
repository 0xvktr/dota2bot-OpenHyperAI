local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local Familiar=require(GetScriptDirectory()..'/FunLib/minion_lib/familiars')
local bot
local GraveChill,SoulAssumption,GravekeepersCloak,SilentAsTheGrave,SummonFamiliars
local function Refresh()
 bot=GetBot();GraveChill=bot:GetAbilityByName('visage_grave_chill');SoulAssumption=bot:GetAbilityByName('visage_soul_assumption');GravekeepersCloak=bot:GetAbilityByName('visage_gravekeepers_cloak');SilentAsTheGrave=bot:GetAbilityByName('visage_silent_as_the_grave');SummonFamiliars=bot:GetAbilityByName('visage_summon_familiars')
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
 return J.IsValid(unit) and J.CanCastOnNonMagicImmune(unit) and J.CanCastOnTargetAdvanced(unit) and not J.CannotBeKilled(bot,unit)
  and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Useful(enemy)
 if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then return true end
 if J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then return true end
 for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,ally) then return true end
 end
 return false
end
local function FlightApproach()
 local target=J.GetProperTarget(bot)
 return bot:HasModifier('modifier_visage_silent_as_the_grave') and J.IsGoingOnSomeone(bot) and J.IsValidHero(target)
  and GetUnitToUnitDistance(bot,target)>bot:GetAttackRange()+100 and not bot:WasRecentlyDamagedByAnyHero(1)
end
function X.ConsiderGraveChill()
 if not J.CanCastAbility(GraveChill) or FlightApproach() then return 0 end
 local range=Range(GraveChill);local choice,best=nil,-1
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy) and GetUnitToUnitDistance(bot,enemy)<=range and not enemy:HasModifier('modifier_visage_grave_chill_debuff')
   and (Useful(enemy) or J.IsInTeamFight(bot,1200) or (J.IsLaning(bot) and J.IsAllowedToSpam(bot,GraveChill:GetManaCost()))) then
   local score=enemy:GetEstimatedDamageToTarget(false,bot,3,DAMAGE_TYPE_PHYSICAL)
   if enemy:GetAttackTarget()~=nil then score=score+100 end
   if enemy==J.GetProperTarget(bot) then score=score+50 end
   if score>best then choice,best=enemy,score end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 local target=J.GetProperTarget(bot)
 if (J.IsFarming(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(target) and J.IsAttacking(bot) and GetUnitToUnitDistance(bot,target)<=range
  and not bot:HasModifier('modifier_visage_grave_chill_buff') and J.IsAllowedToSpam(bot,GraveChill:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH,target end
 return 0
end
function X.ConsiderSoulAssumption()
 if not J.CanCastAbility(SoulAssumption) then return 0 end
 local index=bot:GetModifierByName('modifier_visage_soul_assumption');local stacks=0;local remaining=0
 if index>=0 then stacks=math.max(0,math.min(bot:GetModifierStackCount(index),SoulAssumption:GetSpecialValueInt('stack_limit')));remaining=bot:GetModifierRemainingDuration(index) end
 local range=Range(SoulAssumption);local damage=SoulAssumption:GetSpecialValueInt('soul_base_damage')+stacks*SoulAssumption:GetSpecialValueInt('soul_charge_damage')
 local choice,hp=nil,math.huge
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
   local eta=SoulAssumption:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/SoulAssumption:GetSpecialValueInt('bolt_speed')
   if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,enemy end
   if not FlightApproach() and (Useful(enemy) or J.IsInTeamFight(bot,1200)) and (stacks>=SoulAssumption:GetSpecialValueInt('stack_limit') or (stacks>=2 and remaining<1.5))
    and enemy:GetHealth()<hp then choice,hp=enemy,enemy:GetHealth() end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 local target=J.GetProperTarget(bot)
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(target) and J.IsAttacking(bot) and GetUnitToUnitDistance(bot,target)<=range
  and stacks>=SoulAssumption:GetSpecialValueInt('stack_limit') then return BOT_ACTION_DESIRE_HIGH,target end
 return 0
end
function X.ConsiderGravekeepersCloak()
 if not J.CanCastAbility(GravekeepersCloak) then return 0 end
 local threatened=bot:WasRecentlyDamagedByAnyHero(2) or #J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)>0 or J.GetAttackProjectileDamageByRange(bot,1000)>bot:GetHealth()*0.25
 if J.GetHP(bot)<0.5 and threatened then return BOT_ACTION_DESIRE_HIGH end
 if J.GetHP(bot)<0.4 and not bot:HasModifier('modifier_ice_blast') and J.IsAllowedToSpam(bot,GravekeepersCloak:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
local function Familiars()
 local units={}
 for _,unit in ipairs(GetUnitList(UNIT_LIST_ALLIES)) do
  if unit~=nil and not unit:IsNull() and unit:IsAlive() and unit:GetTeam()==bot:GetTeam() and unit:GetPlayerID()==bot:GetPlayerID()
   and string.find(unit:GetUnitName(),'npc_dota_visage_familiar') then units[#units+1]=unit end
 end
 return units
end
function X.ConsiderSummonFamiliars()
 if not J.CanCastAbility(SummonFamiliars) or FlightApproach() or (bot.visageSummonAttemptTime~=nil and DotaTime()-bot.visageSummonAttemptTime<0.75) then return 0 end
 local units=Familiars();local desired=SummonFamiliars:GetSpecialValueInt('familiar_count')
 if #units<desired then return BOT_ACTION_DESIRE_HIGH end
 if J.IsInTeamFight(bot,1200) then
  local endangered=0
  for _,unit in ipairs(units) do
   if J.GetHP(unit)<0.25 and unit:WasRecentlyDamagedByAnyHero(2) and not unit:HasModifier('modifier_visage_summon_familiars_stone_form_buff') then endangered=endangered+1 end
  end
  if endangered==#units then return BOT_ACTION_DESIRE_HIGH end
 end
 return 0
end
function X.ConsiderSilentAsTheGrave()
 if not J.CanCastAbility(SilentAsTheGrave) or bot:HasModifier('modifier_visage_silent_as_the_grave') or J.IsRealInvisible(bot) then return 0 end
 local target=J.GetProperTarget(bot)
 if J.IsStuck(bot) then return BOT_ACTION_DESIRE_HIGH end
 if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH end
 if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and not J.CannotBeKilled(bot,target) and GetUnitToUnitDistance(bot,target)>bot:GetAttackRange()+100
  and GetUnitToUnitDistance(bot,target)<=1800 then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderStolenFamiliarMinion(unit) return Familiar.Think(GetBot(),unit) end
function X.ConsiderStolenSpell(ability)
 local name=ability:GetName()
 if name~='visage_grave_chill' and name~='visage_soul_assumption' and name~='visage_gravekeepers_cloak' and name~='visage_silent_as_the_grave' and name~='visage_summon_familiars' then return nil end
 Refresh();if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
 local choices={visage_grave_chill=X.ConsiderGraveChill,visage_soul_assumption=X.ConsiderSoulAssumption,visage_gravekeepers_cloak=X.ConsiderGravekeepersCloak,visage_silent_as_the_grave=X.ConsiderSilentAsTheGrave,visage_summon_familiars=X.ConsiderSummonFamiliars}
 local desire,target=choices[name]()
 if desire>0 then
  if name=='visage_grave_chill' or name=='visage_soul_assumption' then bot:Action_UseAbilityOnEntity(ability,target) else bot:Action_UseAbility(ability) end
  if name=='visage_summon_familiars' then bot.visageSummonAttemptTime=DotaTime() end
  return true
 end
 return false
end
return X
