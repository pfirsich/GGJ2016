require "const"
require "input"
require "scenes"

function love.load()
	for k, scene in pairs(scenes) do
		if k ~= "enterScene" and k ~= "currentScene" then
			scene.simTime = 0
			scene.realTime = 0
			if scene.load then scene.load() end
		end
	end

	scenes.enterScene(scenes.gameScene)
end

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
	end

	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	while true do
		-- Process events.
		while scenes.currentScene.simTime < scenes.currentScene.realTime do
			scenes.currentScene.simTime = scenes.currentScene.simTime + const.SIM_DT

			if love.event then
				love.event.pump()
				for name, a,b,c,d,e,f in love.event.poll() do
					if name == "quit" then
						if not love.quit or not love.quit() then
							return a
						end
					end
					love.handlers[name](a,b,c,d,e,f)
					if scenes.currentScene[e] then
						scenes.currentScene[e](a, b, c, d)
					end
				end
			end

			if scenes.currentScene.tick then scenes.currentScene.tick() end
		end

		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end

		scenes.currentScene.realTime = scenes.currentScene.realTime + dt

		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if scenes.currentScene.draw then scenes.currentScene.draw() end
			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end

end