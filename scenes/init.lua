scenes = {}

scenes.currentScene = {}

function scenes.enterScene(scene, ...)
    if scenes.currentScene.onExit then scenes.currentScene.onExit(scene) end
    if scene.onEnter then scene.onEnter(...) end
    scenes.currentScene = scene
end

for i, file in ipairs(love.filesystem.getDirectoryItems("scenes")) do
	if file ~= "init.lua" then
		require ("scenes." .. file:sub(1, -5))
	end
end