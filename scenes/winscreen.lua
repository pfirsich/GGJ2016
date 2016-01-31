scenes.winScreen = {}

function scenes.winScreen.load()
	bigFont = love.graphics.newFont(36)
	midFont = love.graphics.newFont(28)
end

function scenes.winScreen.onEnter()
	TEsound.play("media/sounds/playerdeath.wav", 0.4)
end

function scenes.winScreen.tick()

end

function scenes.winScreen.draw()
	scenes.gameScene.draw()

	--print(scenes.winScreen.simTime)

	local alpha = 0
	local startTime = 2.0
	local endTime = 4.0
	local maxAlpha = 200
	if scenes.winScreen.simTime > startTime then
		alpha = math.min(maxAlpha, (scenes.winScreen.simTime - startTime) / (endTime - startTime) * maxAlpha)
	end

	love.graphics.setColor(50, 50, 50, alpha)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	local oldfont = love.graphics.getFont()
	love.graphics.setFont(bigFont)
	local font = love.graphics.getFont()
	love.graphics.setColor(255, 255, 255, 255)
	if scenes.winScreen.simTime > endTime then
		love.graphics.draw(gameWinner.image, love.graphics.getWidth()/2, love.graphics.getHeight()/3, -math.pi/2, 3.0, 3.0, 49, 49)
		local text = "WINS"
		love.graphics.print(text, love.graphics.getWidth()/2 - font:getWidth(text)/2, love.graphics.getHeight()/3*2)

		local text2 = "Press <space> to restart"
		love.graphics.print(text2, love.graphics.getWidth()/2 - font:getWidth(text2)/2, love.graphics.getHeight()/3*2.5)
	end
	love.graphics.setFont(oldfont)
end

function scenes.winScreen.keypressed(key)
	if key == "space" then
		scenes.enterScene(scenes.levelChooser)
	end
end