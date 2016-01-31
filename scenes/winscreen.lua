scenes.winScreen = {}

function scenes.winScreen.load()

end

function scenes.winScreen.onEnter()
	TEsound.play("media/sounds/playerdeath.wav", 0.4)
end

function scenes.winScreen.tick()

end

function scenes.winScreen.draw()
	scenes.gameScene.draw()

	local alpha = 0
	local startTime = 2.0
	local endTime = 4.0
	if scenes.winScreen.simTime > startTime then
		alpha = math.min(150, (scenes.winScreen.simTime - startTime) / (endTime - startTime) * 150)
	end

	love.graphics.setColor(50, 50, 50, alpha)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	if scenes.winScreen.simTime > endTime then
		love.graphics.print("JBKLAÖ")
	end
end