
local stageInfo = {

    upper_name          = "cherrys_neighborhood_upper",
    lower_name          = "cherrys_neighborhood_lower",
    frame_path          = "assets/StagesGraphics/Stage3/neighborhoodFrame.jpg",
    stage_bso           = AZ.soundLibrary.neighbourhoodLoop,
    level_button_fx     = AZ.soundLibrary.stoneGraveSound,

    stageInfo = {
        bgData = {
            upImages = {
                "assets/StagesGraphics/Stage3/BGs/BGUp_01.jpg",
                "assets/StagesGraphics/Stage3/BGs/BGUp_02.jpg",
                "assets/StagesGraphics/Stage3/BGs/BGUp_03.jpg",
                "assets/StagesGraphics/Common/BGs/BGUp_04.jpg",
                "assets/StagesGraphics/Common/BGs/BGUp_05.jpg",
                "assets/StagesGraphics/Common/BGs/BGUp_06.jpg"
            },
            downImages = {
                "assets/StagesGraphics/Common/BGs/BGDown_01.jpg",
                "assets/StagesGraphics/Common/BGs/BGDown_02.jpg"
            }
        },
        propData = {
            spriteSheetPath = "assets/StagesGraphics/Stage3/Props/propsLv3.png",
            spriteSheetAtlas = {
                sheet = {
                    frames = {
                        {   -- barbacoa
                            x=387, y=101,
                            width=100, height=100,
                        },
                        {   -- caseta
                            x=387, y=0,
                            width=100, height=100,
                        },
                        {   -- cubo
                            x=404, y=359,
                            width=100, height=100,
                        },
                        {   -- cubo1
                            x=359, y=258,
                            width=100, height=100,
                        },
                        {   -- cubo2
                            x=303, y=359,
                            width=100, height=100,
                        },
                        {   -- planta1
                            x=258, y=258,
                            width=100, height=100,
                        },
                        {   -- planta2
                            x=202, y=387,
                            width=100, height=100,
                        },
                        {   -- rueda
                            x=101, y=387,
                            width=100, height=100,
                        },
                        {   -- silla
                            x=0, y=387,
                            width=100, height=100,
                        },
                        {   -- prop_d
                            x=258, y=129,
                            width=128, height=128,
                        },
                        {   -- prop_l
                            x=258, y=0,
                            width=128, height=128,
                        },
                        {   -- prop_ld
                            x=129, y=258,
                            width=128, height=128,
                        },
                        {   -- prop_lu
                            x=129, y=129,
                            width=128, height=128,
                        },
                        {   -- prop_r
                            x=129, y=0,
                            width=128, height=128,
                        },
                        {   -- prop_rd
                            x=0, y=258,
                            width=128, height=128,
                        },
                        {   -- prop_ru
                            x=0, y=129,
                            width=128, height=128,
                        },
                        {   -- prop_u
                            x=0, y=0,
                            width=128, height=128,
                        },
                    },
                    sheetContentWidth = 512,
                    sheetContentHeight = 512
                },
                frameIndex = {
                    ["barbacoa"] = 1,
                    ["caseta"] = 2,
                    ["cubo"] = 3,
                    ["cubo1"] = 4,
                    ["cubo2"] = 5,
                    ["planta1"] = 6,
                    ["planta2"] = 7,
                    ["rueda"] = 8,
                    ["silla"] = 9,
                    ["prop_d"] = 10,
                    ["prop_l"] = 11,
                    ["prop_ld"] = 12,
                    ["prop_lu"] = 13,
                    ["prop_r"] = 14,
                    ["prop_rd"] = 15,
                    ["prop_ru"] = 16,
                    ["prop_u"] = 17,
                }
            },
            spriteFencesScale = 1.2
        }
    }
}

return stageInfo