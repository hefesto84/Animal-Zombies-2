module(..., package.seeall)

-- traducciones

languages = {   "en",   -- English
                "es",   -- español
                "ca",   -- català
                "it",   -- italiano
                --"ru",   -- russian
                --"ch",   -- chinese
            }

--[[
    [""] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
]]

translations =
{
    ["PLAY"] =
    {
        ["en"] = "PLAY",
        ["es"] = "JUGAR",
        ["ca"] = "JUGAR",
        ["it"] = "GIOCA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
	["CONNECT"] =
    {
        ["en"] = "CONNECT",
        ["es"] = "CONECTAR",
        ["ca"] = "CONNECTAR",
        ["it"] = "COLLEGARE",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
	["CONNECTED"] =
    {
        ["en"] = "CONNECTED",
        ["es"] = "CONECTADO",
        ["ca"] = "CONNECTAT",
        ["it"] = "COLLEGATO",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["SURVIVAL"] =
    {
        ["en"] = "SURVIVAL",
        ["es"] = "SUPERVIVENCIA",
        ["ca"] = "SUPERVIVÈNCIA",
        ["it"] = "SOPRAVVIVENZA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["OPTIONS"] =
    {
        ["en"] = "OPTIONS",
        ["es"] = "OPCIONES",
        ["ca"] = "OPCIONS",
        ["it"] = "OPZIONI",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["CREDITS"] =
    {
        ["en"] = "CREDITS",
        ["es"] = "CRÉDITOS",
        ["ca"] = "CRÈDITS",
        ["it"] = "CREDITI",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["SHOP"] =
    {
        ["en"] = "SHOP",
        ["es"] = "TIENDA",
        ["ca"] = "BOTIGA",
        ["it"] = "NEGOZIO",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["choose_level_upper"] =
    {
        ["en"] = "CHOOSE",
        ["es"] = "ELIGE",
        ["ca"] = "ESCULL",
        ["it"] = "SELEZIONA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["choose_level_lower"] =
    {
        ["en"] = "A LEVEL",
        ["es"] = "UN NIVEL",
        ["ca"] = "UN NIVELL",
        ["it"] = "UN LIVELLO",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["loading"] =
    {
        ["en"] = "LOADING",
        ["es"] = "CARGANDO",
        ["ca"] = "CARREGANT",
        ["it"] = "CARICANDO",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["pet_cemetery_upper"] =
    {
        ["en"] = "Pet",
        ["es"] = "Cementerio",
        ["ca"] = "Cementiri",
        ["it"] = "Cimitero",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["pet_cemetery_lower"] =
    {
        ["en"] = "CEMETERY",
        ["es"] = "DE ANIMALES",
        ["ca"] = "D'ANIMALS",
        ["it"] = "DI MASCOTTE",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["county_fair_upper"] =
    {
        ["en"] = "County",
        ["es"] = "Feria",
        ["ca"] = "Fira",
        ["it"] = "Fiera",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["county_fair_lower"] =
    {
        ["en"] = "FAIR",
        ["es"] = "DEL CONDADO",
        ["ca"] = "DEL COMTAT",
        ["it"] = "DELLA CONTEA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["cherrys_neighborhood_upper"] =
    {
        ["en"] = "Cherry's",
        ["es"] = "El vecindario",
        ["ca"] = "El veïnat",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["cherrys_neighborhood_lower"] =
    {
        ["en"] = "NEIGHBORHOOD",
        ["es"] = "DE CHERRY",
        ["ca"] = "DE LA CHERRY",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["ghostwood_upper"] =
    {
        ["en"] = "Ghostwood",
        ["es"] = "Parque Nacional",
        ["ca"] = "Parc Nacional",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["ghostwood_lower"] =
    {
        ["en"] = "NATIONAL PARK",
        ["es"] = "DE GHOSTWOOD",
        ["ca"] = "DE GHOSTWOOD",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["new_stages"] =
    {
        ["en"] = "New Stages",
        ["es"] = "Nuevos Escenarios",
        ["ca"] = "Nous Escenaris",
        ["it"] = "Nuovi Scenari",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["coming_soon"] =
    {
        ["en"] = "COMING SOON",
        ["es"] = "PRÓXIMAMENTE",
        ["ca"] = "PRÒXIMAMENT",
        ["it"] = "PROSSIMAMENTE",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["lang"] =
    {
        ["en"] = "Language",
        ["es"] = "Idioma",
        ["ca"] = "Idioma",
        ["it"] = "Lingua",
        ["ru"] = "язык",
        ["ch"] = "言語",
    },
    ["language"] =
    {
        ["en"] = "English",
        ["es"] = "Español",
        ["ca"] = "Català",
        ["it"] = "Italiano",
        ["ru"] = "Russian",
        ["ch"] = "中国語",
    },
    ["sound"] =
    {
        ["en"] = "Sound",
        ["es"] = "Sonido",
        ["ca"] = "So",
        ["it"] = "Audio",
        ["ru"] = "sound[ru]",
        ["ch"] = "sound[ch]",
    },
    ["music"] =
    {
        ["en"] = "Music",
        ["es"] = "Música",
        ["ca"] = "Música",
        ["it"] = "Musica",
        ["ru"] = "music[ru]",
        ["ch"] = "music[ch]",
    },
    ["vibration"] =
    {
        ["en"] = "Vibration",
        ["es"] = "Vibración",
        ["ca"] = "Vibració",
        ["it"] = "Vibrazione",
        ["ru"] = "vibration[ru]",
        ["ch"] = "vibration[ch]",
    },
    ["reset"] =
    {
        ["en"] = "Reset",
        ["es"] = "Reiniciar",
        ["ca"] = "Reiniciar",
        ["it"] = "Riavviare",
        ["ru"] = "reset[ru]",
        ["ch"] = "reset[ch]",
    },
    ["reset_progress"] =
    {
        ["en"] = "Reset Progress",
        ["es"] = "Borrar partida",
        ["ca"] = "Borrar partida",
        ["it"] = "Riavvia",
        ["ru"] = "Vodka Vladimir",
        ["ch"] = "reset_progress[ch]",
    },
    ["reset_progress_sure"] =
    {
        ["en"] = "Are you sure you want to restart your game?",
        ["es"] = "¿Estás seguro que quieres reiniciar tu partida?",
        ["ca"] = "Estàs segur que vols reiniciar la teva partida?",
        ["it"] = "Sei sicuro di volere riavviare il gioco?",
        ["ru"] = "Matrioska Russia Putin Pussy Riot?",
        ["ch"] = "reset_progress_sure[ch]",
    },
    ["cancel"] =
    {
        ["en"] = "Cancel",
        ["es"] = "Cancelar",
        ["ca"] = "Cancelar",
        ["it"] = "Cancella",
        ["ru"] = "Irina Shayk",
        ["ch"] = "いいえ",
    },
    ["yes"] =
    {
        ["en"] = "Yes",
        ["es"] = "Sí",
        ["ca"] = "Si",
        ["it"] = "Si",
        ["ru"] = "Spenatz",
        ["ch"] = "はい",
    },
    ["alert"] =
    {
        ["en"] = "Alert",
        ["es"] = "Atención",
        ["ca"] = "Atenció",
        ["it"] = "Attenzione",
        ["ru"] = "alert[ru]",
        ["ch"] = "注意",
    },
    ["connection_failed"] =
    {
        ["en"] = "You need internet connection to share on Facebook",
        ["es"] = "Necesitas conexión a internet para compartir en Facebook",
        ["ca"] = "Necessites conexió a internet per a compartir en Facebook",
        ["it"] = "È necessaria la connessione a internet per poter condividere su Facebook",
        ["ru"] = "connection_failed[ru]",
        ["ch"] = "connection_failed[ch]",
    },
    ["game_over"] =
    {
        ["en"] = "GAME OVER",
        ["es"] = "FIN DE LA PARTIDA",
        ["ca"] = "FI DE LA PARTIDA",
        ["it"] = "FINE GIOCO",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["level"] =
    {
        ["en"] = "Level ",
        ["es"] = "Nivel ",
        ["ca"] = "Nivell ",
        ["it"] = "Livello ",
        ["ru"] = "level[ru] ",
        ["ch"] = "レベル ",
    },
    ["deaths"] =
    {
        ["en"] = "Deaths",
        ["es"] = "Muertes",
        ["ca"] = "Morts",
        ["it"] = "Morti",
        ["ru"] = "deaths[ru]",
        ["ch"] = "死亡",
    },
    ["score"] =
    {
        ["en"] = "Score",
        ["es"] = "Puntos",
        ["ca"] = "Punts",
        ["it"] = "Punti",
        ["ru"] = "score[ru]",
        ["ch"] = "スコアー",
    },
    ["time"] =
    {
        ["en"] = "Time",
        ["es"] = "Tiempo",
        ["ca"] = "Temps",
        ["it"] = "Tempo",
        ["ru"] = "time[ru]",
        ["ch"] = "時間",
    },
    ["share"] =
    {
        ["en"] = "SHARE",
        ["es"] = "COMPARTE",
        ["ca"] = "COMPARTEIX",
        ["it"] = "CONDIVIDI",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["on_fb"] =
    {
        ["en"] = "ON FACEBOOK",
        ["es"] = "EN FACEBOOK",
        ["ca"] = "EN FACEBOOK",
        ["it"] = "SU FACEBOOK",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["fb_caption"] =
    {
        ["en"] = "Play Animal Zombies in your smartphone!",
        ["es"] = "¡Juega a Animal Zombies en tu smartphone!",
        ["ca"] = "Juga a Animal Zombies en el teu smartphone!",
        ["it"] = "Gioca a Animal Zombies con il tuo smartphone!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["bonus_combo_score"] =
    {
        ["en"] = "Combo bonus score",
        ["es"] = "Bonus por combo",
        ["ca"] = "Bonus per combo",
        ["it"] = "Bonus per combo",
        ["ru"] = "bonus_combo_score[ru]",
        ["ch"] = "bonus_combo_score[ch]",
    },
    ["bonus_time_score"] =
    {
        ["en"] = "Time Bonus Score",
        ["es"] = "Bonus por Tiempo",
        ["ca"] = "Bonus per Temps",
        ["it"] = "Bonus per Tempo",
        ["ru"] = "bonus_time_score[ru]",
        ["ch"] = "bonus_time_score[ch]",
    },
    ["congrats"] =
    {
        ["en"] = "Congratulations!",
        ["es"] = "¡Felicidades!",
        ["ca"] = "Felicitats!",
        ["it"] = "Congratulazioni!",
        ["ru"] = "congrats[ru]",
        ["ch"] = "おめでとう!",
    },
    ["new_record"] =
    {
        ["en"] = "New Record!",
        ["es"] = "¡Nuevo Récord!",
        ["ca"] = "Nou Record!",
        ["it"] = "Nuovo record!",
        ["ru"] = "new_record[ru]",
        ["ch"] = "new_record[ch]",
    },
    ["rate_app"] =
    {
        ["en"] = "Rate our app!",
        ["es"] = "¡Valora nuestra app!",
        ["ca"] = "Valora la nostra app!",
        ["it"] = "Valuta questa app!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["rate_app_details"] =
    {
        ["en"] = "Please rate this app to help support future development",
        ["es"] = "Por favor, valora esta app y ayudarás a su desarrollo futuro",
        ["ca"] = "Si us plau, valora aquesta app i ajudaràs al seu futur desenvolupament",
        ["it"] = "Per favore, valuta questa app e contribuirai al suo svilupo",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["remind_later"] =
    {
        ["en"] = "Remind me later",
        ["es"] = "Recordar más tarde",
        ["ca"] = "Recordar més tard",
        ["it"] = "Ricordamelo più tardi",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["resume"] =
    {
        ["en"] = "Resume",
        ["es"] = "Continuar",
        ["ca"] = "Continuar",
        ["it"] = "Continua",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["restart"] =
    {
        ["en"] = "Restart",
        ["es"] = "Reiniciar",
        ["ca"] = "Reiniciar",
        ["it"] = "Riavviare",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["levels"] =
    {
        ["en"] = "Levels",
        ["es"] = "Niveles",
        ["ca"] = "Nivells",
        ["it"] = "Livelli",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["menu"] =
    {
        ["en"] = "Menu",
        ["es"] = "Menú",
        ["ca"] = "Menú",
        ["it"] = "Menu",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["max_score"] =
    {
        ["en"] = "Best Score",
        ["es"] = "Mejor Puntuación",
        ["ca"] = "Millor Puntuació",
        ["it"] = "Miglior Punteggio",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["last"] =
    {
        ["en"] = "LAST",
        ["es"] = "ÚLTIMA",
        ["ca"] = "RONDA",
        ["it"] = "ULTIMA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["wave"] =
    {
        ["en"] = "WAVE",
        ["es"] = "OLEADA",
        ["ca"] = "FINAL",
        ["it"] = "ONDATA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },

-- story stage 1
    ["story_1_1"] =
    {
        ["en"] = "She had made it! No one was going to eat Mr. Cooper for the time being, but without her knowing, the Animal Zombies were escaping from the cemetery, towards civilization...",
        ["es"] = "¡Lo había logrado! ¡Nadie se comería a Mr. Cooper por el momento! Pero, sin saberlo, los Animal Zombies estaban escapando del cementerio rumbo a la civilización...",
        ["ca"] = "Ho havia aconseguit! Ningú es menjaria al Mr. Cooper de moment! Però, sense saber-ho, els Animal Zombies estaven escapant del cementiri dirigint-se a la civilització...",
        ["it"] = "Ci era riuscita! Nessuno potrebbe mangiarsi Berry per il momento! Però senza saperlo, gli Animal Zombies stava fuggendo dal cimitero verso la civiltà...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_1_2"] =
    {
        ["en"] = "That afternoon Cherry was paying a visit to Darwin, her dead bunny. But she was shocked to see that he had risen from the grave and was trying to eat Mr. Cooper, her new puppy...",
        ["es"] = "Menuda sorpresa se llevó aquella tarde Cherry cuando, visitando la tumba de su conejito Darwin, éste salió de su tumba e intentó comerse a su nuevo perrito Mr. Cooper...",
        ["ca"] = "Quina sorpresa es va emportar aquella tarda la Cherry quan, visitant la tomba del seu conillet Darwin, aquest va sortir de la seva tomba i va intentar menjar-se al seu nou gosset Mr. Cooper...",
        ["it"] = "Che sorpresa per Cherry quando quel pomeriggio andò a visitare la tomba del suo coniglietto Darwin, e questo provò a mangiarsi il suo nuovo cagnolino Mr. Cooper...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_1_3"] =
    {
        ["en"] = "Cherry squashed all the zombies mercilessly, carried away by enthusiasm, until she left a poor mole unconscious. From that moment on she should be more careful...",
        ["es"] = "Cherry aplastaba a todos los zombies sin piedad hasta que, presa del entusiasmo, dejó inconsciente a un pobre topo. A partir de ahora debería tener más cuidado...",
        ["ca"] = "La Cherry aixafava a tots el zombies sense pietat fins que, presa de l'entusiasme, va deixar inconscient a un pobre talp. A partir d'ara hauria d'anar més amb compte...",
        ["it"] = "Cherry schiacciava tutti gli zombie sensa pietà, fin che presa dall'entusiasmo, lasciò inconscia una povera talpa. Da quel momento dovrebbe stare più attenta...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_1_4"] =
    {
        ["en"] = "Not only bunnies were reviving, but also doggies! She saw the old Cookies, Miss Morris' dog, rising out from the grave, full of dirt, staring in the air...",
        ["es"] = "Ya no solo revivían los conejitos, ¡ahora también había perros! Vio al viejo Cookies, el perro de la señora Morris, salir de su tumba, lleno de tierra y con la mirada perdida...",
        ["ca"] = "Ja no sols revivien els conillets, ara també hi havia gossos! Va veure al vell Cookies, el gos de la senyora Morris, sortir de la seva tomba, ple de sorra i amb la mirada perduda...",
        ["it"] = "Adesso non solo rinascevano i coniglietti. Adesso anche i cani! Vidde il veccio Cookies, il cane della signora Morris, uscire dalla sua tomba pieno di terra con lo sguardo perso...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_1_5"] =
    {
        ["en"] = "Cherry stopped to rest under a tree when she saw, clinging on a branch, the filthiest parrot she had ever seen...",
        ["es"] = "Cherry paró un rato a descansar bajo un árbol cuando vio que, posado sobre sus ramas, estaba el loro más asqueroso que había visto jamás...",
        ["ca"] = "La Cherry va parar a descansar sota d'un arbre quan va veure que posat sobre les seves branques, hi havia el lloro más fastigós que mai havia vist...",
        ["it"] = "Cherri si fermò per riposarsi sotto un albero quando vidde su uno dei rami, il papagallo più schifoso che avesse mai visto...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_1_6"] =
    {
        ["en"] = "After a while Cherry bumped into a huge pig. The deceased pig stared at her with a weird look and, after a repulsive noise, exploded, scattering filth everywhere!",
        ["es"] = "Al cabo de un rato, Cherry se encontró a un cerdo enorme. El difunto cerdo la miró de forma extraña y tras un ruido repugnante, ¡explotó dejándolo todo lleno de porquería!",
        ["ca"] = "Al cap d'una estona, la Cherry es va trobar un porc enorme. El difunt porc la va mirar de manera estranya i, després d'un soroll repugnant, va explotar, deixan't-ho tot ple de porqueria!",
        ["it"] = "Dopo un pò, Cherry trovò un maiale enorme. Il defunto maiale la guardò in modo strano e dopo un rumore disgustoso, esplose lasciando tutto una schifezza!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_1_7"] =
    {
        ["en"] = "Cats and fishes aren't usually much compatible, but this two had matched an alliance in their hunt for meaty innocent puppies...",
        ["es"] = "Los gatos y los peces de colores no suelen ser muy compatibles, pero estos dos parecían haber formado una alianza en su búsqueda de perritos jugosos e inocentes...",
        ["ca"] = "Els gats i els peixos de colors no solen ser molt compatibles, però aquests dos semblaven haver fet una aliança en la seva recerca de gossets suculents i innocents...",
        ["it"] = "I gatti e i pesci di colori non sono compatibili, però questi sembravano avere creato una aleanza in cerca di nuovi cagnolini innocenti...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_1_8"] =
    {
        ["en"] = "There she was... Her friend Betty’s turtle, ran over by a mower last summer. Now it seemed she was back for vengeance...",
        ["es"] = "Allí estaba... Aquella era la tortuga de su amiga Betty. El cortacésped la atropelló el verano pasado y ahora parecía haber vuelto para vengarse...",
        ["ca"] = "Allà  estava... Aquella era la tortuga de la seva amiga Betty. La tallagespa la va atropellar l'estiu passat i ara semblava haver tornat per venjar-se...",
        ["it"] = "Là si trovava... Quella era la tartaruga della sua amica Betty. Il tagliaerba la investÌ la scorsa estate e adesso sembrava di essere tornata per vendicarsi...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_1_9"] =
    {
        ["en"] = "Cherry was getting good at it. She was nearly out of the cemetery, but before that she had to face the last big attack of the Animal Zombies!",
        ["es"] = "Cherry le estaba pillando el truco y ya casi estaba en la salida del cementerio, ¡pero antes tendría que enfrentarse al último gran ataque de los Animal Zombies!",
        ["ca"] = "La Cherry li estava agafant el truc i ja gairebé estava a la sortida del cementiri, però abans hauria d'enfrontar-se a l'últim gran atac dels Animal Zombies!",
        ["it"] = "Cherry aveva capito come funzionava ed era quasi arrivata all'uscita del cimitero, però prima doveva scontrarsi all'ultimo grande attacco degli Animal Zombies!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
-- story stage 2
    ["story_2_1"] =
    {
        ["en"] = "After all, that year's fair didn't go so bad: Cherry won the prize for the best roasted turkey and all those filthy Animal Zombies seemed to have fled away, but... For how long?",
        ["es"] = "Al final la feria de aquel año no fue tan mal: Cherry ganó el premio al mejor pavo asado y todos aquellos horripilantes Animal Zombies parecían haber huido. Pero... ¿Para siempre?",
        ["ca"] = "Finalment la fira d'aquell any no va anar tan malament: la Cherry va guanyar el premi al millor gall d'indi rostit i tots aquells horribles Animal Zombies semblaven haver fugit. Però... Per sempre?",
        ["it"] = "Alla fine la fiera di quel anno non era andata così male. Cherry vinse il premio al migliore tacchino arrostito e tutti quello orripilanti Animal Zombies sembravano di essere fuggiti. Però... Per sempre?",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_2_2"] =
    {
        ["en"] = "The Animal Zombies escaped the cemetery! Cherry was at the county fair, participating in the \"Little Miss Farmer\" contest, when the vermin attacked! There were young beauty queens panicking out everywhere... Cherry would need to be careful with the shovel to avoid hurting them...",
        ["es"] = "¡Los Animal Zombies habían escapado del cementerio! Cherry estaba en la feria del condado participando en el concurso de \"Little Miss Farmer\", ¡cuando las pequeñas sabandijas atacaron! Todo estaba lleno de pequeñas reinas de la belleza histéricas y Cherry tendría que usar la pala con cuidado para no hacerles daño...",
        ["ca"] = "Els Animal Zombies havien escapat del cementiri! La Cherry estava a la fira del comtat participant en el concurs de \"Little Miss Farmer\" quan les petites bestioles començaren a atacar! Tot estava ple de petites reines de la bellesa histèriques i la Cherry hauria d'utilitzar la pala amb cura per no fer-les mal...",
        ["it"] = "Gli Animal Zombies era scappati dal cimitero! Cherry si trovava alla fiera della contea partecipando al concorso di bellezza di \"Little Miss Farmer\" quando i piccoli parassati attaccarono! Era pieno di piccole regginette di bellezza isteriche e Cherry doveva usare la pala con molta attenzione per non farle del male...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_2_3"] =
    {
        ["en"] = "Cherry found a small rake on the floor. She could slide it to squash several Animal Zombies at once! What a shame it broke so fast...",
        ["es"] = "Cherry encontró un pequeño rastrillo en el suelo, con el que poder destrozar varios Animal Zombies ¡a la vez! Era una pena que se rompiese tan rápido...",
        ["ca"] = "La Cherry va trobar un petit rastrell en el terra, amb el que poder destrossar varis Animal Zombies alhora! Era una llàstima que es trenqués tan ràpid...",
        ["it"] = "Cherry trovà un piccolo rastrello a terra, con il quale poter distruggere diversi Animal Zombies in contemporanea! Era un peccato che si ruppe così velocemente...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_2_4"] =
    {
        ["en"] = "Cherry found Mr. Cooper at the dog contest, surrounded by a pack of hungry piranha chihuahua zombies. Someone had to do something to save the puppy from those little monsters...",
        ["es"] = "Cherry se encontró a Mr. Cooper en el concurso canino. Estaba rodeado por una jauría de hambrientos chihuahuas-piraña zombies. ¡Alguien tenía que salvarlo de aquellos pequeños monstruos...",
        ["ca"] = "La Cherry es va trobar al Mr. Cooper en el concurs caní. Estava envoltat d'un grup de famèlics chihuahues-piranya zombis. Algú havia de salvar-lo d'aquells petits monstres...",
        ["it"] = "Cherry si incontrò con Berry al concorso canino. Era cincordato da un branco di cani Chihuahuas-piranhe afamati e qualcuno doveva salvarlo da quei piccoli mostrui...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_2_5"] =
    {
        ["en"] = "That poor duck was hunted that morning at the hunting tournament. Now Cherry was facing it at the cheese contest tent, staring at her in a sinister way...",
        ["es"] = "El pobre pato había sido cazado esa misma mañana en el torneo de caza. Cherry se lo encontró en la carpa del concurso de quesos mirándola de forma inquietante...",
        ["ca"] = "El pobre ànec havia estat caçat aquell mateix matí en el torneig de caça. La Cherry se'l va trobar a la carpa del concurs de formatges mirant-la de forma inquietant...",
        ["it"] = "La povera anatra l'avevano cacciato la stessa mattina al torneo di caccia. Cherry lo trovò sotto la tenda del concorso di formaggi guardandola in una maniera inquietante...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_2_6"] =
    {
        ["en"] = "It seemed its destiny was to end up on a plate served with potatoes, covered with blueberry sauce and a lemon shoved up in his butt. But now it was back to life and willing to eat a puppy...",
        ["es"] = "Parecía que su destino era acabar en una fuente rodeado de patatas, bañado en salsa de arándanos y con un limón metido por el trasero, pero ahora, sin embargo, volvía a estar vivo y le apetecía mucho comerse a un perrito...",
        ["ca"] = "Semblava que el seu destí era acabar en una font envoltat de patates, banyat en salsa de nabius i amb una llimona ficada pel culet, però ara tornava a ser viu i li venia molt de gust menjar-se a un gosset...",
        ["it"] = "Sembrava che il suo destino era finire in una teglia circondato da patate, bagnato da una salsa ai mirtilli e con un limone nel didietro, però adesso, era rinato e aveva tanta voglia di mangiarsi un cagnolino...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_2_7"] =
    {
        ["en"] = "In the past it might have been a ferret, a guinea pig or even a chinchilla. Now it was an unidentifiable monster, and that cage seemed tough...",
        ["es"] = "Antaño quizás fue un hurón o una cobaya, puede que incluso una chinchilla. Ahora era un monstruo indescriptible y esa jaula parecía ser de las buenas...",
        ["ca"] = "Potser alguna vegada havia estat una fura o un conillet d'índies, potser fins i tot una xinxilla. Ara era un monstre indescriptible i aquella gàbia semblava que era de les bones...",
        ["it"] = "Una volta forse fu un furetto, un porcellino d'india, addirittura una cincillà. Adesso era un mostruo indiscrivibile e quella gabbia sembrava delle buone...",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["story_2_8"] =
    {
        ["en"] = "Cherry had trained all the year to win all the important trophies at the fair and now those filthy critters were destroying everything, even the cherry pie she presented to the cake contest. That was the last straw; they were all going to pay!",
        ["es"] = "Cherry se había preparado todo el año para ganar todos los premios importantes de la feria, y ahora aquellos bichos lo habían destrozado todo, incluso la tarta de cerezas que presentó en el concurso de pasteles. Aquella era la gota que colmaba el vaso y ¡se lo iban a pagar todos!",
        ["ca"] = "La Cherry s'havia preparat tot l'any per poder guanyar tots els premis importants de la fira, i ara aquells monstres ho havien destruït tot, incloent-hi el pastís de cireres que va presentar en el concurs de pastissos. Aquella va ser la gota que fa vessar el got i anaven a pagar-ho tots!",
        ["it"] = "Cherry si era preparato durante tutto l'anno per vincere i premi più importanti della fiera e adesso quei animali avevano distrutto tutto, inclusa la torta alla ciliegia che presento alla gara di torte. Quello era la goccia che traboccava il bicchiere e lo pagherebbero tutti!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },

-- tips
    ["tip_1"] =
    {
        ["en"] = "Kill all the Animal Zombies you can, time is running out!",
        ["es"] = "Aplasta a todos los Animal Zombies que puedas, ¡el tiempo corre!",
        ["ca"] = "Elimina a tots els Animal Zombies que puguis, els temps corre!",
        ["it"] = "Schiaccia tutti gli Animal zombies che puoi, il tempo passa!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["tip_2"] =
    {
        ["en"] = "Careful with the Animal Zombies: if they bite you or scratch you, they will damage you!",
        ["es"] = "¡Ten cuidado con los Animal Zombies! ¡Si te muerden o te arañan perderás vidas",
        ["ca"] = "Compte amb els Animal Zombies! Si et mosseguen o t'esgarrapen perdràs vides!",
        ["it"] = "Occhio con gli Animal Zombies! Se ti mordono o ti graffiano perderai vite!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["tip_3"] =
    {
        ["en"] = "Don’t mistake the mole for an Animal Zombie, if you kill one you will lose a life!",
        ["es"] = "No confundas al topo con un Animal Zombie. ¡Si lo golpeas perderás vidas!",
        ["ca"] = "No confonguis el talp amb un Animal Zombie. Si el colpeges perdràs vides!",
        ["it"] = "Non confondere la talpa con uno Animal Zombie. Se lo picchi perderai vite!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["tip_4"] =
    {
        ["en"] = "Collect lollipops to earn more lifes",
        ["es"] = "Atrapa piruletas para conseguir vidas",
        ["ca"] = "Atrapa piruletes per a aconseguir vides",
        ["it"] = "Acchiapa tutti i lecca lecca che puoi per ottenere vite",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["tip_5"] =
    {
        ["en"] = "If you don’t kill the pig, it will explode and kill everything around it",
        ["es"] = "Si no aplastas al cerdo zombie, éste explotará y matará a todo lo que haya a su alrededor",
        ["ca"] = "Si no aixafes al porc zombie, aquest explotarà i matarà a tot el que hi hagi al seu voltant",
        ["it"] = "Se non schiacci il maiale zombie, questo esploderà e ucciderà tutto quello che lo circonda",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["tip_6"] =
    {
        ["en"] = "If you kill a lot of Animal Zombies at the same time you will multiply your score",
        ["es"] = "Si eliminas muchos Animal Zombies de golpe multiplicarás tu puntuación",
        ["ca"] = "Si aixafes molts Animal Zombies de cop multiplicaràs la teva puntuació",
        ["it"] = "Se schiacci tanti Animal Zombies di colpo vedrai come si moltiplicano i tuoi punti",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["tip_7"] =
    {
        ["en"] = "Hit the Zombie Tortoise twice to kill it!",
        ["es"] = "¡Golpea 2 veces a la tortuga zombie para matarla!",
        ["ca"] = "Toca 2 cops a la tortuga zombie per matar-la!",
        ["it"] = "Tocca due volte la tartaruga zombie per ucciderla!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["tip_8"] =
    {
        ["en"] = "As annoying as little Miss Hysteria can be, she's not a zombie! Don't hit her!",
        ["es"] = "Por mucha rabia que de la pequeña Miss Hysteria, ¡no es un zombie! ¡No la golpees!",
        ["ca"] = "Per molta ràbia que faci la petita Miss Hysteria, no és un zombi! No l'ataquis!",
        ["it"] = "Per quanto sia insoportabile la piccola Miss Hysteria, lei non à una zombie! Quindi non l'attaccare!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["tip_9"] =
    {
        ["en"] = "Hit the weird cage three times to destroy it!",
        ["es"] = "¡Golpea la extraña jaula 3 veces para destruirla!",
        ["ca"] = "Ataca a l'extranya gàbia 3 cops per destruïr-la!",
        ["it"] = "Colpisci la strana gabbia 3 volte per distrugerla!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["tip_10"] =
    {
        ["en"] = "Pick the rake and slide your finger through the zombies to kill them!",
        ["es"] = "¡Atrapa el rastrillo y desliza tu dedo sobre los Animal Zombies para matarlos todos a la vez!",
        ["ca"] = "Agafa el rastrell i llisca el dit sobre els Animal Zombies per a matar-los a tots alhora!",
        ["it"] = "Acchiapa il rastrello ed fai scorrere il dito per uccidere più Animal Zombies in una volta solo!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["tip_11"] =
    {
        ["en"] = "The Animal Zombies are preparing a last wave! Get ready for the assault!",
        ["es"] = "Los Animal Zombies están preparando una última oleada. ¡Prepárate para el asalto final!",
        ["ca"] = "Els Animal Zombies estan preparant una última onada d'atacs. Prepara't per a l'assalt final!",
        ["it"] = "Gli Animal Zombies sono pronti per l'ultima ondata di attacchi. Preparati per l'assalto finale!",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
--shop
    ["shop"] =
    {
        ["en"] = "SHOP",
        ["es"] = "TIENDA",
        ["ca"] = "BOTIGA",
        ["it"] = "NEGOZIO",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
--weapons names
    [STONE_NAME .."_name"] =
    {
        ["en"] = "STONE",
        ["es"] = "PIEDRA",
        ["ca"] = "PEDRA",
        ["it"] = "PIETRA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    [ICE_CUBE_NAME .."_name"] =
    {
        ["en"] = "ICE",
        ["es"] = "HIELO",
        ["ca"] = "GEL",
        ["it"] = "GHIACCIO",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    [TRAP_NAME .."_name"] =
    {
        ["en"] = "TRAP",
        ["es"] = "TRAMPA",
        ["ca"] = "TRAMPA",
        ["it"] = "TRAPPOLA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    [RAKE_NAME .."_name"] =
    {
        ["en"] = "RAKE",
        ["es"] = "RASTRILLO",
        ["ca"] = "RAMPÍ",
        ["it"] = "RASTRELLO",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    [LIFE_BOX_NAME .."_name"] =
    {
        ["en"] = "LIFE BOX",
        ["es"] = "CAJA DE VIDA",
        ["ca"] = "CAIXA DE VIDA",
        ["it"] = "BOX VITA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    [DEATH_BOX_NAME .."_name"] =
    {
        ["en"] = "DEATH BOX",
        ["es"] = "CAJA DE MUERTE",
        ["ca"] = "CAIXA DE MORT",
        ["it"] = "BOX MORTE",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    [HOSE_NAME .."_name"] =
    {
        ["en"] = "HOSE",
        ["es"] = "MANGUERA",
        ["ca"] = "MANGUERA",
        ["it"] = "TUBO FLESSIBILE",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    [THUNDER_NAME .."_name"] =
    {
        ["en"] = "THUNDER",
        ["es"] = "RELÁMPAGO",
        ["ca"] = "LLAMP",
        ["it"] = "FULMINE",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    [STINK_BOMB_NAME .."_name"] =
    {
        ["en"] = "STINK BOMB",
        ["es"] = "BOMBA FÉTIDA",
        ["ca"] = "BOMBA FÈTIDA",
        ["it"] = "BOMBETTA PUZZOLENTE",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    [GAVIOT_NAME .."_name"] =
    {
        ["en"] = "GAVIOT",
        ["es"] = "PALOMA",
        ["ca"] = "COLOM",
        ["it"] = "COLOMBA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    [EARTHQUAKE_NAME .."_name"] =
    {
        ["en"] = "EARTHQUAKE",
        ["es"] = "TERREMOTO",
        ["ca"] = "TERRATRÈMOL",
        ["it"] = "TERREMOTO",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["extraLifes_name"] =
    {
        ["en"] = "LIFE",
        ["es"] = "VIDA",
        ["ca"] = "VIDA",
        ["it"] = "VITA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
--weapons description
    ["stone_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["iceCube_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["trap_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["rake_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["lifeBox_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["deathBox_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["hose_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["thunder_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["stinkBomb_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["gaviot_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["earthquake_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["extraLifes_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
--bank
    ["bank"] =
    {
        ["en"] = "BANK",
        ["es"] = "BANCO",
        ["ca"] = "BANC",
        ["it"] = "BANCA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
--bank items names
    ["twitter"] =
    {
        ["en"] = "TWITTER",
        ["es"] = "TWITTER",
        ["ca"] = "TWITTER",
        ["it"] = "TWITTER",
        ["ru"] = "TWITTER",
        ["ch"] = "TWITTER",
    },
    ["facebook"] =
    {
        ["en"] = "FACEBOOK",
        ["es"] = "FACEBOOK",
        ["ca"] = "FACEBOOK",
        ["it"] = "FACEBOOK",
        ["ru"] = "FACEBOOK",
        ["ch"] = "FACEBOOK",
    },
    ["bag"] =
    {
        ["en"] = "BAG",
        ["es"] = "BOLSA",
        ["ca"] = "BOSSA",
        ["it"] = "BORSA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["sack"] =
    {
        ["en"] = "SACK",
        ["es"] = "SACO",
        ["ca"] = "SAC",
        ["it"] = "SACCA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["briefcase"] =
    {
        ["en"] = "BRIEFCASE",
        ["es"] = "MALETÍN",
        ["ca"] = "MALETÍ",
        ["it"] = "VENTIQUATTRONE",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["chest"] =
    {
        ["en"] = "CHEST",
        ["es"] = "COFRE",
        ["ca"] = "COFRE",
        ["it"] = "CASSA",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["safe"] =
    {
        ["en"] = "SAFE",
        ["es"] = "CAJA FUERTE",
        ["ca"] = "CAIXA FORTA",
        ["it"] = "CCASSAFORTE",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
--bank items description
    ["twitter_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["facebook_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["bag_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["sack_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["briefcase_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["chest_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
    ["safe_desc"] =
    {
        ["en"] = "[en]",
        ["es"] = "[es]",
        ["ca"] = "[ca]",
        ["it"] = "[it]",
        ["ru"] = "[ru]",
        ["ch"] = "[ch]",
    },
}

function getTranslation(word)
	if not translations[word] then
		return "null"
	end
	return translations[word][AZ.userInfo.language] or "null"
end

function getFacebookDescription(name, achievement, score, stage, level)
    lang = AZ.userInfo.language
    if lang == "en" then
        return name .." earned the achievement ".. achievement .." scoring ".. score .." playing Animal Zombies in level ".. stage .."-".. level .."!"
    elseif lang == "es" then
        return name .." ganó el logro ".. achievement .." con la puntuación ".. score .." jugando a Animal Zombies en el nivel ".. stage .."-".. level .."!"
    elseif lang == "ca" then
        return name .." va guanyar la fita ".. achievement .." amb la puntuación ".. score .." jugant a Animal Zombies en el nivell ".. stage .."-".. level .."!"
    elseif lang == "it" then
        return name .." ha raggiunto la vittoria ".. achievement .." con il punteggio di ".. score .." giocando a Animal Zombies nel livello ".. stage .."-".. level .."!"
    elseif lang == "ru" then
        return ""
    elseif lang == "ch" then
        return ""
    else
        print("Language ".. lang ".. not supported")
        return ""
    end
end
