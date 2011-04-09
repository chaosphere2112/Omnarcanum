img = display.newImage("images/p1.png",140,200, true )
t=display.newText("ohai", 100,300, nil, 30)
run = 0;
calx=0;
caly=0;

local myListener = function (event)
	if (run==0) then
		calx=event.xGravity
		caly=event.yGravity
		t.text="cal is: "..calx..","..caly
		run=1;
	end
	if (event.name == "accelerometer") then
		local x=event.xGravity
		if (x>0) then
			x=x-calx;
		else
			x=x+calx;
		end
		local y=event.yGravity
		if (y>0) then
			y=y-caly;
		else
			y=y+caly;
		end
		
		if (math.abs(x)>math.abs(y)) then
			img.x=img.x+10*(x)	
		else
			img.y=img.y-10*(y)
		end
	end
end

system.setAccelerometerInterval(50)
Runtime:addEventListener("accelerometer", myListener)

