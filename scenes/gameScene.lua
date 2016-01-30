require "pathfinder"
scenes.gameScene = {}

function scenes.gameScene.load()
	-- shuffle player images (randomize them)
	-- for i = #players.images, 1, -1 do
	-- 	local j = love.math.random(1, i)
	-- 	players.images[i], players.images[j] = players.images[j], players.images[i]
	-- end

	loadMap("level_2")
	loadMapPF("level_2")
	--(sPosX, sPosY, ePosX, ePosY)
	
end

function scenes.gameScene.onEnter(fromScene)
	players.new("Player1", players.images[players.imageIndex], getPlayerController_Gamepad(love.joystick.getJoysticks()[1]))
	--players.new("Player2", players.images[players.imageIndex], getPlayerController_Gamepad(love.joystick.getJoysticks()[2]))
	enemies.new("Heinz", enemies.images[enemies.imageIndex], 2)
	enemies.imageIndex = enemies.imageIndex + 1
end

function scenes.gameScene.tick()
	-- scenes.gameScene.i = (scenes.gameScene.i or 0) + 1
	-- if scenes.gameScene.i % 10 == 0 then
	-- 	print ("sec")
	-- end
	updateObjects()
	players.update()
	enemies.update()
	camera.update()
end

function scenes.gameScene.draw()
	camera.push()
	if map then drawMap() end
	drawObjects()
	players.draw()
	enemies.draw()
	camera.pop()

	-- hud
	local playerScale = 3.0
	local playerSizeX, playerSizeY = players.images[1]:getWidth() * playerScale, players.images[1]:getHeight() * playerScale
	if #players >= 1 then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", 0, 0, playerSizeX, playerSizeY)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(players.images[1], 0, playerSizeY, -math.pi/2.0, playerScale, playerScale)

		for i = 1, #players[1].rituals do
			shadowText(rituals[players[1].rituals[i]], 10, (i-1)*25 + playerSizeY + 10)
		end
	end

	if #players >= 2 then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", love.graphics.getWidth()-playerSizeX, 0, playerSizeX, playerSizeY)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(players.images[2], love.graphics.getWidth()-playerSizeX, playerSizeY, -math.pi/2.0, playerScale, playerScale)

		for i = 1, #players[2].rituals do
			local text = rituals[players[2].rituals[i]]
			local textWidth = love.graphics.getFont():getWidth(text)
			shadowText(text, love.graphics.getWidth() - textWidth - 10, (i-1)*25 + playerSizeY + 10)
		end
	end
end

function shadowText(text, x, y)
	local shadowOffset = 1
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(text, x + shadowOffset, y + shadowOffset)
	love.graphics.setColor(255, 255, 0, 255)
	love.graphics.print(text, x, y)
	love.graphics.setColor(255, 255, 255, 255)
end