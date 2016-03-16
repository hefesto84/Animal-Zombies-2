module(..., package.seeall)

-- modul exclusiu per a la precàrrega de sons

-- loops
menuLoop        = nil
storyLoop       = nil
petCemeteryLoop = nil
countyFairLoop  = nil
ultimateWinLoop = nil
slotMachineLoop = nil
creditsLoop 	 = nil
neighbourhoodLoop = nil
ghostwoodLoop	 = nil
tipLoop			= nil
shopLoop		= nil

-- sons workflow
buttonSound     = nil
switchSound     = nil
welcomeSound    = nil
lightningSound  = nil
crashSound      = nil
stoneGraveSound = nil
chihuahuaMenuWarfSound = nil
woodGraveSound  = nil
stageBlockedSound = nil
stageUnblockSound = nil
bankAccessSound = nil
pauseSound		 = nil
forwardBtnSound = nil
backBtnSound	 = nil
closePopupSound = nil
heartsAccessSound = nil
shareForLifeSound = nil
payFullLifesSound = nil
levelBtnPressSound = nil
levelBtnUnpressSound = nil
buyRealMoneySound = nil
buyMoneySound	= nil

-- sons zombies [ingame]
rabbitSound     = nil
moleSound       = nil
dogSound        = nil
parrotSound     = nil
pigSound        = nil
catSound        = nil
fishSound       = nil
tortoiseSound   = nil
queenSound      = nil
chihuahuaSound  = nil
duckSound       = nil
turkeySound     = nil
cageSound       = nil
ratSound        = nil
possumSound     = nil
bearSound       = nil
mooseSound      = nil
skunkSound      = nil
girlScoutSound  = nil
uterSound       = nil

-- sons powerup [ingame]
lollipopSound   = nil
rakeSound       = nil

-- sons atacs [ingame]
biteSound       = nil
scratchSound    = nil

-- altres sons [ingame]
spawnSound      = nil
disappearSound  = nil
bloodSound      = nil
countDownSound  = nil
mushroomSound   = nil
hitSound        = nil
comboSound      = nil
lastWaveSound   = nil
tipNextSound	 = nil
changeWeaponSound = nil

-- sons win/lose
winSound        = nil
loseSound       = nil
boneSound       = nil
addScoreSound   = nil
newRecord       = nil

-- sons slotmachine
slotWinSound	= nil
slotLoseSound	= nil
slotDealSound	= nil
slotJackpodSound = nil
slotSpinSound	= nil
slotStopSound	= nil
slotToggleDownSound = nil
SlotToggleUpSound = nil

--------------------------------------------------------------------------------

function loadSounds()
    -- loops
    menuLoop        = audio.loadStream("assets/audio/mainTheme.mp3")
    storyLoop       = audio.loadStream("assets/audio/story.mp3")
    petCemeteryLoop = audio.loadStream("assets/audio/petCemeteryGameplay.mp3")
    countyFairLoop  = audio.loadStream("assets/audio/countyFairGameplay.mp3")
    ultimateWinLoop = audio.loadStream("assets/audio/ultimateWin.mp3")
    slotMachineLoop = audio.loadStream("assets/audio/slotmachineTheme.mp3")
	creditsLoop		 = audio.loadStream("assets/audio/creditsTheme.mp3")
	neighbourhoodLoop = audio.loadStream("assets/audio/neighbourhoodTheme.mp3")
	ghostwoodLoop	 = audio.loadStream("assets/audio/ghostwoodTheme.mp3")
	tipLoop			= audio.loadStream("assets/audio/tipTheme.mp3")
	shopLoop		= audio.loadStream("assets/audio/shopTheme.mp3")
    
    -- sons workflow
    buttonSound     = audio.loadSound("assets/audio/button.mp3")
    switchSound     = audio.loadSound("assets/audio/switchButton.mp3")
    welcomeSound    = audio.loadSound("assets/audio/welcome.mp3")
    lightningSound  = audio.loadSound("assets/audio/lightning.mp3")
    crashSound      = audio.loadSound("assets/audio/crash.mp3")
    stoneGraveSound = audio.loadSound("assets/audio/graveStone.mp3")
	chihuahuaMenuWarfSound = audio.loadSound("assets/audio/chihuahuaMenuWarf.mp3")
    woodGraveSound  = audio.loadSound("assets/audio/graveWood.mp3")
	stageBlockedSound = audio.loadSound("assets/audio/stageBlocked.mp3")
	stageUnblockSound = audio.loadSound("assets/audio/stageUnblock.mp3")
	bankAccessSound = audio.loadSound("assets/audio/bankAccess.mp3")
	pauseSound		 = audio.loadSound("assets/audio/pause.mp3")
	forwardBtnSound = audio.loadSound("assets/audio/forwardBtn.mp3")
	backBtnSound	 = audio.loadSound("assets/audio/backBtn.mp3")
	closePopupSound = audio.loadSound("assets/audio/closePopup.mp3")
	heartsAccessSound = audio.loadSound("assets/audio/heartsAccess.mp3")
	shareForLifeSound = audio.loadSound("assets/audio/shareForLife.mp3")
	payFullLifesSound = audio.loadSound("assets/audio/payFullLifes.mp3")
	levelBtnPressSound	= audio.loadSound("assets/audio/levelBtnPress.mp3")
	levelBtnUnpressSound	= audio.loadSound("assets/audio/levelBtnUnpress.mp3")
	buyRealMoneySound = audio.loadSound("assets/audio/buyRealMoney.mp3")
	buyMoneySound	= audio.loadSound("assets/audio/buyMoney.mp3")

    -- sons zombies [ingame]
    rabbitSound     = { audio.loadSound("assets/audio/deathRabbit_1.mp3"),      audio.loadSound("assets/audio/deathRabbit_2.mp3") }
    moleSound       = { audio.loadSound("assets/audio/deathMole_1.mp3"),        audio.loadSound("assets/audio/deathMole_2.mp3") }
    dogSound        = { audio.loadSound("assets/audio/deathDog_1.mp3"),         audio.loadSound("assets/audio/deathDog_2.mp3") }
    parrotSound     = { audio.loadSound("assets/audio/deathParrot_1.mp3"),      audio.loadSound("assets/audio/deathParrot_2.mp3"),  audio.loadSound("assets/audio/deathParrot_3.mp3") }
    pigSound        = { audio.loadSound("assets/audio/deathPig_1.mp3"),         audio.loadSound("assets/audio/deathPig_2.mp3") }
    catSound        = { audio.loadSound("assets/audio/deathCat_1.mp3"),         audio.loadSound("assets/audio/deathCat_2.mp3"),     audio.loadSound("assets/audio/deathCat_3.mp3") }
    fishSound       = { audio.loadSound("assets/audio/deathFish_1.mp3"),        audio.loadSound("assets/audio/deathFish_2.mp3") }
    tortoiseSound   = { audio.loadSound("assets/audio/deathTortoise_1.mp3"),    audio.loadSound("assets/audio/deathTortoise_2.mp3")}
    queenSound      = { audio.loadSound("assets/audio/deathQueen_1.mp3"),       audio.loadSound("assets/audio/deathQueen_2.mp3") }
    chihuahuaSound  = { audio.loadSound("assets/audio/deathChihuahua_1.mp3"),   audio.loadSound("assets/audio/deathChihuahua_2.mp3") }
    duckSound       = { audio.loadSound("assets/audio/deathDuck_1.mp3"),        audio.loadSound("assets/audio/deathDuck_2.mp3"),    audio.loadSound("assets/audio/deathDuck_3.mp3") }
    turkeySound     = { audio.loadSound("assets/audio/deathTurkey_1.mp3"),      audio.loadSound("assets/audio/deathTurkey_2.mp3"),  audio.loadSound("assets/audio/deathTurkey_3.mp3") }
    cageSound       = { audio.loadSound("assets/audio/deathCage_1.mp3"),        audio.loadSound("assets/audio/deathCage_2.mp3"),    audio.loadSound("assets/audio/deathCage_3.mp3") }
    ratSound        = { audio.loadSound("assets/audio/deathCage_1.mp3"),        audio.loadSound("assets/audio/deathCage_2.mp3"),    audio.loadSound("assets/audio/deathCage_3.mp3") }
    possumSound     = { audio.loadSound("assets/audio/deathCage_1.mp3"),        audio.loadSound("assets/audio/deathCage_2.mp3"),    audio.loadSound("assets/audio/deathCage_3.mp3") }
    bearSound       = { audio.loadSound("assets/audio/deathCage_1.mp3"),        audio.loadSound("assets/audio/deathCage_2.mp3"),    audio.loadSound("assets/audio/deathCage_3.mp3") }
    mooseSound      = { audio.loadSound("assets/audio/deathCage_1.mp3"),        audio.loadSound("assets/audio/deathCage_2.mp3"),    audio.loadSound("assets/audio/deathCage_3.mp3") }
    skunkSound      = { audio.loadSound("assets/audio/deathCage_1.mp3"),        audio.loadSound("assets/audio/deathCage_2.mp3"),    audio.loadSound("assets/audio/deathCage_3.mp3") }
    girlScoutSound  = { audio.loadSound("assets/audio/deathCage_1.mp3"),        audio.loadSound("assets/audio/deathCage_2.mp3"),    audio.loadSound("assets/audio/deathCage_3.mp3") }
    uterSound       = { audio.loadSound("assets/audio/deathCage_1.mp3"),        audio.loadSound("assets/audio/deathCage_2.mp3"),    audio.loadSound("assets/audio/deathCage_3.mp3") }

    -- sons powerups [ingame]
    lollipopSound   = { audio.loadSound("assets/audio/lollipop1.mp3"), audio.loadSound("assets/audio/lollipop2.mp3"), audio.loadSound("assets/audio/lollipop3.mp3") }
    rakeSound       = audio.loadSound("assets/audio/lollipop1.mp3")

    -- sons atacs [ingame]
    biteSound       = audio.loadSound("assets/audio/bite.mp3")
    scratchSound    = audio.loadSound("assets/audio/scratch.mp3")

    -- altres sons [ingame]
    spawnSound      = audio.loadSound("assets/audio/spawn.mp3")
    disappearSound  = audio.loadSound("assets/audio/disappear.mp3")
    bloodSound      = { audio.loadSound("assets/audio/blood1.mp3"), audio.loadSound("assets/audio/blood2.mp3"),
                        audio.loadSound("assets/audio/blood3.mp3"), audio.loadSound("assets/audio/blood4.mp3") }
    countDownSound  = { audio.loadSound("assets/audio/321_1.mp3"),  audio.loadSound("assets/audio/321_2.mp3"),
                        audio.loadSound("assets/audio/321_3.mp3"),  audio.loadSound("assets/audio/321_play.mp3") }
    mushroomSound   = audio.loadSound("assets/audio/pigExplosion.mp3")
    hitSound        = audio.loadSound("assets/audio/hitResistance.mp3")
    comboSound      = audio.loadSound("assets/audio/combo.mp3")
    lastWaveSound   = audio.loadSound("assets/audio/lastWave.mp3")
	tipNextSound	 = audio.loadSound("assets/audio/tipNext.mp3")
	changeWeaponSound = audio.loadSound("assets/audio/changeWeapon.mp3")

    -- sons win/lose
    winSound        = audio.loadSound("assets/audio/win.mp3")
    loseSound       = audio.loadSound("assets/audio/lose.mp3")
    boneSound       = { audio.loadSound("assets/audio/bone1.mp3"), audio.loadSound("assets/audio/bone2.mp3"), audio.loadSound("assets/audio/bone3.mp3") }
    addScoreSound   = audio.loadSound("assets/audio/addScore.mp3")
    newRecord       = audio.loadSound("assets/audio/newRecord.mp3")
	
	-- sons slotmachine
	slotWinSound	= audio.loadSound("assets/audio/slotWin.mp3")
	slotLoseSound	= audio.loadSound("assets/audio/slotLose.mp3")
	slotDealSound	= audio.loadSound("assets/audio/slotDeal.mp3")
	slotJackpodSound = audio.loadSound("assets/audio/slotJackpod.mp3")
	slotSpinSound	= audio.loadSound("assets/audio/slotSpin.mp3")
	slotStopSound	= audio.loadSound("assets/audio/slotStop.mp3")
	slotToggleDownSound = audio.loadSound("assets/audio/slotToggleDown.mp3")
	SlotToggleUpSound = audio.loadSound("assets/audio/slotToggleUp.mp3")
end