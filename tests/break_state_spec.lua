local HasBreak = dofile('bots/FunLib/break_state.lua')
local active
local bot = setmetatable({HasModifier=function(_,name) return name==active end},
    {__index=function(_,name) error('unsupported bot API: '..name) end})
active='modifier_silver_edge_debuff'; assert(HasBreak(bot),'Silver Edge blocks passive range and automatic ultimates')
active='modifier_viper_viper_strike_slow'; assert(HasBreak(bot),'Viper Strike disables passives')
active='modifier_break'; assert(HasBreak(bot),'generic break state is recognized')
active='modifier_item_silver_edge_windwalk'; assert(not HasBreak(bot),'caster invisibility is not victim break')
active='modifier_orchid_malevolence_debuff'; assert(not HasBreak(bot),'silence does not disable passive range')
active=nil; assert(not HasBreak(bot),'normal hero retains passives without server methods')
print('Break state scenarios passed')
