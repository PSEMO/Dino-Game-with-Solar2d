------------------------------------------------------------------------------------
--
-- main.lua
--
------------------------------------------------------------------------------------

--holds all keys. True if they are pressed down or being held down, false if not.
local keyDownList = {}

--Last time is needed to calculate deltaTime
local dt = 0
local LastTime = 0

local GameisActive = true
local dt = 0
local LastTime = 0

local Score = 0
local ScoreText = display.newText(Score, 150, 25, nil, 50)

local PlayerSpriteOption =
{
    width = 32,
    height = 32,
    numFrames = 12
}
local PlayerSprites = graphics.newImageSheet("Run.png", PlayerSpriteOption)

local GroundStartPos = -800
local GroundY = 950
local GroundSpriteOption =
{
    width = 48,
    height = 48,
    numFrames = 1
}
local GroundSprites = graphics.newImageSheet("Terrain.png", GroundSpriteOption)
local Grounds = 
{--i is for image
    [1] = {i = display.newImage(GroundSprites, 1)},
    [2] = {i = display.newImage(GroundSprites, 1)},
    [3] = {i = display.newImage(GroundSprites, 1)},
    [4] = {i = display.newImage(GroundSprites, 1)},
    [5] = {i = display.newImage(GroundSprites, 1)},
    [6] = {i = display.newImage(GroundSprites, 1)},
    [7] = {i = display.newImage(GroundSprites, 1)},
    [8] = {i = display.newImage(GroundSprites, 1)},
    [9] = {i = display.newImage(GroundSprites, 1)},
    [10] = {i = display.newImage(GroundSprites, 1)},
    [11] = {i = display.newImage(GroundSprites, 1)},
    [12] = {i = display.newImage(GroundSprites, 1)},
    [13] = {i = display.newImage(GroundSprites, 1)},
    [14] = {i = display.newImage(GroundSprites, 1)},
    [15] = {i = display.newImage(GroundSprites, 1)},
    [16] = {i = display.newImage(GroundSprites, 1)},
    [17] = {i = display.newImage(GroundSprites, 1)},
    [18] = {i = display.newImage(GroundSprites, 1)},
    [19] = {i = display.newImage(GroundSprites, 1)},
    [20] = {i = display.newImage(GroundSprites, 1)},
    [21] = {i = display.newImage(GroundSprites, 1)},
    [22] = {i = display.newImage(GroundSprites, 1)},
    [23] = {i = display.newImage(GroundSprites, 1)},
    [24] = {i = display.newImage(GroundSprites, 1)},
    [25] = {i = display.newImage(GroundSprites, 1)}
}

local Spikes = {}
local spikeSpriteOption =
{
    width = 16,
    height = 16,
    numFrames = 1
}
local spikeSprites = graphics.newImageSheet("spike.png", spikeSpriteOption)

local PlayerFrameStopWatch = 0
local PlayerFrameDuration = 40
local PlayerFrameCurrent = 1
local Player = 
{
    frame = display.newImage(GroundSprites, 1),
    PosX = -400,
    PosY = 850,
    ScaleX = 4,
    ScaleY = 4
}

local HeldJumpingButton = 0
local MaxHeld = 200
local fallingStopwatch = 0

local SpawnStopwatch = 0
local SpawnTimer = 1800

function Update(event)

    ------------------------------------------------------------------------------------
    if(GameisActive)
    then
        dt = event.time - LastTime
        LastTime = event.time

        Score = (event.time / 33)
    else
        dt = 0
    end
    ------------------------------------------------------------------------------------
    GroundStartPos = GroundStartPos - (dt / 3)
    if(GroundStartPos < -1000)
    then
        GroundStartPos = GroundStartPos + 192
    end

    for k,v in pairs(Grounds) do
        local x = GroundStartPos + k * 96
        v.i:removeSelf()
        v.i = display.newImage(GroundSprites, 1)
        v.i:translate(x, GroundY)
        v.i:scale(2, 2)
    end
    ------------------------------------------------------------------------------------
    CreateScoreUI()
    ------------------------------------------------------------------------------------
    PlayerFrameStopWatch = PlayerFrameStopWatch + dt
    if(PlayerFrameStopWatch > PlayerFrameDuration)
    then
        PlayerFrameStopWatch = 0
        PlayerFrameCurrent = PlayerFrameCurrent + 1
        if(PlayerFrameCurrent > 12)
        then
            PlayerFrameCurrent = 1
        end
    end

    Player.frame:removeSelf()
    Player.frame = display.newImage(PlayerSprites, PlayerFrameCurrent)
    Player.frame:translate(Player.PosX, Player.PosY)
    Player.frame:scale(Player.ScaleX, Player.ScaleY)
    ------------------------------------------------------------------------------------
    if(keyDownList["up"] or keyDownList["w"] or keyDownList["space"]) and (HeldJumpingButton < MaxHeld) and GameisActive
    then
        Player.PosY = Player.PosY - 10
        HeldJumpingButton = HeldJumpingButton + dt
    elseif(Player.PosY < 850) 
    then
        fallingStopwatch = fallingStopwatch + dt
        Player.PosY = Player.PosY + (fallingStopwatch / 40) - 5
        if(Player.PosY > 850)
        then
            fallingStopwatch = 0
            Player.PosY = 850
            HeldJumpingButton = 0
        end
    end
    ------------------------------------------------------------------------------------
    SpawnStopwatch = SpawnStopwatch + dt
    if(SpawnStopwatch > SpawnTimer)
    then
        SpawnStopwatch = 0
        CreateSpike()
    end

    for k,v in pairs(Spikes)
    do
        v.x = v.x - (dt / 3)

        v.i:removeSelf()
        v.i =display.newImage(spikeSprites, 1)
        v.i:translate(v.x, v.y)
        v.i:scale(3.5, 3.5)
    end
    ------------------------------------------------------------------------------------
    for k,v in pairs(Spikes)
    do
        IsCollided(Player.PosX, Player.PosY, v.x, v.y)
    end
    ------------------------------------------------------------------------------------
end

function IsCollided(playerPosX, playerPosY, obstaclePosX, obstaclePosY)
      
    local Px = playerPosX - 11 * 2 --player left most position
    local Py = playerPosY - 15 * 2 --player bottom position
    local PLx = 22 * 4 --player X length
    local PLy = 22 * 4 --player Y length

    local Ox = obstaclePosX - 8 * 1.5 --player left most position
    local Oy = obstaclePosY + 1 * 1.5 --player bottom position
    local OLx = 15 *3 --player X length
    local OLy = 7  *3 --player Y length

    if (Px + PLx >= Ox) and
       (Px <= Ox + OLx) and
       (Py + PLy >= Oy) and
       (Py <= Oy + OLy)
    then
        Died()
    end
end

function Died()

    GameisActive = false
end

function KeyHandler(event)
    
    if (event.phase == "up")
    then
       keyDownList[event.keyName] = false
       --print(event.keyName .. " is up")

    elseif (event.phase == "down")
    then
       keyDownList[event.keyName] = true
       --print(event.keyName .. " is pressed down")
       
    end
end

function CreateSpike()
      
    local temp =
    {
        i = display.newImage(spikeSprites, 1),
        x = 1000,
        y = 890
    }
    table.insert(Spikes, temp)
end

function CreateScoreUI()
      
    ScoreText:removeSelf()
    ScoreText = display.newText("Score: " .. Score, 150, 25, nil, 50)
end

Runtime:addEventListener("enterFrame", Update)
Runtime:addEventListener("key", KeyHandler)