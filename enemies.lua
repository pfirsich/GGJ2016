enemies = {}

function getNewEnemyAnimationSet(type)
	-- player.animationSet = animationSet(newImage("media/images/Player" .. players.imageIndex .. "_anim.png"), 9)
	-- player.animationSet.animations = {
	-- 	stand = animation(1, 1, 1.0),
	-- 	walk = animation(1, 8, 16.0),
	-- 	fallen = animation(9, 9, 20.0)
	-- }
	-- player.animationSet:setAnimation("stand")
end

function enemies.new(type)
	local enemy = {}
	enemy.position = {0,0}
	enemy.velocity = {0,0}
	enemy.angle = 0
	enemy.animationSet = animationSet(newImage("media/images/security_anim.png"), 8)
	enemy.animationSet.animations = {
		stand = animation(1, 1, 1.0),
		walk = animation(1, 8, 16.0),
	}
	enemy.animationSet:setAnimation("stand")
	enemy.targetAngle = 0
	enemy.alive = true
	enemy.type = type
	table.insert(enemies, enemy)
	return enemy
end

function enemies.draw()
	love.graphics.setColor(255, 100, 100, 40)
	for i, enemy in ipairs(enemies) do
		love.graphics.arc("fill", enemy.position[1], enemy.position[2], const.enemies.VIEW_DIST, enemy.angle - const.enemies.VIEW_ANGLE/2, enemy.angle + const.enemies.VIEW_ANGLE/2)
	end

	for i, enemy in ipairs(enemies) do
		love.graphics.setColor(255, 255, 255, 255)
		if enemy.red then love.graphics.setColor(255, 0, 0, 255) end
		enemy.animationSet:draw(enemy.position[1], enemy.position[2], enemy.angle, 1.0, 1.0,
								enemy.animationSet.image:getHeight()/2, enemy.animationSet.image:getHeight()/2)
	end
end

function enemies.update()
	for i, enemy in ipairs(enemies) do
		if enemy.type == "roomba" then
			enemy.velocity = vpolar(enemy.angle, 100.0)

		elseif enemy.type == "transrapid" then
			if enemy.currentNode == nil then
				enemy.currentNode = 1
				enemy.nextNode = 2
				enemy.pathNodeStartTime = scenes.gameScene.simTime
				enemy.position = vret(enemy.path[1])
			end

			if enemy.pathNodeTime and enemy.pathNodeTime > 1.0 then
				enemy.pathNodeStartTime = scenes.gameScene.simTime
				enemy.currentNode = enemy.nextNode
				enemy.nextNode = enemy.currentNode + (enemy.forward and 1 or -1)
			end

			if enemy.nextNode > #enemy.path then
				enemy.nextNode = #enemy.path - 1
				enemy.forward = false
			end
			if enemy.nextNode < 1 then
				enemy.nextNode = 2
				enemy.forward = true
			end

			enemy.pathNodeLength = vnorm(vsub(enemy.path[enemy.currentNode], enemy.path[enemy.nextNode]))
			local speed = const.TILESIZE * 3.0
			local dt = (scenes.gameScene.simTime - enemy.pathNodeStartTime)
			enemy.pathNodeTime = (dt * speed) / enemy.pathNodeLength
			enemy.targetPosition = vlerp(enemy.path[enemy.currentNode], enemy.path[enemy.nextNode], enemy.pathNodeTime)

			local rel = vsub(enemy.targetPosition, enemy.position)
			enemy.velocity = vmul(vnormed(rel), const.TILESIZE * 3.0)
			enemy.targetAngle = vangle(enemy.velocity)
			--enemy.lastPosition = vret(enemy.position)
			--enemy.position = vadd(enemy.position, vmul(delta, const.SIM_DT * 5.0))
		elseif enemy.type == "" then

		end

		-- integrate
		enemy.position = vadd(enemy.position, vmul(enemy.velocity, const.SIM_DT))

		local deltaAng = angleDiff(enemy.targetAngle, enemy.angle)
		enemy.angle = enemy.angle + deltaAng * (const.ENEMY_TURN_SPEED or 6.0) * const.SIM_DT

		-- collision
		local getCollisionShape = function()
			local enemySize = 0.9 * const.TILESIZE
			local shape = {
				type = "box",
				data = {enemy.position[1] - enemySize/2, enemy.position[2] - enemySize/2,
						enemy.position[1] + enemySize/2, enemy.position[2] + enemySize/2}
			}
			return shape
		end

		local shape = getCollisionShape()
		local mtvSum, mtvCount = {0, 0}, 0
		local startX, endX, startY, endY = getTileRanges(shape)
		for y = startY, endY do
			for x = startX, endX do
				local tile = map.layers[1].tileMap[y][x]
				if map.layers[1].solid[y][x] then
					local mtv = _aabbCollision(shape.data, {x*const.TILESIZE, y*const.TILESIZE, (x+1)*const.TILESIZE, (y+1)*const.TILESIZE})
					if mtv then
						enemy.position = vadd(enemy.position, mtv)
						shape = getCollisionShape()

						mtvSum = vadd(mtvSum, mtv)
						mtvCount = mtvCount + 1
					end
				end
			end
		end

		if mtvCount > 0 then
			local orthoMTV = vnormed(vortho(mtvSum))
			enemy.velocity = slide(enemy.velocity, orthoMTV, 0.1)

			if enemy.type == "roomba" then
				enemy.targetAngle = love.math.random()*2.0*math.pi
			end
		end

		local playerInSight = {}
		enemy.red = false
		local lookDir = vpolar(enemy.angle, 1.0)
		for p, player in ipairs(players) do
			local rel = vsub(player.position, enemy.position)
			if vdot(rel, lookDir) / vnorm(rel) > math.cos(const.enemies.VIEW_ANGLE) then
				if vnorm(rel) < const.enemies.VIEW_DIST and not enemy.red then
					enemy.red = true
					enemy.type = "pursuit"
					enemy.path = findPath(enemy.position[1], enemy.position[2], player.position[1], player.position[2])
					print("find")
				end
			end
		end

		if enemy.path then
			if enemy.pathInterp == nil or enemy.pathInterp > 1 then
				if enemy.pathInterp and enemy.pathInterp > 1 then
					table.remove(enemy.path, 1)
				end

				enemy.pathInterp = 0
				enemy.pathStartPos = {enemy.path[1][2] * TILESIZE, enemy.path[1][1] * TILESIZE}
				enemy.pathEndPos = {enemy.path[2][2] * TILESIZE, enemy.path[2][1] * TILESIZE}
				local speed = const.TILESIZE * 5.0
				enemy.pathInterpSpeed = speed / vnorm(vsub(enemy.pathStartPos, enemy.pathEndPos))
			end

			enemy.pathInterp = enemy.pathInterp + enemy.pathInterpSpeed * SIM_DT
			enemy.targetPosition = vlerp(enemy.pathStartPos, enemy.pathEndPos, enemy.pathInterp)

			local rel = vsub(enemy.targetPosition, enemy.position)
			enemy.velocity = vmul(vnormed(rel), const.TILESIZE * 5.0)
			enemy.targetAngle = vangle(enemy.velocity)
		end

		enemy.animationSet:update(const.SIM_DT)
	end
end

function angleDiff(a, b)
	local temp = (a - b) % (2*math.pi)
	if temp > math.pi then
		temp = - 2*math.pi + temp
	end
	if temp <= - math.pi then
		temp = 2*math.pi - temp
	end
	return temp
end
