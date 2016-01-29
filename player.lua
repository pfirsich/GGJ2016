players = {}
players.imageIndex = 1
players.images = {
	love.graphics.newImage("media/player.png"),
}

function getPlayerController_Gamepad(joystick)
	local ctrl = {}
	ctrl.moveX = input.floatInput_fromGamepad(joystick, "leftx")
	ctrl.moveY = input.floatInput_fromGamepad(joystick, "lefty")
	return ctrl
end

function newPlayer(name, image, controller)
	local player = {}
	player.name = name
	player.position = {0, 0}
	player.velocity = {0, 0}
	player.image = image
	player.angle = 0
	player.controller = controller

	table.insert(players, player)
end

function updatePlayers()
	for i, player in ipairs(players) do
		input.updateController(player.controller)
		print(player.controller.moveX.state, player.controller.moveY.state)
	end
end

function drawPlayers()
	for i, player in ipairs(players) do
		love.graphics.draw(player.image, player.position[1], player.position[2], player.angle, 1.0, 1.0, player.image:getWidth()/2, player.image:getHeight()/2)
	end
end