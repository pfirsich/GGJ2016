function newImage(path)
	local img = love.graphics.newImage(path)
	img:setFilter("nearest", "nearest")
	return img
end

function arrayShuffle(array)
	for i = #array, 1, -1 do
		local j = love.math.random(1, i)
		array[i], array[j] = array[j], array[i]
	end
end

function filter(list, func)
	local ret = {}
	for i = 1, #list do
		if func(list[i]) then ret[#ret+1] = list[i] end
	end
	return ret
end


function setResolution(w, h, flags) -- this is encapsulated, so if canvases are used later, they can be updated here!
	if not love.window.setMode(w, h, flags) then
		error(string.format("Resolution %dx%d could not be set successfully.", w, h))
	end
end

function autoFullscreen()
	local supported = love.window.getFullscreenModes()
	table.sort(supported, function(a, b) return a.width*a.height < b.width*b.height end)

	local scrWidth, scrHeight = love.window.getDesktopDimensions()
	supported = filter(supported, function(mode) return mode.width*scrHeight == scrWidth*mode.height end)

	local max = supported[#supported]
	local flags = {fullscreen = true}
	setResolution(max.width, max.height, flags)
end