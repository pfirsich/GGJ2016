require "pathfinder"
scenes.gameScene = {}

function scenes.gameScene.load()
	--loadMapPF(levelName)
	--(sPosX, sPosY, ePosX, ePosY)
end

function scenes.gameScene.onEnter(level)
	loadMap(level)
	TEsound.playLooping("/media/sounds/backgroundmusic_2.wav", const.SOU_VOLUME*0.1)
end

function scenes.gameScene.onExit()
	TEsound.stop("/media/sounds/backgroundmusic_2.wav")
end

function scenes.gameScene.tick()
	-- scenes.gameScene.i = (scenes.gameScene.i or 0) + 1
	-- if scenes.gameScene.i % 10 == 0 then
	-- 	print ("sec")
	-- end
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	updateObjects()
	players.update()
	enemies.update()
	camera.update()

	if showWinScreen and scenes.gameScene.simTime > showWinScreen then
		error("Player wins: " .. gameWinner.name)
	end
end

function scenes.gameScene.draw()
	love.graphics.setColor(255, 255, 255, 255)
	camera.push()
	if map then drawMap() end
	drawObjects()
	players.draw()
	enemies.draw()
	camera.pop()

	-- hud
	local playerScale = 1.0
	local playerSizeX, playerSizeY = players.images[1]:getWidth() * playerScale, players.images[1]:getHeight() * playerScale
	if #players >= 1 then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", 0, 0, playerSizeX, playerSizeY)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(players.images[1], 0, playerSizeY, -math.pi/2.0, playerScale, playerScale)

		for i = 1, #players[1].rituals do
			shadowText(players[1].rituals[i].ritMsg, 10, (i-1)*25 + playerSizeY + 10)
		end
	end

	if #players >= 2 then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", love.graphics.getWidth()-playerSizeX, 0, playerSizeX, playerSizeY)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(players.images[2], love.graphics.getWidth()-playerSizeX, playerSizeY, -math.pi/2.0, playerScale, playerScale)

		for i = 1, #players[2].rituals do
			local text = players[2].rituals[i].ritMsg
			local textWidth = love.graphics.getFont():getWidth(text)
			shadowText(text, love.graphics.getWidth() - textWidth - 10, (i-1)*25 + playerSizeY + 10)
		end
	end

	if scenes.gameScene.dogMode then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("DOGMODE", 5, 5)
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

function scenes.gameScene.keypressed(key)
	if key == "d" and scenes.gameScene.dogCounter == 0 or scenes.gameScene.dogCounter == nil then
		print(key)
		scenes.gameScene.dogCounter = 1
	elseif key == "o" and scenes.gameScene.dogCounter == 1 then
		print(key)
		scenes.gameScene.dogCounter = 2
	elseif key == "g" and scenes.gameScene.dogCounter == 2 then
		print(key)
		scenes.gameScene.dogMode = true
	else
		scenes.gameScene.dogCounter = 0
	end
end