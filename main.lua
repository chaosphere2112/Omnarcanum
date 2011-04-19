require "sprite"

system.setIdleTimer(false)

display.setStatusBar(display.HiddenStatusBar )

local psprite= sprite.newSpriteSheet("images/playerss1.png",32,32)
local p =sprite.newSpriteSet(psprite,1,4);
local player={};
player=sprite.newSprite(p)
player.x=160
player.y=160
local objects={};
local direction;
local walls={}
local exit={}
local entrance={}
local map={}
local img={}
local first=true
local curobj;
local function parse(input)
	io.input(system.pathForFile(input))
	while true do
		local a=io.read("*line")
		if (a==nil) then
			print("End of input")
			break
		end

		_,_,obj,var,val = string.find(a,"(%w+)%s*(%w+)%s*=%s*(-?%w+%.?%w*)")
		if (obj=="room") then
			if (var=="X") then
				map.x=tonumber(val)+map.width/2
			end

			if (var=="Y") then
				map.y=tonumber(val)+map.height/2
			end
		end
		
		if (obj=="object") then
			if (var=="img") then
				curobj=#objects+1
				objects[curobj]=display.newImage("images/"..val, 0,0,true)

				objects[curobj].fire=false
				objects[curobj].ice=false
				objects[curobj].water=false
				objects[curobj].light=false
				objects[curobj].earth=false
				objects[curobj].metal=false
				objects[curobj].nat=false
				objects[curobj].air=false
			end
			if (var=="X") then
				objects[curobj].x=tonumber(val)	
			end
			if (var=="Y") then
				objects[curobj].y=tonumber(val)
			end
			if (var=="fire") then
				objects[curobj].fire=true;
			end
			if (var=="ice") then
				objects[curobj].ice=true;
			end
			if (var=="light") then
				objects[curobj].light=true;
			end
			if (var=="air") then
				objects[curobj].air=true;
			end
			if(var=="water") then
				objects[curboj].water=true;
			end
			if(var=="earth") then
				objects[curobj].earth=true
			end
			if (var=="metal") then
				objects[curobj].metal=true;
			end
			if (var=="nat") then
				objects[curobj].nat=true;
			end
		end

		if (obj=="entrance") then
			if (var=="X") then
				if (first==true) then
					player.x=tonumber(val)
				else
					transition.to(player, {time=1500, x=tonumber(val)})
				end
			end
			if (var=="Y") then
				if (first==true) then
					first=false
					player.y=tonumber(val)
				else
					transition.to(player, {time=1500, y=tonumber(val)})
				end
			end
			if (var=="dir") then
				direction=tonumber(val)
				player.currentFrame=(tonumber(val))
			end
		end
		if (obj=="exit") then
			if (var=="X") then
				exit.x=tonumber(val)+map.x
			end
			if (var=="Y") then
				exit.y=tonumber(val)+map.y
			end
			if (var=="W") then
				exit.width=tonumber(val)
			end
			if (var=="H") then
				exit.height=tonumber(val)
			end
		end
		if (string.match(obj,"%d+")) then
			--Initialize the wall object with the index obj
			obj=tonumber(obj)
			if(walls[obj]==nil) then
				walls[obj]=display.newRect(0,0,0,0)
				walls[obj].isVisible=true
				walls[obj].alpha=.5
			end
			if (var=="X") then
				walls[obj].x=map.x+tonumber(val)
			end
			if (var=="Y") then
				walls[obj].y=map.y+tonumber(val)
			end
			if (var=="W") then
				walls[obj].width=tonumber(val)
			end
			if (var=="H") then
				walls[obj].height=tonumber(val)
			end
		end
	end
	io.input()
end


--Initialize info for Map loading
	--Base string of the map location
local mapstr="images/maps/";
	--The current zone- naming convention is zone_ROOM#.png
local zonestr="tut_";
	--Current room number- starts with 1.
local room=1;
	--Convenience string.
local ext=".png";


--Now whenever we load a map, the file will be mapstr..zonestr..room..ext  (See how clever I am?)
--Default the location to 0,0, then move it based on width so that it's appropriately located.
map=display.newImage(mapstr..zonestr..room..ext,0,0,true )
map.x=160;
map.y=160;


local old;


--Acceleration trackers
local xaccel=0;
local yaccel=0;
local poll=0;

exit=display.newRect(0,0,64,128)
exit.alpha=.5
--exit.isVisible=false;
exit.x=map.x+map.width/2-exit.width/2
exit.y=map.y+map.height/2-2*exit.height

local cards={};
for q=1, 4, 1 do
	cards[q]=display.newImage("images/Card.png",64, 96,true);
end


cards[1].y=32;
cards[2].y=32;
cards[3].y=display.contentHeight - 32
cards[4].y=display.contentHeight-32
cards[1].x=48
cards[2].x=display.contentWidth-48
cards[3].x=display.contentWidth-48
cards[4].x=48


b=display.newImage("images/Button.png",200,300, true)
bd=display.newImage("images/ButtonDown.png",200,300, false)
bd.isVisible=false;


--TO DO:
	--Spell casting
	--Spell interaction with objects

--[[
img = display.newImage("images/p1.png",160,240, true )
img.x=160;
img.y=240;
]]--
parse(mapstr..room..".rconfig")
t=display.newText("ohai", 100,300, nil, 30)
t.rotation=90;
t.text=exit.x..","..exit.y
t2=display.newText("", 200,300,nil,30)
t2.rotation=90;
run = 0;
calx=0;
caly=0;

player:toFront()
--img:toFront()
local removeObject= function(obj)
	if (obj~=nil) then
		obj:removeSelf()
	end
end

local buttonlistener = function (event)
	if (event.phase=="began")then
		b.isVisible=false;
		bd.isVisible=true;
	end
	if (event.phase=="ended") then
		run=0
		b.isVisible=true
		bd.isVisible=false
		player.x=160
		player.y=240
		meX=32*9;
		meY=32*9;
	end
	return true
end

local myListener = function (event)
	if (run==0) then
		calx=event.xGravity
		caly=event.yGravity
		run=1 
	end

	if (event.name == "accelerometer") then
		local x=event.xGravity
		local y=event.yGravity
		x=x-calx;
		y=y-caly;
		xaccel=xaccel+x;
		yaccel=yaccel+y;
		poll= poll+1;
	end
end

local function overlap(a, b)
	if (a.x+a.width/2>b.x-b.width/2 and a.x-a.width/2<b.x+b.width/2 and a.y+a.height/2>b.y-b.height/2 and a.y-a.height/2<b.y+b.height/2) then
		return true
	else
		return false
	end

end

local function update()
	if (poll>0) then
		local x=xaccel/poll;
		if (math.abs(x)<.01)then
			x=0;
		end
		local y=yaccel/poll;
		if (math.abs(y)<.01)then
			y=0;
		end	

		if (math.abs(x)>math.abs(y)) then
			--If the movement is within the bounds of the map, move the map
			--If the movement is within the bounds of the screen, move the character
			local mapmove=false
			if (player.x>display.contentWidth/2-5 and player.x<display.contentWidth/2+5 and map.x-15*x+map.width/2>display.contentWidth and map.x-15*x-map.width/2<0) then
				x=math.floor(-15*x)
				map:translate(x,0)
				exit:translate(x,0)
				local q
				for q=1,#walls,1 do
					walls[q]:translate(x,0)
				end
				player.x=display.contentWidth/2
				if (x>0) then
					direction=1;
				else
					direction=3;
				end
				mapmove=true
			else
				if((x<0 and player.x+15*x-player.width/2>0) or (x>0 and player.x+15*x+player.width/2<display.contentWidth)) then
					local wallcheck=false
					local q
					local qh
					for q=1,#walls,1 do
						if (overlap(player,walls[q]) and ((x>0 and player.x<walls[q].x) or (x<0 and player.x>walls[q].x))) then
							wallcheck=true
							t.text="Overlap with wall "..q
						end
					end
					if (wallcheck==false) then
						x=math.floor(15*x)
						player:translate(x,0)
					end
				end
			end

				if (x>0) then
					player.currentFrame=1
				else
					player.currentFrame=3
				end
				if (mapmove==false) then
					if(x>0) then
						player.currentFrame=3
					else
						player.currentFrame=1
					end
				end
		else
			local mapmove=false
			if (player.y>display.contentHeight/2-5 and player.y<display.contentHeight/2+5 and map.y+10*y+map.height/2>display.contentHeight and map.y+10*y-map.height/2<0) then
				y=math.floor(10*y)
				player.y=display.contentHeight/2
				map:translate(0,y)
				local q
				for q=1,#walls,1 do
					walls[q]:translate(0,y)
				end
				exit:translate(0,y)
				if (y>0)then
					direction=4;
				else
					direction=2;
				end
				t.text=direction
				mapmove=true
			else
				if ((y>0 and player.y-10*y-player.height/2>0) or (y<0 and player.y+10*y+player.height/2<display.contentHeight)) then
					local wallcheck=false
					local q
					local qh
					if (y>0) then
						direction=2
					else
						direction=4
					end
					for q=1,#walls,1 do
						--stuck in corners- Address this.
						if (overlap(player,walls[q]) and ((y>0 and player.y>walls[q].y) or (y<0 and player.y<walls[q].y))) then
							wallcheck=true
							qh=q
							t.text="Overlap with wall "..q
						end
					end
					if (wallcheck==false) then
						y=math.floor(-10*y)
						player:translate(0,y)
					end
				end
			end
			
				if (y>0) then
					player.currentFrame=4
				else
					player.currentFrame=2
				end
				if (mapmove==false) then
					if (y>0) then
						player.currentFrame=2
					else
						player.currentFrame=4
					end
				end
		end
	end
	if (overlap(player,exit))then
		old=map;
		transition.to(old, {time=750, alpha=0, onComplete=removeObject})
		room=room+1;
		map=display.newImage(mapstr..zonestr..room..ext,0,0,true)
		map.alpha=0;
		map.x=160
		map.y=160
		map:toBack()
		transition.to(map, {time=750, delay=750, alpha=1})
		parse(mapstr..room..".rconfig")
	end
	xaccel=0;
	yaccel=0;
	poll=0;
end

bd:addEventListener("touch",buttonlistener)
b:addEventListener("touch", buttonlistener)
system.setAccelerometerInterval(60)
Runtime:addEventListener("accelerometer", myListener)
timer.performWithDelay(33, update, 0);
