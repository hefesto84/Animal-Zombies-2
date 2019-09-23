module(..., package.seeall)

BSO_ENABLED         = true
FX_ENABLED          = true

--local previousBSO = nil
local previousBSO = nil

AUDIO_VOLUME_BSO        = 0.3
AUDIO_VOLUME_BUTTONS    = 1
AUDIO_VOLUME_ZOMBIES    = 0.4
AUDIO_VOLUME_ZOMBIE_FX  = 1
AUDIO_VOLUME_OTHER_FX   = 1     -- [lollipop, explosio porc, combo...]

function setBSO(isEnabled)
    BSO_ENABLED = isEnabled
    
    if audio.reservedChannels == 0 then
        audio.reserveChannels(1)
    end
        
    if BSO_ENABLED == true then
        audio.setVolume(AUDIO_VOLUME_BSO, { channel = 1 })

        if previousBSO ~= nil then
            audio.stop(1)
            playBSO(previousBSO)
        end
    else
        audio.setVolume(0, { channel = 1 })
    end
end

function setFX(isEnabled)
    FX_ENABLED = isEnabled
end

function playFX(audioHandle, volume)
    if FX_ENABLED == true and audioHandle ~= nil then
        
        local myChannel = audio.play(audioHandle)
        
        if myChannel ~= 0 then
            audio.setVolume(volume, { channel = myChannel })
        else
            print("         WARNING!     Couldn't play FX")
        end
    end
end

function playBSO(audioHandle)
    if audioHandle ~= previousBSO or audio.isChannelPlaying(1) == false then
        
        if audio.isChannelPlaying(1) then
            audio.stop(1)
            --audio.dispose(loopHandle)
        end
		 
        if audio.getVolume({ channel = 1 }) ~= AUDIO_VOLUME_BSO and audio.getVolume({ channel = 1 }) ~= 0 then
            --print("             Channel 1 volume is ".. audio.getVolume({ channel = 1 }) ..". Resetted to ".. AUDIO_VOLUME_BSO)
            audio.setVolume(AUDIO_VOLUME_BSO, { channel = 1 })
        end
        
        audio.rewind(audioHandle)
        audio.play(audioHandle, { channel = 1, loops = -1 })
        
        al.Source(audio.getSourceFromChannel(1), al.PITCH, 1)
        
        previousBSO = audioHandle
    end
end

function fadeBSO(newVolume)
    if BSO_ENABLED == true then
        audio.fade({channel = 1, time = 250, volume = newVolume })
    end
end