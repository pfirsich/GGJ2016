collision = {}

function getTileRanges(shape)
	local bounds = shape.data
	if shape.type == "circle" then
		-- aabbox = {startx, starty, endx, endy}
		bounds = {	shape.data.center[1] - shape.data.radius, shape.data.center[2] - shape.data.radius,
					shape.data.center[1] + shape.data.radius, shape.data.center[2] + shape.data.radius, }
	end

	local mtvs = {}
	local startX, startY = worldToTiles(bounds[1], bounds[2])
	startX, startY = clamp(startX - 1, 1, map.width), clamp(startY - 1, 1, map.height)
	local endX, endY = worldToTiles(bounds[3], bounds[4])
	endX, endY = clamp(endX + 1, 1, map.width), clamp(endY + 1, 1, map.height)

	return startX, endX, startY, endY
end

function collision.colliders(shape)
	local bounds = shape.data
	if shape.type == "circle" then
		-- aabbox = {startx, starty, endx, endy}
		bounds = {	shape.data.center[1] - shape.data.radius, shape.data.center[2] - shape.data.radius,
					shape.data.center[1] + shape.data.radius, shape.data.center[2] + shape.data.radius, }
	end

	local mtvs = {}
	local startX, startY = worldToTiles(bounds[1], bounds[2])
	startX, startY = clamp(startX, 1, map.width), clamp(startY, 1, map.height)
	local endX, endY = worldToTiles(bounds[3], bounds[4])
	endX, endY = clamp(endX, 1, map.width), clamp(endY, 1, map.height)
	local x, y = startX - 1, startY - 1

	return function()
		while y <= endY do
			y = y + 1
			while x <= endX do
				x = x + 1
				local tile = map.layers[1].tileMap[y][x]
				if tile >= 1 and tile <= 26 then
					local mtv = _aabbCollision(shape.data, {x*const.TILESIZE, y*const.TILESIZE, (x+1)*const.TILESIZE, (y+1)*const.TILESIZE})
					if mtv then
						return x, y, mtv
					end
				end
			end
			x = startX
		end

		return nil
	end
end

function _intervalsOverlap(A, B) -- interval: {left, right}
	-- they dont overlap if left_B > right_A or right_B < left_A
	-- negate: left_B <= right_A and right_B >= left_A
	return A[1] <= B[2] and B[1] <= A[2]
end

function _aabbCollision(A, B) -- box: {{xleft, xright}, {yleft, yright}}
	-- returns the MTV (minimal translation vector to resolve the collision) for the shape A if there is a collision, otherwise nil
	if  _intervalsOverlap({A[1], A[3]}, {B[1], B[3]})
    and _intervalsOverlap({A[2], A[4]}, {B[2], B[4]}) then
        local xOverlap = 0
		local xMTVSign = 1
		if A[3] - B[1] < B[3] - A[1] then
			xOverlap = A[3] - B[1]
			xMTVSign = -1
		else
			xOverlap = B[3] - A[1]
			xMTVSign = 1
		end

		local yOverlap = 0
		local yMTVSign = 1
		if A[4] - B[2] < B[4] - A[2] then
			yOverlap = A[4] - B[2]
			yMTVSign = -1
		else
			yOverlap = B[4] - A[2]
			yMTVSign = 1
		end

		if xOverlap < yOverlap then
			return {xOverlap * xMTVSign, 0.0}
		else
			return {0.0, yOverlap * yMTVSign}
		end
	else
		return nil
	end
end

function _circleAABBCollision(circle, aabb)
	local pCol = pointAABBMTV(circle[1], aabb)
	if pCol then
		local l = vnorm(pCol)
		return vmul(pCol, (l + circle[2]) / l)
	else
		local dist = 0
		local mtvs = {}
		for i = 1, 2 do
			if     circle[1][i] < aabb[i][1] then
				local d = aabb[i][1] - circle[1][i]
				dist = dist + d*d

				local mtv = {0,0}
				mtv[i] = mtv[i] - (circle[2] - d)
				table.insert(mtvs, mtv)
			elseif circle[1][i] > aabb[i][2] then
				local d = circle[1][i] - aabb[i][2]
				dist = dist + d*d

				local mtv = {0,0}
				mtv[i] = mtv[i] + (circle[2] - d)
				table.insert(mtvs, mtv)
			end
		end

		local minLength = math.huge
		local mtv = {0,0}
		for i = 1, #mtvs do
			local l = mtvs[i][1]*mtvs[i][1] + mtvs[i][2]*mtvs[i][2]
			if l < minLength then
				minLength = l
				mtv = mtvs[i]
			end
		end

		return dist <= circle[2] * circle[2] and mtv or nil
	end
end

-- function castRayIntoMap(ray)
-- 	local cur = vret(ray[1])
-- 	local dir = vsub(ray[2], ray[1])

-- 	if vdot(dir, dir) > 1 then
-- 		local dcur = vmul(vnormed(dir), const.TILESIZE * 0.9)

-- 		while cur[1] > 0 and cur[1] < map.width*const.TILESIZE and cur[2] > 0 and cur[2] < map.height*const.TILESIZE do
-- 			local c = {worldToTiles(unpack(cur))}
-- 			local tile = map.layers[1].tileMap[c[2]][c[1]]
-- 			if tile >= 1 and tile <= 26 then
-- 				return cur
-- 			end
-- 			cur = vadd(cur, dcur)
-- 		end
-- 	end
-- 	return cur
-- end

function getRayCastHelperValues(origin, dir)
	local tile = math.floor(origin / const.TILESIZE) + 1

	local step, tMax
	if dir > 0.0 then
		step = 1.0
		tMax = (const.TILESIZE*tile - origin) / dir -- maximal t (r = o + t*d) to hit next cell border
	else
		step = -1.0
		tMax = (origin - const.TILESIZE*(tile-1)) / -dir
	end
	if dir == 0 then tMax = math.huge end

	local tDelta = const.TILESIZE / dir * step -- cell width in units of t, * step to make it positive

	return tile, step, tMax, tDelta
end

function castRayIntoMap(ray)
	local rel = vsub(ray[2], ray[1])
	local x, xStep, tMaxX, tDeltaX = getRayCastHelperValues(ray[1][1], rel[1])
	local y, yStep, tMaxY, tDeltaY = getRayCastHelperValues(ray[1][2], rel[2])

	while x > 0 and x <= map.width and y > 0 and y <= map.height do
		local tile = map.layers[1].tileMap[y][x]
		if tile >= 1 and tile <= 26 then
			return {ray[1][1] + rel[1] * tMaxX, ray[1][2] + rel[2] * tMaxY}
		end

		if(tMaxX < tMaxY) then
			tMaxX = tMaxX + tDeltaX
			x = x + xStep
		else
			tMaxY = tMaxY + tDeltaY
			y = y + yStep
		end
	end
end

function castRayIntoMap(ray)
	local t = 0
	local x = ray[1][1]
	local y = ray[1][2]
	while x > 0 and x <= map.width*const.TILESIZE and y > 0 and y <= map.height*const.TILESIZE do
		local tx = math.floor(x / const.TILESIZE)
		local ty = math.floor(y / const.TILESIZE)

		local tile = map.layers[1].tileMap[y][x]
		if tile >= 1 and tile <= 26 then
			return {x, y}
		end

		local dt_x = ((tx + 1)*const.TILESIZE - x) / ray[2][1]
		local dt_y = ((ty + 1)*const.TILESIZE - y) / ray[2][2]

		if dt_x < dt_y then
			t = t + dt_x
		else
			t = t + dt_y
		end

		x = ray[1]
	end
end
