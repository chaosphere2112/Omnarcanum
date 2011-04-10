require "sprite"
t=display.newText("ohai", 100,300, nil, 30)
b=display.newImage("images/Button.png",200,300, true)
bd=display.newImage("images/ButtonDown.png",200,300, false)
bd.isVisible=false;
local tile= sprite.newSpriteSheet("images/brick_tiles_1.png",32 , 32)
local sp=sprite.newSpriteSet(tile,1,1);
local sp2=sprite.newSprite(sp);
local tilelist ={};
local q;
for q=1,12,1 do 
	local q2;
	tilelist[q]={}
	for q2=1,17,1 do
		tilelist[q][q2]=sprite.newSprite(sp);
		tilelist[q][q2].y=(q2-2)*32;
		tilelist[q][q2].x=(q-2)*32;
	end
end

img = display.newImage("images/p1.png",140,200, true )


sp2.x=200;
sp2.y=200;
t.text=sp2.x..","..sp2.y

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
		img.x=140
		img.y=200
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



		if (math.abs(x)>math.abs(y)) then
			for i,v in ipairs(tilelist) do
				for i2,v2 in ipairs(v) do
					v2.x=v2.x+15*x
					if (x<0) then
						v2:setReferencePoint(display.CenterLeftReferencePoint)
						if(v2.x<0) then
							tilelist[i-1][i2].x=tilelist[i-1][i2]+display.contentWidth
							t.setText("h");
						end
						v2:setReferencePoint(display.CenterReferencePoint)
					else
						v2:setReferencePoint(display.CenterRightReferencePoint)
						if (v2.x>display.contentWidth) then
							tilelist[i+1][i2].x=tilelist[i+1][i2]-display.contentWidth
							t.setText("H");
						end
						v2:setReferencePoint(display.CenterReferencePoint)
					end
				end
			end
		else
			for i,v in ipairs(tilelist) do
				for i2, v2 in ipairs(v) do
					v2.y=v2.y-10*y
				end
			end
		end

	end
end

local function update()
	
end

bd:addEventListener("touch",buttonlistener)
b:addEventListener("touch", buttonlistener)
system.setAccelerometerInterval(50)
Runtime:addEventListener("accelerometer", myListener)

