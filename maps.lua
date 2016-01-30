map = nil

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

	local tileset = map.tilesets[1]
	for i, layer in ipairs(map.layers) do
		if layer.visible then
			if layer.type == "tilelayer" then
				map.width = layer.width
				map.height = layer.height

				layer._spriteBatch = love.graphics.newSpriteBatch(tileset._imageObject, const.maps.MAX_SPRITES, "static")
				local index = 1
				layer.tileMap = {}
				for y = 1, layer.height do
					layer.tileMap[y] = {}
					for x = 1, layer.width do
						local tileIndex = layer.data[index]
						index = index + 1
						layer.tileMap[y][x] = tileIndex
						if tileIndex > 0 then
							layer._spriteBatch:setColor(255, 255, 255, 255)
							if tileIndex == 28 then -- floor
								local h = love.math.random(175, 200)
								layer._spriteBatch:setColor(h, h, h, 255)
							end
							-- if index < 120 then print(tileIndex) end
							layer._spriteBatch:add(tileset._quads[tileIndex], x*tileset.tilewidth, y*tileset.tileheight)
						end
					end
				end
			end
		end
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