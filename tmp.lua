io.input("images/maps/1.rconfig")
while true do
	local a=io.read("*line")
	if (a==nil) then
		print("End of file")
		break
	end
	_, _, d,n, m = string.find(a, "(%w+)%s*(%w+)%s*=%s*(%w+)")
	print(d,n, m)  --> 17  7  1990
end
