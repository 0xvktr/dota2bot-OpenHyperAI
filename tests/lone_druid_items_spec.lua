package.path = './?.lua;'..package.path
local H = dofile('tests/hero_harness.lua')
local Items = H.realDofile('bots/FunLib/lone_druid_items.lua')
local Data = H.realDofile('bots/BotLib/Builds/lone_druid.lua')
local policy = Data.itemOwnership
local recipes = {
    item_power_treads={'item_boots','item_gloves','item_belt_of_strength'},
    item_maelstrom={'item_mithril_hammer','item_javelin','item_gloves'},
    item_mjollnir={'item_maelstrom','item_hyperstone','item_recipe_mjollnir'},
    item_ultimate_scepter={'item_point_booster','item_ogre_axe','item_blade_of_alacrity','item_staff_of_wizardry'},
    item_invis_sword={'item_shadow_amulet','item_blitz_knuckles','item_broadsword'},
    item_silver_edge={'item_invis_sword','item_demon_edge','item_recipe_silver_edge'},
    item_magic_wand={'item_magic_stick','item_branches','item_branches','item_recipe_magic_wand'},
    item_double_branches={'item_branches','item_branches'},
    item_black_king_bar={'item_ogre_axe','item_mithril_hammer','item_recipe_black_king_bar'},
}
BOT_MODE_NONE = 0
function GetUnitToUnitDistance(a,b) return math.abs(a.location-b.location) end
function GetUnitToLocationDistance(unit,location) return math.abs(unit.location-location) end
local function unit(names)
    local u = {slots={},location=0,enemies={},alive=true,actions={},shopDistance=2000}
    for slot,name in pairs(names or {}) do u.slots[slot]={GetName=function() return name end,IsFullyCastable=function() return true end} end
    function u:IsNull() return false end
    function u:IsAlive() return self.alive end
    function u:IsChanneling() return self.channeling end
    function u:IsUsingAbility() return self.casting end
    function u:GetItemInSlot(slot) return self.slots[slot] end
    function u:GetNearbyHeroes() return self.enemies end
    function u:GetLocation() return self.location end
    function u:HasScepter() return self.consumedScepter end
    function u:IsMagicImmune() return self.immune end
    function u:IsInvisible() return self.invisible end
    function u:IsHero() return true end
    function u:GetTeam() return self.team or 2 end
    function u:WasRecentlyDamagedByAnyHero() return self.damaged end
    function u:GetAttackTarget() return self.target end
    function u:DistanceFromFountain() return self.shopDistance end
    function u:DistanceFromSecretShop() return self.shopDistance end
    function u:Action_DropItem(item,location) self.actions[#self.actions+1]={'drop',item,location} end
    function u:Action_PickUpItem(item) self.actions[#self.actions+1]={'pickup',item} end
    function u:Action_MoveToLocation(location) self.actions[#self.actions+1]={'move',location} end
    function u:ActionImmediate_SwapItems(a,b)
        self.slots[a],self.slots[b]=self.slots[b],self.slots[a]
        self.actions[#self.actions+1]={'swap',a,b}
    end
    function u:ActionImmediate_SellItem(item) self.actions[#self.actions+1]={'sell',item} end
    function u:Action_UseAbility(item) self.actions[#self.actions+1]={'cast',item} end
    function u:Action_UseAbilityOnEntity(item,target) self.actions[#self.actions+1]={'cast',item,target} end
    return u
end

for _,role in ipairs({'pos_1','pos_2','pos_3','pos_4','pos_5'}) do
    local hero = H.load('npc_dota_hero_lone_druid',role)
    local expected = {'A1','A2','A2','A1','A2','A6','A2','A1','A1','A3','T2'}
    for level,name in ipairs(expected) do assert(hero.sSkillList[level]==name, role..' skill '..level) end
    local talents={}
    for _,name in ipairs(hero.sSkillList) do if name:match('^T') then talents[#talents+1]=name end end
    assert(talents[2]=='T3' and talents[3]=='T5' and talents[4]=='T8')
    assert(hero.itemOwnership==hero.buildMetadata.itemOwnership)
end
assert(H.load('npc_dota_hero_lone_druid','pos_1',{custom=true}).sSkillList[10]=='T2')
local init=H.J.SetUserHeroInit
H.J.SetUserHeroInit=function(a,t,items,sells)
    local copy={}; for i,v in ipairs(items) do copy[i]=v end
    return a,t,copy,sells
end
assert(H.load('npc_dota_hero_lone_druid','pos_1').itemOwnership==nil, 'custom items do not enable transfers')
H.J.SetUserHeroInit=init
local bearBuild=H.realDofile('bots/BotLib/hero_lone_druid_bear.lua')
assert(#bearBuild.sSkillList==0 and #bearBuild.sBuyList==0, 'bear inherits skills and uses owner purchases')

local hero=unit({[0]='item_magic_wand',[1]='item_boots',[2]='item_branches'})
local bear=unit({[0]='item_power_treads',[1]='item_maelstrom',[2]='item_ultimate_scepter'})
assert(Items.Complete(hero,bear,policy,'item_ultimate_scepter'))
assert(not Items.Complete(hero,nil,policy,'item_ultimate_scepter'))
assert(not Items.Complete(bear,hero,policy,'item_ultimate_scepter'), 'wrong inventory does not complete a bear target')
assert(Items.OwnedCount(hero,bear,policy,'item_mjollnir','item_javelin',recipes,{})==1)
assert(Items.OwnedCount(hero,bear,policy,'item_mjollnir','item_gloves',recipes,{})==1, 'do not count gloves inside unrelated Treads')
assert(Items.OwnedCount(hero,bear,policy,'item_black_king_bar','item_ogre_axe',recipes,{})==0, 'Scepter cannot supply BKB components')
assert(Items.OwnedCount(hero,bear,policy,'item_mjollnir','item_branches',recipes,{})==0, 'reserve hero inventory')
assert(#Items.BasicItems('item_mjollnir',recipes)==5)
local bootsHero=unit({[0]='item_boots'})
assert(Items.OwnedCount(bootsHero,unit(),policy,'item_power_treads','item_boots',recipes,{})==0, 'bear Treads require a second pair of boots')
hero.loneDruidOpeningBranches=4
assert(not Items.Complete(hero,bear,policy,'item_double_branches'))
local opening=unit({[0]='item_branches',[1]='item_branches',[2]='item_branches',[3]='item_branches'})
opening.loneDruidOpeningBranches=4
assert(Items.Complete(opening,bear,policy,'item_double_branches'))

hero=unit({[0]='item_magic_wand',[1]='item_boots',[2]='item_hyperstone',[3]='item_recipe_mjollnir'})
hero.currBuyingItemInPurchaseList='item_mjollnir'
bear=unit({[0]='item_maelstrom'})
assert(Items.Transfer(hero,bear,policy,recipes,{}))
assert(hero.actions[1][2]==hero.slots[2], 'Mjollnir component transfers to existing Maelstrom; hero items stay')
local drop={owner=hero,item=hero.slots[2],location=150}
hero.slots[2]=nil
assert(Items.IsBearDrop(hero,drop.item))
assert(Items.OwnedCount(hero,bear,policy,'item_mjollnir','item_hyperstone',recipes,{drop})==1, 'pending drop prevents rebuy')
assert(#Items.MissingItems(hero,bear,policy,'item_mjollnir',recipes,{drop})==0, 'pending upgrade is fully paid for')
assert(Items.MissingItems(hero,bear,policy,'item_mjollnir',recipes,{})[1]=='item_hyperstone', 'lost drop rebuilds its missing component')
assert(Items.Transfer(hero,bear,policy,recipes,{drop}) and bear.actions[1][1]=='move', 'close pickup gap still moves')
bear.location=150
assert(Items.Transfer(hero,bear,policy,recipes,{drop}) and bear.actions[2][1]=='pickup')
local stranger=unit()
assert(not Items.Transfer(stranger,bear,policy,recipes,{drop}), 'different owner cannot take transfer')

hero=unit({[0]='item_boots',[1]='item_gloves',[2]='item_belt_of_strength'})
hero.currBuyingItemInPurchaseList='item_power_treads';bear=unit()
assert(not Items.Transfer(hero,bear,policy,recipes,{}), 'first composite assembles on hero before transfer')
hero.slots[1]={GetName=function() return 'item_power_treads' end};hero.slots[2]=nil
assert(Items.Transfer(hero,bear,policy,recipes,{}))
assert(hero.actions[1][2]==hero.slots[1], 'completed Treads transfer, hero boots stay')
hero=unit({[0]='item_ultimate_scepter'});bear=unit()
assert(Items.Transfer(hero,bear,policy,recipes,{}), 'completed Scepter goes to bear')

hero=unit({[0]='item_butterfly'});bear=unit();bear.consumedScepter=true
assert(Items.Complete(hero,bear,policy,'item_ultimate_scepter'))
assert(Items.Transfer(hero,bear,policy,recipes,{}), 'consumed Scepter does not stop subsequent transfers')
hero=unit({[0]='item_ultimate_scepter'})
bear=unit();bear.enemies={unit()}
assert(not Items.Transfer(hero,bear,policy,recipes,{}))
bear.enemies={}; hero.channeling=true
assert(not Items.Transfer(hero,bear,policy,recipes,{}))
hero.channeling=false;bear.alive=false
assert(not Items.Transfer(hero,bear,policy,recipes,{}))
bear.alive=true;bear.location=600
assert(not Items.Transfer(hero,bear,policy,recipes,{}))
bear.location=0;for slot=0,8 do bear.slots[slot]={GetName=function() return 'item_butterfly' end} end
assert(not Items.Transfer(hero,bear,policy,recipes,{}), 'full bear inventory cannot accept a drop')

bear=unit({[0]='item_blight_stone',[1]='item_power_treads',[2]='item_mjollnir',[3]='item_ultimate_scepter',
    [4]='item_silver_edge',[5]='item_black_king_bar',[6]='item_butterfly'})
assert(Items.Transfer(hero,bear,policy,recipes,{}))
assert(bear.slots[0]:GetName()=='item_butterfly' and bear.slots[6]:GetName()=='item_blight_stone', 'six-slot finish equips the upgrade')
bear.shopDistance=0
assert(Items.Transfer(hero,bear,policy,recipes,{}) and bear.actions[2][1]=='sell')
assert(not Items.Transfer(hero,bear,nil,recipes,{}), 'no default policy on custom builds')

bear=unit({[0]='item_black_king_bar'});bear.enemies={unit()};bear.damaged=true
assert(Items.UseItems(bear,nil,false) and bear.actions[1][2]==bear.slots[0])
bear.damaged=false
assert(not Items.UseItems(bear,nil,false), 'save BKB without incoming damage')
bear=unit({[0]='item_mjollnir'});bear.enemies={unit()};bear.target=unit()
assert(Items.UseItems(bear,nil,false) and bear.actions[1][3]==bear, 'Mjollnir shield targets bear')
bear.channeling=true
assert(not Items.UseItems(bear,nil,false))
bear=unit({[0]='item_silver_edge'});local enemy=unit();enemy.team=3;enemy.location=900
assert(Items.UseItems(bear,enemy,false), 'Silver Edge starts a distant approach')
bear.invisible=true
assert(not Items.UseItems(bear,enemy,false), 'do not recast invisibility')
bear.invisible=false;enemy.location=100
assert(not Items.UseItems(bear,enemy,false))
enemy.location=900;enemy.team=2
assert(not Items.UseItems(bear,enemy,false), 'friendly target is not an approach')
assert(not Items.UseItems(bear,nil,true), 'retreat alone does not spend invisibility')
bear.enemies={unit()}
assert(Items.UseItems(bear,nil,true))

-- Execute the real generic purchase dedupe against both inventories.
local purchaseHook = H.realDofile('.test-tools/lone-druid-purchase-hooks.lua')
function GetGameMode() return 0 end
function GetDroppedItemList() return {} end
GAMEMODE_ARDM=20
recipes.HasBootsInMainSolt=function() return false end
hero=unit({[0]='item_boots',[1]='item_magic_wand'});bear=unit({[0]='item_maelstrom'})
local needs = purchaseHook(hero,{itemOwnership=policy},{GetLoneDruid=function() return {bear=bear} end},recipes,Items)
hero.currBuyingItemInPurchaseList='item_mjollnir'
hero.currBuyingRequiredCounts={item_javelin=1,item_mithril_hammer=1,item_gloves=1,item_hyperstone=1,item_recipe_mjollnir=1}
assert(not needs('item_javelin') and not needs('item_gloves'), 'generic queue reuses bear Maelstrom')
assert(needs('item_hyperstone') and needs('item_recipe_mjollnir'), 'generic queue buys only missing upgrade parts')
hero.currBuyingItemInPurchaseList='item_power_treads';hero.currBuyingRequiredCounts={item_boots=1}
assert(needs('item_boots'), 'reserve Druid boots while buying bear boots')
hero.currBuyingItemInPurchaseList='item_boots'
assert(not needs('item_boots'), 'hero target dedupes only hero inventory')
hero=unit({[0]='item_branches',[1]='item_branches'})
needs=purchaseHook(hero,{itemOwnership=policy},{GetLoneDruid=function() return {bear=bear} end},recipes,Items)
hero.currBuyingItemInPurchaseList='item_double_branches';hero.currBuyingRequiredCounts={item_branches=4}
assert(needs('item_branches'), 'second starting pair is still required')
hero.slots[2]=hero.slots[0];hero.slots[3]=hero.slots[1]
assert(not needs('item_branches'), 'four starting branches stop buying')
print('Lone Druid ownership scenarios passed')
