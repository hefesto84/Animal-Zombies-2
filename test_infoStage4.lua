
local stageInfo = {

    upper_name          = "ghostwood_upper",
    lower_name          = "ghostwood_lower",
    frame_path          = "assets/StagesGraphics/Stage4/ghostwoodFrame.jpg",
    stage_bso           = AZ.soundLibrary.ghostwoodLoop,
    level_button_fx     = AZ.soundLibrary.stoneGraveSound,

    stageInfo = {
        bgData = {
            upImages = {
                "assets/StagesGraphics/Stage4/BGs/BGUp_01.jpg",
                "assets/StagesGraphics/Stage4/BGs/BGUp_02.jpg",
                "assets/StagesGraphics/Stage4/BGs/BGUp_03.jpg",
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
            spriteSheetPath = "assets/StagesGraphics/Stage4/Props/propsLv4.png",
            spriteSheetAtlas = {
                sheet = {
                    frames = {
                        {   -- Arbusto
                            x=387, y=101,
                            width=100, height=100,
                        },
                        {   -- Arbusto2
                            x=387, y=0,
                            width=100, height=100,
                        },
                        {   -- Arbusto3
                            x=101, y=387,
                            width=100, height=100,
                        },
                        {   -- Hoguera
                            x=0, y=387,
                            width=100, height=100,
                        },
                        {   -- Lenya
                            x=359, y=359,
                            width=100, height=100,
                        },
                        {   -- Tocon
                            x=359, y=258,
                            width=100, height=100,
                        },
                        {   -- Totem
                            x=258, y=359,
                            width=100, height=100,
                        },
                        {   -- Tronco
                            x=258, y=258,
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
                    ["Arbusto"] = 1,
                    ["Arbusto2"] = 2,
                    ["Arbusto3"] = 3,
                    ["Hoguera"] = 4,
                    ["LeÃÂ±a"] = 5,
                    ["Tocon"] = 6,
                    ["Totem"] = 7,
                    ["Tronco"] = 8,
                    ["prop_d"] = 9,
                    ["prop_l"] = 10,
                    ["prop_ld"] = 11,
                    ["prop_lu"] = 12,
                    ["prop_r"] = 13,
                    ["prop_rd"] = 14,
                    ["prop_ru"] = 15,
                    ["prop_u"] = 16,
                }
            },
            spriteFencesScale = 1.2
        }
    }
}

return stageInfo