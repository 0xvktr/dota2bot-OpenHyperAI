local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local U=require(GetScriptDirectory()..'/FunLib/minion_lib/utils')
local I=dofile(GetScriptDirectory()..'/FunLib/minion_lib/illusions')
local X={}
local bot,MagicMissile,WaveOfTerror,NetherSwap
local function Range(ability)
 local range=ability:GetCastRange()
 if not bot:IsIllusion() then
  for slot=0,5 do
   local item=bot:GetItemInSlot(slot)
   if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end
  end
 end
 local passive=bot:GetAbilityByName('rubick_arcane_supremacy')
 if passive~=nil and not passive:IsNull() and passive:IsTrained() and not J.HasBreakModifier(bot) then range=range+passive:GetSpecialValueInt('cast_range') end
 return range
end
local function Enemy(unit,pierce)
 return J.IsValid(unit) and (pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit))
  and not J.CannotBeKilled(bot,unit) and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Fighting()
 return J.IsGoingOnSomeone(bot) or (bot:IsIllusion() and J.IsValidHero(bot:GetAttackTarget()))
end
local function Held(unit)
 return unit:HasModifier('modifier_faceless_void_chronosphere_freeze') or unit:HasModifier('modifier_enigma_black_hole_pull')
  or unit:HasModifier('modifier_legion_commander_duel') or unit:HasModifier('modifier_bane_fiends_grip')
  or unit:HasModifier('modifier_mars_arena_of_blood_leash')
end
local function Safe(point)
 return not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point) and not J.IsLocHaveTower(700,true,point)
end
function X.ConsiderMagicMissile()
 if not J.CanCastAbility(MagicMissile) then return 0 end
 local range=Range(MagicMissile);local damage=MagicMissile:GetSpecialValueInt('magic_missile_damage');local target=J.GetProperTarget(bot)
 local choice,score=nil,-1
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
   local eta=MagicMissile:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/MagicMissile:GetSpecialValueInt('magic_missile_speed')
   if enemy:IsChanneling() then return BOT_ACTION_DESIRE_HIGH,enemy end
   if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,enemy end
   local useful=(Fighting() and enemy==target) or J.IsInTeamFight(bot,1200) or (J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot))
   for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
    if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,ally) then useful=true end
   end
   if useful and not J.IsDisabled(enemy) and not Held(enemy) then
    local value=enemy:GetEstimatedDamageToTarget(false,bot,3,DAMAGE_TYPE_ALL)
    if bot:HasModifier('modifier_item_aghanims_shard') then
     for _,secondary in ipairs(J.GetEnemiesNearLoc(enemy:GetLocation(),range*0.75)) do
      if secondary~=enemy and J.IsValidHero(secondary) and Enemy(secondary,false) then value=value+100 end
     end
    end
    if value>score then choice,score=enemy,value end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 return 0
end
local function WavePoint(unit,range,speed)
 local point=J.GetCorrectLoc(unit,WaveOfTerror:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/speed)
 if (point-bot:GetLocation()):Length2D()>range then point=bot:GetLocation()+(point-bot:GetLocation()):Normalized()*range end
 return point
end
local function Hits(unit,point,range,width,speed)
 local position=J.GetCorrectLoc(unit,WaveOfTerror:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/speed)-bot:GetLocation()
 local direction=(point-bot:GetLocation()):Normalized();local along=position.x*direction.x+position.y*direction.y
 return along>=0 and along<=range and (position-direction*along):Length2D()<=width
end
function X.ConsiderWaveOfTerror()
 if not J.CanCastAbility(WaveOfTerror) then return 0 end
 local range=Range(WaveOfTerror);local width=WaveOfTerror:GetSpecialValueInt('wave_width');local speed=WaveOfTerror:GetSpecialValueInt('wave_speed')
 local target=J.GetProperTarget(bot);local heroes=J.GetNearbyHeroes(bot,math.min(range+width,1600),true,BOT_MODE_NONE)
 local choice,score=nil,0
 for _,enemy in ipairs(heroes) do
  if Enemy(enemy,false) then
   local point=WavePoint(enemy,range,speed)
   if Hits(enemy,point,range,width,speed) then
    local eta=WaveOfTerror:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/speed
    if J.WillKillTarget(enemy,WaveOfTerror:GetAbilityDamage(),DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,point end
    local useful=(Fighting() and enemy==target) or (J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot))
     or ((J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,WaveOfTerror:GetManaCost()))
    if useful and not enemy:HasModifier('modifier_vengefulspirit_wave_of_terror') then
     local count=0;for _,other in ipairs(heroes) do if Enemy(other,false) and Hits(other,point,range,width,speed) then count=count+1 end end
     if count>score then choice,score=point,count end
    end
   end
  end
 end
 if choice~=nil then return BOT_ACTION_DESIRE_HIGH,choice end
 if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,WaveOfTerror:GetManaCost()) then
  local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
  for _,creep in ipairs(creeps) do
   if Enemy(creep,false) then
    local point=WavePoint(creep,range,speed);local count,kills=0,0
    for _,other in ipairs(creeps) do
     if Enemy(other,false) and not other:HasModifier('modifier_fountain_glyph') and Hits(other,point,range,width,speed) then
      count=count+1
      if J.WillKillTarget(other,WaveOfTerror:GetAbilityDamage(),DAMAGE_TYPE_MAGICAL,WaveOfTerror:GetCastPoint()+GetUnitToUnitDistance(bot,other)/speed) then kills=kills+1 end
     end
    end
    if (J.IsLaning(bot) and kills>=2) or (not J.IsLaning(bot) and count>=3) then return BOT_ACTION_DESIRE_HIGH,point end
   end
  end
 end
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(target,false) and J.IsAttacking(bot) and GetUnitToUnitDistance(bot,target)<=range
  and not target:HasModifier('modifier_vengefulspirit_wave_of_terror') and J.IsAllowedToSpam(bot,WaveOfTerror:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH,WavePoint(target,range,speed) end
 return 0
end
function X.ConsiderNetherSwap()
 if not J.CanCastAbility(NetherSwap) then return 0 end
 local range=Range(NetherSwap);local allies=J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)
 local origin=bot:GetLocation();local originSafe=Safe(origin) and not Held(bot)
 local friends=J.GetAlliesNearLoc(origin,600);local foes=J.GetEnemiesNearLoc(origin,600)
 for _,ally in ipairs(allies) do
  if J.IsValidHero(ally) and ally~=bot and not ally:IsIllusion() and not ally:IsInvulnerable() and GetUnitToUnitDistance(bot,ally)<=range and GetUnitToUnitDistance(bot,ally)>250
   and originSafe and #foes<=#friends+1 then
   local trapped=Held(ally)
   if trapped or (not ally:IsChanneling() and J.GetHP(ally)<0.35 and ally:WasRecentlyDamagedByAnyHero(2) and #J.GetEnemiesNearLoc(ally:GetLocation(),500)>#foes) then return BOT_ACTION_DESIRE_HIGH,ally end
  end
 end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,true) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range and Safe(enemy:GetLocation())
   and not Held(enemy) and #J.GetEnemiesNearLoc(enemy:GetLocation(),500)<=#friends+1 then
   if enemy:IsChanneling() then return BOT_ACTION_DESIRE_HIGH,enemy end
   if not enemy:IsMagicImmune() and J.WillKillTarget(enemy,NetherSwap:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,NetherSwap:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,enemy end
   if Fighting() and enemy==J.GetProperTarget(bot) and GetUnitToUnitDistance(bot,enemy)>400 and #friends>=1 and originSafe
    and not J.IsDisabled(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end
  end
 end
 return 0
end
function X.Think(ownerBot,unit)
 if not U.IsValidUnit(unit) or unit:GetUnitName()~='npc_dota_hero_vengefulspirit' or not unit:IsIllusion()
  or unit:GetPlayerID()~=ownerBot:GetPlayerID() or J.CanNotUseAbility(unit) or unit:NumQueuedActions()>0 then return end
 bot=unit
 MagicMissile=unit:GetAbilityByName('vengefulspirit_magic_missile')
 WaveOfTerror=unit:GetAbilityByName('vengefulspirit_wave_of_terror')
 NetherSwap=unit:GetAbilityByName('vengefulspirit_nether_swap')
 local desire,target=X.ConsiderNetherSwap()
 if desire>0 then unit:Action_UseAbilityOnEntity(NetherSwap,target);return end
 desire,target=X.ConsiderMagicMissile()
 if desire>0 then unit:Action_UseAbilityOnEntity(MagicMissile,target);return end
 desire,target=X.ConsiderWaveOfTerror()
 if desire>0 then unit:Action_UseAbilityOnLocation(WaveOfTerror,target);return end
 I.Think(ownerBot,unit)
end
return X
