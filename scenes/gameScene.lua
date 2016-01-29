scenes.gameScene = {}

function scenes.gameScene.load()
	-- shuffle player images (randomize them)
	for i = #players.images, 1, -1 do
		local j = love.math.random(1, i)
		players.images[i], players.images[j] = players.images[j], players.images[i]
	end
end

function scenes.gameScene.onEnter(fromScene)
	newPlayer("Joel", players.images[players.imageIndex])
	players.imageIndex = players.imageIndex + 1
end

function scenes.gameScene.tick()
	-- scenes.gameScene.i = (scenes.gameScene.i or 0) + 1
	-- if scenes.gameScene.i % 10 == 0 then
	-- 	print ("sec")
	-- end
end

function scenes.gameScene.draw()
	drawPlayers()
end