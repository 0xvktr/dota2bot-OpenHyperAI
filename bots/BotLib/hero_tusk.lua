local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: support roles; skipped roles use pos 5 without core wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/tusk')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local buildRole = BuildData.roles[sRole].skipped and 'pos_5' or sRole
-- [1] Ice Shards, [2] Snowball, [3] Tag Team, [6] Walrus Punch.
local nAbilityBuildList = {3,1,2,3,3,6,3,2,2,2,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({t10={10,0},t15={10,0},t20={0,10},t25={0,10}})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {
    pos_4={
        'item_boots','item_ward_sentry','item_blood_grenade',
        'item_tranquil_boots','item_magic_wand','item_blink','item_cyclone','item_aghanims_shard',
        'item_ultimate_scepter','item_black_king_bar',
        -- Bot policy: consume Scepter, then defensive utility within six major slots.
        'item_ultimate_scepter_2','item_lotus_orb','item_wind_waker','item_sheepstick','item_overwhelming_blink',
    },
    pos_5={
        'item_boots','item_ward_sentry','item_blood_grenade',
        'item_tranquil_boots','item_magic_wand','item_blink','item_cyclone','item_ultimate_scepter','item_lotus_orb',
        -- Bot policy: Shard, consumed Scepter and late defensive/control upgrades.
        'item_aghanims_shard','item_ultimate_scepter_2','item_black_king_bar','item_wind_waker','item_sheepstick','item_overwhelming_blink',
    },
}
X.sBuyList = sRoleItemsBuyList[buildRole]
if sRole == 'pos_1' or sRole == 'pos_2' or sRole == 'pos_3' then
    X.sBuyList = {}
    for _,item in ipairs(sRoleItemsBuyList[buildRole]) do
        if item ~= 'item_ward_sentry' then table.insert(X.sBuyList,item) end
    end
end
X.sSellList = {'item_ultimate_scepter','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_antimage'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local IceShards,Snowball,LaunchSnowball,TagTeam,WalrusPunch,DrinkingBuddies
local function Refresh()
 bot=GetBot();IceShards=bot:GetAbilityByName('tusk_ice_shards');Snowball=bot:GetAbilityByName('tusk_snowball')
 LaunchSnowball=bot:GetAbilityByName('tusk_launch_snowball');TagTeam=bot:GetAbilityByName('tusk_tag_team')
 WalrusPunch=bot:GetAbilityByName('tusk_walrus_punch');DrinkingBuddies=bot:GetAbilityByName('tusk_drinking_buddies')
end
Refresh()
local function ActualRange(ability)
 local range=ability:GetCastRange()
 for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
 local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
 if supremacy~=nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
 return range
end
local function Enemy(unit,pierce)
 return J.IsValid(unit) and (pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit))
  and not J.CannotBeKilled(bot,unit) and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function MovingBlocked()
 return bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled')
end
local function SnowballState()
 return bot:HasModifier('modifier_tusk_snowball_movement') or bot:HasModifier('modifier_tusk_snowball')
end
function X.ConsiderIceShards()
 if not J.CanCastAbility(IceShards) then return 0 end
 local range=ActualRange(IceShards);local width=IceShards:GetSpecialValueInt('shard_width');local speed=IceShards:GetSpecialValueInt('shard_speed')
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range+width,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) then
   local eta=IceShards:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/speed
   local predicted=J.GetCorrectLoc(enemy,eta);local delta=predicted-bot:GetLocation();local distance=delta:Length2D()
   local lethal=J.WillKillTarget(enemy,IceShards:GetSpecialValueInt('shard_damage'),DAMAGE_TYPE_MAGICAL,eta)
   local wanted=lethal or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot))
    or (SnowballState() and enemy==bot.tuskSnowballTarget) or (J.IsRetreating(bot) and enemy:GetAttackTarget()==bot)
   if distance>0 and distance<=range and wanted then
    -- A point beyond the target places the barrier across its escape direction.
    if not lethal and not J.IsRetreating(bot) then
     local travel=predicted-enemy:GetLocation()
     if travel:Length2D()>0 then predicted=predicted+travel:Normalized()*100 end
    end
    local castDelta=predicted-bot:GetLocation()
    if castDelta:Length2D()>range then predicted=bot:GetLocation()+castDelta:Normalized()*range end
    return BOT_ACTION_DESIRE_HIGH,predicted
   end
  end
 end
 if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,IceShards:GetManaCost()) then
  local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
  for _,creep in ipairs(creeps) do
   if Enemy(creep,false) then
    local eta=IceShards:GetCastPoint()+GetUnitToUnitDistance(bot,creep)/speed;local point=J.GetCorrectLoc(creep,eta);local delta=point-bot:GetLocation();local distance=delta:Length2D()
    if distance>0 and distance<=range then
     if J.IsLaning(bot) and string.find(creep:GetUnitName(),'ranged') and GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()
      and J.WillKillTarget(creep,IceShards:GetSpecialValueInt('shard_damage'),DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,point end
     if not J.IsLaning(bot) then
      local direction=delta:Normalized();local count=0
      for _,other in ipairs(creeps) do
       if Enemy(other,false) then
        local offset=J.GetCorrectLoc(other,eta)-bot:GetLocation();local forward=offset.x*direction.x+offset.y*direction.y
        if forward>=0 and forward<=distance and math.abs(offset.x*direction.y-offset.y*direction.x)<=width then count=count+1 end
       end
      end
      if count>=3 then return BOT_ACTION_DESIRE_HIGH,point end
     end
    end
   end
  end
 end
 return 0
end
local function NeedsPickup(ally)
 return ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not ally:HasModifier('modifier_tusk_snowball_movement_friendly')
  and (J.IsDisabled(ally) or J.GetAttackProjectileDamageByRange(ally,1000)>ally:GetHealth()*0.2 or (J.GetHP(ally)<0.4 and ally:WasRecentlyDamagedByAnyHero(2)))
end
function X.ConsiderSnowball()
 if not J.CanCastAbility(Snowball) or MovingBlocked() or SnowballState() then return 0 end
 local range=ActualRange(Snowball)
 local rescue=J.GetAttackProjectileDamageByRange(bot,1000)>bot:GetHealth()*0.25
 for _,ally in ipairs(J.GetNearbyHeroes(bot,325,false,BOT_MODE_NONE)) do if NeedsPickup(ally) then rescue=true;break end end
 local retreat=J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
 if rescue or retreat then
  local best,bestDistance=nil,math.huge
  for _,unit in ipairs(bot:GetNearbyCreeps(math.min(range,1600),true)) do
   if Enemy(unit,false) and J.CanCastOnTargetAdvanced(unit) and GetUnitToUnitDistance(bot,unit)<=range then
    local escapeDistance=GetUnitToLocationDistance(unit,J.GetEscapeLoc())
    if escapeDistance+250<GetUnitToLocationDistance(bot,J.GetEscapeLoc()) and escapeDistance<bestDistance then best=unit;bestDistance=escapeDistance end
   end
  end
  if best~=nil then return BOT_ACTION_DESIRE_HIGH,best,rescue and 'save' or 'escape' end
 end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
   local endpointSafe=not J.IsLocHaveTower(700,true,enemy:GetLocation()) and not J.IsLocationInChrono(enemy:GetLocation()) and not J.IsLocationInBlackHole(enemy:GetLocation())
   if endpointSafe and (rescue or enemy:IsChanneling() or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)
      and #J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)<=#J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)+1)) then return BOT_ACTION_DESIRE_HIGH,enemy,rescue and 'save' or 'attack' end
  end
 end
 return 0
end
function X.ConsiderTagTeam()
 if not J.CanCastAbility(TagTeam) or bot:HasModifier('modifier_tusk_tag_team') then return 0 end
 local radius=TagTeam:GetSpecialValueInt('radius')
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) and J.CanBeAttacked(enemy) then
   local attack=(not bot:IsDisarmed() and (bot:GetAttackTarget()==enemy or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot))))
   for _,ally in ipairs(J.GetAlliesNearLoc(enemy:GetLocation(),800)) do if not ally:IsDisarmed() and ally:GetAttackTarget()==enemy then attack=true;break end end
   if attack and (WalrusPunch==nil or not J.CanCastAbility(WalrusPunch) or bot:GetMana()>=TagTeam:GetManaCost()+WalrusPunch:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH end
  end
 end
 local target=bot:GetAttackTarget()
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(target,false) and GetUnitToUnitDistance(bot,target)<=radius and not bot:IsDisarmed() then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderWalrusPunch()
 if not J.CanCastAbility(WalrusPunch) or bot:IsDisarmed() then return 0 end
 local range=bot:GetAttackRange()
 -- The critical component is guaranteed; do not overpromise bonus or random attack procs.
 local damage=bot:GetAttackDamage()*WalrusPunch:GetSpecialValueInt('crit_multiplier')/100
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,true) and J.CanBeAttacked(enemy) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
   if enemy:IsChanneling() or J.WillKillTarget(enemy,damage,DAMAGE_TYPE_PHYSICAL,bot:GetAttackPoint())
    or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and not J.IsDisabled(enemy)) then return BOT_ACTION_DESIRE_HIGH,enemy end
  end
 end
 local target=bot:GetAttackTarget()
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(target,true) and J.CanBeAttacked(target) and GetUnitToUnitDistance(bot,target)<=range then return BOT_ACTION_DESIRE_HIGH,target end
 return 0
end
function X.ConsiderDrinkingBuddies()
 if not J.CanCastAbility(DrinkingBuddies) or MovingBlocked() or SnowballState() then return 0 end
 local range=ActualRange(DrinkingBuddies)
 for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)) do
  if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not ally:IsRooted()
   and not ally:HasModifier('modifier_puck_coiled') and not ally:HasModifier('modifier_slark_pounce_leash') and not ally:HasModifier('modifier_bloodseeker_rupture')
   and not ally:HasModifier('modifier_tusk_drinking_buddies') and GetUnitToUnitDistance(bot,ally)<=range then
   local midpoint=(bot:GetLocation()+ally:GetLocation())*0.5
   if IsLocationPassable(midpoint) and not J.IsLocHaveTower(700,true,midpoint) and not J.IsLocationInChrono(midpoint) and not J.IsLocationInBlackHole(midpoint) then
    local dist=GetUnitToUnitDistance(bot,ally)
    local escape=J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and GetUnitToLocationDistance(ally,J.GetEscapeLoc())+400<GetUnitToLocationDistance(bot,J.GetEscapeLoc())
    local save=NeedsPickup(ally) and dist>DrinkingBuddies:GetSpecialValueInt('min_distance') and GetUnitToLocationDistance(bot,J.GetEscapeLoc())+400<GetUnitToLocationDistance(ally,J.GetEscapeLoc())
    local buff=dist<=DrinkingBuddies:GetSpecialValueInt('min_distance') and (bot:IsChanneling()==false) and (J.IsValid(ally:GetAttackTarget()) or NeedsPickup(ally))
    if escape or save or buff then return BOT_ACTION_DESIRE_HIGH,ally end
   end
  end
 end
 return 0
end
function X.ConsiderLaunchSnowball()
 if not SnowballState() or not J.CanCastAbility(LaunchSnowball) then return 0 end
 if bot.tuskSnowballPurpose=='escape' or bot.tuskSnowballPurpose=='save' then return 0 end
 return BOT_ACTION_DESIRE_HIGH
end
function X.ConsiderSnowballContinuation()
 local caster=GetBot()
 if not caster:HasModifier('modifier_tusk_snowball_movement') and not caster:HasModifier('modifier_tusk_snowball') then return false end
 Refresh()
 if not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsSilenced() or bot:IsCastingAbility() or J.HasQueuedAction(bot)
  or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
 if bot:IsChanneling() or bot:IsUsingAbility() then
  local active=bot:GetCurrentActiveAbility();if active==nil or active:GetName()~='tusk_snowball' then return false end
 end
 if J.CanCastAbility(LaunchSnowball) then
  for _,ally in ipairs(J.GetNearbyHeroes(bot,325,false,BOT_MODE_NONE)) do
   if NeedsPickup(ally) then
    if bot.tuskPickupTarget==ally and bot.tuskPickupIssuedAt~=nil and DotaTime()-bot.tuskPickupIssuedAt<0.3 then return false end
    bot.tuskPickupTarget=ally;bot.tuskPickupIssuedAt=DotaTime();bot:Action_AttackUnit(ally,true);return true
   end
  end
 end
 if bot.tuskSnowballPurpose=='attack' or bot.tuskSnowballPurpose==nil then
  local qd,qp=X.ConsiderIceShards();if qd>0 then bot:Action_UseAbilityOnLocation(IceShards,qp);return true end
  if X.ConsiderTagTeam()>0 then bot:Action_UseAbility(TagTeam);return true end
  if X.ConsiderLaunchSnowball()>0 then bot:Action_UseAbility(LaunchSnowball);return true end
 end
 return false
end

function X.SkillsComplement()
 Refresh();if X.ConsiderSnowballContinuation() then return end
 if J.CanNotUseAbility(bot) then return end
 local sd,st,kind=X.ConsiderSnowball();if sd>0 and kind=='save' then bot.tuskSnowballTarget=st;bot.tuskSnowballPurpose=kind;bot:Action_UseAbilityOnEntity(Snowball,st);return end
 local pd,pt=X.ConsiderWalrusPunch();if pd>0 and pt:IsChanneling() then bot:Action_UseAbilityOnEntity(WalrusPunch,pt);return end
 local bd,bt=X.ConsiderDrinkingBuddies();if bd>0 then bot:Action_UseAbilityOnEntity(DrinkingBuddies,bt);return end
 if X.ConsiderTagTeam()>0 then bot:Action_UseAbility(TagTeam);return end
 if pd>0 then bot:Action_UseAbilityOnEntity(WalrusPunch,pt);return end
 local qd,qp=X.ConsiderIceShards();if qd>0 then bot:Action_UseAbilityOnLocation(IceShards,qp);return end
 if sd>0 then bot.tuskSnowballTarget=st;bot.tuskSnowballPurpose=kind;bot:Action_UseAbilityOnEntity(Snowball,st);return end
end
return X
