input = {}

-- local controller = {}
-- controller.moveX = input.floatInput_fromGamepad(joystick, "axisx")
-- controller.moveX = input.floatInput_fromKeyboard("a", "d")

-- if controller.moveX.state > 0 then

-- if controller.action.pressed then

-- end

function input._control(getState)
	return {
		getState = getState,
		state = 0,
		lastState = 0,
		pressed = false,
		released = false
	}
end

function input.floatInput_fromKeyboard(negative, positive)
	return input._control(function() return (love.keyboard.isDown(positive) and 1.0 or 0.0) - (love.keyboard.isDown(negative) and 1.0 or 0.0) end)
end

function input.binaryInput_fromKeyboard(key)
	return input._control(function() return love.keyboard.isDown(key) end)
end

function input.binaryInput_fromGamepad(joystick, button)
	return input._control(function() return joystick:isGamepadDown(button) end)
end

function input.floatInput_fromGamepad(joystick, axis)
	return input._control(function() return joystick:getGamepadAxis(axis) end)
end

function input.binaryInput_fromFloatInput(control, threshold)
	local oldFunc = control.getState
	control.getState = function() return oldFunc() >= threshold end
	return control
end

function input.updateController(controller)
	for k, control in pairs(controller) do
		if not controller.frozen then
			control.lastState = control.state
			control.state = control.getState()
			if type(control.state) == "boolean" then control.state = (control.state and 1 or 0) end

			control.pressed = control.state > control.lastState
			control.released = control.state < control.lastState
		end
	end
end