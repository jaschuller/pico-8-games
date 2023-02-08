pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- system
debugging = false

-- game clock
elapsedtime = 0
secondselapsed = 0
newdoubletime = 0
lastdoubletime = 0

-- sound
soundmanunavigate = 0
soundcancel = 1
sounddamage = 2
soundconfirm = 3

-- music

-- state variables
playerstate = 'none'
choosing_combat_action = 'choosing_combat_action'
choosing_target = 'choosing_target'

-- menu (combat)
cursorsprite = 3
arrowsprite = 2
cursorlocation = "start"
menuvisible = false
emptyspritesmall = 0 -- draw this over an 8x8 sprite (cursorsprite) to simulate blinking
lastfliptimestamp = 0
flipsprite = false

fightx = 20
fighty = 100
fightcolor = 10 -- 10 yellow

defendx = 60
defendy = fighty
defendcolor = 7 -- white

runx = 100
runy = fighty
runcolor = 7 -- white

-- border element
skullbordersprite = 4

-- enemies
enemyleft = 'none' -- specify enemy at the left position
enemycenter = 'none' -- specify enemy at the center position
enemyright = 'none' -- specify enemy at the right position
targetingenemy = 'none'
enemiesy = 30 -- enemies are in one row, specify where the row appears on the screen. used to calculate position or targeting arrow 

function _init()
    starttime = time()
    cursorlocation = "fight"
    menuvisible = true

    -- create a table for storing enemies object
    enemies = {}
    
    -- move this into encounter logic
    addfairy(1)
    addgoblin(2)
    adddemon(3)
    
    -- todo playerstate for being at title screen
    -- todo handle transitioning into other states
    playerstate = choosing_combat_action
end

function _update()
    elapsedtime = time() - starttime

    -- round down for elapsed time to get seconds
    secondselapsed = flr(elapsedtime)
    newdoubletime = flr(elapsedtime * 2)

    if(lastfliptimestamp < newdoubletime) then
        if(flipsprite == false) then
            flipsprite = true
        elseif(flipsprite == true) then
            flipsprite = false
        end
        lastfliptimestamp = newdoubletime
    end

    -- update each enemy, mainly navigation
    for e in all(enemies) do
        e:update()
    end

    -- handle player keystrokes given various states they may be in
    if(playerstate == choosing_combat_action) then
        handlecombatmenukeystroke()
    elseif(playerstate == choosing_target) then
        handletargetingkeystroke()
    end
end

------------------------------------------------------------------------
-- objects start
------------------------------------------------------------------------

function addenemy(_name, _sprite, _position)

    -- setup targeting variables based on position
    if(_position == 1) then
        enemyleft = _name -- specify enemy at the left position
    elseif(_position == 2) then
        enemycenter = _name -- specify enemy at the center position
    elseif(_position == 3) then
        enemyright = _name -- specify enemy at the right position    
    end

    -- create an instance of the enemies class and add it to the table
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

        -- draw an enemy, position can be 1-3 for 3 different enemy slots
        -- each sprite is 8 pixels wide, so account for 24 w/h
        draw = function(self)
            -- pset(self.x, self.y, 8)
        
            -- 4th and 5th param are number of 8x8 sprites wide
            spr(self.sprite, (self.position * 24), enemiesy, 3, 3, flipsprite)            
        end,
        update = function(self)
            -- self.x+=self.dx
            -- self.y+=self.dy
            -- self.life-=1

            -- todo code removal/defeated logic here
            if (self.hp<0) then
                -- del(dust,self)
                -- award experience, gold, items, etc
            end            
        end
    })
end

function addgoblin(_position)
    goblinsprite = 67
    addenemy('goblin', goblinsprite, _position)
end

function addskeleton(_position)
    skeletonsprite = 64
    addenemy('skeleton', skeletonsprite, _position)
end

function adddemon(_position)
    demonsprite = 70
    addenemy('skeleton', demonsprite, _position)
end

function addfairy(_position)
    fairysprite = 73
    addenemy('skeleton', fairysprite, _position)
end

------------------------------------------------------------------------
-- objects end
------------------------------------------------------------------------

------------------------------------------------------------------------
-- update handlers start 
------------------------------------------------------------------------ 

-- handles keystrokes when determining to run, fight or defend
-- btnp mapping is as follows:
-- left 	0
-- right 	1
-- up 		2
-- down 	3
-- o 		4
-- x 		5
function handlecombatmenukeystroke()
    -- sfx( n, [channel,] [offset,] [length] )
    -- channel is 0-3, with default -1 (any channel play the sound on it)

    -- btnp( [i,] [p] ) use for menus
    -- btn use for movement

    if btnp(0) then --left
        sfx(soundmanunavigate, 0)
        if(cursorlocation == 'fight' or targetingenemy == 'left') then
            focusrun()
        elseif(cursorlocation == 'defend') then
            focusfight()            
        elseif(cursorlocation == 'run') then
            focusdefend()
        end
    elseif btnp(1) then -- right
        sfx(soundmanunavigate, 0)
        if(cursorlocation == 'fight') then
            focusdefend()
        elseif(cursorlocation == 'defend') then
            focusrun()            
        elseif(cursorlocation == 'run') then
            focusfight()            
        end
    elseif btnp(2) then -- up todo: implement use
        sfx(soundmanunavigate, 0)
    elseif btnp(3) then -- down todo: implement use
        sfx(soundmanunavigate, 0)
    elseif btnp(4) then -- cancel
        sfx(soundcancel, 0)
        targetingenemy = 'none'        
    elseif btnp(5) then -- confirm
        sfx(soundconfirm, 0)

    -- todo: implement start key (pause)
    -- todo: implement select key (map?, spells?)       

        -- check how which enemies are present, and target leftmost one first one
        if(enemyleft ~= 'none') then
            targetingenemy = 'left'
        elseif(enemycenter ~= 'none') then
            targetingenemy = 'center'
        elseif(enemyright ~= 'none') then
            targetingenemy = 'right'
        end
        playerstate = choosing_target
    end                        
end 

function focusfight()
    cursorlocation = 'fight'
    fightcolor = 10
    runcolor = 7
    defendcolor = 7 
end

function focusdefend()
    cursorlocation = 'defend'
    fightcolor = 7
    runcolor = 7
    defendcolor = 10 
end

function focusrun()
    cursorlocation = 'run'
    fightcolor = 7
    runcolor = 10
    defendcolor = 7 
end

-- handles keystrokes when choosing which enemy to target with an attack or spell
-- btnp mapping is as follows:
-- left 	0
-- right 	1
-- up 		2
-- down 	3
-- o 		4
-- x 		5
function handletargetingkeystroke()
    -- sfx( n, [channel,] [offset,] [length] )
    -- channel is 0-3, with default -1 (any channel play the sound on it)

    -- btnp( [i,] [p] ) use for menus
    -- btn use for movement

    if btnp(0) then --left
        sfx(soundmanunavigate, 0)
        -- move cursor to left, skipping spots where there is no enemy
        -- cycle over to right side if already targeting left enemy

        -- handle scenarios where cursor is targeting left enemy
        if(targetingenemy == 'left' and enemyright ~= 'none') then
            targetingenemy = 'right'
        elseif(targetingenemy == 'left' and enemycenter ~= 'none') then
            targetingenemy = 'center'
        elseif(targetingenemy == 'left' and enemyleft ~= 'none') then
            targetingenemy = 'left'
        -- handle scenarios where cursor is targeting center enemy
        elseif(targetingenemy == 'center' and enemyleft ~= 'none') then
            targetingenemy = 'left'
        elseif(targetingenemy == 'center' and enemyright ~= 'none') then
            targetingenemy = 'right'
        elseif(targetingenemy == 'center' and enemycenter ~= 'none') then
            targetingenemy = 'center'
        -- handle scenarios where cursor is targeting right enemy
        elseif(targetingenemy == 'right' and enemycenter ~= 'none') then
            targetingenemy = 'center'
        elseif(targetingenemy == 'right' and enemyleft ~= 'none') then
            targetingenemy = 'left'
        elseif(targetingenemy == 'right' and enemyright ~= 'none') then
            targetingenemy = 'right'
        end
    elseif btnp(1) then -- right
        sfx(soundmanunavigate, 0)
        -- move cursor to right, skipping spots where there is no enemy
        -- cycle over to left side if already targeting right enemy

        -- handle scenarios where cursor is targeting left enemy
        if(targetingenemy == 'left' and enemycenter ~= 'none') then
            targetingenemy = 'center'
        elseif(targetingenemy == 'left' and enemyright ~= 'none') then
            targetingenemy = 'right'
        elseif(targetingenemy == 'left' and enemyleft ~= 'none') then
            targetingenemy = 'left'
        -- handle scenarios where cursor is targeting center enemy
        elseif(targetingenemy == 'center' and enemyright ~= 'none') then
            targetingenemy = 'right'
        elseif(targetingenemy == 'center' and enemyleft ~= 'none') then
            targetingenemy = 'left'
        elseif(targetingenemy == 'center' and enemycenter ~= 'none') then
            targetingenemy = 'center'
        -- handle scenarios where cursor is targeting right enemy
        elseif(targetingenemy == 'right' and enemyleft ~= 'none') then
            targetingenemy = 'left'
        elseif(targetingenemy == 'right' and enemycenter ~= 'none') then
            targetingenemy = 'center'
        elseif(targetingenemy == 'right' and enemyright ~= 'none') then
            targetingenemy = 'right'
        end
    elseif btnp(2) then -- up todo: target all in case of a spell, divide damage
        sfx(soundmanunavigate, 0)
    elseif btnp(3) then -- down todo: revert to single target if targeting all
        sfx(soundmanunavigate, 0)
    elseif btnp(4) then -- cancel
        playerstate = choosing_combat_action -- todo switch state contextually
        sfx(soundcancel, 0)
    elseif btnp(5) then -- confirm
        -- todo: handle the attack, then playerstate = 'choosing_combat_action'
        sfx(sounddamage, 0)

        -- once attack animation and stats are adjusted, return state to combat action
        -- todo play victory fanfare etc when battle is over
        playerstate = choosing_combat_action
    end                        
end

-- todo impement if some special handling is required
function handlesoundeffect(effectindex, channel)
    -- check if the sound is already playing on the given channel before playing it
end

-- stat(46) - stat(49) return the index of the sound effect currently playing on the four channels, respectively. 
-- if no sound is playing on the channel, stat() returns -1.

------------------------------------------------------------------------
----------------------update handlers end-------------------------------
------------------------------------------------------------------------

function _draw()
    -- clear the screen
    rectfill(0,0,128,128,0)   
    
    if(debugging == true) then
        drawtimers()
    end

    drawmenu() -- top level combat menu

    -- todo: draw the map
    -- todo: draw title screen
    -- todo: draw the dungeon
    -- todo: draw game over screen

    -- draw each enemy in the table (defined in addenemy), there should never be more then 3
    for e in all(enemies) do
        e:draw()
    end

end 

------------------------------------------------------------------------
----------------------draw functions start------------------------------
------------------------------------------------------------------------
function drawarrow()
    -- position when arrow is pointed at leftmost enemy
    -- center and right arrows add 24 pixels each (size of enemey sprites) to shift over
    positionx = 32 -- positionx needs to be directly in the middle of 1st enemy
    positiony = enemiesy + 24 -- sprites are 24x24 pixels so offset to sit below the enemies on y axis

    -- draw targeting arrows for enemies that are being targeted
    -- todo make arrows blink by drawing over with black sprite 4 times a second
    if((targetingenemy == 'left' or targetingenemy == 'all' ) and enemyleft ~= 'none') then
        spr(arrowsprite, positionx, positiony, 1, 1)
    elseif((targetingenemy == 'center' or targetingenemy == 'all' ) and enemycenter ~= 'none') then
        spr(arrowsprite, positionx + 24, positiony, 1, 1)
    elseif((targetingenemy == 'right' or targetingenemy == 'all' ) and enemyright ~= 'none') then
        spr(arrowsprite, positionx + 48, positiony, 1, 1)
    end
end

-- width/height specified in number of repeated 8x8 pixel sprites
function drawboarder(topx, topy, width, height, bordersprite)
    -- draw top and bottom border
    for i = 1, (width)  do
        spr(bordersprite, topx + ((i-1)*8), topy, 1, 1)
        spr(bordersprite, topx + ((i-1)*8), topy + ((height-1)*8), 1, 1)
    end
    -- draw left and right border
    for i = 1, (height) do
        spr(bordersprite, topx, topy + ((i-1)*8), 1, 1)
        spr(bordersprite, topx + ((width-1)*8), topy + ((i-1)*8), 1, 1)
    end                   
end

-- spr( n, [x,] [y,] [w,] [h,] [flip_x,] [flip_y] )
function drawcursor()
    if(cursorlocation == 'fight') then
        spr(cursorsprite, fightx - 8, fighty, 1, 1)
    elseif(cursorlocation == 'defend') then
        spr(cursorsprite, defendx - 8, defendy, 1, 1)
    elseif(cursorlocation == 'run') then
        spr(cursorsprite, runx - 8, runy, 1, 1)
    end
end

-- main draw function for all menus
-- screen dimension 128/128
function drawmenu()
    -- draw the border around enemy/env window
    topx = 1
    topy =  1
    width = 16
    height = 10
    drawboarder(topx, topy, width, height, skullbordersprite)

    if(menuvisible == true) then            
        -- print( text, [,] [y,] [color] )
        print('fight', fightx, fighty, fightcolor)
        print('defend', defendx, defendy, defendcolor)
        print('run', runx, runy, runcolor)

        -- draw the menu outline/border

        -- rect( x1, y1, x2, y2, color )
        rect( fightx - 10, fighty - 5, runx + 15, runy + 8, 7 )
    end

    if(playerstate == choosing_combat_action) then
        drawcursor() -- cursor used for selecting combat choice
    elseif(playerstate == choosing_target) then
        drawarrow() -- cursor used for selecting combat choice
    end
end 

function drawtimers()
    -- string concat in lua is ..
    print(secondselapsed, 112, 10, 7)
    print(newdoubletime, 112, 16, 7)
    
    print('enemy left: ' .. enemyleft, 9, 9, 7)
    print('enemy center: ' .. enemycenter, 9, 15, 7)
    print('enemy right: ' .. enemyright, 9, 21, 7)

    print('targeting: ' .. targetingenemy, 9, 64, 7)
    print('state: ' .. playerstate, 1, 112, 7)
end

------------------------------------------------------------------------
----------------------draw functions end--------------------------------
------------------------------------------------------------------------ 
__gfx__
00000000000000000000000040004000141141140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000a000000400004440000117777110000000000666770006000000000660000000000000000000000000000000000000000000000000000000000
00000000000a00000004440004040000170000740667000006666670006000000006660000000000000000000000000000000000000000000000000000000000
0000000000a009000044444004440000474004710666700066666667006000000006660000000000000000000000000000000000000000000000000000000000
000000000000a0000000000040004000170000710666700066666667006000000006660000000000000000000000000000000000000000000000000000000000
000000000000aa000000000000000000117007110666700066666667006000000006660000000000000000000000000000000000000000000000000000000000
00000000009aaaa00000000000000000117777110366700000336670006000000076660000000000000000000000000000000000000000000000000000000000
00000000009999a00000000000000000141111410300000000330000006000000076660000000000000000000000000000000000000000000000000000000000
00000000004994400000000000000000000000000300000000330000066000000076660000000000000000000000000000000000000000000000000000000000
00000000004494000000000000000000000000000300000000330000066000000076660000000000000000000000000000000000000000000000000000000000
00000000000330000000000000000000000000000300000000330000333300000333333000000000000000000000000000000000000000000000000000000000
00000000000330000000000000000000000000000300000000330000003000000000330000000000000000000000000000000000000000000000000000000000
00000000000330000000000000000000000000000000000000000000003000000000330000000000000000000000000000000000000000000000000000000000
00000000000330000000000000000000000000000000000000000000000000000000330000000000000000000000000000000000000000000000000000000000
00000000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
566556655665566556655665000000003222233333322223baabbbbbbab9bbab1412141114114122000000000000000000000000000000000000000000000000
665566556655665566556655000000003255333232223323aaaab9abbaaabaa94112214111144221000000000000000000000000000000000000000000000000
566556655665566556655665000000003323332332233333bbbabbabbbbbbbaa1441444114114441000000000000000000000000000000000000000000000000
665566556655665566556655000000003333352222333323b9bb9bbbbbbaabbb4111411122114111000000000000000000000000000000000000000000000000
566556655665566556655665000000003233553222323332babbbbabbabaa9bb1441414112211141000000000000000000000000000000000000000000000000
665566556655665566556655000000003255333233322332babbbaab9aabbabb4111422211214111000000000000000000000000000000000000000000000000
566556655665566556655665000000003332255233323522baabbaabbabbbaab4224424441142244000000000000000000000000000000000000000000000000
665566556655665566556655000000002333222223322232bbaab9abbab9babb2114121111412141000000000000000000000000000000000000000000000000
666666666666666666666666000000003533333333533555b9bbbbabab9bbbbb1411111111411141000000000000000000000000000000000000000000000000
565656565656565656565656000000005532332335525533baaaabbbababba9b1244444114124441000000000000000000000000000000000000000000000000
555555555555555555555555000000005322332332535523bbbbbbb9abaabbbb1211122414122111000000000000000000000000000000000000000000000000
656565656565656565656565000000005323333333555335b9abbbbbb9bbbbaa4211442444141111000000000000000000000000000000000000000000000000
666666666666666666666666000000005523333255332335baabbaabbaa9babb1411412444142244000000000000000000000000000000000000000000000000
565656565656565656565656000000003532233235335535bbababbbbaabbabb1442114112241221000000000000000000000000000000000000000000000000
555555555555555555555555000000003532333332333535abbbabbbbbaabaab1141114114211411000000000000000000000000000000000000000000000000
6565656565656565656565650000000023332222332335559babbb9bbbbaa9bb1411444111411441000000000000000000000000000000000000000000000000
0000000007777770000000000a000001111111110000000000004000404444040040000007000000070000000000000000070000000000000000000000000000
0000000070000007000000000aa00001111111110000000000004400444994440440000000000000000000000000000000000000000000000000000000000000
000000007048048700000000aaaa0001333333330000000000004440499999944440000000000000000000700000000000000000000000000000000000000000
0000000070000007000000000aa00001337137130000000000000444499099994400000000000000000000000000000000000000000000000000000000000000
0000000070000007000000000aa00001333333330000000000000044490609060000f00000000000000000000000000000000000000000000000000000000000
0000000007000007000000000aa000113300033300000000000000000990999900f0f0f070000000000000000000070000000000000000000000000000000000
0000000000777770000000000660000003333330000000000000000009999ff000fffff00000000000ff00f00000000000000000000000000000000000000000
000000000007700000000000066000000033330000000000000000000099f880000f99f000007000000ffff00000000000000000000000000000000000000000
000000000007700066600000363300bbbbbbbbbb3000000000000000099908880009990000000000088cfc880000000000000000000000000000000000000000
0707070007777770006660003633a3bbbbbbbbbbb300000000000000999988000099990000000000888f9f888000000000000000000000000000000000000000
0777770070077007777766000663a3bb3bbbbbbbbb300000000000000999009009999000000000008666666ff000000000000000000000000000000000000000
0077770077777777777776600660033bb3bbbbbbbb333000000099090999999099999000000000008f8666888000000000000700000000000000000000000000
0000777770077007333333340660003b3bbbbbbbbbb333000009999999999d999990000000000000888ccc888000000000000000000000000000000000000000
0000077777777777000006600660003b3b3bbb33bb30330000099999999d99999000000000000000880ccc088000000000000000000000000000000000000000
00000000700770070000660006600033b33b33bbb300aa00009999000999999000000000000000000ccccccc0000000000000000000000000000000000000000
000000000777777066666000066000033bb333333003330000ff9990099999900000000007000000fcccccc00000000000000000000000000000000000000000
0000000000077700000000000660000bbbbbbbb0000333000ffffff000099999000000000000000000f000000000000700000000000000000000000000000000
0000000000777700000000000660000bbbb0bbb00033330000fffff0009999990000000000000000000000000000000000000000000000000000000000000000
0000000007777770000000000660000bb0000bb00000000000f0f0f0999099990000000000000000000000000000000000000000000000000000000000000000
0000000007700770000000000660000330000333000000000000f0f0900999999900000000000000000000000000000000000000000000000000000000000000
000000000700007000000000066000033000033300000000000000f0909900000990000000000000000000000000000000000000000000000000000000000000
00000000070007700000000006600033300003330000000000000099909900000999000000000000000000000000000000000000000000000000000000000000
00000000077007700000000006600333330003333300000000009990099000000099900000000700070000000000000000000000000000000000000000000000
00000000777007770000000006600333300000333300000009999000999000000099990000000000000000000007000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000009999000000000999900000000000000000000000000000000000000000000000000000000
__sfx__
0001000000000000003d0503b05038050360503405032050300502e0502d0502c05029050260502405026050280502a0502c0502e05030050320503405037050390503a0503a0503d0503d0503a0503a05000000
0001000000000000003c0503a05037050360503405032050300502e0502c0502b05029050270502505023050200501e0501c0501a05019050170501505013050110500f0500d0500b05009050070500505003050
000100003c6503a65038650366503465031650316502f6502e6502d6502a6502965027650266502465022650206501f6501d6501c6501a6501865017650166501465012650116500f6500d6500b6500a65009650
0002000004150081500b1500e1500f1500b150081500d150121501c150291503a1503f15000100011000110001100011000010000100001000010001100001000010000100001000010000100001000010000100
