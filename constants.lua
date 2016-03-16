require "resolutions"

-- Splash Screen
SPLASH_TIME                 = 4000
SPLASH_PATH                 = "assets/splash.jpg"
SPLASH_NAME                 = "splash"

-- Codiwans Screen
CODIWANS_NAME               = "codiwans"
CODIWANS_VIDEO_PATH         = "assets/video.mp4"

-- Menu Screen
MENU_NAME                   = "menu"
MENU_SPRITESHEET            = "assets/menu.png"
MENU_PATH                   = "assets/fondomenu.jpg"

-- Credits Screen
CREDITS_NAME                = "creditos"

-- Options Screen
OPTIONS_NAME        = "options"
OPTIONS_PATH        = "assets/textos2.png"

-- Survival Screen
SURVIVAL_NAME       = "survival"

-- Stage Screen
STAGE_NAME		= "stage"
STAGE_UPPER_DEFAULT     = "new_stages"
STAGE_LOWER_DEFAULT     = "coming_soon"
STAGE_PATH		= "assets/fondoliso.jpg"
COMING_SOON_PATH        = "assets/comingsoon.png"
STAGES_COUNT            = 4

-- Levels Screen
LEVELS_NAME		= "levels2"

-- Story Screen
STORY_NAME              = "story"
FINAL_STORY_NAME        = "finalStory"
STORY_CHAR_TIME         = 30
STORY_TIME              = 5000

-- Loading Screen
LOADING_NAME            = "loading"
LOADING_TIME            = 3000

-- Win/Loose Screen
WIN_NAME                = "win"
WIN_PATH                = "assets/fondoliso.jpg"
FACEBOOK_APP_ID         = "379479158828435" --HA DE SER UNA STRING, tot i que nomes son numeros
FACEBOOK_NO_NET_TITLE   = "Facebook not avaliable"
FACEBOOK_NO_NET_MSG     = "The connection with Facebook failed"
FACEBOOK_NO_NET_BTN     = "Ok"
LOSE_NAME               = "loose"
LOOSE_PATH              = "assets/fondogameover.jpg"
DEATHS_TIME             = 100
MAX_DEATHS_TIME         = 2000
LIVES_TIME              = 200
LOLLIPOPCOMBO_TIME      = 500
ROTATION_SPEED          = 75 --graus per segon

-- Generic
SCENE_TRANSITION_TIME       = 250
SCENE_TRANSITION_EFFECT     = "crossFade"

if system.getInfo("environment") == "simulator" then
    INTERSTATE_REGULAR  = "Interstate-Regular"
    INTERSTATE_BOLD     = "Interstate-BlackCondensed"
    BRUSH_SCRIPT        = "HFF Low Sun"
    HAUNT_AOE           = "Haunt AOE"
--ios name of the font (not always the same as name of the file)
elseif system.getInfo("platformName") == "iPhone OS" then 
    INTERSTATE_REGULAR  = "Interstate-Regular"
    INTERSTATE_BOLD     = "Interstate-BlackCondensed"
    BRUSH_SCRIPT        = "HFF Low Sun"
    HAUNT_AOE           = "Haunt AOE"
--android name of the file
else
    INTERSTATE_REGULAR  = "Interstate-Regular"
    INTERSTATE_BOLD     = "Interstate-BlackCondensed"
    BRUSH_SCRIPT        = "HFF Low Sun"
    HAUNT_AOE           = "HauntAOE"
end

FONT_BLACK_COLOR    = { 0, 0, 0, 170 }      -- negre amb -40% de 255 d'opacitat
FONT_WHITE_COLOR    = { 192, 207, 182, 255 }--beix


-- InGame Variables
INGAME_NAME                 = "ingame"
INGAME_COUNTDOWN_TIME       = 1000
INGAME_COMBO_TIME           = 400
INGAME_MAX_LIFES            = 3
INGAME_RAKE_TIME            = 20000
INGAME_SPAWN_SCORE_FONT     = INTERSTATE_BOLD
INGAME_SPAWN_SCORE_COLOR    = { 203, 82, 117 }  -- RGB
INGAME_SCORE_FONT           = INTERSTATE_BOLD
INGAME_SCORE_COLOR          = { 65, 65, 59 }    -- RGB
INGAME_COMBO_COLOR          = { 220, 220, 200 } -- RGB
PAUSE_NAME                  = "pause"
PAUSE_CORTE_PATH            = "assets/superiorcorte480.png"

-- Board MODULE
BOARD_CHARACTER_ID_POSITION     = 1
BOARD_CHARACTER_NAME_POSITION   = 2
BOARD_CHARACTER_POINTER         = 3
BOARD_CHARACTER_NAME_DEFAULT    = "EMPTY"
BOARD_MAX_X                     = 3
BOARD_MAX_Y                     = 4

-- posicions relatives generiques
RELATIVE_SCREEN_X2	= display.contentWidth * 0.5
RELATIVE_SCREEN_X3	= display.contentWidth * 0.33
RELATIVE_SCREEN_X6	= display.contentWidth * 0.17
RELATIVE_SCREEN_Y2	= display.contentHeight * 0.5
RELATIVE_SCREEN_Y3	= display.contentHeight * 0.33
RELATIVE_SCREEN_Y6	= display.contentHeight * 0.17

-- les posicions son relatives al tamany de la pantalla, no son hardcoded
ZOMBIE_MATRIX_ROW =     {   RELATIVE_SCREEN_Y3,
                            RELATIVE_SCREEN_Y2,
                            display.contentHeight - RELATIVE_SCREEN_Y3,
                            display.contentHeight - RELATIVE_SCREEN_Y6
                        }
ZOMBIE_MATRIX_COLUMN =  {   RELATIVE_SCREEN_X6,
                            RELATIVE_SCREEN_X2,
                            display.contentWidth - RELATIVE_SCREEN_X6
                        }

ZOMBIE_MATRIX_NEWCOLUMN =   {   display.contentWidth *0.125,
                                display.contentWidth *0.375,
                                display.contentWidth *0.625,
                                display.contentWidth *0.875
                            }

-- equivalents de puntuacio
SCORE_LIFE      = 50
SCORE_DEATHS    = 10
SCORE_COMBO     = 5