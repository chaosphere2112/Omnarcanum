require "sprite"


display.setStatusBar(display.HiddenStatusBar )
--[[local tile= sprite.newSpriteSheet("images/brick_tiles_1.png",32 , 32)
local sp=sprite.newSpriteSet(tile,1,1);
local sp2=sprite.newSprite(sp);
local q;
]]--

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
local map=display.newImage(mapstr..zonestr..room..ext,0,0,true )
map.x=160;
map.y=160;


--Acceleration trackers
local xaccel=0;
local yaccel=0;
local poll=0;



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
	--Map movement
	--Direction tracking
	--Spell casting
	--Spell interaction with objects

img = display.newImage("images/p1.png",160,240, true )
img.x=160;
img.y=240;

t=display.newText("ohai", 100,300, nil, 30)
t.rotation=90;
t2=display.newText("", 200,300,nil,30)
t2.rotation=90;
run = 0;
calx=0;
caly=0;

local buttonlistener = function (event)
	if (event.phase=="began")then
		b.isVisible=false;
		bd.isVisible=true;
	end
	if (event.phase=="ended") then
		run=0
		b.isVisible=true
		bd.isVisible=false
		img.x=160
		img.y=240
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
local poppp=0;
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
			if (x>0) then
				t.text="x>0"
			else
				t.text="x<=0"
			end
			if (img.x>display.contentWidth/2-5 and img.x<display.contentWidth/2+5 and map.x-15*x>map.width/2-display.contentWidth and map.x-15*x<map.width-display.contentWidth) then
				map.x=map.x-15*x
				img.x=display.contentWidth/2
			else
				if(img.x+15*x>0 and img.x+15*x<display.contentWidth) then
					img.x=img.x+15*x
				end
			end
			t2.text=math.floor(map.x)..""

		else
			--BOUNDARY FOR LEFT SIDE NEEDED
			if (map.y+10*y > map.height-display.contentHeight) then
				map.y=map.y+10*y
			end
			t.text=math.floor(map.y+10*y)
			t2.text=math.floor(map.y)
		end
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
