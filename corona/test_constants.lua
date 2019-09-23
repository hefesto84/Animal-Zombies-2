
---------------------------------- TIPOGRAFIES ---------------------------------
if system.getInfo("environment") == "simulator" then
    INTERSTATE_REGULAR      = "Interstate-Regular"
    INTERSTATE_BOLD         = "Interstate-BlackCondensed"
    INTERSTATE_LIGHT        = "Interstate-Light"
    INTERSTATE_EXTRALIGHT   = "Interstate-ExtraLight"
    BRUSH_SCRIPT            = "HFF Low Sun"
    HAUNT_AOE               = "Haunt AOE"
--ios name of the font (not always the same as name of the file)
elseif system.getInfo("platformName") == "iPhone OS" then 
    INTERSTATE_REGULAR      = "Interstate-Regular"
    INTERSTATE_BOLD         = "Interstate-BlackCondensed"
    INTERSTATE_LIGHT        = "Interstate-Light"
    INTERSTATE_EXTRALIGHT   = "Interstate-ExtraLight"
    BRUSH_SCRIPT            = "HFF Low Sun"
    HAUNT_AOE               = "Haunt AOE"
--android name of the file
else
    INTERSTATE_REGULAR      = "Interstate-Regular"
    INTERSTATE_BOLD         = "Interstate-BlackCondensed"
    INTERSTATE_LIGHT        = "Interstate-Light"
    INTERSTATE_EXTRALIGHT   = "Interstate-ExtraLight"
    BRUSH_SCRIPT            = "HFF Low Sun"
    HAUNT_AOE               = "HauntAOE"
end


---------------------------------- ENUMERABLES ---------------------------------

BOARD_OBJECT_TYPES = { ZOMBIE = 1, PROP = 2 , TRAP = 3 , PROP_HOSE = 4 , STONE = 5, CONTAINER = 6 }

SHOVEL_NAME = "shovel"      RAKE_NAME = "rake"              STONE_NAME = "stone"            TRAP_NAME = "trap"
ICE_CUBE_NAME = "iceCube"   THUNDER_NAME = "thunder"        STINK_BOMB_NAME = "stinkBomb"   HOSE_NAME = "hose"          
GAVIOT_NAME = "gaviot"      EARTHQUAKE_NAME = "earthquake"  LIFE_BOX_NAME = "lifeBox"       DEATH_BOX_NAME = "deathBox"
EXPLOSION_PIG_NAME = "pigExplosion"                         EXPLOSION_SKUNK_NAME = "skunkExplosion"



---------------------------------- EVENT NAMES ---------------------------------

-- [MODUL_][OBJECTE_]ACCIO_EVNAME     -- qui crida @ qui escolta : efecte

GENERIC_ERROR = "_onError"  -- ... @ main : notifica un error

-- gameplay

ANDROID_BACK_BUTTON_TOUCH_EVNAME = "frayVicente"									-- main @ ... : notifica que s'ha polsat el boto de back d'Android
GENERIC_TOUCH_EVNAME = "dispensadorDeToallas"                                   -- tile, background @ board : notifica que hi ha hagut touch
ALL_DESTROY_EVNAME = "polloConPolea"                                            -- ingameScene @ ... : notifica que s'ha de destruir
OBJECT_TOUCH_EVNAME = "israelIsraelQueBonitoEsIsrael"                           -- gameplay @ object : notifica a l'objecte que se l'ha tocat
OBJECT_KILL_EVNAME = "maximilianoWei"                                           -- earthquake/gameplay @ object : notifica a l'objecte que ha de morir
OBJECT_DAMAGED_EVNAME = "gitanosYSupervivientes"                                -- object @ ... : notifica que el zombie acaba de rebre dany
OBJECT_FINISH_SPAWN_ANIM_EVNAME = "soyProgramador"                              -- object @ ... : notifica que acaba d'aparèixer un zombie (ha acabat l'spawn)
OBJECT_JUST_ESCAPING_ANIM_EVNAME = "Z4QQotraQmasYElSimboloDeBatman"             -- object @ ... : notifica que comença a escapar un zombie
OBJECT_FINISH_ESCAPE_ANIM_EVNAME = "ayPaaayo"                                   -- object @ ... : notifica que acaba de marxar un zombie
OBJECT_JUST_KILLED_EVNAME = "compraEnSabadell"                                  -- object @ ... : notifica que acaba de morir un zombie
OBJECT_FINISH_DEAD_ANIM_EVNAME = "jesucristoElRobotDelFuturo"                   -- object @ weaponController : notifica que ha acabat l'animació de morir
OBJECT_PROP_JUST_ERASED = "elAlientoDeMiGatoHueleAComidaDeGato"                 -- object @ weaponController : notifica que acaba de desaparèixer un Prop
OBJECT_KILLED_BY_STONE_EVNAME = "soySecreta"                                    -- object @ stone : notifica que ha desaparegut un objecte mort per una pedra
OBJECT_KILLED_BY_HOSE_EVNAME = "drojaEnElColacao"                               -- object @ hose : notifica que ha desaparegut un objecte mort per un hose
OBJECT_DESTROY_EVNAME = "amorComprensionYTernura"                               -- tile @ object : notifica que s'ha destruit l'objecte físic i ha de destruir la llògica
OBJECT_DRAG_EVNAME = "youBetterBecomeDoctor"                                    -- tile @ object : notifica que comença o acaba de fer drag
OBJECT_UPDATE_ID_EVNAME = "ohDaniGayMiDaniGay"                                  -- tile @ object : notifica a l'objecte que s'ha actualitzat el seu id dins del board
GAMEPLAY_NO_LIFES_LEFT_EVNAME = "miGatoSeLlamaGuantes"                          -- ui @ ingameScene : notifica que hem perdut totes les vides i mostrarem 
GAMEPLAY_END_GAME_EVNAME = "cines4D"                                            -- ui @ ingameScene : notifica que sembla que ha acabat la partida
GAMEPLAY_END_IS_NEAR_EVNAME = "elMinerialismoVaALlegar"                         -- ui @ objects, deathLifeContainer : notifica que acabarà la partida en breus
GAMEPLAY_EXPLOSION_EVNAME = "relaxingCupOfCafeConLeche"                         -- ??? @ weaponController : notifica que hi ha hagut una explosió, i té els ID dels tiles afectats
GAMEPLAY_FINISH_TIP_EVNAME = "ozaOza"                                           -- tip @ ingameScene : notifica que ha acabat el tip i pot començar el gameplay
GAMEPLAY_PAUSE_EVNAME = "tempuraJohnson"                                        -- main, ingameScene, ingameUI @ ... : notifica que s'ha de pausar el gameplay
GAMEPLAY_WEAPON_CHANGED_EVNAME = "noPuedeSerDiosMioAyudame"                     -- weaponController @ ... : notifica que s'ha canviat l'arma
GAMEPLAY_WEAPON_CANCEL_EVNAME = "vivaEspanaVivaElReyVivaElOrdenYLaLey"          -- weaponController @ weapon : notifica que s'ha de cancelar l'arma
GAMEPLAY_WEAPON_END_IN_TIP_EVNAME = "esoNoEsNadaEnElTaller"						-- tipGenerator @ ... : notifica a l'arma actual que ha d'acabar
GAMEPLAY_WEAPON_FINISH_EVNAME = "soyElNinoMasBonito"                            -- weapon @ weaponController : notifica al gestor d'armes que ha acabat l'efecte d'una arma
GAMEPLAY_EARTHQUAKE_START_EARTHQUAKE_EVNAME = "trrustMeImAnIngenierr"           -- earthquake @ gameplay : notifica que comença un earthquake
GAMEPLAY_EARTHQUAKE_KILL_IN_AIR_EVNAME = "andesnouFrai"                         -- object @ ... : notifica que un objecte ha mort mentres es feia [o a l'acabar] l'earthquake
GAMEPLAY_EARTQUAKE_FINISH_LAUNCH_EVNAME = "weCodeHard"                          -- earthquake @ object : notifica als objectes que han arribat al terra i s'espatarren
GAMEPLAY_EARTHQUAKE_FINISH_EARTHQUAKE_EVNAME = "titoMC"                         -- earthquake @ gameplay, object : notifica que acaba un earthquake
GAMEPLAY_GAVIOT_START_EVNAME = "dejaQueTeCuenteMiNena"                          -- gaviot @ gameplay : notifica que comença el gaviot attack
GAMEPLAY_GAVIOT_FINISH_EVNAME = "ajoaseiteNena"                                 -- gaviot @ gameplay : notifica que acaba el gaviot attack
GAMEPLAY_STINKBOMB_KILL_RATS_EVNAME = "miOsitoLindoNoPuedeSer"                  -- stinkBomb @ object : notifica als objectes que se'ls ha de matar per bomba fètida [només per a rates]
GAMEPLAY_HOSE_NEWTILEREACHED_EVNAME = "puesMiAmigoTieneUnSatelite"              -- hose @ stone : notifica a les pedres de la pantalla que una manguera ha arribat a un Tile
GAMEPLAY_CONTAINER_EXPLODING_EVNAME = "atchundana"                              -- container @ hose : notifica que està desapareixent un container
GAMEPLAY_CONTAINER_EXPLODED_EVNAME = "cebadacretinos"                           -- container @ hose : notifica que ha desaparegut un container
GAMEPLAY_PLANTED_WEAPON_INTERACTED_EVNAME = "porQueYaNoMeMirasCuando"			-- container, trap @ ... : notifica que una arma plantada en el board ha interactuat
GAMEPLAY_COMBO_EVNAME = "hablarPortigo"											-- ui @ ... : notifica que hi ha un combo
GAMEPLAY_SPAWN_POWERUP = "peroGordii"                                           -- gameplay @ ui : notifica que s'ha de crear un powerup
GAMEPLAY_POWERUP_GET = "mamaSeLlevoLasPilasQueCaraDuraMamaSeLlevoEsasPilasQueTantoDuran"    -- powerup @ ??? : notifica que s'ha obtingut un powerup
GAMEPLAY_POWERUP_LOST = "superficialYPedante"                                   -- powerup @ ??? : notifica que s'ha perdut un powerup
GAMEPLAY_POWERUP_DESTROYED = "ninosNinosFuturoFuturo"                           -- powerup @ ??? : notifica que un powerup ha sigut destruit, ja s'hagi agafat o no
BOARD_UPDATE_TILES_EVNAME = "laTetita"                                          -- ??? @ board : notifica que s'ha d'actualitzar els patrons d'aparició
BOARD_PATTERNS_UPDATED_EVNAME = "siElCespedHaCrecidoQueEmpieceElPartido"        -- ??? @ board : notifica que s'han actualitzat els patrons d'aparició
GAMEDONIA_DATA_RECEIVED_EVNAME = "cartmanRetrasado"                             -- gamedonia @ thousandgears : notifica que s'ha descarregat un json
GAMEDONIA_JUST_SETTED_EVNAME = "soyUnBarranco"                                  -- gamedonia @ thousandgears : notifica que s'ha loggejat i ja podem demanar json
RECOVERED_LIFES_EVNAME = "brillisBrillis"											-- recoveryController @ ... : notifica que s'ha recuperat vides
ZOMBIE_TIP_CALLBACK_EVNAME = "heTenidoUnaIdeaQueTeVaAPonerCachondo"				-- zombie @ tipGenerator : notifica que ha passat amb el zombie perque es gestioni l'endFunc del tip
TIP_PERFORM_END_FUNC_WITH_DELAY = "podriasMoverloTodoUnPixelALaDerecha"			-- tipGenerator @ tipGenerator : notifica que s'ha de fer l'endFunc

-- 

---------------------------------- VARIABLES -----------------------------------

-- PLAYER

PLAYER_MAX_LIFES = 7

-- COLORS
AZ_BLACK_RGB = { 0, 0, 0, 170 }

AZ_BRIGHT_RGB = { 192, 207, 182 }
AZ_DARK_RGB =   { 65, 65, 59 }

-- TRANSITIONS
SCENE_TRANSITION_TIME       = 250
SCENE_TRANSITION_EFFECT     = "crossFade"

-- WIN
DEATHS_TIME                 = 100
LIVES_TIME                  = 200
LOLLIPOPCOMBO_TIME          = 500

-- GAMEPLAY

INGAME_COUNTDOWN_TIME       = 1000
INGAME_COMBO_TIME           = 300
INGAME_SPAWN_SCORE_FONT     = INTERSTATE_BOLD
INGAME_SPAWN_SCORE_RGB      = { 203, 82, 117 }  -- RGB
INGAME_SCORE_FONT           = INTERSTATE_BOLD
INGAME_COMBO_RGB            = { 220, 220, 200 } -- RGB
INGAME_MAX_TIME_TO_KILL     = 300
SCORE_LIFE                  = 50
SCORE_DEATHS                = 10


-- ZOMBIE --

-- rata
RAT_NUM_PLAGUES             = 3

-- zarigüeya
POSSUM_TIME_EAT             = 2000


-- ARMES --

-- rastrell
WEAP_RAKE_LIFETIME = 3000
WEAP_RAKE_SLASH_COLOR = { 192, 207, 182, 100 }

-- pedra
WEAP_STONE_DAMAGE = 2
WEAP_STONE_LIFETIME_PER_ATTACK = 5000

-- trampa
WEAP_TRAP_INITLIFE          = 9
WEAP_TRAP_DAMAGE            = 3

-- glaçó de gel
WEAP_ICECUBE_LIFETIME       = 30

-- manguera d'aigua
WEAP_HOSE_DAMAGE_PER_SECOND = 2
WEAP_HOSE_LIFETIME = 5000

-- raig
WEAP_THUNDER_DAMAGE_PER_SECOND = 5
WEAP_THUNDER_LIFETIME = 5000

-- bomba fetida
WEAP_STINKBOMB_DAMAGE       = 3
WEAP_STINKBOMB_DISTANCE     = 1

-- coloms
WEAP_GAVIOT_NUM_ATTACKS     = 7
WEAP_GAVIOT_BIRD_TIME_FLY   = 2000;
WEAP_GAVIOT_DAMAGE_PER_BULLET = 10;

-- recipients
WEAP_CONTAINER_LIFETIME = 15000


-- rutes d'arxius de guardat

FILE_GAME_INFO  = "game.json"
FILE_USER_INFO  = "user.json"
FILE_USER_TEMPLATE_INFO = "user-template.json"
FILE_SHOP_INFO  = "shop.json"
FILE_BANK_INFO  = "bank.json"
FILE_STG1_INFO  = "stg1.json"
FILE_STG2_INFO  = "stg2.json"
FILE_STG3_INFO  = "stg3.json"
FILE_STG4_INFO  = "stg4.json"
FILE_SLOT_INFO  = "slot.json"
FILE_LOCALIZATION_INFO = "localization.json"
FILE_TIPS_INFO	 = "tips.json"


-- altres
TYPING_EFFECT_TIME = 30
STORY_LIFETIME = 5000
LOADING_LIFETIME = 3000
LOADING_ROTATION_SPEED = 75 -- graus per segon
STAGES_COUNT = 4
