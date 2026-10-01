local H=dofile('tests/hero_harness.lua'); local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0;BOT_ACTION_DESIRE_HIGH=1;BOT_MODE_NONE=0;DAMAGE_TYPE_PURE=4;DAMAGE_TYPE_PHYSICAL=1
local enemies,allies,lanes,neutrals,actions,target={},{},{},{},{},nil
local U={};U.__index=U
local function unit(x,hp) return setmetatable({x=x,hp=hp or 1000,maxHp=1000,mods={},valid=true},U) end
function U:CanBeSeen() return self.valid end
function U:IsInvulnerable() return self.invul==true end
function U:IsMagicImmune() return self.immune==true end
function U:IsChanneling() return self.channel==true end
function U:HasModifier(n) return self.mods[n]==true end
function U:GetHealth() return self.hp end
function U:GetHealthRegen() return 0 end
function U:GetMaxHealth() return self.maxHp end
function U:GetAttackRange() return 150 end
function U:GetAttackDamage() return 100 end
function U:IsInvisible() return false end
function U:GetLocation() return {x=self.x,y=0} end
function U:WasRecentlyDamagedByAnyHero() return self.recent==true end
setmetatable(bot,U)
local abilities={}
for _,n in ipairs({'axe_berserkers_call','axe_battle_hunger','axe_culling_blade'}) do
 local a={name=n,castable=false,range=n=='axe_culling_blade' and 175 or 600,stack=false}
 function a:GetName() return self.name end
 function a:IsFullyCastable() return self.castable end
 function a:GetLevel() return 3 end
 function a:GetCastRange() return self.range end
 function a:GetCastPoint() return 0.3 end
 function a:GetManaCost() return 100 end
 function a:GetSpecialValueInt(k) return ({radius=315,damage=475,should_stack=self.stack and 1 or 0})[k] or 0 end
 abilities[n]=a
end
local talent={IsTrained=function() return false end,GetSpecialValueInt=function() return 150 end}
bot.GetAbilityByName=function(_,n) return ({A1=abilities.axe_berserkers_call,A2=abilities.axe_battle_hunger,A6=abilities.axe_culling_blade})[n] or (n:sub(1,1)=='T' and talent or nil) end
function bot:GetMana() return 1000 end
function bot:GetMaxMana() return 1000 end
function bot:GetLevel() return 20 end
function bot:GetNearbyLaneCreeps(_,enemy) return enemy and {} or lanes end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:ActionQueue_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
bot.Action_UseAbilityOnEntity=bot.ActionQueue_UseAbilityOnEntity
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={name=a.name} end
bot.Action_UseAbility=bot.ActionQueue_UseAbility
J.IsValid=function(u) return u~=nil and u.valid end;J.IsValidHero=J.IsValid
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.IsInRange=function(a,b,r) return a and b and math.abs(a.x-b.x)<=r end
J.GetAroundEnemyHeroList=function(r) local l={};for _,e in ipairs(enemies) do if J.IsInRange(bot,e,r) then l[#l+1]=e end end;return l end
J.GetNearbyHeroes=function() return enemies end;J.GetAlliesNearLoc=function() return allies end
J.GetProperTarget=function() return target end;J.GetHP=function(u) return u.hp/u.maxHp end
J.IsItemAvailable=function() return nil end;J.CanNotUseAbility=function() return false end
J.IsDisabled=function(u) return u.disabled or u.mods.modifier_axe_berserkers_call end
J.CanCastOnNonMagicImmune=function(u) return not u.immune and not u.invul end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked end
J.IsHaveAegis=function(u) return u.aegis==true end
J.SetQueuePtToINT=function() end;J.SetReportMotive=function() end;J.Chat={GetNormName=function() return 'enemy' end}
for _,n in ipairs({'GoingOnSomeone','InTeamFight','Retreating','Laning','Farming','Pushing','Defending'}) do J['Is'..n]=function() return bot.mode==n end end
J.IsDoingRoshan=function() return false end;J.IsDoingTormentor=function() return false end;J.IsAttacking=function() return true end
J.IsRoshan=function() return false end;J.IsAllowedToSpam=function() return true end
J.GetMostHpUnit=function(l) return l[1] end;J.CanKillTarget=function(u,d) return u.hp<=d end
local hero=H.load('npc_dota_hero_axe','pos_3');local stolen=H.realDofile('bots/FunLib/rubick_hero/axe.lua')
local function reset()
 enemies,allies,lanes,neutrals,actions,target={},{},{},{},{},nil
 bot.x=0;bot.hp=1000;bot.maxHp=1000;bot.mods={};bot.mode=nil;bot.recent=false
 for _,a in pairs(abilities) do a.castable=false;a.stack=false end
end
local function tick(copy,n) actions={};if copy then stolen.ConsiderStolenSpell(abilities[n]) else hero.SkillsComplement() end;return actions[1] end
local call,hunger,blade='axe_berserkers_call','axe_battle_hunger','axe_culling_blade'
for _,copy in ipairs({false,true}) do
 reset();bot.mode='GoingOnSomeone';target=unit(280);target.immune=true;enemies={target};abilities[call].castable=true
 assert(tick(copy,call).name==call,'Call must catch an immune hero')
 bot.mode='Retreating';bot.recent=true;assert(tick(copy,call).name==call,'Call peels while retreating')
 target.disabled=true;assert(tick(copy,call)==nil,'do not overlap existing control')
 target.disabled=false;target.channel=true;assert(tick(copy,call),'interrupt immune channel')
 reset();target=unit(500);enemies={target};bot.mode='GoingOnSomeone';abilities[hunger].castable=true
 target.mods.modifier_axe_battle_hunger=true;assert(tick(copy,hunger)==nil,'existing enemy Hunger prevents refresh')
 abilities[hunger].stack=true;assert(tick(copy,hunger).target==target,'Shard permits Hunger stacking')
 target.mods.modifier_antimage_counterspell=true;assert(tick(copy,hunger)==nil,'avoid current Counterspell')
 reset();target=unit(500);enemies={target};bot.mode='Laning';abilities[hunger].castable=true
 lanes={unit(520,30)};assert(tick(copy,hunger)==nil,'easy last hit immediately removes lane Hunger')
 lanes[1].hp=1000;assert(tick(copy,hunger).target==target,'harass when nearby creeps remain healthy')
 reset();target=unit(170,450);target.immune=true;target.mods.modifier_dazzle_shallow_grave=true;enemies={target};abilities[blade].castable=true
 assert(tick(copy,blade).target==target,'current 475 execute pierces immunity and Grave')
 target.x=176;assert(tick(copy,blade)==nil,'never walk into fake bonus execute range')
 target.x=170;target.mods.modifier_antimage_counterspell=true;assert(tick(copy,blade)==nil,'no reflected execute')
 target.mods={};target.illusion=true;target.mods.modifier_illusion=true;assert(tick(copy,blade)==nil,'do not spend execute on illusion')
end
print('Axe ability scenarios passed')
