function ray_check(origin, angle)
	local xhits = {}
	local yhits = {}
	local xgrid = {}
	local ygrid = {}
	local slope = math.tan(angle)
	
	for i = 1, 200 do
		xhits[i] = {i*32, slope*i*32+origin[2] - origin[1]}
		--print(xhits[i][1].." "..xhits[i][2])

		yhits[i] = {(i*32 - origin[2])/slope + origin[1], i*32}
		--print(yhits[i][1].." "..yhits[i][2])
	end

end

--ray_check({1,1}, 1.4*math.pi) --raytest