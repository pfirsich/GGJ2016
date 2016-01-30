function newImage(path)
	local img = love.graphics.newImage(path)
	img:setFilter("nearest", "nearest")
	return img
end