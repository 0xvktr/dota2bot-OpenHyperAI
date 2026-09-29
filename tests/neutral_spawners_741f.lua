-- Neutral camps as GetNeutralSpawners() returns them in 7.41f (dumped in a lobby game with
-- FunLib/debug_dumps.lua on 2026-09-29). team 2 = Radiant, 3 = Dire; min/max are the spawn box corners:
-- any unit or ward inside the box stops the camp from respawning.
-- Usage: local camps = dofile('tests/neutral_spawners_741f.lua')(Vector)
return function(V)
    return {
        { team = 2, type = 'small', location = V(3978.5, -5026.5, 136.0), min = V(3647.4, -5437.9, -284.0), max = V(4442.9, -4648.1, 472.0) }, -- key 1
        { team = 2, type = 'small', location = V(2768.0, -8336.0, 24.0), min = V(2343.8, -8714.1, -328.0), max = V(2998.6, -8026.8, 360.0) }, -- key 10
        { team = 2, type = 'medium', location = V(1921.6, -3974.8, 384.0), min = V(1458.0, -4448.5, -256.0), max = V(2206.0, -3617.9, 571.8) }, -- key 11
        { team = 2, type = 'small', location = V(-8023.0, -1838.0, 264.0), min = V(-8357.0, -2173.0, -176.0), max = V(-7608.0, -1392.0, 600.0) }, -- key 12
        { team = 2, type = 'medium', location = V(-2415.0, -8402.0, 150.0), min = V(-2855.5, -8767.5, -451.0), max = V(-2103.5, -8031.5, 386.6) }, -- key 13
        { team = 2, type = 'medium', location = V(4416.0, -8432.0, 24.0), min = V(4071.8, -8634.1, -328.0), max = V(4726.6, -7946.8, 360.0) }, -- key 14
        { team = 3, type = 'medium', location = V(-852.0, 4940.0, 265.3), min = V(-1216.0, 4520.0, -299.4), max = V(-316.0, 5304.0, 472.0) }, -- key 15
        { team = 3, type = 'medium', location = V(3392.0, -1408.0, 264.0), min = V(3008.0, -1536.0, 0.0), max = V(3776.0, -896.0, 600.0) }, -- key 16
        { team = 3, type = 'large', location = V(7928.0, -120.0, 256.0), min = V(7617.1, -408.8, -192.0), max = V(8257.1, 295.2, 600.0) }, -- key 17
        { team = 3, type = 'large', location = V(-4823.9, 3914.8, 179.7), min = V(-5211.7, 3584.1, -276.3), max = V(-4495.6, 4398.0, 472.0) }, -- key 18
        { team = 3, type = 'ancient', location = V(4352.0, 48.0, 313.0), min = V(3528.0, -402.0, -172.0), max = V(4670.0, 528.0, 600.0) }, -- key 19
        { team = 2, type = 'large', location = V(4649.3, -3698.8, 136.0), min = V(4379.1, -4312.6, -360.0), max = V(5121.9, -3495.4, 472.0) }, -- key 2
        { team = 3, type = 'medium', location = V(1224.0, 4176.0, 264.0), min = V(783.2, 3772.0, -512.0), max = V(1520.8, 4420.0, 472.0) }, -- key 20
        { team = 3, type = 'medium', location = V(336.0, 7696.0, 251.0), min = V(-39.7, 7358.3, 0.7), max = V(654.5, 8062.3, 472.0) }, -- key 21
        { team = 3, type = 'large', location = V(1064.0, 2580.0, 264.0), min = V(637.0, 2142.0, -512.0), max = V(1539.0, 2931.0, 472.0) }, -- key 22
        { team = 3, type = 'small', location = V(8429.7, 1262.8, 384.0), min = V(8192.0, 896.0, 256.0), max = V(8704.0, 1536.0, 600.0) }, -- key 23
        { team = 3, type = 'small', location = V(-2880.0, 7376.0, 60.4), min = V(-3318.7, 7060.0, -112.1), max = V(-2609.0, 7764.0, 366.6) }, -- key 24
        { team = 3, type = 'medium', location = V(-2595.5, 3850.1, 310.7), min = V(-2923.0, 3543.0, 139.0), max = V(-2213.3, 4170.7, 600.0) }, -- key 25
        { team = 3, type = 'small', location = V(-3910.8, 4829.3, 128.0), min = V(-4260.0, 4550.3, -320.0), max = V(-3620.0, 5340.7, 472.0) }, -- key 26
        { team = 3, type = 'medium', location = V(2016.0, 7896.0, 256.0), min = V(1629.3, 7524.4, 8.0), max = V(2530.6, 8267.6, 492.1) }, -- key 27
        { team = 3, type = 'medium', location = V(-4208.0, 8336.0, 64.0), min = V(-4594.8, 7904.0, -112.1), max = V(-3885.2, 8608.0, 366.6) }, -- key 28
        { team = 2, type = 'large', location = V(-1453.7, -3356.2, 221.1), min = V(-2036.0, -3881.0, -512.0), max = V(-988.0, -3034.2, 472.0) }, -- key 3
        { team = 2, type = 'medium', location = V(186.0, -5197.2, 264.0), min = V(-250.6, -5531.5, -256.0), max = V(636.0, -4776.0, 472.0) }, -- key 4
        { team = 2, type = 'ancient', location = V(-5014.6, -96.0, 264.0), min = V(-5348.7, -592.0, -15.5), max = V(-4245.0, 385.0, 600.0) }, -- key 5
        { team = 2, type = 'medium', location = V(-1983.0, -4815.0, 264.0), min = V(-2304.0, -5088.0, 152.5), max = V(-1619.0, -4393.0, 472.0) }, -- key 6
        { team = 2, type = 'medium', location = V(-4012.7, 991.7, 279.0), min = V(-4368.0, 535.4, -512.0), max = V(-3696.0, 1255.4, 600.0) }, -- key 7
        { team = 2, type = 'medium', location = V(-720.0, -7696.0, 152.0), min = V(-1068.5, -8019.4, -512.0), max = V(-469.1, -7350.1, 448.0) }, -- key 8
        { team = 2, type = 'large', location = V(-8313.3, -552.9, 320.0), min = V(-8645.0, -815.2, -192.0), max = V(-7877.0, -47.2, 600.0) }, -- key 9
    }
end
