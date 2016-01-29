camera = {
    position = {0, 0},
    targetPosition = {0, 0},
    scale = 1.0,
    targetScale = 1.0
}

function getCenterAndDist(axisIndex)
    local center, dist = 0, 0
    for i, player in ipairs(players) do
        center = center + player.position[axisIndex]
        local lookVec = vpolar(player.angle, const.camera.VIEW_OFFSET)
        center = center + lookVec[axisIndex]
    end
    center = center / #players / 2

    for i, player in ipairs(players) do
        local d = math.abs(player.position[axisIndex] - center) + const.camera.PLAYER_MARGIN
        if d > dist then dist = d end
    end

    return center, dist
end

function camera.update()
    -- calculate target values
    local centerX, distX = getCenterAndDist(1)
    local centerY, distY = getCenterAndDist(2)
    camera.targetPosition = {centerX, centerY}
    local scaleX = love.graphics.getWidth()/2/distX
    local scaleY = love.graphics.getHeight()/2/distY
    camera.targetScale = math.min(scaleX, scaleY, const.camera.MAX_SCALE)

    -- lerp and apply
    local tfac = const.camera.MOVE_SPEED * const.SIM_DT
    -- Interpolation
    camera.position[1] = camera.position[1] + (camera.targetPosition[1] - camera.position[1]) * tfac
    camera.position[2] = camera.position[2] + (camera.targetPosition[2] - camera.position[2]) * tfac

    -- scale
    camera.scale = camera.scale + (camera.targetScale - camera.scale) * const.camera.SCALE_SPEED * const.SIM_DT
end

function camera.push()
    love.graphics.push()
    -- Center Screen
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    -- Here I swap scale and translate, so I can scale the translation myself and floor the values, to prevent sub-pixel-flickering around the edges
    local tx = -math.floor(camera.position[1] * camera.scale)
    local ty = -math.floor(camera.position[2] * camera.scale)
    love.graphics.translate(tx, ty)
    -- FIXME: flickering on edges caused by pixel positions not being whole numbers after scaling (see math.floor in translate). ?
    love.graphics.scale(camera.scale, camera.scale)
end

camera.pop = love.graphics.pop

function camera.screenToWorld(x, y)

end

function camera.worldToScreen(x, y)

end