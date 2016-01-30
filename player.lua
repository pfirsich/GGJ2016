players = {}
players.imageIndex = 1
players.images = {
	newImage("media/player.png"),
}

function getPlayerController_Gamepad(joystick)
	local ctrl = {}
	ctrl.moveX = input.floatInput_fromGamepad(joystick, "leftx")
	ctrl.moveY = input.floatInput_fromGamepad(joystick, "lefty")
	ctrl.angleX = input.floatInput_fromGamepad(joystick, "rightx")
	ctrl.angleY = input.floatInput_fromGamepad(joystick, "righty")
	ctrl.buttonA = input.binaryInput_fromGamepad(joystick, "a")
	return ctrl
end

function players.new(name, image, controller)
	local player = {}
	player.name = name
	player.position = {0, 0}
	player.velocity = {0, 0}
	player.image = image
	player.angle = 0
	player.controller = controller

	table.insert(players, player)
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

	player.position = vadd(player.position, vmul(player.velocity, const.SIM_DT))

		--orientation
	if vnorm({player.controller.angleX.state, player.controller.angleY.state}) > const.GP_DEADZONE * 2 then --deadzone, higher than above because orientation with analog stick is weird
		player.angle = vangle({player.controller.angleX.state, player.controller.angleY.state})
	end

	--fighting
	if gp_bintrigger(player.controller, "triggerright", 0.4) then
		player_attack(player)
	end
	end

end

function players.draw()
	for i, player in ipairs(players) do
		love.graphics.draw(player.image, player.position[1], player.position[2], player.angle, 1.0, 1.0, player.image:getWidth()/2, player.image:getHeight()/2)
	end
end

function player_attack(player)
	return nil
end
