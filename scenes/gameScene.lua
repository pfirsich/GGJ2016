scenes.gameScene = {}

function scenes.gameScene.load()
	-- shuffle player images (randomize them)
	for i = #players.images, 1, -1 do
		local j = love.math.random(1, i)
		players.images[i], players.images[j] = players.images[j], players.images[i]
	end

	loadMap("TestMap")
end

function scenes.gameScene.onEnter(fromScene)
	players.new("Joel", players.images[players.imageIndex], getPlayerController_Gamepad(love.joystick.getJoysticks()[1]))
	players.imageIndex = players.imageIndex + 1
	enemies.new("Heinz", enemies.images[enemies.imageIndex], 2)
	enemies.imageIndex = enemies.imageIndex + 1
end

function scenes.gameScene.tick()
	-- scenes.gameScene.i = (scenes.gameScene.i or 0) + 1
	-- if scenes.gameScene.i % 10 == 0 then
	-- 	print ("sec")
	-- end
	players.update()
	enemies.update()
	camera.update()
end

function scenes.gameScene.draw()
	camera.push()
	if map then drawMap() end
	players.draw()
	enemies.draw()
	camera.pop()
end