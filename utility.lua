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