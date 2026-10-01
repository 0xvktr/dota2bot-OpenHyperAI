-- Specialized dispatch must stop generic fallback after either a cast or a deliberate skip.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_ACTION_DESIRE_MODERATE=0.5
BOT_MODE_NONE=0; BOT_MODE_ROSHAN=10; BOT_MODE_LANING=11
TEAM_NEUTRAL=4; DAMAGE_TYPE_PHYSICAL=1; DAMAGE_TYPE_MAGICAL=2
UNIT_LIST_ALLIES=1; UNIT_LIST_ALLIED_HEROES=2
local now, blocked, target, actions = 100, false, {}, {}
function DotaTime() return now end
function GetLinearProjectiles() return {} end
function GetUnitList() return {} end
function bot:GetLocation() return {x=0,y=0,z=0} end
function bot:GetMana() return 1000 end
function bot:GetMaxMana() return 1000 end
function bot:GetHealth() return 1000 end
function bot:GetMaxHealth() return 1000 end
function bot:GetLevel() return 20 end
function bot:IsAlive() return true end
function bot:IsStunned() return false end
function bot:IsHexed() return false end
function bot:IsNightmared() return false end
function bot:IsChanneling() return false end
function bot:IsInvisible() return false end
function bot:HasModifier() return false end
function bot:GetAbilityByName() return nil end
function bot:GetItemInSlot() return nil end
function bot:GetActiveMode() return 0 end
function bot:GetAttackDamage() return 100 end
for _,name in ipairs({'Action_UseAbility','Action_UseAbilityOnEntity','Action_UseAbilityOnLocation',
    'ActionQueue_UseAbility','ActionQueue_UseAbilityOnEntity','ActionQueue_UseAbilityOnLocation'}) do
    bot[name]=function(_,ability,arg)
        assert(ability ~= nil, 'cast a valid stolen ability')
        if name:find('OnEntity') then assert(arg == target or arg == bot, 'entity cast uses the selected unit') end
        actions[#actions+1]={name=name,ability=ability,target=arg}
    end
end
function bot:Action_ClearActions() end
function bot:ActionQueue_Delay() end
function target:GetLocation() return {x=100,y=0,z=0} end
J.CanNotUseAbility=function() return blocked end
J.GetProperTarget=function() return target end
J.GetNearbyHeroes=function() return {} end
J.GetAlliesNearLoc=function() return {} end
J.SetQueuePtToINT=function() end
J.SetQueueToInvisible=function() end
local function Spell(name, values)
    local a={}
    function a:GetName() return name end
    function a:IsFullyCastable() return true end
    function a:IsTrained() return true end
    function a:IsHidden() return false end
    function a:GetLevel() return 1 end
    function a:GetCastRange() return 600 end
    function a:GetCastPoint() return 0 end
    function a:GetManaCost() return 100 end
    function a:GetSpecialValueInt(key) return values and values[key] or 100 end
    function a:GetSpecialValueFloat(key) return values and values[key] or 1.5 end
    return a
end
local function Load(name)
    return H.realDofile('bots/FunLib/rubick_hero/'..name..'.lua')
end
local cases={
    abaddon={'abaddon_aphotic_shield','abaddon_death_coil'},
    abyssal_underlord={'abyssal_underlord_pit_of_malice','abyssal_underlord_firestorm','abyssal_underlord_dark_portal'},
    alchemist={'alchemist_chemical_rage','alchemist_unstable_concoction_throw','alchemist_unstable_concoction','alchemist_acid_spray','alchemist_berserk_potion'},
    ancient_apparition={'ancient_apparition_ice_blast_release','ancient_apparition_ice_blast','ancient_apparition_ice_vortex','ancient_apparition_cold_feet','ancient_apparition_chilling_touch'},
    antimage={'antimage_counterspell','antimage_mana_overload','antimage_blink','antimage_mana_void','antimage_counterspell_ally'},
    arc_warden={'arc_warden_flux','arc_warden_magnetic_field','arc_warden_spark_wraith'},
    axe={'axe_culling_blade','axe_berserkers_call','axe_battle_hunger'},
    bane={'bane_enfeeble','bane_brain_sap','bane_fiends_grip','bane_nightmare'},
    batrider={'batrider_flaming_lasso','batrider_firefly','batrider_flamebreak','batrider_sticky_napalm'},
    beastmaster={'beastmaster_primal_roar','beastmaster_summon_razorback','beastmaster_summon_raptor','beastmaster_wild_axes'},
    bloodseeker={'bloodseeker_blood_mist','bloodseeker_rupture','bloodseeker_bloodrage','bloodseeker_blood_bath'},
    bounty_hunter={'bounty_hunter_wind_walk','bounty_hunter_wind_walk_ally','bounty_hunter_track','bounty_hunter_shuriken_toss'},
    brewmaster={'brewmaster_cinder_brew','brewmaster_thunder_clap'},
    bristleback={'bristleback_hairball','bristleback_bristleback','bristleback_viscous_nasal_goo','bristleback_quill_spray'},
    broodmother={'broodmother_spawn_spiderlings','broodmother_spin_web','broodmother_silken_bola','broodmother_insatiable_hunger'},
    centaur={'centaur_mount','centaur_work_horse','centaur_stampede','centaur_hoof_stomp','centaur_double_edge'},
    chaos_knight={'chaos_knight_phantasm','chaos_knight_reality_rift','chaos_knight_chaos_bolt'},
    chen={'chen_hand_of_god','chen_penitence','chen_holy_persuasion','chen_divine_favor'},
    clinkz={'clinkz_wind_walk','clinkz_tar_bomb','clinkz_burning_barrage','clinkz_strafe','clinkz_death_pact','clinkz_burning_army'},
    crystal_maiden={'crystal_maiden_crystal_clone','crystal_maiden_crystal_nova','crystal_maiden_frostbite','crystal_maiden_freezing_field'},
    rattletrap={'rattletrap_overclocking','rattletrap_hookshot','rattletrap_power_cogs','rattletrap_battery_assault','rattletrap_rocket_flare','rattletrap_jetpack'},
}
local count=0
for hero,names in pairs(cases) do
    for _,name in ipairs(names) do
        local X=Load(hero)
        for key in pairs(X) do
            if key:match('^Consider') and key ~= 'ConsiderStolenSpell' then
                X[key]=function() return 0,target end
            end
        end
        X.HasBlink=function() return false end
        X.CanBKB=function() return false end
        X.ConsiderCombo=function() return false end
        local ability=Spell(name)
        actions={}; blocked=false
        assert(X.ConsiderStolenSpell(ability)==false and #actions==0, hero..' recognized skip must stop fallback')
        actions={}; blocked=true
        assert(X.ConsiderStolenSpell(Spell('unrecognized_spell'))==nil and #actions==0, hero..' unknown must preserve fallback')
        assert(X.ConsiderStolenSpell(ability)==false and #actions==0, hero..' blocked known spell must stop fallback')
        blocked=false
        for key in pairs(X) do
            if key:match('^Consider') and key ~= 'ConsiderStolenSpell' then
                X[key]=function() return 1,target end
            end
        end
        X.ConsiderCombo=function() return false end
        if name=='clinkz_burning_army' then
            assert(X.ConsiderStolenSpell(ability)==false and #actions==0, 'unsupported vector spell must remain skipped')
        else
            assert(X.ConsiderStolenSpell(ability)==true and #actions==1, hero..' reports true only after exactly one spell action: '..name)
            assert(actions[1].ability==ability, 'dispatch must use the supplied stolen handle')
            if name=='bloodseeker_bloodrage' then assert(actions[1].name=='Action_UseAbility', 'Bloodrage is a self buff') end
            if name=='crystal_maiden_crystal_clone' then assert(actions[1].name=='Action_UseAbilityOnLocation', 'Clone requires a point') end
        end
        count=count+1
    end
end

-- Linked spells can exist without their owner's other abilities.
local X=Load('batrider')
local blink=Spell('item_blink')
function bot:GetItemInSlot(slot) return slot==0 and blink or nil end
X.CanBKB=function() return false end
X.ConsiderBlinkLasso=function() return 1,target end
X.ConsiderFirefly=function() error('absent linked Firefly must not be considered') end
actions={}
assert(X.ConsiderStolenSpell(Spell('batrider_flaming_lasso'))==true)
assert(#actions==2 and actions[2].target==target, 'blink Lasso works without stolen Firefly')

X=Load('alchemist')
J.GetProperCastRange=function(_,_,range) return range end
J.IsGoingOnSomeone=function() return false end
J.IsRetreating=function() return false end
J.GetNearbyHeroes=function() return {} end
local throw=Spell('alchemist_unstable_concoction_throw',{max_damage=360})
assert(X.ConsiderStolenSpell(throw)==false, 'Concoction Throw must not dereference absent brewing ability')

X=Load('ancient_apparition')
assert(X.ConsiderStolenSpell(Spell('ancient_apparition_ice_blast_release'))==false, 'release without a tracked tracer does not cast')

-- Persuasion counts only this bot's units and respects levels in its early branch.
local creeps,allies={},{}
function bot:GetNearbyNeutralCreeps() return creeps end
function GetUnitList() return allies end
local function Creep(level,owner,converted)
    return {GetLevel=function() return level end,IsAncientCreep=function() return false end,
        GetUnitName=function() return 'npc_dota_neutral_alpha_wolf' end,
        GetPlayerID=function() return owner end,HasModifier=function() return converted end}
end
J.IsValid=function(unit) return unit~=nil end
X=Load('chen')
local persuasion=Spell('chen_holy_persuasion',{max_units=1,level_req=3})
creeps={Creep(5,9,false)}
assert(X.ConsiderStolenSpell(persuasion)==false, 'do not select a creep above the stolen persuasion cap')
creeps={Creep(3,9,false)};target=creeps[1];allies={Creep(3,1,true)}
actions={}
assert(X.ConsiderStolenSpell(persuasion)==true, 'another Chen player does not fill Rubick control cap')
allies={Creep(3,bot:GetPlayerID(),true)};actions={}
assert(X.ConsiderStolenSpell(persuasion)==false and #actions==0, 'own controlled-unit cap prevents needless replacement')

-- Current Culling damage and renamed Coil/Wraith fields drive actual targeting.
function target:GetLocation() return {x=100,y=0,z=0} end
function target:CanBeSeen() return true end
function target:GetHealth() return 260 end
function target:GetHealthRegen() return 0 end
function target:IsInvulnerable() return false end
function target:IsMagicImmune() return false end
function target:HasModifier() return false end
function target:GetExtrapolatedLocation(delay) assert(delay==1.5); return self:GetLocation() end
J.IsValidHero=function(unit) return unit~=nil end
J.IsHaveAegis=function() return false end
J.GetAroundEnemyHeroList=function() return {target} end
X=Load('axe');X.HasSpecialModifier=function() return false end;X.IsKillBotAntiMage=function() return false end
assert(X.ConsiderStolenSpell(Spell('axe_culling_blade',{damage=275}))==true, 'use the current 275 execution threshold, not 250')
J.GetNearbyHeroes=function() return {target} end
J.CanCastOnNonMagicImmune=function() return true end
J.IsSuspiciousIllusion=function() return false end
J.CanKillTarget=function(_,damage) assert(damage==320); return true end
X=Load('abaddon')
local coil=Spell('abaddon_death_coil')
coil.GetSpecialValueInt=function(_,key) assert(key=='damage_heal'); return 320 end
assert(X.ConsiderStolenSpell(coil)==true, 'Mist Coil reads damage_heal')
J.GetNearbyHeroes=function() return {} end
J.CanKillTarget=function(_,damage) assert(damage==310); return true end
J.IsInRange=function() return true end
X=Load('arc_warden')
local wraith=Spell('arc_warden_spark_wraith')
wraith.GetSpecialValueInt=function(_,key) assert(key=='radius' or key=='spark_damage_base'); return key=='radius' and 375 or 310 end
wraith.GetSpecialValueFloat=function(_,key) assert(key=='base_activation_delay'); return 1.5 end
assert(X.ConsiderStolenSpell(wraith)==true, 'Spark Wraith uses current damage and fractional delay')

-- A stolen Stomp does not require Stampede to exist.
J.CanKillTarget=function() return false end
J.IsGoingOnSomeone=function() return true end
J.IsDisabled=function() return false end
J.IsValidTarget=function(unit) return unit~=nil end
J.GetNearbyHeroes=function() return {} end
X=Load('centaur')
assert(X.ConsiderStolenSpell(Spell('centaur_hoof_stomp',{radius=315,stomp_damage=120}))==true, 'stolen Stomp works without Stampede')

-- Release survives losing the launch handle and clears its tracked shot afterward.
X=Load('ancient_apparition')
X.ConsiderIceBlast=function() return 1,target:GetLocation() end
local blast=Spell('ancient_apparition_ice_blast',{speed=1500})
assert(X.ConsiderStolenSpell(blast)==true)
blast.GetSpecialValueInt=function() error('release must not read a stale launch handle') end
J.GetLocationToLocationDistance=function(a,b) return math.abs(a.x-b.x) end
now=now+0.2
local release=Spell('ancient_apparition_ice_blast_release')
assert(X.ConsiderStolenSpell(release)==true, 'release tracks the launch speed independently')
assert(X.ConsiderStolenSpell(release)==false, 'released shot must not leave stale tracker state')

X=Load('bloodseeker')
J.IsInTeamFight=function() return false end
J.IsPushing=function() return false end
J.IsDefending=function() return false end
J.CanCastOnMagicImmune=function() return true end
actions={}
assert(X.ConsiderStolenSpell(Spell('bloodseeker_bloodrage'))==true)
assert(actions[1].name=='Action_UseAbility', 'current Bloodrage combat logic uses a self cast')
print('Rubick specialized handler scenarios passed ('..count..' spell dispatches)')
