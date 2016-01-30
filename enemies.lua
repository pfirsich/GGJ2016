enemies = {}
enemies.imageIndex = 1
enemies.images = {
	newImage("media/enemy.png"), --change to enemy sprite
}

function enemies.new(name, image, type)
	local enemy = {}
	enemy.name = name
	enemy.position = {0, 0}
	enemy.velocity = {0, 0}
	enemy.image = image
	enemy.angle = 0
	enemy.type = type

	table.insert(enemies, enemy)
end

function enemies.draw()
	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.image, enemy.position[1], enemy.position[2], enemy.angle, 1.0, 1.0, enemy.image:getWidth()/2, enemy.image:getHeight()/2)
	end
end

function enemies.update()
	for i, enemy in ipairs(enemies) do	

	if enemy.type == 1 then
	while enemy.angle > math.pi do
		love.love.timer.sleep(3s)
		enemy.angle = enemy.angle + math.pi/4 * const.SIM_DT
	end
	while enemy.angle < math.pi do
		love.love.timer.sleep(3s)
		enemy.angle = enemy.angle + math.pi/4 * const.SIM_DT
	end
	elseif enemy.type == 2 then

	elseif enemy.type == 3 then

	end
	
	end
end