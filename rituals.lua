rituals = {
}

ritualTypes = {
	{name = "doorOpen", id = 1, ritMsg = "Open a door", state = false},
	{name = "objWomen01", id = 2, ritMsg = "\"Interact\" with a blonde woman", state = false},
	{name = "objWomen02", id = 3, ritMsg = "\"Interact\" with a black haird woman", state = false},
	{name = "objVase", id = 4, ritMsg = "Steal a vase", state = false},
	{name = "hit", id = 5, ritMsg = "Hit the other player", state = false},
	{name = "objTable", id = 6, ritMsg = "Steal a table", state = false},
	{name = "objBath", id = 7, ritMsg = "You really need to wash yourself! Get in the bathtub", state = false}
}


--//for k, v in pairs(rituals) do
--	table.insert(ritualNames, k)
--end
genericRitual = {}

function newRitual(ritualType)
	local ritual = {}
	ritual.type = ritualType
	setmetatable(ritualTypes[ritualType], {__index = genericRitual})
	setmetatable(ritual, {__index = ritualTypes[ritualType]})
	table.insert(rituals, ritual)
	return ritual
end

function generateRituals(number)
	local ret = {}
	for i = 1, number-1 do
		table.insert(ret, newRitual(love.math.random(1, #ritualTypes)))
	end
	--es soll immer beendet werden mit dem Schlag eines Gegners
	table.insert(ret, newRitual(5))
	ret[number].ritMsg = "FINISH the other player!!!"
	return ret
end

function progressRitual(player, id)
	actualRit = getActualRitual(player)
	if player.rituals[actualRit].id == id then
		player.rituals[actualRit].state = true
		player.rituals[actualRit].ritMsg= ""..player.rituals[actualRit].ritMsg.." DONE"
	end
end

function getActualRitual(player)
	for i = 1, #player.rituals do
		if player.rituals[i].state == false then
			return i
		end
	end
	return -1
end

function hasWon(player)
	return getActualRitual(player) == -1
end

--progressRitual(player, "doorOpen")