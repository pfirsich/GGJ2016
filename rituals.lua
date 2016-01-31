rituals = {
	doorOpen = "Open a door"
}

ritualNames = {}
for k, v in pairs(rituals) do
	table.insert(ritualNames, k)
end

function generateRituals(number)
	local ret = {}
	for i = 1, number do
		table.insert(ret, ritualNames[love.math.random(1, #ritualNames)])
	end
	return ret
end

function progressRitual(player, name)
	if player.rituals[1] == name then
		table.remove(player.rituals, 1)
	end

	-- TODO: alle weg
end

--progressRitual(player, "doorOpen")