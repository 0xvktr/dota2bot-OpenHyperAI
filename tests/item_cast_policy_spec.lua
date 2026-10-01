package.path = './?.lua;'..package.path
BOT_MODE_NONE = 0; BOT_ACTION_DESIRE_HIGH = 1; BOT_ACTION_DESIRE_NONE = 0
DAMAGE_TYPE_PHYSICAL = 1
local now = 100
function DotaTime() return now end
local P = require('bots/FunLib/item_cast_policy')
local bot = { mana=50, maxMana=1000, hp=1000, maxHP=1000, mode=0, slots={}, enemies={} }
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return self.maxMana end
function bot:GetHealth() return self.hp end
function bot:GetMaxHealth() return self.maxHP end
bot.OriginalGetHealth = bot.GetHealth; bot.OriginalGetMaxHealth = bot.GetMaxHealth
function bot:GetActiveMode() return self.mode end
function bot:GetTeam() return 2 end
function bot:GetUnitName() return self.name or 'npc_dota_hero_sven' end
function bot:GetItemInSlot(i) return self.slots[i] end
function bot:IsAlive() return not self.dead end
function bot:NumQueuedActions() return self.queued or 0 end
function bot:HasModifier() return self.teleporting end
function bot:GetAttackTarget() return self.target end
function bot:GetAttackRange() return 600 end
function bot:GetAttackDamage() return 100 end
function bot:WasRecentlyDamagedByAnyHero() return false end
function bot:SetTarget(t) self.target=t end
for _, method in ipairs({'IsChanneling','IsCastingAbility','IsUsingAbility','IsSilenced','IsMuted',
    'IsStunned','IsHexed','IsNightmared','IsInvisible'}) do
    bot[method] = function(self) return self[method..'Flag'] == true end
end
local function ability(name, cost)
    local a = { name=name, cost=cost or 150, cd=0, trained=true, active=true, specials={} }
    function a:GetName() return self.name end
    function a:GetManaCost() return self.cost end
    function a:GetCastRange() return 600 end
    function a:GetCooldownTimeRemaining() return self.cd end
    function a:IsNull() return self.null == true end
    function a:IsTrained() return self.trained end
    function a:IsHidden() return self.hidden == true end
    function a:IsActivated() return self.active end
    function a:IsPassive() return self.passive == true end
    function a:IsFullyCastable() return P.Ready(self) and (self.item or self.cost <= bot.mana) end
    function a:GetSpecialValueInt(key) return self.specials[key] or 0 end
    function a:GetCurrentCharges() return self.charges or 0 end
    return a
end
local target = { hero=true, alive=true, team=3, range=400 }
function target:IsHero() return self.hero end
function target:IsAlive() return self.alive end
function target:GetTeam() return self.team end
local J = {
    IsValidHero=function(t) return t ~= nil and t.hero and t.alive end,
    IsValid=function(t) return t ~= nil and t.alive end,
    IsValidBuilding=function() return false end,
    CanBeAttacked=function(t) return not t.immune end,
    IsInRange=function(_, t, range) return t.range <= range end,
    CanCastOnNonMagicImmune=function(t) return not t.immune end,
    CanCastOnTargetAdvanced=function(t) return not t.shield end,
    GetEnemyCount=function() return #bot.enemies end,
    GetNearbyHeroes=function() return bot.enemies end,
    CanKillTarget=function() return false end,
    GetAroundTargetEnemyUnitCount=function() return 2 end,
}
local spell = ability('sven_storm_bolt')
local selected = true
local function request() assert(P.Request(bot, spell, target, 'unit', function() return selected end, J)) end
local function item(name, charges)
    local a = ability(name, 0); a.item=true; a.charges=charges
    return a
end
local mango, stick, wand, ring = item('item_enchanted_mango'), item('item_magic_stick',7),
    item('item_magic_wand',7), item('item_soul_ring')
bot.slots = {[0]=mango,[1]=stick,[2]=wand,[3]=ring}
local decisions = dofile('.test-tools/item-cast-hooks.lua')(bot, J)
for _, h in ipairs({mango,stick,wand,ring}) do
    assert(P.RestoreDesire(bot,h,J) == 0, 'missing cast intent must not consume '..h.name)
end
request()
for _, h in ipairs({mango,stick,wand,ring}) do
    assert(decisions[h.name](h) > 0, 'enable current useful spell with '..h.name)
end
stick.charges=6; assert(P.RestoreDesire(bot,stick,J)==0, 'insufficient charges cannot enable spell')
stick.charges=0; assert(P.RestoreDesire(bot,stick,J)==0)
spell.cost=300; assert(P.RestoreDesire(bot,mango,J)==0, 'one mango must cover deficit')
spell.cost=150
bot.maxMana=100; assert(P.RestoreDesire(bot,mango,J)==0, 'restoration is capped by maximum mana'); bot.maxMana=1000
for field, value in pairs({cd=1, hidden=true, active=false, trained=false, passive=true, null=true}) do
    local old=spell[field]; spell[field]=value
    assert(P.RestoreDesire(bot,mango,J)==0, 'reject unavailable spell '..field)
    spell[field]=old
end
for field, value in pairs({alive=false, immune=true, shield=true, range=601, hero=false}) do
    local old=target[field]; target[field]=value
    assert(P.RestoreDesire(bot,mango,J)==0, 'reject invalid target '..field)
    target[field]=old
end
selected=false; assert(P.RestoreDesire(bot,mango,J)==0, 'revalidate useful desire')
selected=true
bot.mode=1; assert(P.RestoreDesire(bot,mango,J)==0, 'mode changed'); bot.mode=0
now=100.36; assert(P.RestoreDesire(bot,mango,J)==0, 'intent expired'); request()
for _, field in ipairs({'IsChannelingFlag','IsCastingAbilityFlag','IsUsingAbilityFlag','IsSilencedFlag',
    'IsMutedFlag','IsStunnedFlag','IsHexedFlag','IsNightmaredFlag','IsInvisibleFlag','dead','teleporting'}) do
    bot[field]=true; assert(P.RestoreDesire(bot,mango,J)==0, field..' must block restoration'); bot[field]=false
end
bot.queued=1; assert(P.RestoreDesire(bot,mango,J)==0, 'do not clear pending combo'); bot.queued=0
bot.mana=150; assert(P.RestoreDesire(bot,mango,J)==0, 'already affordable'); bot.mana=50
bot.hp=650; assert(P.RestoreDesire(bot,ring,J)==0, 'real health after payment too low')
bot.hp=1000; bot.enemies={ {}, {}, {} }; assert(P.RestoreDesire(bot,ring,J)>0)
bot.hp=950; assert(P.RestoreDesire(bot,ring,J)==0, 'higher combat reserve'); bot.enemies={}
bot.hp=1000; bot.mana=500
assert(not P.SoulRingUseful(bot,ring,nil,0,false), 'legacy helper without spell cannot spend health')
assert(P.SoulRingUseful(bot,ring,spell,0,false), 'safe selected cast spends temporary mana first')
spell.cost=50; assert(not P.SoulRingUseful(bot,ring,spell,0,false), 'small cast wastes temporary mana')
spell.cost=150; bot.mana=950; assert(not P.SoulRingUseful(bot,ring,spell,0,false), 'near full mana wastes ring')
bot.mana=50; request(); P.Clear(bot)
local available = bot.slots; bot.slots={}
assert(not P.Request(bot,spell,target,'unit',function() return true end,J) and bot.ohaManaCastIntent==nil,
    'missing active restoration must not stall other spells')
bot.slots=available
bot.hp=350; bot.enemies={target}
stick.charges=7
assert(decisions.item_magic_stick(stick)>0 and decisions.item_magic_wand(wand)>0, 'emergency healing remains')
bot.hp=1000
assert(decisions.item_magic_wand(wand)==0 and decisions.item_enchanted_mango(mango)==0,
    'low mana alone does not burn restoration')

-- Exercise the real MoM predicate: the old OR always passed these cases.
bot.target=target; target.alive=true; target.hero=true; target.range=400
for hero, names in pairs({sniper={'sniper_assassinate'}, medusa={'medusa_stone_gaze'},
    faceless_void={'faceless_void_chronosphere','faceless_void_time_walk'}}) do
    bot.name='npc_dota_hero_'..hero
    local spells={}
    for _, n in ipairs(names) do spells[n]=ability(n) end
    function bot:GetAbilityByName(n) return spells[n] end
    local consider=dofile('.test-tools/item-cast-hooks.lua')(bot,J).item_mask_of_madness
    assert(consider(item('item_mask_of_madness'))==0, hero..' must reserve ready important spell')
    for _, a in pairs(spells) do a.cd=10 end
    assert(consider(item('item_mask_of_madness'))>0, hero..' may attack while spells on cooldown')
    bot.enemies={}
    for _, a in pairs(spells) do a.cd=0 end
    assert(consider(item('item_mask_of_madness'))>0, 'safe farming remains possible')
    bot.enemies={target}
end
bot.name='npc_dota_hero_drow_ranger'
assert(not P.AllowMask(bot,false), 'retain Drow policy')
bot.name='npc_dota_hero_sven'; assert(P.AllowMask(bot,true), 'ordinary hero still allowed')
print('Shared item policy scenarios passed')
