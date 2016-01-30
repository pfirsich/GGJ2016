enemies = {}
enemies.imageIndex = 1
enemies.images = {
	newImage("media/enemy.png"),
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
	enemy.targetAngle = 0
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
				enemy.targetAngle = enemy.angle + math.pi
			end
			if (scenes.currentScene.simTime - enemy.startTimer) > 1  or enemy.shouldTurn then
				enemies.tarangle(enemy.targetAngle, 1.0, enemy)
			end

		elseif enemy.type == 2 then

			if enemy.startTimer == 0 then
				enemy.startTimer = scenes.currentScene.simTime
				enemy.targetAngle = enemy.angle + math.pi
			end
			if (scenes.currentScene.simTime - enemy.startTimer) > 1  or enemy.shouldTurn then
				enemies.tarangle(enemy.targetAngle, 1.0, enemy)
			else
				enemy.position = vadd(enemy.position, vmul(vnormed(angletovec(enemy.angle)), 150*const.SIM_DT))
			end

		elseif enemy.type == 3 then
			playerToDes = players[1]

			pathOfDes = findPath(enemy.pos[1], enemy.pos[2], playerToDes.pos[2], playerToDes.pos[2])


		end

	end
end


function enemies.tarangle(angle, speed, enemy)
	enemy.shouldTurn = true

	if math.abs(anglecalc(angle, enemy.angle)) < (math.pi/20.0/speed) then
		enemy.angle = angle
		enemy.targetAngle = enemy.angle + math.pi
		enemy.shouldTurn = false
		enemy.startTimer = scenes.currentScene.simTime
	elseif anglecalc(angle, enemy.angle) < 0  then
		enemy.angle = enemy.angle - math.pi*speed*const.SIM_DT
	else
		enemy.angle = enemy.angle + math.pi*speed*const.SIM_DT
	end

end

function anglecalc (a, b)
	local temp = (a - b) % (2*math.pi)
	if temp > math.pi then
		temp = - 2*math.pi + temp
	end
	if temp <= - math.pi then
		temp = 2*math.pi - temp
	end
	return temp
end

function angletovec(angle)
	local tempv = {}
	tempv[1] = math.cos(angle)
	tempv[2] = math.sin(angle)
	return tempv
end