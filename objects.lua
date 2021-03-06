objects = {}

objectTypes = {
	door = {image = newImage("media/images/door_inside_vertical.png"), radius = TILESIZE*1.7, interactOffset = {const.TILESIZE, 0}, open = false, deadUntil = 0},
	-- storage = {imaage = newImage("media/images/")}
	-- light = {imaage = newImage("media/images/")}
	-- window = {imaage = newImage("media/images/")}
	-- crowbar = {imaage = newImage("media/images/")}
	-- knife = {imaage = newImage("media/images/")}
	-- baseball = {imaage = newImage("media/images/")}
	-- pistol = {imaage = newImage("media/images/")}
	-- painting = {imaage = newImage("media/images/")}
	vase = {image = newImage("media/images/vase.png"), radius = TILESIZE*1.7, interactOffset = {const.TILESIZE, 0}, removable = true},
	blond = {image = newImage("media/images/blond.png"), radius = TILESIZE*1.7, interactOffset = {const.TILESIZE, 0},},
	black = {image = newImage("media/images/black.png"), radius = TILESIZE*1.7, interactOffset = {const.TILESIZE, 0},},
	bathtub = {image = newImage("media/images/bathtub.png"), radius = TILESIZE*1.7, interactOffset = {const.TILESIZE, 0},},
	tableq = {image = newImage("media/images/table.png"), radius = TILESIZE*1.7, interactOffset = {const.TILESIZE, 0}, removable = true}
}

genericObject = {}
genericObject.position = {0,0}
genericObject.velocity = {0,0}
genericObject.angle = 0
genericObject.maxAngle = math.huge
genericObject.minAngle = -math.huge
genericObject.angularVel = 0
genericObject.colliding = false
genericObject.damping = 0
genericObject.angularDamping = 0
genericObject.offset = {0,0}
genericObject.interactOffset = vmul({0,0}, const.TILESIZE)
genericObject.image = nil
genericObject.radius = const.TILESIZE * 1.5
genericObject.removable = false
genericObject.interactStaticStatus = true

function newObject(objType)
	local object = {}
	object.type = objType
	setmetatable(objectTypes[objType], {__index = genericObject})
	setmetatable(object, {__index = objectTypes[objType]})
	table.insert(objects, object)
	return object
end

function objectTypes.door.updateTiles(self)
	for i = 1, 2 do
		local tx, ty = unpack(self.tiles[i])
		map.layers[1].solid[ty][tx] = not self.open
	end
end

function objectTypes.door.interact(self, player)
	if scenes.gameScene.simTime > self.deadUntil then
		self.originAngle = self.originAngle or self.angle
		self.open = not self.open

		if self.open then
			if vdot(self.doorNormal, vsub(self.position, player.position)) < 0 then
				self.angle = self.originAngle - math.pi / 2.0
			else
				self.angle = self.originAngle + math.pi / 2.0
			end
			TEsound.play("/media/sounds/dooropen.wav", const.SOU_VOLUME*0.1)
			progressRitual(player, 1)
		else
			self.angle = self.originAngle
			TEsound.play("/media/sounds/doorclose.wav", const.SOU_VOLUME*0.1)
		end
		self:updateTiles()

		local axis = self.horizontal and 2 or 1
		local delta = player.position[axis] - self.position[axis]
		self.deadUntil = scenes.gameScene.simTime + const.DOOR_DEADTIME
	end
end

function objectTypes.vase.interact(self, player)
	progressRitual(player, 4)
end

function objectTypes.tableq.interact(self, player)
	progressRitual(player, 6)
end

function objectTypes.bathtub.interact(self, player)
	TEsound.play("/media/sounds/bathtubsound.wav", const.SOU_VOLUME*0.1)
	progressRitual(player, 7)
end

function objectTypes.blond.interact(self, player)
	progressRitual(player, 2)
	TEsound.play("/media/sounds/femalescream_1.wav", const.SOU_VOLUME*0.05)
	self.interactStaticStatus = false
	self.image = newImage("media/images/Player2_down.png")
end

function objectTypes.black.interact(self, player)
	progressRitual(player, 3)
	TEsound.play("/media/sounds/femalescream_2.wav", const.SOU_VOLUME*0.05)
	self.interactStaticStatus = false
	self.image = newImage("media/images/Player1_down.png")
end

function drawObjects()
	for i, object in ipairs(objects) do
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(object.image, object.position[1], object.position[2], object.angle, 1.0, 1.0, object.offset[1]*object.image:getWidth(), object.offset[2]*object.image:getHeight())
		local posX, posY = object.position[1], object.position[2]
		posX, posY = unpack(vadd({posX, posY}, vrotate(object.interactOffset, object.angle)))

		love.graphics.setColor(50, 50, 255, object.interactable and 150 or 65)
		love.graphics.setLineWidth(5)
		love.graphics.circle("line", posX, posY, object.radius)
	end
end

function updateObjects()
	for i, object in ipairs(objects) do
		local lastPosition = vret(object.position)
		object.velocity = vadd(object.velocity, vmul(object.velocity, object.damping))
		object.position = vadd(object.position, vmul(object.velocity, const.SIM_DT))

		object.angularVel = object.angularVel - object.angularDamping * const.SIM_DT
		object.angle = object.angle + object.angularVel * const.SIM_DT
		object.angle = clamp(object.angle, object.minAngle, object.maxAngle)

		object.interactable = false

		if object.colliding then
			local startX, endX, startY, endY = getTileRanges(shape)
			for y = startY, endY do
				for x = startX, endX do
					local tile = map.layers[1].tileMap[y][x]
					if tileIndexIsSolid(tile) then
						local mtv = _aabbCollision({object.position[1] - object.radius, object.position[2] - object.radius,
													object.position[1] + object.radius, object.position[2] + object.radius},
												   {x*const.TILESIZE, y*const.TILESIZE, (x+1)*const.TILESIZE, (y+1)*const.TILESIZE})
						if mtv then
							object.position = lastPosition
							object.velocity = {0,0}
							object.angularVel = 0
							break
						end
					end
				end
			end
		end
	end
end