-- buffalo
score=0
scoremultiplier=1
lives=3
elapsedtime=0
timelimit=5
endingplayed=false

--buffalo
buffalox=56
buffaloy=56
buffaloflipx=false
buffalosprite=2

--buffalo female
--buffalofsprite = 32
buffalofsprite = 32
buffalofx = 32
buffalofy = 32
pixelspeed = 1
xrange = 0
yrange = 0
buffalofxcounter = 0
buffalofycounter = 0
buffalofflipx = false
buffalofflipy = false
showfemale = false
femaleai = ""


-- grass
grassxboundsoffset = 0
grassyboundsoffset = 0
grassrespawn = true
grasses = {}

debugitem1 = "empty"
debugitem2 = "empty"
debugitem3 = "empty"

level = 0;

-- todo add in female buffalo "conga line" style

function grasscreatex(x)
	if (x) then
		return grassxboundsoffset + x
	else
		return grassxboundsoffset + flr(rnd(120-grassxboundsoffset))
	end
end

function grasscreatey(y)
	if (y) then
		return grassxboundsoffset + y
	else
		return grassyboundsoffset + flr(rnd(120-grassyboundsoffset))
	end
end
 
-- old random grass population code
--for row = 1, grasscount do
--  add(grasses, {grasscreatex(),grasscreatey()})
--end

 -- move the female buffalo in a square pattern
 function movefemalebuffalo()
	-- only do move logic if female exists
	if showfemale == false then
		return
	end
		
	if(femaleai == "lurd") then
		if (buffalofxcounter<xrange and buffalofflipx==false)then
			buffalofx-=pixelspeed
			buffalofxcounter+=1
		elseif (buffalofycounter<yrange and buffalofflipx==false) then
			buffalofy-=pixelspeed
			buffalofycounter+=1
		elseif (buffalofxcounter==xrange and buffalofycounter==yrange and buffalofflipx==false) then
			buffalofflipx=true
			debugitem2="flip"
		elseif (buffalofxcounter>0 and buffalofflipx==true) then
			buffalofx+=pixelspeed
			buffalofxcounter-=1
		elseif (buffalofycounter>0 and buffalofflipx==true) then
			buffalofy+=pixelspeed
			buffalofycounter-=1
		else
			debugitem3="reset"
			buffalofxcounter = 0
			buffalofycounter = 0
			buffalofflipx = false
		end
	elseif (femaleai=="ldru") then
		if (buffalofxcounter<xrange and buffalofflipx==false)then
			buffalofx-=pixelspeed
			buffalofxcounter+=1
		elseif (buffalofycounter<yrange and buffalofflipx==false) then
			buffalofy+=pixelspeed
			buffalofycounter+=1
		elseif (buffalofxcounter==xrange and buffalofycounter==yrange and buffalofflipx==false) then
			debugitem2="flip"
			buffalofflipx=true
		elseif (buffalofxcounter>0 and buffalofflipx==true) then
			buffalofx+=pixelspeed
			buffalofxcounter-=1
		elseif (buffalofycounter>0 and buffalofflipx==true) then
			buffalofy-=pixelspeed
			buffalofycounter-=1
		else
			debugitem3 ="reset"
			buffalofxcounter = 0
			buffalofycounter = 0
			buffalofflipx = false
		end	
	elseif femaleai=="" then
		-- no ai define so sit put
	end

 end
 
 function buildfemale(x,y,speed,xr,yr,ai) 
	buffalofx = x
	buffalofy = y
	pixelspeed = speed
	xrange = xr
	yrange = yr
	showfemale = true
	femaleai = ai
	
	--reset old values
	buffalofxcounter=0
	buffalofycounter=0
	buffalofflipx=false
 end
 
 
 function movebuffalo()
 
	-- handle buffalo movement, accounting for when 2 directional
	-- keys are pressed as well for diagnal movement
 	if btn(0) and btn(2) then
		buffalox-=3
		buffaloy-=3
		buffaloflipx=false
		buffalomoveanimation()
 	elseif btn(0) and btn(3) then
		buffalox-=3
		buffaloy+=3
		buffaloflipx=false
		buffalomoveanimation()
 	elseif btn(3) and btn(1) then
		buffalox+=3
		buffaloy+=3
		buffaloflipx=true
		buffalomoveanimation()
 	elseif btn(1) and btn(2) then
		buffalox+=3
		buffaloy-=3
		buffaloflipx=true
		buffalomoveanimation()
	elseif btn(0) then
		buffalox-=3
		buffaloflipx=false
		buffalomoveanimation()
 	elseif btn(1) then
		buffalox+=3
		buffaloflipx=true
		buffalomoveanimation()
 	elseif btn(2) then
		buffaloy-=3
		buffalomoveanimation()
 	elseif btn(3) then
		buffaloy+=3
		buffalomoveanimation()
	end
	
	-- move buffalo across screen from leftmost to rightmost (and vice versa)
	if(buffalox<1) then
		buffalox=127
	elseif (buffalox>128) then
		buffalox = 1
	end

	if buffaloy<1 then
		buffaloy = 127
	elseif buffaloy>128 then
		buffaloy = 1
	end	
	
 end
 
 function buffalomoveanimation()
 	if buffalosprite==2 then
		buffalosprite=3
	elseif buffalosprite==3 then
		buffalosprite=2
	end
 end
 	
 -- eat grass
 function eatgrass()
	grasstracker = 0
 
    for x=1, grasscount do
		if buffalox+4>= grasses[x][1]  
		and buffalox<=(grasses[x][1] + 4)
		and buffaloy+4>= grasses[x][2] 
		and buffaloy<=(grasses[x][2] + 4) then
			sfx(0)
			score+=(1*scoremultiplier) -- increase grass consumed counter

			-- respawn grass automatically if flag is set to true
			if grassrespawn==true then
				grasses[x][1] = flr(rnd(120))
				grasses[x][2] = flr(rnd(120))
			-- remove grass from screen and from table rather than setting new position
			elseif grassrespawn==false then				
				for item in all(grasses) do
					if(item[1] == grasses[x][1]) 
					and(item[2] == grasses[x][2]) then
							-- delete the instance of the grass found and return
							del(grasses, item)
							grasscount = grasscount-1
							return
					end		
				end	
			end
		end
    end
 end
 

  -- check for collision with female buff and increaser multiplier
 function pickupfemale()
	if(showfemale==false) then
		return
	end
	
	if buffalox+4>= buffalofx  
	and buffalox<=(buffalofx + 4)
	and buffaloy+4>= buffalofy 
	and buffaloy<=(buffalofy + 4) then
		sfx(3)
		scoremultiplier+=1-- increase score multiplier
		showfemale=false
	end

 end
 
function extendtimer(extend)
	timelimit += extend
end

 function istimeleft()
 	if elapsedtime<timelimit then
		return true
	elseif elapsedtime>=timelimit then
		return false
	end
 end
 
 function ending()
	if endingplayed==false then
		sfx(2)
		endingplayed=true
	end
end
 
function _init()
  starttime = time()
  sfx(1)
  
  player={}
  player.frame=17
  player.step=0
  
  
  setleveldetails(10,1,false)
  buildfemale(80,80,1,42,42,"lurd")
  loadlevel1()
  

	
 
	--setleveldetails(5,7,false)
	--buildfemale(16,20,2,68,68,"")
	--loadlevel7()


end

function setleveldetails(extend, lv, gspawn)
	grasses = {}
	grasscount = 0
	extendtimer(extend)
	grassrespawn = gspawn
	level = lv
	showfemale = false -- reset female flag
end

function fillgrasscount()
	grasscount = 0
	for item in all(grasses) do
		grasscount = grasscount + 1
	end	
end

--- level info start ---
function loadlevel7(extend)

	for i = 1, 7 do
		add(grasses, {0+8*i,68-8*i})
		add(grasses, {0+8*i,60+8*i})
		add(grasses, {120-8*i,68-8*i})
		add(grasses, {120-8*i,60+8*i})
	end

	fillgrasscount()
end

function loadlevel6(extend)

	for i = 0, 20 do
		add(grasses, {20 + flr(rnd(80)),20+ flr(rnd(80))})
	end	
	
	fillgrasscount()
end

function loadlevel5(extend)

	for row = 1, 6 do
	  for column = 1, 6 do
		add(grasses, {grasscreatex(row*16),grasscreatey(column*16)})
	  end
	end

	fillgrasscount()	
end

function loadlevel4(extend)

	for column = 0, 13 do
		add(grasses, {grasscreatex(8),grasscreatey(8+ column*8)})
	end

	for column = 1, 13 do
		add(grasses, {grasscreatex(120),grasscreatey(8+ column*8)})
	end

	for row = 1, 14 do
		add(grasses, {grasscreatex(8 + row*8),grasscreatey(8)})
	end

	for row =0, 14 do
		add(grasses, {grasscreatex(8 + row*8),grasscreatey(119)})
	end	
	
	fillgrasscount()	
end

function loadlevel3(extend)

	for row = 1, 3 do
	  for column = 1, 8 do
		add(grasses, {grasscreatex(22+ column*8),grasscreatey(row*16 + 32)})
	  end
	end

	fillgrasscount()	
end

function loadlevel2(extend)	
	
	for column = 1, 7 do
	  for row = 1, 2 do
		add(grasses, {grasscreatex(20+ row*24),grasscreatey(column*16)})
	  end
	end
	
	fillgrasscount()	
end

function loadlevel1(extend)	
	
	for row = 1, 4 do
	  for column = 1, 4 do
		add(grasses, {grasscreatex(40+ row*8),grasscreatey(40+ column*8)})
	  end
	end
	
	fillgrasscount()	
end

function leveldetails()
	print("level",65,1,7)
	print(level,105,1,7)
	--print("grass left",65,9,7)
	--print(grasscount,120,9,7)	
end 

function drawleveldetails()

				
	if level==1 then
		if grasscount==0 then
			setleveldetails(5,2,false) 
			loadlevel2()
		end
	elseif level==2 then
		if grasscount==0 then
			setleveldetails(5,3,false)
			loadlevel3()
		end
	elseif level==3 then
		if grasscount==0 then
			setleveldetails(5,4,false)
			buildfemale(112,15,2,48,48,"ldru")
			loadlevel4()
		end	
	elseif level==4 then
		if grasscount==0 then
			setleveldetails(5,5,false)
			loadlevel5()
		end
	elseif level==5 then
		if grasscount==0 then
			setleveldetails(5,6,false)
			loadlevel6()
		end	
	elseif level==6 then
		if grasscount==0 then
			setleveldetails(5,7,false)
			loadlevel7()
		end			
	elseif level==7 then
		if grasscount==0 then
			setleveldetails(5,1,false)
			--buildfemale(112,15,2,48,48,"ldru")
			buildfemale(80,80,1,42,42,"lurd")
			loadlevel1()
		end			
	end	
	
end
--- level info end

-- returns the sprite id to show, based on a 0 to x sprite 
-- list index where the first sprite is at position
function getspriteframe(framespersecond, startsprite, totalsprites)
	if(startsprite==null) then
		startsprite=0
	end
	if(totalsprites==null) then
		totalsprites=0
	end

	frame = flr(flr(elapsedtime*framespersecond)%framespersecond)
	frame = flr(frame%totalsprites)
	return (frame+startsprite)
end

 function _update()
 	if istimeleft()==true then
		movebuffalo()
		pickupfemale()
		movefemalebuffalo()
		eatgrass()
		elapsedtime = time()-starttime
		
		--debugitem1 = getspriteframe(2,1,2)
		--debugitem2 = getspriteframe(3,5,2)
		--debugitem3 = getspriteframe(4,50)
		--debugitem3 = flr(flr(elapsedtime*8)%8)
		--framespersecond
	elseif istimeleft()==false then
		ending()
	end
 end
 
 
 function _draw()
  --clear the screen
  rectfill(0,0,128,128,0)
   
  -- draw the buffalo
  drawbuffalo()
  drawfemalebuffalo()
  
  --draw the grass
  drawgrass()
  
  -- draw the score
  drawscore()
  
  -- draw the time
  drawtime()
  
  -- draw the leve details
  drawleveldetails()
  
  -- debugger
  --print(debugitem1,1,90,7)
  --print(debugitem2,1,98,7)
  --print(debugitem3,1,106,7)
  
 end 
 
function drawgrass()	
  
  for x=1, grasscount do
	spr(getspriteframe(8,17,3),grasses[x][1],grasses[x][2])
  end
end

 function drawbuffalo()
	spr(buffalosprite,buffalox,buffaloy,1,1,buffaloflipx)
 end
 
 function drawfemalebuffalo()
	if(showfemale == true) then
		spr(getspriteframe(8,buffalofsprite,2),buffalofx,buffalofy,1,1,buffalofflipx)
	end
 end
 

 function drawscore()
	print("grass consumed",1,1,15)
	print(score,1,9,15)
	
	if(scoremultiplier>1) then
		print(scoremultiplier,32-10,9,15)
		print("x",27-10,9,15)
	end
 end
 
 function drawtime()
	if istimeleft()==true then
		--print(gameplaytime-elapsedtime,30,9,7)
		print(timelimit-elapsedtime,90,110,7)
	elseif istimeleft()==false then
		--print("times up!",30,9,7)
		print("times up!",90,110,7)
	end
 end
 

 
 
 
 		