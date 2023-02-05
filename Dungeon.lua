-- System
startTime = 'initializing...'
debugging = true
elapsedTime = 0
secondsElapsed = 0
newDoubleTime = 0
lastDoubleTime = 0


-- Menu
cursorSprite = 3
cursorLocation = "start"
menuVisible = false

fightX = 20
fightY = 100
fightColor = 10

defendX = 60
defendY = fightY
defendColor = 7

runX = 100
runY = fightY
runColor = 7

soundManuNavigate = 0
soundCancel = 1
soundDamage = 2
soundConfirm = 3

-- Enemies
skeletonSprite = 64
enemyFlip = false

-- Color codes
-- 7 WHITE
-- 10 YELLOW

function _init()
    startTime = time()
    cursorLocation = "FIGHT"
    menuVisible = true
end

function _update()
    handleMenuKeystroke()
    elapsedTime = time() - startTime

    -- Round down for elapsed time to get seconds
    secondsElapsed = flr(elapsedTime)
    newDoubleTime = flr(elapsedTime * 2)
end

function _draw()
    -- clear the screen
    rectfill(0,0,128,128,0)   
    
    if(debugging == true) then
        drawTimer()
    end

    drawMenu()
    drawCursor()

    -- TODO
    -- draw the map
    -- draw title screen
    -- draw the dungeon
    -- draw the enemy
    drawEnemy(skeletonSprite, 1)
    drawEnemy(skeletonSprite, 2)
    drawEnemy(skeletonSprite, 3)

    -- draw Game Over screen

end 

function drawTimer()
    print(secondsElapsed, 100, 10, 7)
    print(newDoubleTime, 100, 20, 7)
end

function drawMenu()
    -- rect( x1, y1, x2, y2, color )
    
    -- w and h are number of sprites

    if(menuVisible == true) then

    --Screen Dimension 128/128    

    -- print( text, [,] [y,] [color] )
    print('FIGHT', fightX, fightY, fightColor)
    print('DEFEND', defendX, defendY, defendColor)
    print('RUN', runX, runY, runColor)

    -- Draw the menu outline/border

    -- rect( x1, y1, x2, y2, color )
    rect( fightX - 10, fightY - 5, runX + 15, runY + 8, 7 )

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

-- Draw an enemy, position can be 1-3 for 3 different enemy slots
-- Each sprite is 8 pixels wide, so account for 24 w/h 
function drawEnemy(enemySprite, position)
    if(newDoubleTime > lastDoubleTime) then
        if(enemyFlip == false) then
            enemyFlip = true
        elseif(enemyFlip == true) then
            enemyFlip = false
        end
        lastDoubleTime = newDoubleTime
    end

    spr(skeletonSprite, (position * 24), 30, 3, 3, enemyFlip)
end

function handleMenuKeystroke()
    -- Left 	0
    -- Right 	1
    -- Up 		2
    -- Down 	3
    -- O 		4
    -- X 		5

    -- sfx( n, [channel,] [offset,] [length] )
    -- channel is 0-3, with default -1 (any channel play the sound on it)

    -- btnp( [i,] [p] ) use for menus
    -- btn use for movement

    if btnp(0) then --Left
        sfx(soundManuNavigate, 0)
        if(cursorLocation == 'FIGHT') then
            cursorLocation = 'RUN'
            fightColor = 7
            runColor = 10
            defendColor = 7
        elseif(cursorLocation == 'DEFEND') then
            cursorLocation = 'FIGHT'
            fightColor = 10
            runColor = 7
            defendColor = 7            
        elseif(cursorLocation == 'RUN') then
            cursorLocation = 'DEFEND'
            fightColor = 7
            runColor = 7
            defendColor = 10
        end
    elseif btnp(1) then -- Right
        sfx(soundManuNavigate, 0)
        if(cursorLocation == 'FIGHT') then
            cursorLocation = 'DEFEND'
            fightColor = 7
            runColor = 7
            defendColor = 10           
        elseif(cursorLocation == 'DEFEND') then
            cursorLocation = 'RUN'
            fightColor = 7
            runColor = 10
            defendColor = 7            
        elseif(cursorLocation == 'RUN') then
            cursorLocation = 'FIGHT'
            fightColor = 10
            runColor = 7
            defendColor = 7            
        end
    elseif btnp(2) then -- Up
        sfx(soundManuNavigate, 0)
    elseif btnp(3) then -- Down
        sfx(soundManuNavigate, 0)
    elseif btnp(4) then -- Cancel
        sfx(soundCancel, 0)
    elseif btnp(5) then -- Confirm
        sfx(soundConfirm, 0)
    end                        
end

-- TODO impement if some special handling is required
function handleSoundEffect(effectIndex, channel)
    -- Check if the sound is already playing on the given channel before playing it
end

-- stat(46) - stat(49) return the index of the sound effect currently playing on the four channels, respectively. 
-- If no sound is playing on the channel, stat() returns -1.