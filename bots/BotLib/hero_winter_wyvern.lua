local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; forced skipped roles use pos 5.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/winter_wyvern')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Arctic Burn, [2] Splinter Blast, [3] Cold Embrace, [6] Winter's Curse.
-- D2PT shows a fifth Arctic Burn point at 8; use legal Splinter Blast instead.
local roleAbilityBuilds, roleTalentTrees = {}, {}
roleAbilityBuilds.pos_4 = {1,3,1,2,1,6,1,2,2,2,6,3,3,3,6}
roleTalentTrees.pos_4 = {
    t10={10,0}, -- Damage
    t15={0,10}, -- Arctic Burn debuff duration
    t20={10,0}, -- Splinter Blast damage
    t25={10,0}, -- Splinter Blast stun
}
roleAbilityBuilds.pos_5 = {1,3,1,2,1,6,1,2,2,2,6,3,3,3,6}
roleTalentTrees.pos_5 = {
    t10={0,10}, -- Cold Embrace healing
    t15={10,0}, -- Splinter Blast radius
    t20={10,0}, -- Splinter Blast damage
    t25={10,0}, -- Splinter Blast stun
}
local nAbilityBuildList = roleAbilityBuilds[sRole] or roleAbilityBuilds.pos_5
local nTalentBuildList = J.Skill.GetTalentBuild(roleTalentTrees[sRole] or roleTalentTrees.pos_5)
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList, sRoleItemsSellList = {}, {}
sRoleItemsBuyList.pos_4 = {
        'item_branches','item_double_circlet','item_tango','item_faerie_fire','item_faerie_fire',
        'item_magic_wand','item_arcane_boots','item_blink',
        -- Bot policy: selected situational items and late upgrades.
        'item_force_staff','item_aether_lens','item_aghanims_shard','item_glimmer_cape','item_ultimate_scepter',
        'item_ultimate_scepter_2','item_sheepstick','item_overwhelming_blink',
}
sRoleItemsSellList.pos_4 = {'item_aether_lens','item_magic_wand'}
sRoleItemsBuyList.pos_5 = {
        'item_double_branches','item_magic_stick','item_ward_sentry','item_tango','item_faerie_fire',
        'item_blood_grenade','item_magic_wand','item_arcane_boots','item_blink',
        -- Bot policy: selected situational items and late upgrades.
        'item_glimmer_cape','item_force_staff','item_aether_lens','item_aghanims_shard','item_ultimate_scepter',
        'item_ultimate_scepter_2','item_sheepstick','item_overwhelming_blink',
}
sRoleItemsSellList.pos_5 = {'item_aether_lens','item_magic_wand'}
sRoleItemsBuyList.pos_1 = sRoleItemsBuyList.pos_5
sRoleItemsSellList.pos_1 = sRoleItemsSellList.pos_5
sRoleItemsBuyList.pos_2 = sRoleItemsBuyList.pos_5
sRoleItemsSellList.pos_2 = sRoleItemsSellList.pos_5
sRoleItemsBuyList.pos_3 = sRoleItemsBuyList.pos_5
sRoleItemsSellList.pos_3 = sRoleItemsSellList.pos_5
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = sRoleItemsSellList[sRole]
-- Core bots omit observed starting wards.
if sRole == 'pos_1' or sRole == 'pos_2' or sRole == 'pos_3' then
    local coreBuyList = {}
    for _, item in ipairs(X.sBuyList) do
        if item ~= 'item_ward_observer' and item ~= 'item_ward_sentry' then table.insert(coreBuyList, item) end
    end
    X.sBuyList = coreBuyList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT takes an ability at 10, then the first talent at 11.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

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

function X.SkillsComplement()
 Refresh();if J.CanNotUseAbility(bot) or J.HasQueuedAction(bot) then return end
 local desire,target=X.ConsiderColdEmbrace();if desire>0 then bot:Action_UseAbilityOnEntity(ColdEmbrace,target);return end
 desire,target=X.ConsiderWintersCurse();if desire>0 then bot:Action_UseAbilityOnEntity(WintersCurse,target);return end
 desire,target=X.ConsiderSplinterBlast();if desire>0 then J.SetQueuePtToINT(bot,false);bot:ActionQueue_UseAbilityOnEntity(SplinterBlast,target);return end
 if X.ConsiderArcticBurn()>0 then bot:Action_UseAbility(ArcticBurn);return end
end
return X
