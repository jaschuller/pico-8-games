-- System
debugging = false

-- Game clock
elapsedTime = 0
secondsElapsed = 0
newDoubleTime = 0
lastDoubleTime = 0

-- Sound
soundManuNavigate = 0
soundCancel = 1
soundDamage = 2
soundConfirm = 3

-- Music

-- State Variables
playerState = 'none'
CHOOSING_COMBAT_ACTION = 'CHOOSING_COMBAT_ACTION'
CHOOSING_TARGET = 'CHOOSING_TARGET'

-- Menu (Combat)
cursorSprite = 3
arrowSprite = 2
cursorLocation = "start"
menuVisible = false
emptySpriteSmall = 0 -- draw this over an 8x8 sprite (cursorSprite) to simulate blinking
lastFlipTimestamp = 0
flipSprite = false

fightX = 20
fightY = 100
fightColor = 10 -- 10 YELLOW

defendX = 60
defendY = fightY
defendColor = 7 -- WHITE

runX = 100
runY = fightY
runColor = 7 -- WHITE

-- Border Element
skullBorderSprite = 4

-- Enemies
enemyLeft = 'none' -- Specify enemy at the left position
enemyCenter = 'none' -- Specify enemy at the center position
enemyRight = 'none' -- Specify enemy at the right position
targetingEnemy = 'none'
enemiesY = 30 -- Enemies are in one row, specify where the row appears on the screen. Used to calculate position or targeting arrow 

function _init()
    startTime = time()
    cursorLocation = "FIGHT"
    menuVisible = true

    -- Create a table for storing enemies object
    enemies = {}
    
    -- Move this into encounter logic
    addFairy(1)
    addGoblin(2)
    addDemon(3)
    
    -- TODO playerState for being at title screen
    -- TODO handle transitioning into other states
    playerState = CHOOSING_COMBAT_ACTION
end

function _update()
    elapsedTime = time() - startTime

    -- Round down for elapsed time to get seconds
    secondsElapsed = flr(elapsedTime)
    newDoubleTime = flr(elapsedTime * 2)

    if(lastFlipTimestamp < newDoubleTime) then
        if(flipSprite == false) then
            flipSprite = true
        elseif(flipSprite == true) then
            flipSprite = false
        end
        lastFlipTimestamp = newDoubleTime
    end

    -- Update each enemy, mainly navigation
    for e in all(enemies) do
        e:update()
    end

    -- Handle player keystrokes given various states they may be in
    if(playerState == CHOOSING_COMBAT_ACTION) then
        handleCombatMenuKeystroke()
    elseif(playerState == CHOOSING_TARGET) then
        handleTargetingKeystroke()
    end
end

------------------------------------------------------------------------
-- OBJECTS START
------------------------------------------------------------------------

function addEnemy(_name, _sprite, _position)

    -- Setup targeting variables based on position
    if(_position == 1) then
        enemyLeft = _name -- Specify enemy at the left position
    elseif(_position == 2) then
        enemyCenter = _name -- Specify enemy at the center position
    elseif(_position == 3) then
        enemyRight = _name -- Specify enemy at the right position    
    end

    -- Create an instance of the enemies class and add it to the table
    add(enemies, {
        name = _name,
        sprite = _sprite,
        position = _position,   
        hp = 5,
        xp = 3,
        gp = 10,
        at = 4,
        def = 1,
        dx = 0,
        dy = 0,

        -- Draw an enemy, position can be 1-3 for 3 different enemy slots
        -- Each sprite is 8 pixels wide, so account for 24 w/h
        draw = function(self)
            -- pset(self.x, self.y, 8)
        
            -- 4th and 5th param are number of 8x8 sprites wide
            spr(self.sprite, (self.position * 24), enemiesY, 3, 3, flipSprite)            
        end,
        update = function(self)
            -- self.x+=self.dx
            -- self.y+=self.dy
            -- self.life-=1

            -- TODO code removal/defeated logic here
            if (self.hp<0) then
                -- del(dust,self)
                -- Award experience, gold, items, etc
            end            
        end
    })
end

function addGoblin(_position)
    goblinSprite = 67
    addEnemy('goblin', goblinSprite, _position)
end

function addSkeleton(_position)
    skeletonSprite = 64
    addEnemy('skeleton', skeletonSprite, _position)
end

function addDemon(_position)
    demonSprite = 70
    addEnemy('skeleton', demonSprite, _position)
end

function addFairy(_position)
    fairySprite = 73
    addEnemy('skeleton', fairySprite, _position)
end

------------------------------------------------------------------------
-- OBJECTS END
------------------------------------------------------------------------

------------------------------------------------------------------------
-- UPDATE HANDLERS START 
------------------------------------------------------------------------ 

-- Handles keystrokes when determining to RUN, FIGHT or DEFEND
-- btnp mapping is as follows:
-- Left 	0
-- Right 	1
-- Up 		2
-- Down 	3
-- O 		4
-- X 		5
function handleCombatMenuKeystroke()
    -- sfx( n, [channel,] [offset,] [length] )
    -- channel is 0-3, with default -1 (any channel play the sound on it)

    -- btnp( [i,] [p] ) use for menus
    -- btn use for movement

    if btnp(0) then --Left
        sfx(soundManuNavigate, 0)
        if(cursorLocation == 'FIGHT' or targetingEnemy == 'left') then
            focusRun()
        elseif(cursorLocation == 'DEFEND') then
            focusFight()            
        elseif(cursorLocation == 'RUN') then
            focusDefend()
        end
    elseif btnp(1) then -- Right
        sfx(soundManuNavigate, 0)
        if(cursorLocation == 'FIGHT') then
            focusDefend()
        elseif(cursorLocation == 'DEFEND') then
            focusRun()            
        elseif(cursorLocation == 'RUN') then
            focusFight()            
        end
    elseif btnp(2) then -- Up TODO: Implement use
        sfx(soundManuNavigate, 0)
    elseif btnp(3) then -- Down TODO: Implement use
        sfx(soundManuNavigate, 0)
    elseif btnp(4) then -- Cancel
        sfx(soundCancel, 0)
        targetingEnemy = 'none'        
    elseif btnp(5) then -- Confirm
        sfx(soundConfirm, 0)

    -- TODO: Implement start key (pause)
    -- TODO: Implement select key (map?, spells?)       

        -- check how which enemies are present, and target leftmost one first one
        if(enemyLeft ~= 'none') then
            targetingEnemy = 'left'
        elseif(enemyCenter ~= 'none') then
            targetingEnemy = 'center'
        elseif(enemyRight ~= 'none') then
            targetingEnemy = 'right'
        end
        playerState = CHOOSING_TARGET
    end                        
end 

function focusFight()
    cursorLocation = 'FIGHT'
    fightColor = 10
    runColor = 7
    defendColor = 7 
end

function focusDefend()
    cursorLocation = 'DEFEND'
    fightColor = 7
    runColor = 7
    defendColor = 10 
end

function focusRun()
    cursorLocation = 'RUN'
    fightColor = 7
    runColor = 10
    defendColor = 7 
end

-- Handles keystrokes when choosing which enemy to target with an attack or spell
-- btnp mapping is as follows:
-- Left 	0
-- Right 	1
-- Up 		2
-- Down 	3
-- O 		4
-- X 		5
function handleTargetingKeystroke()
    -- sfx( n, [channel,] [offset,] [length] )
    -- channel is 0-3, with default -1 (any channel play the sound on it)

    -- btnp( [i,] [p] ) use for menus
    -- btn use for movement

    if btnp(0) then --Left
        sfx(soundManuNavigate, 0)
        -- Move cursor to left, skipping spots where there is no enemy
        -- Cycle over to right side if already targeting left enemy

        -- Handle scenarios where cursor is targeting left enemy
        if(targetingEnemy == 'left' and enemyRight ~= 'none') then
            targetingEnemy = 'right'
        elseif(targetingEnemy == 'left' and enemyCenter ~= 'none') then
            targetingEnemy = 'center'
        elseif(targetingEnemy == 'left' and enemyLeft ~= 'none') then
            targetingEnemy = 'left'
        -- Handle scenarios where cursor is targeting center enemy
        elseif(targetingEnemy == 'center' and enemyLeft ~= 'none') then
            targetingEnemy = 'left'
        elseif(targetingEnemy == 'center' and enemyRight ~= 'none') then
            targetingEnemy = 'right'
        elseif(targetingEnemy == 'center' and enemyCenter ~= 'none') then
            targetingEnemy = 'center'
        -- Handle scenarios where cursor is targeting right enemy
        elseif(targetingEnemy == 'right' and enemyCenter ~= 'none') then
            targetingEnemy = 'center'
        elseif(targetingEnemy == 'right' and enemyLeft ~= 'none') then
            targetingEnemy = 'left'
        elseif(targetingEnemy == 'right' and enemyRight ~= 'none') then
            targetingEnemy = 'right'
        end
    elseif btnp(1) then -- Right
        sfx(soundManuNavigate, 0)
        -- Move cursor to right, skipping spots where there is no enemy
        -- Cycle over to left side if already targeting right enemy

        -- Handle scenarios where cursor is targeting left enemy
        if(targetingEnemy == 'left' and enemyCenter ~= 'none') then
            targetingEnemy = 'center'
        elseif(targetingEnemy == 'left' and enemyRight ~= 'none') then
            targetingEnemy = 'right'
        elseif(targetingEnemy == 'left' and enemyLeft ~= 'none') then
            targetingEnemy = 'left'
        -- Handle scenarios where cursor is targeting center enemy
        elseif(targetingEnemy == 'center' and enemyRight ~= 'none') then
            targetingEnemy = 'right'
        elseif(targetingEnemy == 'center' and enemyLeft ~= 'none') then
            targetingEnemy = 'left'
        elseif(targetingEnemy == 'center' and enemyCenter ~= 'none') then
            targetingEnemy = 'center'
        -- Handle scenarios where cursor is targeting right enemy
        elseif(targetingEnemy == 'right' and enemyLeft ~= 'none') then
            targetingEnemy = 'left'
        elseif(targetingEnemy == 'right' and enemyCenter ~= 'none') then
            targetingEnemy = 'center'
        elseif(targetingEnemy == 'right' and enemyRight ~= 'none') then
            targetingEnemy = 'right'
        end
    elseif btnp(2) then -- Up TODO: Target all in case of a spell, divide damage
        sfx(soundManuNavigate, 0)
    elseif btnp(3) then -- Down TODO: Revert to single target if targeting all
        sfx(soundManuNavigate, 0)
    elseif btnp(4) then -- Cancel
        playerState = CHOOSING_COMBAT_ACTION -- TODO switch state contextually
        sfx(soundCancel, 0)
    elseif btnp(5) then -- Confirm
        -- TODO: handle the attack, then playerState = 'CHOOSING_COMBAT_ACTION'
        sfx(soundDamage, 0)

        -- Once attack animation and stats are adjusted, return state to combat action
        -- TODO play victory fanfare etc when battle is over
        playerState = CHOOSING_COMBAT_ACTION
    end                        
end

-- TODO impement if some special handling is required
function handleSoundEffect(effectIndex, channel)
    -- Check if the sound is already playing on the given channel before playing it
end

-- stat(46) - stat(49) return the index of the sound effect currently playing on the four channels, respectively. 
-- If no sound is playing on the channel, stat() returns -1.

------------------------------------------------------------------------
----------------------UPDATE HANDLERS END-------------------------------
------------------------------------------------------------------------

function _draw()
    -- clear the screen
    rectfill(0,0,128,128,0)   
    
    if(debugging == true) then
        drawTimers()
    end

    drawMenu() -- Top level combat menu

    -- TODO: draw the map
    -- TODO: draw title screen
    -- TODO: draw the dungeon
    -- TODO: draw Game Over screen

    -- draw each enemy in the table (defined in addEnemy), there should never be more then 3
    for e in all(enemies) do
        e:draw()
    end

end 

------------------------------------------------------------------------
----------------------DRAW FUNCTIONS START------------------------------
------------------------------------------------------------------------
function drawArrow()
    -- position when arrow is pointed at leftmost enemy
    -- center and right arrows add 24 pixels each (size of enemey sprites) to shift over
    positionX = 32 -- positionX needs to be directly in the middle of 1st enemy
    positionY = enemiesY + 24 -- Sprites are 24x24 pixels so offset to sit below the enemies on Y axis

    -- Draw targeting arrows for enemies that are being targeted
    -- TODO make arrows blink by drawing over with black sprite 4 times a second
    if((targetingEnemy == 'left' or targetingEnemy == 'all' ) and enemyLeft ~= 'none') then
        spr(arrowSprite, positionX, positionY, 1, 1)
    elseif((targetingEnemy == 'center' or targetingEnemy == 'all' ) and enemyCenter ~= 'none') then
        spr(arrowSprite, positionX + 24, positionY, 1, 1)
    elseif((targetingEnemy == 'right' or targetingEnemy == 'all' ) and enemyRight ~= 'none') then
        spr(arrowSprite, positionX + 48, positionY, 1, 1)
    end
end

-- width/height specified in number of repeated 8x8 pixel sprites
function drawBoarder(topX, topY, width, height, borderSprite)
    -- Draw top and bottom border
    for i = 1, (width)  do
        spr(borderSprite, topX + ((i-1)*8), topY, 1, 1)
        spr(borderSprite, topX + ((i-1)*8), topY + ((height-1)*8), 1, 1)
    end
    -- Draw left and right border
    for i = 1, (height) do
        spr(borderSprite, topX, topY + ((i-1)*8), 1, 1)
        spr(borderSprite, topX + ((width-1)*8), topY + ((i-1)*8), 1, 1)
    end                   
end

-- spr( n, [x,] [y,] [w,] [h,] [flip_x,] [flip_y] )
function drawCursor()
    if(cursorLocation == 'FIGHT') then
        spr(cursorSprite, fightX - 8, fightY, 1, 1)
    elseif(cursorLocation == 'DEFEND') then
        spr(cursorSprite, defendX - 8, defendY, 1, 1)
    elseif(cursorLocation == 'RUN') then
        spr(cursorSprite, runX - 8, runY, 1, 1)
    end
end

-- Main draw function for all menus
-- Screen Dimension 128/128
function drawMenu()
    -- Draw the border around enemy/env window
    topX = 1
    topY =  1
    width = 16
    height = 10
    drawBoarder(topX, topY, width, height, skullBorderSprite)

    if(menuVisible == true) then            
        -- print( text, [,] [y,] [color] )
        print('FIGHT', fightX, fightY, fightColor)
        print('DEFEND', defendX, defendY, defendColor)
        print('RUN', runX, runY, runColor)

        -- Draw the menu outline/border

        -- rect( x1, y1, x2, y2, color )
        rect( fightX - 10, fightY - 5, runX + 15, runY + 8, 7 )
    end

    if(playerState == CHOOSING_COMBAT_ACTION) then
        drawCursor() -- Cursor used for selecting combat choice
    elseif(playerState == CHOOSING_TARGET) then
        drawArrow() -- Cursor used for selecting combat choice
    end
end 

function drawTimers()
    -- String concat in lua is ..
    print(secondsElapsed, 112, 10, 7)
    print(newDoubleTime, 112, 16, 7)
    
    print('Enemy left: ' .. enemyLeft, 9, 9, 7)
    print('Enemy center: ' .. enemyCenter, 9, 15, 7)
    print('Enemy right: ' .. enemyRight, 9, 21, 7)

    print('Targeting: ' .. targetingEnemy, 9, 64, 7)
    print('State: ' .. playerState, 1, 112, 7)
end

------------------------------------------------------------------------
----------------------DRAW FUNCTIONS END--------------------------------
------------------------------------------------------------------------ 