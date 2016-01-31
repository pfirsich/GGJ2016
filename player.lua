require "TEsound"

players = {}
players.imageIndex = 1
players.images = {
	newImage("media/images/Player1.png"),
	newImage("media/images/Player2.png"),
}
players.pchn01_vol = const.SOU_VOLUME * .1
players.pchn01_snd = {
	"media/sounds/punch1.wav",
	"media/sounds/punch2.wav",
	"media/sounds/punch3.wav",
}
players.pchn02_vol = const.SOU_VOLUME * .2
players.pchn02_snd = {
	"media/sounds/punchdown1.wav",
	"media/sounds/punchdown2.wav",
}
players.mov_vol = const.SOU_VOLUME * .01
players.mov_snd = {"media/sounds/singlefootstep.wav"}

function getPlayerController_Gamepad(joystick)
	local ctrl = {}
	ctrl.moveX = input.floatInput_fromGamepad(joystick, "leftx")
	ctrl.moveY = input.floatInput_fromGamepad(joystick, "lefty")
	ctrl.angleX = input.floatInput_fromGamepad(joystick, "rightx")
	ctrl.angleY = input.floatInput_fromGamepad(joystick, "righty")
	ctrl.attack = input.binaryInput_fromFloatInput(input.floatInput_fromGamepad(joystick, "triggerright"), 0.4)
	ctrl.interact = input.binaryInput_fromGamepad(joystick, "a")
	ctrl.autoaggression = input.binaryInput_fromKeyboard("8")
	ctrl.shove = input.binaryInput_fromGamepad(joystick, "rightshoulder")
	return ctrl
end

function players.new(name, image, controller)
	local player = {}
	player.name = name
	player.position = table.remove(map.spawns)
	player.velocity = {0, 0}
	player.lastVelocity = {0, 0}
	player.image = image
	player.angle = 0
	player.controller = controller
	player.fallen = false
	player.fallEnd = 0
	player.rituals = generateRituals(5)
	player.shoveStart = 0
	player.imageIndex = players.imageIndex
	player.animationSet = animationSet(newImage("media/images/Player" .. players.imageIndex .. "_anim.png"), 9)
	player.animationSet.animations = {
		stand = animation(1, 1, 1.0),
		walk = animation(1, 8, 16.0),
		fallen = animation(9, 9, 20.0)
	}
	player.animationSet:setAnimation("stand")

	player.formerFrame = player.animationSet:getCurrentFrame()
	player.currentFrame = player.animationSet:getCurrentFrame()

	table.insert(players, player)
	players.imageIndex = players.imageIndex + 1
end

function slide(vec, normal, reflect) -- normal should be normalized
	-- vec = a*normal + b*orthoNormal
	-- -> vec = a*normal - b*orthoNormal*slide
	local orthoNormal = vortho(normal)
	return vadd(vmul(normal, vdot(normal, vec)), vmul(orthoNormal, vdot(orthoNormal, vec) * -reflect))
end

function players.shove(player, direction)
	player.fallEnd = scenes.gameScene.simTime + const.FALL_DURATION
	player.fallen = true
	player.animationSet:setAnimation("fallen")
		TEsound.play(players.pchn02_snd, players.pchn02_vol)
	player.fallDirection = vnormed(direction)
end

function players.update()
	TEsound.cleanup()
	for i, player in ipairs(players) do
		input.updateController(player.controller)

		if player.controller.autoaggression.pressed then
			players.shove(player, vrotate({1,0}, love.math.random() * 2.0 * math.pi))
				TEsound.play(players.pchn02_snd, players.pchn02_vol*2)
		end

		if player.controller.shove.pressed and not player.fallen then
			player.shoveStart = scenes.gameScene.simTime
			TEsound.play(players.pchn01_snd, players.pchn01_vol, love.math.random())
			for j, other in ipairs(players) do
				if i ~= j then
					local rel = vsub(player.position, other.position)
					if vdot(rel, rel) < const.PLAYER_SHOVE_DIST*const.PLAYER_SHOVE_DIST then
						if vdot(rel, vpolar(player.angle, 1.0)) / vnorm(rel) < math.cos(const.PLAYER_SHOVE_ANGLE) then
							if not other.fallen then
								players.shove(other, vsub(other.position, player.position))
								progressRitual(player, 5)
							end
						end
					end
				end
			end
		end

		--**character controls**
		--velocity
		if player.fallen then
			player.velocity = vmul(player.fallDirection, const.FALL_SPEED * 10.0)
		else
			if vnorm({player.controller.moveX.state, player.controller.moveY.state}) > const.GP_DEADZONE then
				player.velocity = vmul({player.controller.moveX.state, player.controller.moveY.state}, const.PLAYER_SPEED)
			else
				player.velocity = vmul(vnormed(player.velocity), 0.1)
			end
		end

		if scenes.gameScene.simTime > player.fallEnd and player.fallen then
			player.fallen = false
			player.velocity = {0, 0}
		end

		if not player.fallen then
			if vnorm(player.lastVelocity) < 1.0 and vnorm(player.velocity) > 1.0 then
				player.animationSet:setAnimation("walk")
				if(player.currentFrame==1 or player.currentFrame==5) then
            		TEsound.play(players.mov_snd, players.mov_vol)
            	end
			end

			if vnorm(player.velocity) < 1.0 then
				player.animationSet:setAnimation("stand")
			end
			player.lastVelocity = vret(player.velocity)
		end

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
		else
			player.angle = vangle(player.velocity)
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

				if object.interactStaticStatus and (player.controller.interact.pressed or (player.fallen and object.type == "door" and not object.open) )then
					object:interact(player)
					if object.removable then
						table.remove(objects, i)
					end
					
				end
			end
		end

		if love.math.random() > .25 and(player.currentFrame==1 or player.currentFrame==5) and (player.formerFrame ~= player.currentFrame) then
            TEsound.play(players.mov_snd, players.mov_vol, 0.25+(love.math.random())/2)
        end
		player.animationSet:update(const.SIM_DT * vnorm(player.velocity) / const.PLAYER_SPEED)
		player.formerFrame = player.currentFrame
		player.currentFrame = player.animationSet:getCurrentFrame()
		
		if(hasWon(player))then
			print(player.name)
			print("hat gewonnen")
		end
	end
end

function players.draw()
	for i, player in ipairs(players) do
		local shoveAmount = 1.0 - math.min(const.SHOVE_ANIM_DURATION, scenes.gameScene.simTime - player.shoveStart) / const.SHOVE_ANIM_DURATION
		local shoveAnim = vmul(vnormed(player.velocity), math.sin(shoveAmount*math.pi)*math.sin(shoveAmount*math.pi)*const.SHOVE_AMOUNT)

		love.graphics.setColor(255, 255, 255, 30)
		local dir = vpolar(player.angle, 4.0 * const.TILESIZE)
		love.graphics.setLineWidth(1)
		love.graphics.line(player.position[1], player.position[2], player.position[1] + dir[1], player.position[2] + dir[2])
		love.graphics.setColor(255, 255, 255, 255)
		if player.col then love.graphics.setColor(255, 0, 0, 255) end
		local angle = vangle(player.velocity)
		if player.animationSet.currentAnimation == "fallen" then angle = scenes.gameScene.simTime * const.FALL_TURN_SPEED end
		local shoveScale = 1.0 + 0.3 * shoveAmount
		player.animationSet:draw(player.position[1] + shoveAnim[1], player.position[2] + shoveAnim[2], angle, shoveScale, shoveScale,
								player.image:getWidth()/2, player.image:getHeight()/2)
		if player.animationSet.currentAnimation ~= "fallen" then
			love.graphics.draw(player.image, player.position[1] + shoveAnim[1], player.position[2] + shoveAnim[2], player.angle + math.pi, shoveScale, shoveScale,
								player.image:getWidth()/2, player.image:getHeight()/2)
		end

		-- local hit1 = castRayIntoMap_behindi({player.position, vadd(player.position, {10,0})})
		-- local hit2 = castRayIntoMap_behindi({player.position, vadd(player.position, {-10,0})})
		-- local hit3 = castRayIntoMap_behindi({player.position, vadd(player.position, {0,10})})
		-- local hit4 = castRayIntoMap_behindi({player.position, vadd(player.position, {0,-10})})
		-- if hit1 then love.graphics.circle("fill", hit1[1], hit1[2], 20) end
		-- if hit2 then love.graphics.circle("fill", hit2[1], hit2[2], 20) end
		-- if hit3 then love.graphics.circle("fill", hit3[1], hit3[2], 20) end
		-- if hit4 then love.graphics.circle("fill", hit4[1], hit4[2], 20) end

		-- love.graphics.circle("fill", 0, 0, 10)
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function player_attack(player)
	player.angle = 90
end
