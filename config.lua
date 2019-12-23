Config = {
    -- METH --
    -- meth lab entrance/exit markers
    MethEntrances = {
        {x = 910.54754638672, y = -1065.3074951172, z = 37.943222045898},
        {x = 115.69, y = -1685.78, z = 33.49},
        {x = 1538.94, y = 6321.92, z = 25.07},
        {x = 3304.26, y = 5184.55, z = 19.71}
    },
    MethExit = {x = 996.933, y = -3200.605, z = -36.394},

    -- meth supplies --
    MethSupply = {x = 2437.36, y = 4967.62, z = 42.35},
    MethSupplyPrice = 60,

    -- meth processing --
    MethMixer = {x = 1005.7, y = -3200.31, z = -38.52},
    MethMixerTime = 15000,
    MethPurifier = {x = 1008.19, y = -3199.41, z = -38.99},
    MethPurifierTime = 20000,
    MethFurnace = {x = 1002.83, y = -3200.1, z = -38.99},
    MethFurnaceTime = 20000,
    MethTable = {x = 1012.14, y = -3194.91, z = -38.99},
    MethTableTime = 15000,

    -- amount of meth produced --
    MethAmount = {min = 10, max = 20},

    -- COKE --
    -- coke lab entrance/exit markers --
    CokeEntrances = {
        {x = 387.51754760742, y = 3584.7612304688, z = 33.29222869873},
        {x = 1577.65, y = 3606.99, z = 38.73},
        {x = 1759.56, y = 3299.07, z = 42.17},
        {x = -50.22, y = 1911.01, z = 195.71}
    },
    CokeExit = {x = 1088.803, y = -3188.257, z = -38.993},

    -- coke supplies --
    CokeField = {x = -2129.67, y = 2680.88, z = 2.9},
    CokeFieldTime = 30000,
    CokeFieldAmount = {min = 3, max = 15},
    CokeSupply = {x = 1525.53, y = 1710.27, z = 110.01},
    CokeSupplyPrice = 40,
    CokePlantsUsed = 5,

    -- coke processing locations --
    CokeCutting = {x = 1092.73, y = -3194.91, z = -38.99},
    CokeCuttingTime = 15000,
    CokeWeighing = {x = 1099.75, y = -3195.95, z = -38.99},
    CokeWeighingTime = 15000,
    CokePackaging = {x = 1100.39, y = -3198.73, z = -38.99},
    CokePackagingTime = 15000,
    
    -- amount of coke produced --
    CokeAmount = {min = 10, max = 20},
}