io.input("images/maps/1.rconfig")
local a=io.read("*line")
i,b=string.find(a,"(%n+)%s*(%a+)=(%a+)")
print(i)
print(b)
