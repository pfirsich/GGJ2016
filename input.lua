input = {}

-- local controller = {}
-- controller.moveX = input.floatInput_fromGamepad(joystick, "axisx")
-- controller.moveX = input.floatInput_fromKeyboard("a", "d")

-- if controller.moveX.state > 0 then

-- if controller.moveX.action.pressed then

-- end

function input.floatInput_fromKeyboard(negative, positive)
	return {getState = function()
		return (love.keyboard.isDown(positive) and 1.0 or 0.0) - (love.keyboard.isDown(negative) and 1.0 or 0.0)
	}
end

function input.binaryInput_fromKeyboard(key)
	return {getState = function() return love.keyboard.isDown(key) end}
end

function input.updateController(controller)
	for k, control in pairs(ctrl) do
		control.lastState = control.state
		control.state = control.getState()
		if type(control.state) == "boolean" then control.state = control.state and 1 or 0

		control.pressed = control.state > control.lastState
		control.released = control.state < control.lastState
	end
end