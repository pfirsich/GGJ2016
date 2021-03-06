map = nil

function tileIndexIsFloor(index)
	return index >= 35 and index <= 40
end

function loadMap(name)
	local mapFile = assert(love.filesystem.read("media/maps/" .. name .. ".lua"))
	map = assert(loadstring(mapFile))()

	for i, tileset in ipairs(map.tilesets) do
		tileset._imageObject = newImage("media/maps/" .. tileset.image)

		tileset._tilesize = tileset.tilewidth
		tileset._tileCountX = tileset.imagewidth / tileset.tilewidth
		tileset._tileCountY = tileset.imageheight / tileset.tileheight
		tileset._quads = {}
		for y = 0, tileset.imageheight - tileset.tileheight, tileset.tileheight do
			for x = 0, tileset.imagewidth - tileset.tilewidth, tileset.tilewidth do
				-- print(x, y, tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight)
				table.insert(tileset._quads, love.graphics.newQuad(x, y, tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight))
			end
		end
	end

	for i = 1, #enemies do
		table.remove(enemies)
	end

	for i = 1, #objects do
		table.remove(objects)
	end

	local tileset = map.tilesets[1]
	for i, layer in ipairs(map.layers) do
		if layer.visible then
			if layer.type == "tilelayer" then
				map.width = layer.width
				map.height = layer.height

				layer._spriteBatch = love.graphics.newSpriteBatch(tileset._imageObject, const.maps.MAX_SPRITES, "static")
				local index = 1
				layer.tileMap = {}
				layer.solid = {}
				for y = 1, layer.height do
					layer.tileMap[y] = {}
					layer.solid[y] = {}
					for x = 1, layer.width do
						local tileIndex = layer.data[index]
						index = index + 1
						layer.tileMap[y][x] = tileIndex
						layer.solid[y][x] = tileIndex > 0 and (tileIndex <= 34 or tileIndex > 40)
						if tileIndex > 0 then
							layer._spriteBatch:setColor(255, 255, 255, 255)
							if tileIndexIsFloor(tileIndex) then -- floor
								local h = love.math.random(175, 200)
								layer._spriteBatch:setColor(h, h, h, 255)
							end
							-- if index < 120 then print(tileIndex) end
							layer._spriteBatch:add(tileset._quads[tileIndex], x*tileset.tilewidth, y*tileset.tileheight)
						end
					end
				end
			end

			map.spawns = {}
			if layer.type == "objectgroup" then
				for i, mapObject in ipairs(layer.objects) do
					if mapObject.visible then
						if mapObject.type == "door" then
							local object = newObject(mapObject.type)
							local tx, ty = worldToTiles(mapObject.x, mapObject.y)
							object.position = {tx * const.TILESIZE, ty * const.TILESIZE}
							object.tiles = {{tx, ty}}
							if mapObject.height > mapObject.width then
								object.angle = object.angle + math.pi/2.0
								object.position[1] = object.position[1] + 0.5 * const.TILESIZE
								object.offset[2] = 0.5
								table.insert(object.tiles, {tx, ty+1})
								object.horizontal = true
							else
								object.angle = 0
								object.position[2] = object.position[2] + 0.5 * const.TILESIZE
								object.offset[2] = 0.5
								table.insert(object.tiles, {tx+1, ty})
								object.horizontal = true
							end

							object.doorNormal = vortho(vpolar(object.angle, 1.0))
							object:updateTiles()
						end

						if mapObject.type == "vase" then
							local object = newObject(mapObject.type)
							local tx, ty = worldToTiles(mapObject.x, mapObject.y)
							object.position = {tx * const.TILESIZE, ty * const.TILESIZE}

						end

						if mapObject.type == "bathtub" then
							local object = newObject(mapObject.type)
							local tx, ty = worldToTiles(mapObject.x, mapObject.y)
							object.position = {tx * const.TILESIZE, ty * const.TILESIZE}

						end

						if mapObject.type == "table" then
							local object = newObject("tableq")
							local tx, ty = worldToTiles(mapObject.x, mapObject.y)
							object.position = {tx * const.TILESIZE, ty * const.TILESIZE}

						end

						if mapObject.type == "blonde" then
							local object = newObject("blond")
							local tx, ty = worldToTiles(mapObject.x, mapObject.y)
							object.position = {tx * const.TILESIZE, ty * const.TILESIZE}

						end

						if mapObject.type == "black" then
							local object = newObject(mapObject.type)
							local tx, ty = worldToTiles(mapObject.x, mapObject.y)
							object.position = {tx * const.TILESIZE, ty * const.TILESIZE}
						end

						if mapObject.type == "spawn" then
							local tx, ty = worldToTiles(mapObject.x, mapObject.y)
							table.insert(map.spawns, {(tx+0.5)*const.TILESIZE, (ty+0.5)*const.TILESIZE})
						end

						if mapObject.type == "enemy" then
							if mapObject.properties.type == "roomba" then
								local enemy = enemies.new("roomba")
								enemy.position = {mapObject.x, mapObject.y}
								enemy.angle = love.math.random() * 2.0 * math.pi
							elseif mapObject.properties.type == "transrapid" then
								if mapObject.polyline then
									local enemy = enemies.new("transrapid")
									enemy.path = {}
									for j, point in ipairs(mapObject.polyline) do
										table.insert(enemy.path, {point.x + mapObject.x + const.TILESIZE, point.y + mapObject.y + const.TILESIZE})
									end

									enemy.forward = true

									enemy.position = enemy.path[1]
									enemy.angle = 0
								else
									error("no polyline for transrapid")
								end
							end
						end
					end
				end
			end

			arrayShuffle(map.spawns)
		end
	end

	for i = 1, #players do
		players[i].position = table.remove(map.spawns)
		players.refresh(players[i])
	end
end

function drawMap()
	for i, layer in ipairs(map.layers) do
		if layer._spriteBatch then
			love.graphics.draw(layer._spriteBatch)
		end
	end
end

function worldToTiles(x, y)
	return math.floor(x / map.tilewidth) + 1, math.floor(y / map.tileheight) + 1
end