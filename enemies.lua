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
	enemy.shouldTurn = false

	enemy.startTimer = 0

	local temp_angle = 0

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
			if enemy.startTimer == 0 then
				enemy.startTimer = scenes.currentScene.simTime

			end
			if (scenes.currentScene.simTime - enemy.startTimer) > 1  or enemy.shouldTurn then
				enemies.tarangle(-0.75*math.pi, 1.0, enemy)
			end

		elseif enemy.type == 2 then

		elseif enemy.type == 3 then

		end

	end
end

-- function enemies.tarangle(angle, speed, enemy)
-- 	enemy.shouldTurn = true

-- 	if enemy.angle%math.pi < angle%math.pi and math.abs(angle%math.pi - enemy.angle%math.pi) < math.pi/32 then
-- 		enemy.angle = angle
-- 		enemy.shouldTurn = false
-- 		enemy.startTimer = scenes.currentScene.simTime
-- 	end

-- 	if math.abs(enemy.angle - angle)  then
-- 		enemy.angle = enemy.angle + math.pi*speed*const.SIM_DT
-- 	else
-- 		enemy.angle = enemy.angle - math.pi*speed*const.SIM_DT
-- 	end
-- 	if enemy.angle%math.pi > angle%math.pi and math.abs(enemy.angle%math.pi - angle%math.pi) < math.pi/32 then
-- 		enemy.angle = angle
-- 		enemy.target_angle = angle + math.pi
-- 		enemy.shouldTurn = false
-- 		enemy.startTimer = scenes.currentScene.simTime
-- 	end



-- end

function enemies.tarangle(angle, speed, enemy)
	enemy.shouldTurn = true

	print(math.abs(anglecalc(angle, enemy.angle)))
	if math.abs(anglecalc(angle, enemy.angle)) < (math.pi/20.0/speed) then
		print("test")
		enemy.angle = angle
		enemy.shouldTurn = false
		enemy.startTimer = scenes.currentScene.simTime
	elseif anglecalc(angle, enemy.angle) < 0  then
		enemy.angle = enemy.angle - math.pi*speed*const.SIM_DT
	else
		enemy.angle = enemy.angle + math.pi*speed*const.SIM_DT
	end




	-- if math.abs(anglecalc(enemy.angle, angle)) < math.pi/32 then
	-- 	enemy.angle = angle
	-- 	enemy.shouldTurn = false
	-- 	enemy.startTimer = scenes.currentScene.simTime
	-- end

end

function anglecalc (a, b)
	local temp = (a - b) % (2*math.pi)
	--print("cals", a-b, (a-b) % 2*math.pi, (a-b) - math.floor((a-b) / 2*math.pi) * 2*math.pi)
	-- local temp = a-b
	if temp > math.pi then
		temp = - 2*math.pi + temp
	end
	if temp <= - math.pi then
		temp = 2*math.pi - temp
	end
	return temp
end