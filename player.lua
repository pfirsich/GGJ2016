players = {}
players.imageIndex = 1
players.images = {
	newImage("media/images/Player1.png"),
	newImage("media/images/Player2.png"),
}

function getPlayerController_Gamepad(joystick)
	local ctrl = {}
	ctrl.moveX = input.floatInput_fromGamepad(joystick, "leftx")
	ctrl.moveY = input.floatInput_fromGamepad(joystick, "lefty")
	ctrl.angleX = input.floatInput_fromGamepad(joystick, "rightx")
	ctrl.angleY = input.floatInput_fromGamepad(joystick, "righty")
	ctrl.attack = input.binaryInput_fromFloatInput(input.floatInput_fromGamepad(joystick, "triggerright"), 0.4)
	ctrl.interact = input.binaryInput_fromGamepad(joystick, "a")
	return ctrl
end

function players.new(name, image, controller)
	local player = {}
	player.name = name
	player.position = {0, 0}
	player.velocity = {0, 0}
	player.lastVelocity = {0, 0}
	player.image = image
	player.angle = 0
	player.controller = controller
	player.rituals = generateRituals(12)
	player.imageIndex = players.imageIndex
	player.animationSet = animationSet(newImage("media/images/Player" .. players.imageIndex .. "_anim.png"), 9)
	player.animationSet.animations = {
		stand = animation(1, 1, 1.0),
		walk = animation(1, 8, 16.0),
		fallen = animation(9, 9, 20.0)
	}
	player.animationSet:setAnimation("stand")

	table.insert(players, player)
	players.imageIndex = players.imageIndex + 1
end

function slide(vec, normal, reflect) -- normal should be normalized
	-- vec = a*normal + b*orthoNormal
	-- -> vec = a*normal - b*orthoNormal*slide
	local orthoNormal = vortho(normal)
	return vadd(vmul(normal, vdot(normal, vec)), vmul(orthoNormal, vdot(orthoNormal, vec) * -reflect))
end

function players.update()
	for i, player in ipairs(players) do
		input.updateController(player.controller)

		--**character controls**
		--velocity
		player.velocity = vmul({player.controller.moveX.state, player.controller.moveY.state}, const.PLAYER_SPEED)
		if vnorm({player.controller.moveX.state, player.controller.moveY.state}) < const.GP_DEADZONE then --deadzone
			player.velocity = {0, 0}
		end

		if vnorm(player.lastVelocity) < 1.0 and vnorm(player.velocity) > 1.0 then
			player.animationSet:setAnimation("walk")
		end

		if vnorm(player.lastVelocity) > 1.0 and vnorm(player.velocity) < 1.0 then
			player.animationSet:setAnimation("stand")
		end
		player.lastVelocity = vret(player.velocity)

		-- collision
		local penalty = 1.0
		if vnorm(player.velocity) > 0.001 then
			penalty = 1.0 + math.min(vdot(player.velocity, vpolar(player.angle, 1.0)) / vnorm(player.velocity), 0.0) * 0.5
		end
		player.position = vadd(player.position, vmul(player.velocity, const.SIM_DT * penalty))

		local getCollisionShape = function()
			local playerSize = 0.9 * const.TILESIZE
			local shape = {
				type = "box",
				data = {player.position[1] - playerSize/2, player.position[2] - playerSize/2,
						player.position[1] + playerSize/2, player.position[2] + playerSize/2}
			}
			return shape
		end

		local shape = getCollisionShape()
		local mtvSum, mtvCount = {0, 0}, 0
		local startX, endX, startY, endY = getTileRanges(shape)
		for y = startY, endY do
			for x = startX, endX do
				local tile = map.layers[1].tileMap[y][x]
				if map.layers[1].solid[y][x] then
					local mtv = _aabbCollision(shape.data, {x*const.TILESIZE, y*const.TILESIZE, (x+1)*const.TILESIZE, (y+1)*const.TILESIZE})
					if mtv then
						player.position = vadd(player.position, mtv)
						shape = getCollisionShape()

						mtvSum = vadd(mtvSum, mtv)
						mtvCount = mtvCount + 1
					end
				end
			end
		end

		if mtvCount > 0 then
			local orthoMTV = vnormed(vortho(mtvSum))
			player.velocity = slide(player.velocity, orthoMTV, const.player.WALL_BOUNCE)
		end

		--orientation
		if vnorm({player.controller.angleX.state, player.controller.angleY.state}) > const.GP_DEADZONE * 2 then --deadzone, higher than above because orientation with analog stick is weird
			player.angle = vangle({player.controller.angleX.state, player.controller.angleY.state})
		end

		--fighting
		if player.controller.attack.pressed then
			player_attack(player)
		end

		-- objects
		for i, object in ipairs(objects) do
			local rel = vsub(player.position, vadd(object.position, vrotate(object.interactOffset, object.angle)))
			if vdot(rel, rel) < object.radius*object.radius then
				object.interactable = true

				if player.controller.interact.pressed then
					object:interact(player)
				end
			end
		end

		player.animationSet:update(const.SIM_DT)
	end
end

function players.draw()
	for i, player in ipairs(players) do
		love.graphics.setColor(255, 255, 255, 30)
		local dir = vpolar(player.angle, 4.0 * const.TILESIZE)
		love.graphics.setLineWidth(1)
		love.graphics.line(player.position[1], player.position[2], player.position[1] + dir[1], player.position[2] + dir[2])
		love.graphics.setColor(255, 255, 255, 255)
		if player.col then love.graphics.setColor(255, 0, 0, 255) end
		player.animationSet:draw(player.position[1], player.position[2], vangle(player.velocity), 1.0, 1.0, player.image:getWidth()/2, player.image:getHeight()/2)
		love.graphics.draw(player.image, player.position[1], player.position[2], player.angle + math.pi, 1.0, 1.0, player.image:getWidth()/2, player.image:getHeight()/2)
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function player_attack(player)
	player.angle = 90
end
