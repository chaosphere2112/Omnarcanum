require "sprite"

system.setIdleTimer(false)

display.setStatusBar(display.HiddenStatusBar )

local esprite=sprite.newSpriteSheet("images/elespritesheet",32,32)
local e=sprite.newSpriteSet(esprite,1,9)
local spell ={}
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
local fuse={}
local first=true
local curobj;
local curtab;
local highestspell=0;

local function blocked(obj1, obj2)
	local table={};
	table[1]=obj1.x-obj1.width/2-obj2.x-obj2.width/2
	table[2]=obj1.x+obj1.width/2-obj2.x+obj2.width/2
	table[3]=obj1.y-obj1.height/2-obj2.y-obj2.height/2
	table[4]=obj1.y+obj1.height/2-(obj2.y-obj2.height/2)
	local closest=1;
	local i,v
	for i,v in ipairs(table) do
		if (math.abs(v) < math.abs(table[closest])) then
			closest=i
		end
	end
	--1: left blocked
	--2: right blocked
	--3: down blocked
	--4: up blocked
	return closest
end



local function postburn(obj)
	obj.isVisible=false;
	if(obj.ind<#fuse[obj.tind]) then
		transition.to(fuse[obj.tind][obj.ind+1], {time=1000, alpha=0, onComplete=postburn})
	else
		--Blow up the boulders!
		local i,v
		for i,v in ipairs(obj.boom) do
			v.isVisible=false
		end
	end
end

local function parse(input)
	io.input(system.pathForFile(input))
	local linenum=0;
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

		if (obj=="fuse") then
			if (var=="tab") then
				fuse[tonumber(val)]={}
				curtab=tonumber(val)
			end
			if (var=="img") then
				local a=#fuse[curtab]+1
				fuse[curtab][a]=display.newImage("images/"..val,0,0,true)
				fuse[curtab][a].ind=a
				fuse[curtab][a].tind=curtab
				fuse[curtab][a].tname="fuse"
				fuse[curtab][a].boom={}
			end
			if (var=="X") then
				fuse[curtab][#fuse[curtab]].x=tonumber(val)+map.x
			end
			if (var=="Y") then
				fuse[curtab][#fuse[curtab]].y=tonumber(val)+map.y
			end
		end
		
		if (obj=="object") then
			if (var=="img") then
				curobj=#objects+1
				objects[curobj]=display.newImage("images/"..val, 0,0,true)
				objects[curobj].tname="objects"
				objects[curobj].ind=curobj
				objects[curobj].fire=false
				objects[curobj].ice=false
				objects[curobj].water=false
				objects[curobj].light=false
				objects[curobj].earth=false
				objects[curobj].metal=false
				objects[curobj].nat=false
				objects[curobj].air=false
			end

			if (var=="explode") then
				local last=fuse[tonumber(val)][#fuse[tonumber(val)]]
				last.boom[#last.boom+1]=objects[curobj]
			end

			if (var=="X") then
				objects[curobj].x=tonumber(val)+map.x
			end
			if (var=="Y") then
				objects[curobj].y=tonumber(val)+map.y
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
				walls[obj].alpha=.8
				walls[obj].ind=obj
				walls[obj].tname="walls"
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
local zonestr="fire_";
	--Current room number- starts with 1.
local room=1;
	--Convenience string.
local ext=".png";


--Now whenever we load a map, the file will be mapstr..zonestr..room..ext  (See how clever I am?)
--Default the location to 0,0, then move it based on width so that it's appropriately located.
map=display.newImage(mapstr..zonestr..room..ext,0,0,true )

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
local elements={};
for q=1, 4, 1 do
	cards[q]=display.newImage("images/Card.png",64, 96,true);
	elements[q]=sprite.newSprite(e)
end


cards[1].y=32;
cards[2].y=32;
cards[3].y=display.contentHeight - 32
cards[4].y=display.contentHeight-32
cards[1].x=48
cards[2].x=display.contentWidth-48
cards[3].x=display.contentWidth-48
cards[4].x=48

elements[1].y=cards[1].y
elements[1].x=cards[1].x

elements[2].y=cards[2].y
elements[2].x=cards[2].x

elements[3].y=cards[3].y
elements[3].x=cards[3].x

elements[4].y=cards[4].y
elements[4].x=cards[4].x

b=display.newImage("images/Button.png",200,300, true)
bd=display.newImage("images/ButtonDown.png",200,300, false)
bd.isVisible=false;



--[[
img = display.newImage("images/p1.png",160,240, true )
img.x=160;
img.y=240;
]]--
parse(mapstr..room..".rconfig")
t=display.newText("", 100,300, nil, 30)
t.rotation=90;
t2=display.newText("", 200,300,nil,30)
t2.rotation=90;
run = 0;
calx=0;
caly=0;

--"Struct" to keep track of the indices of each element.  Syntax sugar for lightning.
local Element={}
Element.fire=1
Element.air=2
Element.water=3
Element.metal=4
Element.nature=5
Element.light=6 --Because typing too much is bad...
Element.lightning=6 --But sometimes I forget things.
Element.ice=7
Element.earth=8
Element.null=9
Element[1]="fire"
Element[2]="air"
Element[3]="water"
Element[4]="metal"
Element[5]="nature"
Element[6]="lightning"
Element[7]="ice"
Element[8]="earth"
Element[9]="null"

--So, suggested use is: element.currentFrame=Element["elename"]

cards[1]:toFront()
cards[2]:toFront()
cards[3]:toFront()
cards[4]:toFront()
elements[1]:toFront()
elements[2]:toFront()
elements[3]:toFront()
elements[4]:toFront()



player:toFront()
--img:toFront()
local removeObject= function(obj)
	if (obj~=nil) then
		if (obj.tname=="spell") then
			spell[obj.ind]=nil
		end
		obj:removeSelf();
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

local function mapOverlap(set, player)
--Split the map in half
--Split the set into things to the left and right of the map
	local table={}
	for i,v in ipairs(set) do
		if (overlap(player,v)) then
			table[#table+1]=v
		end
	end
	return table
end

local function movecheck(x,y)
	--Compare with walls
	--Compare with objects
	local i,v
	local hitTable={}
	local l=1;
	for i,v in ipairs(walls) do
		hitTable[i]=v;
		l=l+1;
	end
	for i,v in ipairs(objects) do
		if (v.isVisible==true) then
			hitTable[l]=v
			l=l+1
		end
	end
	local hitCheck=mapOverlap(hitTable,player)
	if (hitCheck~={}) then
		for i,v in ipairs(hitCheck) do
			local blockcheck=blocked(player,v)
			if (blockcheck==1) then
				if (x<0) then
					--t.text="down blocked by "..v.tname..v.ind
					return false
				end
			else
				if (blockcheck==2) then
					if (x>0) then
						--t.text="up blocked by "..v.tname..v.ind
						return false
					end
				else
					if (blockcheck==3) then
						if (y>0) then
							--t.text="left blocked by "..v.tname..v.ind
							return false
						end
					else
						if (y<0) then
							--t.text="right blocked by "..v.tname..v.ind
							return false
						end
					end
				end
			end
		end
		return true
	else
		return true
	end
end




local function update()
	if (poll>0) then
		local x=xaccel/poll;
		if (math.abs(x)<.07)then
			x=0;
		end
		local y=yaccel/poll;
		if (math.abs(y)<.07)then
			y=0;
		end	
		if (math.abs(x)>math.abs(y)) then
			y=0
			--If the movement is within the bounds of the map, move the map
			--If the movement is within the bounds of the screen, move the character
			local move=false
			local movedImg;
			if (player.x>display.contentWidth/2-5 and player.x<display.contentWidth/2+5 and map.x-15*x+map.width/2>display.contentWidth and map.x-15*x-map.width/2<0) then
				player.x=display.contentWidth/2
				movedImg=map
				move=true
			else
				if((x<0 and player.x+15*x-player.width/2>0) or (x>0 and player.x+15*x+player.width/2<display.contentWidth)) then
					movedImg=player
					move=true
				end
			end
			
			move=movecheck(x,y);
			
			if (move) then
				if (movedImg==player) then
					movedImg:translate(math.floor(15*x), 0)
					if(x>0) then
						direction=1;
						player.currentFrame=3
					else
						direction=3
						player.currentFrame=1
					end
				else
					movedImg:translate(math.floor(-15*x),0)
					exit:translate(math.floor(-15*x),0)
					for q=1,#walls, 1 do
						walls[q]:translate(math.floor(-15*x),0)
					end
					local ix,vx
					for ix,vx in ipairs(fuse) do
						local iy,vy
						for iy,vy in ipairs(vx) do
							vy:translate(math.floor(-15*x),0)
						end
					end
					for q=1,#objects,1 do
						objects[q]:translate(math.floor(-15*x),0)
					end
					if (x>0) then
						direction=1;
						player.currentFrame=3
					else
						direction=3;
						player.currentFrame=1
					end
				end
			end
		else
			x=0
			local move=false
			local movedImg=map;
			if (player.y>display.contentHeight/2-5 and player.y<display.contentHeight/2+5 and map.y+10*y+map.height/2>display.contentHeight and map.y+10*y-map.height/2<0) then
				player.y=display.contentHeight/2
				movedImg=map
				move=true
			else
				if((y<0 and player.y-10*y-player.height/2>0) or (y>0 and player.y-10*y+player.height/2<display.contentHeight)) then
					movedImg=player
					move=true
				end
			end
			
			move=movecheck(x,y)
			if (move) then
				if (movedImg==player) then
					movedImg:translate(0,math.floor(-10*y))
					if(y>0) then
						direction=2;
						player.currentFrame=4
					else
						direction=4
						player.currentFrame=2
					end
				else
					movedImg:translate(0, math.floor(10*y))
					exit:translate(0,math.floor(10*y) )
					local ix,vx
					for ix,vx in ipairs(fuse) do
						local iy,vy
						for iy,vy in ipairs(vx) do
							vy:translate(0,math.floor(10*y))
						end
					end
					for q=1,#walls, 1 do
						walls[q]:translate(0,math.floor(10*y))
					end

					for q=1,#objects, 1 do
						objects[q]:translate(0,math.floor(10*y))
					end

					if (y>0) then
						direction=2;
						player.currentFrame=4
					else
						direction=4;
						player.currentFrame=2
					end
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
	local v=1
	for v=1,highestspell,1 do
		if(spell[v]) then
			if (spell[v].isVisible==true) then
				local hittable={};
				local ind=1;
				for i2,v2 in ipairs(objects) do
					if (v2.isVisible==true) then
						hittable[ind]=v2
						ind=ind+1;
					end
				end
				for i2,v2 in ipairs(fuse) do
					if (v2[1].isVisible==true) then
						hittable[ind]=v2[1];
						ind=ind+1;
					end
				end
				local hit=mapOverlap(hittable, spell[v])
				if (hit~={}) then
					for i3,v3 in ipairs(hit) do
						if (v3.tname=="fuse") then
							transition.to(v3, {time=1000, alpha=0, onComplete=postburn})
						else
							if (v3.tname=="objects") then
								if (spell[i].ele==Element.fire and v3.fire==true) then
									v3.isVisible=false;
								end
							end
						end
						spell[v].isVisible=false
					end
				end
			end
		end
	end
	
	xaccel=0;
	yaccel=0;
	poll=0;
end


local shoot1=function (event)
	if (event.phase=="ended") then
		local i=#spell+1
		if (elements[1].currentFrame==Element.fire) then
			spell[i]=display.newImage("images/fireball1.png",0,0)
			spell[i].ele=Element.fire;
			spell[i].x=player.x
			spell[i].y=player.y
			local xd=player.x
			local yd=player.y
			if (direction==1) then
				spell[i].rotation=-90
				xd=player.x+400
			else if (direction==2) then
					spell[i].rotation=180
					yd=player.y-400
				else if (direction==3) then
						spell[i].rotation=90
						xd=player.x-400
					else if (direction==4) then
							spell[i].rotation=0
							yd=player.y+400
						end
					end
				end	
			end
			spell[i].tname="spell"
			spell[i].ind=i
			transition.to(spell[i], {time=1000, x=xd, y=yd, alpha=0, onComplete=removeObject})
			if(i>highestspell) then
				highestspell=i
			end
		end
	end
end
local shoot2=function (event)
	if (event.phase=="ended") then
		local i=#spell+1
		if (elements[2].currentFrame==Element.fire) then
			spell[i]=display.newImage("images/fireball1.png",0,0)
			
			spell[i].ele=Element.fire;
			spell[i].x=player.x
			spell[i].y=player.y
			local xd=player.x
			local yd=player.y
			if (direction==1) then
				spell[i].rotation=-90
				xd=player.x+400
			else if (direction==2) then
					spell[i].rotation=180
					yd=player.y-400
				else if (direction==3) then
						spell[i].rotation=90
						xd=player.x-400
					else if (direction==4) then
							spell[i].rotation=0
							yd=player.y+400
						end
					end
				end	
			end
			spell[i].tname="spell"
			spell[i].ind=i
			transition.to(spell[i], {time=1000,x=xd, y=yd, alpha=0,onComplete=removeObject})
			if(i>highestspell) then
				highestspell=i
			end
		end
	end
end
local shoot3=function (event)
	if (event.phase=="ended") then
		local i=#spell+1
		if (elements[3].currentFrame==Element.fire) then
			spell[i]=display.newImage("images/fireball1.png",0,0)
			spell[i].x=player.x
			spell[i].y=player.y
			spell[i].ele=Element.fire;
			local xd=player.x
			local yd=player.y
			if (direction==1) then
				spell[i].rotation=-90
				xd=player.x+400
			else if (direction==2) then
					spell[i].rotation=180
					yd=player.y-400
				else if (direction==3) then
						spell[i].rotation=90
						xd=player.x-400
					else if (direction==4) then
							spell[i].rotation=0
							yd=player.y+400
						end
					end
				end	
			end
			spell[i].tname="spell"
			spell[i].ind=i
			transition.to(spell[i], {time=1000,x=xd, y=yd, alpha=0,onComplete=removeObject})
			if(i>highestspell) then
				highestspell=#spell
			end
		end
	end
end
local shoot4=function (event)
	if (event.phase=="ended") then
		local i=#spell+1
		if (elements[4].currentFrame==Element.fire) then
			spell[i]=display.newImage("images/fireball1.png",0,0)
			spell[i].x=player.x
			spell[i].y=player.y
			spell[i].ele=Element.fire;
			local xd=player.x
			local yd=player.y
			if (direction==1) then
				spell[i].rotation=-90
				xd=player.x+400
			else if (direction==2) then
					spell[i].rotation=180
					yd=player.y-400
				else if (direction==3) then
						spell[i].rotation=90
						xd=player.x-400
					else if (direction==4) then
							spell[i].rotation=0
							yd=player.y+400
						end
					end
				end	
			end
			spell[i].tname="spell"
			spell[i].ind=i
			transition.to(spell[i], {time=1000,x=xd, y=yd, alpha=0,onComplete=removeObject})
			if(i>highestspell) then
				highestspell=#spell
			end
		end
	end
end

cards[1]:addEventListener("touch",shoot1)
cards[2]:addEventListener("touch",shoot2)
cards[3]:addEventListener("touch",shoot3)
cards[4]:addEventListener("touch",shoot4)

bd:addEventListener("touch",buttonlistener)
b:addEventListener("touch", buttonlistener)
system.setAccelerometerInterval(60)
Runtime:addEventListener("accelerometer", myListener)
timer.performWithDelay(33, update, 0);
