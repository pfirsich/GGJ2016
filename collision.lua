collision = {}

function collision.collides(shape)
	local bounds = shape.data
	if shape.type == "circle" then
		bounds = {	shape.data.center[1] - shape.data.radius, shape.data.center[2] - shape.data.radius,
					shape.data.center[1] + shape.data.radius, shape.data.center[2] + shape.data.radius, }
	end

	local mtvs = {}
	local startX, startY = worldToTiles(bounds[1], bounds[2])
	local endX, endY = worldToTiles(bounds[3], bounds[4])
	for y = startY, endY do
		for x = startX, endX do
			local tile = map.layers[1].tileMap[y][x]
			if tile >= 1 and tile <= 26 then
				local mtv = _aabbCollision(shape.data, {x*map._tilesize, y*map._tilesize, (x+1)*map._tilesize, (y+1)*map.tilesize})
				if mtv then
					table.insert(mtvs, mtv)
				end
			end
		end
	end

	return mtvs
end

function _intervalOverlap(A, B) -- interval: {left, right}
	-- they dont overlap if left_B > right_A or right_B < left_A
	-- negate: left_B <= right_A and right_B >= left_A
	return A[1] <= B[2] and B[1] <= A[2]
end

function _aabbCollision(A, B) -- box = {{topleftx, toplefty}, {sizex, sizey}}
	-- returns the MTV (minimal translation vector to resolve the collision) for the shape A if there is a collision, otherwise nil

	if  intervalsOverlap({A[1], A[3]}, {B[1], B[3]})
    and intervalsOverlap({A[2], A[4]}, {B[2], B[4]}) then
        local yOverlap = 0
		local yMTVSign = 1
		if A[4] - B[2] < B[4] - A[2] then
			yOverlap = A[4] - B[2]
			yMTVSign = -1
		else
			yOverlap = B[4] - A[2]
			yMTVSign = 1
		end

        return {0.0, math.max(0, yOverlap) * yMTVSign}
	else
		return nil
	end
end

function castRayIntoMap(ray)
	local cur = vret(ray[1])
	local dir = vsub(ray[2], ray[1])

	if vdot(dir, dir) > 1 then
		local dcur = vmul(vnormed(dir), tileSize * 0.9)

		while cur[1] > 0 and cur[1] < map.width*map.tileSize and cur[2] > 0 and cur[2] < map.height*map.tileSize do
			local c = {worldToTiles(cur)}
			local tile = map.tileLayers[1].data[c[2]][c[1]].tileIndex
			if tile == SOLID_BLOCK_TILE or tile == DOOR_BLOCK_TILE then
				return cur
			end
			cur = vadd(cur, dcur)
		end
	end
	return cur
end