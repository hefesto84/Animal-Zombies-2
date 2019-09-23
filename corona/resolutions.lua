--iPads
if string.sub(system.getInfo("model"),1,4) == "iPad" then
    --print("resolutions. Using iPad resolution")
    INGAME_SPAWN_SCORE_SIZE     = 20
    INGAME_SCORE_SIZE           = 30
    SMALL_FONT_SIZE             = 35
    NORMAL_FONT_SIZE            = 45
    BIG_FONT_SIZE               = 55
    LAST_WAVE_FONT_SIZE         = 90
    SCALE_SMALL                 = 0.35
    SCALE_DEFAULT               = 0.45
    SCALE_BIG                   = 0.7
    SCALE_EXTRA_BIG             = 0.75
    ZOMBIE_SCALE                = 0.7
    ZOMBIE_EFF_SCALE            = 1.2
    ZOMBIE_DEATH_SCALE          = 1.8
--iPhone large screen (5)
elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then
    --print("resolutions. Using iPhone 5 resolution")
    INGAME_SPAWN_SCORE_SIZE     = 20
    INGAME_SCORE_SIZE           = 30
    SMALL_FONT_SIZE             = 40
    NORMAL_FONT_SIZE            = 45
    BIG_FONT_SIZE               = 55
    LAST_WAVE_FONT_SIZE         = 95
    SCALE_SMALL                 = 0.3
    SCALE_DEFAULT               = 0.45
    SCALE_BIG                   = 0.7
    SCALE_EXTRA_BIG             = 0.8
    ZOMBIE_SCALE                = 0.6
    ZOMBIE_EFF_SCALE            = 1.2
    ZOMBIE_DEATH_SCALE          = 1.7
--iPhone normal
elseif string.sub(system.getInfo("model"),1,2) == "iP" then
    --print("resolutions. Using iPhone resolution")
    INGAME_SPAWN_SCORE_SIZE     = 18
    INGAME_SCORE_SIZE           = 28
    SMALL_FONT_SIZE             = 34 --vigilar sobretot amb el story del stage 2 level 1
    NORMAL_FONT_SIZE            = 45
    BIG_FONT_SIZE               = 55
    LAST_WAVE_FONT_SIZE         = 90
    SCALE_SMALL                 = 0.27
    SCALE_DEFAULT               = 0.45
    SCALE_BIG                   = 0.65
    SCALE_EXTRA_BIG             = 0.75
    ZOMBIE_SCALE                = 0.6
    ZOMBIE_EFF_SCALE            = 1.2
    ZOMBIE_DEATH_SCALE          = 1.7
-- resolcuio del s3
elseif display.pixelHeight == 1280 and display.pixelWidth == 720 then
    --print("resolutions. Using Galaxy S3 resolution")
    INGAME_SPAWN_SCORE_SIZE     = 25
    INGAME_SCORE_SIZE           = 40
    SMALL_FONT_SIZE             = 35
    NORMAL_FONT_SIZE            = 40
    BIG_FONT_SIZE               = 45
    LAST_WAVE_FONT_SIZE         = 90
    SCALE_SMALL                 = 0.6
    SCALE_DEFAULT               = 0.7
    SCALE_BIG                   = 1
    SCALE_EXTRA_BIG             = 1.2
    ZOMBIE_SCALE                = 1
    ZOMBIE_EFF_SCALE            = 1.5
    ZOMBIE_DEATH_SCALE          = 1.8
--majoria d'androids
elseif display.pixelHeight / display.pixelWidth > 1.72 then
    --print("resolutions. Using Androids de pantalla llarga resolution")
    INGAME_SPAWN_SCORE_SIZE     = 25
    INGAME_SCORE_SIZE           = 40
    SMALL_FONT_SIZE             = 30
    NORMAL_FONT_SIZE            = 40
    BIG_FONT_SIZE               = 50
    LAST_WAVE_FONT_SIZE         = 90
    SCALE_SMALL                 = 0.65
    SCALE_DEFAULT               = 0.8
    SCALE_BIG                   = 1
    SCALE_EXTRA_BIG             = 1.2
    ZOMBIE_SCALE                = 1.2
    ZOMBIE_EFF_SCALE            = 1.9
    ZOMBIE_DEATH_SCALE          = 1.7
--altres
else
    --print("resolutions. Using default resolution")
    INGAME_SPAWN_SCORE_SIZE     = 25
    INGAME_SCORE_SIZE           = 40
    SMALL_FONT_SIZE             = 32
    NORMAL_FONT_SIZE            = 50
    BIG_FONT_SIZE               = 55
    LAST_WAVE_FONT_SIZE         = 105
    SCALE_SMALL                 = 0.5
    SCALE_DEFAULT               = 0.7
    SCALE_BIG                   = 0.9--coses amb les que anar amb compte: menu.lua: alguns botons es poden apretar a la vegada si son molt grans, win.lua: shine_mask es molt petit si scale_big tambe ho es
    SCALE_EXTRA_BIG             = 1.1
    ZOMBIE_SCALE                = 1
    ZOMBIE_EFF_SCALE            = 1.6
    ZOMBIE_DEATH_SCALE          = 1.8
end
