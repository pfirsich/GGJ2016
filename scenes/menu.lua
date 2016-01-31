scenes.menu = {}

function scenes.menu.load()
	bigFont = love.graphics.newFont(36)
	midFont = love.graphics.newFont(28)
	defaultFont = love.graphics.getFont()
	scenes.menu.message = ""
end

function scenes.menu.onEnter()
	TEsound.playLooping("media/sounds/mainmenumusic.wav", 0.4)
end

function scenes.menu.onExit()
	--TEsound.stop("media/sounds/mainmenumusic.wav")
	love.graphics.setFont(defaultFont)
end

function scenes.menu.tick()

end

function scenes.menu.draw()
	love.graphics.setFont(midFont)
	love.graphics.print("Please plug in two controllers to play.", 15, 15)
	love.graphics.print("Use your left stick to move, right to aim, A to interact, right shoulder to shove", 15, 50)
	love.graphics.print("Press <space> to start the game", 15, 80)
	love.graphics.print(scenes.menu.message, 15, love.graphics.getHeight() - midFont:getHeight() - 15)
end

function scenes.menu.keypressed(key)
	if key == "space" then
		if #love.joystick.getJoysticks() >= 2 then
			players.new("WOMBO COMBO", players.images[players.imageIndex], getPlayerController_Gamepad(love.joystick.getJoysticks()[1]))
			players.new("MOM GET THE CAMERA", players.images[players.imageIndex], getPlayerController_Gamepad(love.joystick.getJoysticks()[2]))
			scenes.enterScene(scenes.levelChooser)
		else
			scenes.menu.message = "Please plug in two controllers"
		end
	end
end