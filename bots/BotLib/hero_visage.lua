local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; forced skipped roles use pos 3.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/visage')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Grave Chill, [2] Soul Assumption, [3] Gravekeeper's Cloak, [6] Summon Familiars.
local roleAbilityBuilds, roleTalentTrees = {}, {}
roleAbilityBuilds.pos_2 = {2,1,1,3,1,6,1,3,3,3,6,2,2,2,6}
roleTalentTrees.pos_2 = {
    t10={10,0}, -- Damage
    t15={10,0}, -- Soul Assumption targets
    t20={10,0}, -- Familiar armor corruption
    t25={10,0}, -- Additional Familiar
}
roleAbilityBuilds.pos_3 = {2,1,1,3,1,6,1,3,3,3,6,2,2,2,6}
roleTalentTrees.pos_3 = {
    t10={10,0}, -- Damage
    t15={10,0}, -- Soul Assumption targets
    t20={10,0}, -- Familiar armor corruption
    t25={10,0}, -- Additional Familiar
}
local nAbilityBuildList = roleAbilityBuilds[sRole] or roleAbilityBuilds.pos_3
local nTalentBuildList = J.Skill.GetTalentBuild(roleTalentTrees[sRole] or roleTalentTrees.pos_3)
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList, sRoleItemsSellList = {}, {}
sRoleItemsBuyList.pos_2 = {
        'item_double_branches','item_double_circlet','item_circlet','item_magic_wand','item_null_talisman',
        'item_vladmir','item_tranquil_boots','item_ancient_janggo','item_aghanims_shard','item_ultimate_scepter',
        -- Bot policy: selected situational items and late upgrades.
        'item_boots_of_bearing','item_assault','item_ultimate_scepter_2','item_black_king_bar','item_sheepstick',
}
sRoleItemsSellList.pos_2 = {'item_assault','item_magic_wand','item_black_king_bar','item_null_talisman'}
sRoleItemsBuyList.pos_3 = {
        'item_double_branches','item_double_circlet','item_tango','item_enchanted_mango','item_null_talisman',
        'item_magic_wand','item_tranquil_boots','item_ancient_janggo','item_vladmir',
        -- Bot policy: selected situational items and late upgrades.
        'item_boots_of_bearing','item_aghanims_shard','item_assault','item_ultimate_scepter','item_ultimate_scepter_2',
        'item_black_king_bar','item_sheepstick',
}
sRoleItemsSellList.pos_3 = {'item_assault','item_magic_wand','item_black_king_bar','item_null_talisman'}
sRoleItemsBuyList.pos_1 = sRoleItemsBuyList.pos_3
sRoleItemsSellList.pos_1 = sRoleItemsSellList.pos_3
sRoleItemsBuyList.pos_4 = sRoleItemsBuyList.pos_3
sRoleItemsSellList.pos_4 = sRoleItemsSellList.pos_3
sRoleItemsBuyList.pos_5 = sRoleItemsBuyList.pos_3
sRoleItemsSellList.pos_5 = sRoleItemsSellList.pos_3
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
	Minion.MinionThink(hMinionUnit)
end

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
function X.SkillsComplement()
 Refresh();if J.CanNotUseAbility(bot) then return end
 if X.ConsiderGravekeepersCloak()>0 then bot:Action_UseAbility(GravekeepersCloak);return end
 local desire,target=X.ConsiderSoulAssumption()
 if desire>0 then bot:Action_UseAbilityOnEntity(SoulAssumption,target);return end
 if X.ConsiderSilentAsTheGrave()>0 then bot:Action_UseAbility(SilentAsTheGrave);return end
 desire,target=X.ConsiderGraveChill()
 if desire>0 then bot:Action_UseAbilityOnEntity(GraveChill,target);return end
 if X.ConsiderSummonFamiliars()>0 then bot:Action_UseAbility(SummonFamiliars);bot.visageSummonAttemptTime=DotaTime() end
end
return X
