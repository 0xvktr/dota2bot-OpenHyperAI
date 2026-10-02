local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; forced skipped roles use pos 2.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/void_spirit')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Aether Remnant, [2] Dissimilate, [3] Resonant Pulse, [6] Astral Step.
local roleAbilityBuilds, roleTalentTrees = {}, {}
roleAbilityBuilds.pos_2 = {3,1,3,2,3,6,3,2,2,2,6,1,1,1,6}
roleTalentTrees.pos_2 = {
    t10={10,0}, -- Resonant Pulse damage
    t15={10,0}, -- Aether Remnant damage
    t20={0,10}, -- Dissimilate outer ring
    t25={0,10}, -- Astral Step critical damage
}
roleAbilityBuilds.pos_3 = {3,1,3,2,3,6,3,1,1,1,6,2,2,2,6}
roleTalentTrees.pos_3 = {
    t10={10,0}, -- Resonant Pulse damage
    t15={10,0}, -- Aether Remnant damage
    t20={0,10}, -- Dissimilate outer ring
    t25={0,10}, -- Astral Step critical damage
}
local nAbilityBuildList = roleAbilityBuilds[sRole] or roleAbilityBuilds.pos_2
local nTalentBuildList = J.Skill.GetTalentBuild(roleTalentTrees[sRole] or roleTalentTrees.pos_2)
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList, sRoleItemsSellList = {}, {}
sRoleItemsBuyList.pos_2 = {
        'item_double_branches','item_double_branches','item_tango','item_faerie_fire','item_bottle',
        'item_magic_wand','item_urn_of_shadows','item_power_treads','item_spirit_vessel','item_aghanims_shard',
        'item_ultimate_scepter',
        -- Bot policy: selected situational items and late upgrades.
        'item_kaya','item_yasha_and_kaya','item_black_king_bar','item_ultimate_scepter_2','item_shivas_guard',
        'item_octarine_core',
}
sRoleItemsSellList.pos_2 = {'item_kaya','item_bottle','item_black_king_bar','item_magic_wand'}
sRoleItemsBuyList.pos_3 = {
        'item_double_branches','item_double_circlet','item_tango','item_faerie_fire','item_magic_wand',
        'item_urn_of_shadows','item_power_treads','item_spirit_vessel','item_aghanims_shard','item_ultimate_scepter',
        -- Bot policy: selected situational items and late upgrades.
        'item_yasha','item_manta','item_black_king_bar','item_ultimate_scepter_2','item_shivas_guard',
        'item_octarine_core',
}
sRoleItemsSellList.pos_3 = {'item_black_king_bar','item_magic_wand'}
sRoleItemsBuyList.pos_1 = sRoleItemsBuyList.pos_2
sRoleItemsSellList.pos_1 = sRoleItemsSellList.pos_2
sRoleItemsBuyList.pos_4 = sRoleItemsBuyList.pos_2
sRoleItemsSellList.pos_4 = sRoleItemsSellList.pos_2
sRoleItemsBuyList.pos_5 = sRoleItemsBuyList.pos_2
sRoleItemsSellList.pos_5 = sRoleItemsSellList.pos_2
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = sRoleItemsSellList[sRole]

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

	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

local AetherRemnant,Dissimilate,ResonantPulse,AstralStep
local function Refresh()
 bot=GetBot();AetherRemnant=bot:GetAbilityByName('void_spirit_aether_remnant');Dissimilate=bot:GetAbilityByName('void_spirit_dissimilate');ResonantPulse=bot:GetAbilityByName('void_spirit_resonant_pulse');AstralStep=bot:GetAbilityByName('void_spirit_astral_step')
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
  and not J.IsSuspiciousIllusion(unit) and not J.CannotBeKilled(bot,unit) and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function CanMove()
 return not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture') and not bot:HasModifier('modifier_puck_coiled')
  and not bot:HasModifier('modifier_slark_pounce_leash') and not bot:HasModifier('modifier_item_gungir_root')
end
local function Point(location,range)
 local delta=location-bot:GetLocation();if delta:Length2D()>range then return bot:GetLocation()+delta:Normalized()*range end;return location
end
local function Safe(location,offensive)
 return IsLocationPassable(location) and not J.IsLocationInChrono(location) and not J.IsLocationInBlackHole(location)
  and (not offensive or (not J.IsLocHaveTower(700,true,location) and #J.GetEnemiesNearLoc(location,800)<=#J.GetAlliesNearLoc(location,800)+1))
end
local function Useful(enemy)
 if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then return true end
 if J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then return true end
 for _,ally in ipairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
  if J.IsValidHero(ally) and not ally:IsIllusion() and ally:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,ally) then return true end
 end
 return false
end
function X.ConsiderAetherRemnant()
 if not J.CanCastAbility(AetherRemnant) then return 0 end
 local range=Range(AetherRemnant)
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) and GetUnitToUnitDistance(bot,enemy)<=range and (enemy:IsChanneling() or (Useful(enemy) and J.IsDisabled(enemy))) then
   local eta=AetherRemnant:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/AetherRemnant:GetSpecialValueInt('projectile_speed')+AetherRemnant:GetSpecialValueFloat('activation_delay')
   local point=J.GetCorrectLoc(enemy,eta)
   -- The bot API offers one point, not the vector endpoint. Facing and a hit are not guaranteed.
   if GetUnitToLocationDistance(bot,point)<=range then return BOT_ACTION_DESIRE_HIGH,point end
  end
 end
 return 0
end
function X.ConsiderResonantPulse()
 if not J.CanCastAbility(ResonantPulse) then return 0 end
 local radius=ResonantPulse:GetSpecialValueInt('radius');local damage=ResonantPulse:GetSpecialValueInt('damage')
 local shield=bot:HasModifier('modifier_void_spirit_resonant_pulse_physical_buff');local relevant=0
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
  local eta=ResonantPulse:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/ResonantPulse:GetSpecialValueInt('speed')
  if Enemy(enemy,false) and GetUnitToLocationDistance(bot,J.GetCorrectLoc(enemy,eta))<=radius then
   if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH end
   if bot:HasScepter() and enemy:IsChanneling() and not enemy:IsSilenced() then return BOT_ACTION_DESIRE_HIGH end
   if Useful(enemy) or J.IsInTeamFight(bot,1200) then
    if not bot:HasScepter() or not enemy:IsSilenced() then relevant=relevant+1 end
   end
  end
 end
 -- The default barrier is physical. A nearby spell alone is not a shield trigger.
 if not shield and (J.GetAttackProjectileDamageByRange(bot,1000)>0 or (bot:WasRecentlyDamagedByAnyHero(2) and J.GetHP(bot)<0.65 and relevant>0)) then return BOT_ACTION_DESIRE_HIGH end
 if relevant>0 and (not shield or (bot:HasScepter() and (ResonantPulse:GetCurrentCharges()>1 or relevant>=2))) then return BOT_ACTION_DESIRE_HIGH end
 if not shield and J.IsAllowedToSpam(bot,ResonantPulse:GetManaCost()) then
  local creeps={}
  if J.IsFarming(bot) then creeps=bot:GetNearbyNeutralCreeps(radius) elseif J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot) then creeps=bot:GetNearbyLaneCreeps(radius,true) end
  if #creeps>=3 then return BOT_ACTION_DESIRE_HIGH end
  if J.IsLaning(bot) then
   for _,creep in ipairs(creeps) do
    if Enemy(creep,false) and (J.IsKeyWordUnit('ranged',creep) or J.IsKeyWordUnit('siege',creep))
     and J.WillKillTarget(creep,damage,DAMAGE_TYPE_MAGICAL,GetUnitToUnitDistance(bot,creep)/ResonantPulse:GetSpecialValueInt('speed')) then return BOT_ACTION_DESIRE_HIGH end
   end
  end
  local target=J.GetProperTarget(bot)
  if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(target,false) and J.IsAttacking(bot) and GetUnitToUnitDistance(bot,target)<=radius then return BOT_ACTION_DESIRE_HIGH end
 end
 return 0
end
function X.ConsiderDissimilate()
 if not J.CanCastAbility(Dissimilate) or not CanMove() then return 0 end
 if J.IsStunProjectileIncoming(bot,600) then return BOT_ACTION_DESIRE_HIGH end
 if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,700,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
 -- Until real portal selection is observed, only value damage at the center portal.
 local radius=Dissimilate:GetSpecialValueInt('damage_radius');local eta=Dissimilate:GetCastPoint()+Dissimilate:GetSpecialValueFloat('phase_duration')
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(radius+300,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,false) and GetUnitToLocationDistance(bot,J.GetCorrectLoc(enemy,eta))<=radius
   and (Useful(enemy) or J.WillKillTarget(enemy,Dissimilate:GetAbilityDamage(),DAMAGE_TYPE_MAGICAL,eta)) then return BOT_ACTION_DESIRE_HIGH end
 end
 if J.IsFarming(bot) and J.IsAllowedToSpam(bot,Dissimilate:GetManaCost()) and #bot:GetNearbyNeutralCreeps(radius)>=3 then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderAstralStep()
 if not J.CanCastAbility(AstralStep) or not CanMove() or bot:HasModifier('modifier_void_spirit_astral_step_caster') then return 0 end
 local range=AstralStep:GetSpecialValueInt('max_travel_distance');local minimum=AstralStep:GetSpecialValueInt('min_travel_distance')
 if J.IsStuck(bot) or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) then
  local point=Point(J.GetEscapeLoc(),range);if Safe(point,false) then return BOT_ACTION_DESIRE_HIGH,point end
 end
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy,true) then
   local prediction=J.GetCorrectLoc(enemy,AstralStep:GetCastPoint());local distance=GetUnitToLocationDistance(bot,prediction)
   if distance>=minimum and distance<=range then
    local point=Point(prediction,range)
    local lethal=J.WillKillTarget(enemy,bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL,AstralStep:GetCastPoint())
     or (not enemy:IsMagicImmune() and J.WillKillTarget(enemy,AstralStep:GetSpecialValueInt('pop_damage'),DAMAGE_TYPE_MAGICAL,AstralStep:GetCastPoint()+AstralStep:GetSpecialValueFloat('pop_damage_delay')))
    local escapeReady=J.CanCastAbility(Dissimilate) and bot:GetMana()>=AstralStep:GetManaCost()+Dissimilate:GetManaCost()
    if Safe(point,true) and (lethal or (Useful(enemy) and J.IsGoingOnSomeone(bot) and GetUnitToUnitDistance(bot,enemy)>bot:GetAttackRange()+100 and (AstralStep:GetCurrentCharges()>1 or escapeReady))) then return BOT_ACTION_DESIRE_HIGH,point end
   end
  end
 end
 return 0
end
function X.ConsiderDissimilatePortal()
 local current=GetBot()
 if not current:HasModifier('modifier_void_spirit_dissimilate_phase') then return false end
 local index=current:GetModifierByName('modifier_void_spirit_dissimilate_phase');if index<0 then return false end
 local source=current:GetModifierSourceAbility(index)
 if source==nil or source:IsNull() or source:GetName()~='void_spirit_dissimilate' or source:GetCaster()~=current then return false end
 if not current:IsAlive() or current:NumQueuedActions()>0 or current:IsStunned() or current:IsHexed() or current:IsNightmared() or current:IsSilenced()
  or current:HasModifier('modifier_doom_bringer_doom') or current:HasModifier('modifier_ringmaster_the_box_buff') or current:HasModifier('modifier_item_forcestaff_active') then return false end
 local active=current:GetCurrentActiveAbility()
 if (current:IsChanneling() or current:IsUsingAbility() or current:IsCastingAbility()) and (active==nil or active:IsNull() or active:GetName()~='void_spirit_dissimilate') then return false end
 Refresh();if not CanMove() then return false end
 local point
 if J.IsRetreating(bot) or J.IsStuck(bot) then point=J.GetEscapeLoc()
 elseif J.IsGoingOnSomeone(bot) then
  local target=J.GetProperTarget(bot)
  if Enemy(target,false) then point=J.GetCorrectLoc(target,math.max(0,current:GetModifierRemainingDuration(index))) end
 end
 if point==nil then return false end
 -- A movement order is a portal-selection intent, not evidence of a chosen portal or exit.
 point=Point(point,source:GetSpecialValueInt('first_ring_distance_offset'))
 if not Safe(point,J.IsGoingOnSomeone(bot)) then return false end
 bot:Action_MoveToLocation(point);return true
end
function X.SkillsComplement()
 Refresh()
 if J.CanNotUseAbility(bot) or bot:NumQueuedActions()>0 then return end
 local desire,point=X.ConsiderResonantPulse()
 if desire>0 then bot:Action_UseAbility(ResonantPulse);return end
 desire,point=X.ConsiderAstralStep()
 if desire>0 then bot:Action_UseAbilityOnLocation(AstralStep,point);return end
 desire,point=X.ConsiderDissimilate()
 if desire>0 then bot:Action_UseAbility(Dissimilate);return end
 desire,point=X.ConsiderAetherRemnant()
 if desire>0 then bot:Action_UseAbilityOnLocation(AetherRemnant,point);return end
end
return X
