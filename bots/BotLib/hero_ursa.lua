local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: carry only; forced roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/ursa')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Earthshock, [2] Overpower, [3] Fury Swipes, [6] Enrage.
local nAbilityBuildList = {3,1,3,2,3,6,3,2,2,2,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({t10={0,10},t15={10,0},t20={10,0},t25={10,0}})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_magic_wand','item_phase_boots','item_bfury','item_blink','item_basher','item_black_king_bar',
    'item_aghanims_shard','item_abyssal_blade',
    -- Bot policy: consume Scepter before the sixth major, then upgrade mobility.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_monkey_king_bar','item_swift_blink','item_moon_shard',
}
X.sSellList = {'item_bfury','item_quelling_blade','item_black_king_bar','item_magic_wand'}

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

	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

local Earthshock,Overpower,Enrage
local function Refresh()
 bot=GetBot();Earthshock=bot:GetAbilityByName('ursa_earthshock');Overpower=bot:GetAbilityByName('ursa_overpower');Enrage=bot:GetAbilityByName('ursa_enrage')
end
Refresh()
local function Enemy(unit)
 return J.IsValid(unit) and J.CanCastOnNonMagicImmune(unit) and not J.CannotBeKilled(bot,unit)
  and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Landing()
 local distance=Earthshock:GetSpecialValueInt('hop_distance')
 if bot:IsRooted() then distance=0 end
 if distance>0 and (bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled')) then return nil end
 local angle=bot:GetFacing()*math.pi/180
 local point=bot:GetLocation()+Vector(math.cos(angle),math.sin(angle),0)*distance
 if not IsLocationPassable(point) or J.IsLocationInChrono(point) or J.IsLocationInBlackHole(point) then return nil end
 if distance>0 and J.IsLocHaveTower(700,true,point) and not J.IsRetreating(bot) then return nil end
 return point
end
function X.ConsiderEarthshock()
 if not J.CanCastAbility(Earthshock) or bot:HasModifier('modifier_ursa_earthshock_move') then return 0 end
 local point=Landing();if point==nil then return 0 end
 local radius=Earthshock:GetSpecialValueInt('shock_radius');local delay=Earthshock:GetSpecialValueFloat('hop_duration');local damage=Earthshock:GetAbilityDamage()
 local target=J.GetProperTarget(bot)
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(radius+Earthshock:GetSpecialValueInt('hop_distance'),1600),true,BOT_MODE_NONE)) do
  if Enemy(enemy) and (J.GetCorrectLoc(enemy,delay)-point):Length2D()<=radius then
   if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,delay) or (J.IsGoingOnSomeone(bot) and enemy==target)
    or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and bot:IsFacingLocation(J.GetEscapeLoc(),30)) then return BOT_ACTION_DESIRE_HIGH end
  end
 end
 if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,Earthshock:GetManaCost()) then
  local creeps=bot:GetNearbyCreeps(math.min(radius+Earthshock:GetSpecialValueInt('hop_distance'),1600),true);local count=0
  for _,creep in ipairs(creeps) do
   if Enemy(creep) and not creep:HasModifier('modifier_fountain_glyph') and (J.GetCorrectLoc(creep,delay)-point):Length2D()<=radius then
    if J.IsLaning(bot) and string.find(creep:GetUnitName(),'ranged') and GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()
      and J.WillKillTarget(creep,damage,DAMAGE_TYPE_MAGICAL,delay) then return BOT_ACTION_DESIRE_HIGH end
    count=count+1
   end
  end
  if not J.IsLaning(bot) and count>=3 then return BOT_ACTION_DESIRE_HIGH end
 end
 local attack=bot:GetAttackTarget()
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and Enemy(attack) and (J.GetCorrectLoc(attack,delay)-point):Length2D()<=radius
  and J.IsAttacking(bot) and J.IsAllowedToSpam(bot,Earthshock:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderOverpower()
 if not J.CanCastAbility(Overpower) or bot:IsDisarmed() then return 0 end
 if bot:HasModifier('modifier_ursa_overpower') then
  local index=bot:GetModifierByName('modifier_ursa_overpower')
  if index>=0 and bot:GetModifierRemainingDuration(index)>1 and bot:GetModifierStackCount(index)>0 then return 0 end
 end
 local target=J.GetProperTarget(bot)
 if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanBeAttacked(target) and not J.CannotBeKilled(bot,target)
  and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace') and GetUnitToUnitDistance(bot,target)<=800 then return BOT_ACTION_DESIRE_HIGH end
 local attack=bot:GetAttackTarget()
 if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and (J.IsValid(attack) or J.IsValidBuilding(attack))
  and J.CanBeAttacked(attack) and not attack:HasModifier('modifier_fountain_glyph') and J.IsAttacking(bot) and GetUnitToUnitDistance(bot,attack)<=bot:GetAttackRange()+100
  and J.IsAllowedToSpam(bot,Overpower:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderEnrage()
 if not J.CanCastAbility(Enrage) or bot:HasModifier('modifier_ursa_enrage') then return 0 end
 local threat=J.GetAttackProjectileDamageByRange(bot,1000)
 for _,enemy in ipairs(J.GetNearbyHeroes(bot,1000,true,BOT_MODE_NONE)) do
  if J.IsValidHero(enemy) then threat=threat+enemy:GetEstimatedDamageToTarget(false,bot,1,DAMAGE_TYPE_ALL) end
 end
 local held=bot:IsRooted() or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_batrider_flaming_lasso')
  or bot:HasModifier('modifier_bane_fiends_grip') or bot:HasModifier('modifier_bounty_hunter_track') or bot:HasModifier('modifier_slardar_amplify_damage')
 if threat>bot:GetHealth()*0.3 or (held and (#J.GetNearbyHeroes(bot,1000,true,BOT_MODE_NONE)>0 or bot:WasRecentlyDamagedByAnyHero(2)))
  or (J.GetHP(bot)<0.65 and bot:WasRecentlyDamagedByAnyHero(1.5)) then return BOT_ACTION_DESIRE_HIGH end
 local attack=bot:GetAttackTarget()
 if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot) or J.IsFarming(bot)) and J.IsValid(attack) and J.IsAttacking(bot)
  and GetUnitToUnitDistance(bot,attack)<=bot:GetAttackRange()+50 and J.GetHP(bot)<0.4 then return BOT_ACTION_DESIRE_HIGH end
 return 0
end
function X.ConsiderDisabledEnrage()
 local caster=GetBot()
 if not caster:HasScepter() or (not caster:IsStunned() and not caster:IsNightmared()) then return false end
 Refresh()
 if not bot:IsAlive() or bot:IsHexed() or bot:IsSilenced() or bot:IsInvulnerable() or bot:IsChanneling() or bot:IsUsingAbility() or bot:IsCastingAbility()
  or J.HasQueuedAction(bot) or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active')
  or not J.CanCastAbility(Enrage) or bot:HasModifier('modifier_ursa_enrage') then return false end
 bot:Action_UseAbility(Enrage);return true
end

function X.SkillsComplement()
 if X.ConsiderDisabledEnrage() then return end
 Refresh();if J.CanNotUseAbility(bot) then return end
 if X.ConsiderEnrage()>0 then bot:Action_UseAbility(Enrage);return end
 if X.ConsiderOverpower()>0 then bot:Action_UseAbility(Overpower);return end
 if X.ConsiderEarthshock()>0 then bot:Action_UseAbility(Earthshock);return end
end
return X
