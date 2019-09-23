
local stageInfo = {

    upper_name          = "county_fair_upper",
    lower_name          = "county_fair_lower",
    frame_path          = "assets/StagesGraphics/Stage2/fairFrame.jpg",
    stage_bso           = AZ.soundLibrary.countyFairLoop,
    level_button_fx     = AZ.soundLibrary.stoneGraveSound,

    stageInfo = {
        bgData = {
            upImages = {
                "assets/StagesGraphics/Stage2/BGs/BGUp_01.jpg",
                "assets/StagesGraphics/Stage2/BGs/BGUp_02.jpg",
                "assets/StagesGraphics/Stage2/BGs/BGUp_03.jpg",
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
            spriteSheetPath = "assets/StagesGraphics/Stage2/Props/propsLv2.png",
            spriteSheetAtlas = {
                sheet = {
                    frames = {
                        {   -- Banderas
                            x=404, y=359,
                            width=100, height=100,
                        },
                        {   -- Cartel Cakes
                            x=359, y=258,
                            width=100, height=100,
                        },
                        {   -- Cartel popcorn
                            x=303, y=359,
                            width=100, height=100,
                        },
                        {   -- Globos
                            x=258, y=258,
                            width=100, height=100,
                        },
                        {   -- Papelera
                            x=202, y=387,
                            width=100, height=100,
                        },
                        {   -- Papelera2
                            x=101, y=387,
                            width=100, height=100,
                        },
                        {   -- Sacos
                            x=0, y=387,
                            width=100, height=100,
                        },
                        {   -- prop_d
                            x=303, y=129,
                            width=128, height=128,
                        },
                        {   -- prop_l
                            x=129, y=258,
                            width=128, height=128,
                        },
                        {   -- prop_ld
                            x=129, y=129,
                            width=128, height=128,
                        },
                        {   -- prop_lu
                            x=331, y=0,
                            width=128, height=128,
                        },
                        {   -- prop_r
                            x=202, y=0,
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
                    ["Banderas"] = 1,
                    ["Cartel Cakes"] = 2,
                    ["Cartel popcorn"] = 3,
                    ["Globos"] = 4,
                    ["Papelera"] = 5,
                    ["Papelera2"] = 6,
                    ["Sacos"] = 7,
                    ["prop_d"] = 8,
                    ["prop_l"] = 9,
                    ["prop_ld"] = 10,
                    ["prop_lu"] = 11,
                    ["prop_r"] = 12,
                    ["prop_rd"] = 13,
                    ["prop_ru"] = 14,
                    ["prop_u"] = 15,
                }
            },
            spriteFencesScale = 1.2
        }
    }
}

return stageInfo