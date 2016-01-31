scenes.levelChooser = {}

function scenes.levelChooser.load()
	midFont = love.graphics.newFont(28)
	defaultFont = love.graphics.getFont()
end

function scenes.levelChooser.onEnter()
end

function scenes.levelChooser.onExit()
	TEsound.stop("menu")
	love.graphics.setFont(defaultFont)
end

function scenes.levelChooser.tick()

end

function scenes.levelChooser.draw()
	love.graphics.setFont(midFont)
	love.graphics.print("Press 1, 2 or 3 to start the map 1, 2 or 3")
end

function scenes.levelChooser.keypressed(key)
	if key == "1" or key == "2" or key == "3" then
		scenes.enterScene(scenes.gameScene, "level_" .. key)
	end
end