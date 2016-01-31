parseMap = nil
queue = {}

function loadMapPF(name)

	for i, layer in ipairs(map.layers) do
		if layer.visible then
			if layer.type == "tilelayer" then
				parseMap = {}
				index = 1
				for y = 1, layer.width do
					teilMap = {}
					for x = 1, layer.width do
						local tileIndex = layer.data[index]
						index = index + 1
						if map.layers[1].solid[y][x] then
							teilMap[x]=0
						else
						    teilMap[x]=1

						end
					end
					parseMap[y]=teilMap
				end
			end
		end
	end
end

function findPath(sPosX, sPosY, ePosX, ePosY)
	local tRoot = {worldToTiles(sPosX, sPosY)}
	local root = {tRoot[2], tRoot[1], -1, -1}
	local tTarget = {worldToTiles(ePosX, ePosY)}
	local target = {tTarget[2], tTarget[1]}
	local place = {}
	local invalid = {}
	local switcher = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}
	queue = {}

	enqueue(root)
	zaehler = 1
	while zaehler ~=2000 do
		place = dequeue()
		local break1 = false

		if place[1] == target[1] and place[2] == target[2] then
			path = {}
			while place[3] ~= -1 do
				table.insert(path, {place[1], place[2]})
				for i = 1, #invalid do
					if invalid[i][1] == place[3] and invalid[i][2] == place[4] then
						place = invalid[i]
						break
					end
				end
			end
			table.insert(path, {place[1], place[2]})
			for i=1, #path do
				print(path[i][1]..path[i][2])
			end
			-- print("Schritt: "..#path)
			-- print ("zaehler: "..zaehler)
			return path

		else
			table.insert(invalid, place)
			for i = 1, 4 do
				break1 = false
				tempPlace = vadd(switcher[i], place)
				if parseMap[tempPlace[1]][tempPlace[2]]==0 then
				else
					for i = 1, #invalid do
						if invalid[i][1] == tempPlace[1] and invalid[i][2] == tempPlace[2] then
							break1 = true
							break
						end
					end

					if break1 then
						break
					end
					enqueue({tempPlace[1], tempPlace[2], place[1], place[2]})
				end
			end
		end
		zaehler = zaehler + 1
	end
	-- print("nix gefunden")
end

function enqueue(x)
	table.insert(queue, 1, x)
end

function dequeue()
	local temp = queue[#queue]
	table.remove(queue)
	return temp
end

function printMap()
	for y = 1, #parseMap do
		for x = 1, #parseMap[y] do
			print(parseMap[y][x])
		end
		print("_______________________")
	end
end