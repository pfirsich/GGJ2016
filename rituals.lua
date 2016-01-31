rituals = {
}

ritualTypes = {
	{name = "doorOpen", id = 1, ritMsg = "Open a door", state = false},
	{name = "objWomen01", id = 2, ritMsg = "Kill a blond women", state = false},
	{name = "objWomen02", id = 3, ritMsg = "Marry a black haired women", state = false},
	{name = "objVase", id = 4, ritMsg = "Bang a Vasee", state = false},
	{name = "hit", id = 5, ritMsg = "Hit the other player", state = false},
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
	for i = 1, number do
		table.insert(ret, newRitual(love.math.random(1, #ritualTypes)))
	end
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