maps = {}

function maps.new(name)
	local mapFile = assert(love.filesystem.read("media/maps/" .. name .. ".lua"))
	local mapTable = assert(loadstring(mapFile))()

	for i, tileset in ipairs(mapTable.tilesets) do
		tileset._imageObject = newImage("media/images/" .. tileset.image)

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

	local tileset = mapTable.tilesets[1]
	for i, layer in ipairs(mapTable.layers) do
		if layer.visible then
			if layer.type == "tilelayer" then
				layer._spriteBatch = love.graphics.newSpriteBatch(tileset._imageObject, const.maps.MAX_SPRITES, "static")
				local index = 1
				for y = 1, layer.height do
					for x = 1, layer.width do
						local tileIndex = layer.data[index]
						index = index + 1
						if tileIndex > 0 then
							layer._spriteBatch:setColor(255, 255, 255, 255)
							if tileIndex == 28 then
								local h = love.math.random(200, 255)
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

	return mapTable
end

function maps.draw(map)
	for i, layer in ipairs(map.layers) do
		if layer._spriteBatch then
			love.graphics.draw(layer._spriteBatch)
		end
	end
end