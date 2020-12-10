local endLoop = false

function checkObsidian()
	turtle.select(2)
	if turtle.compare() then
		turtle.dig()
	end
	turtle.select(1)
end

function checkBoxedIn()
	-- Count the number of sides
	LFR = 0
	
	-- Check if there is a block to the left
	turtle.turnLeft()
	if turtle.detect() then 
		LFR = LFR + 1 
	end
	turtle.turnRight()
	
	-- Check if there is a box forwards
	if turtle.detect() then
		LFR = LFR + 1
	end
	
	-- Check right
	turtle.turnRight()
	if turtle.detect() then
		LFR = LFR + 1
	end
	turtle.turnLeft()
	
	if LFR == 3 then
		endLoop = true
	end
end

function lavaRefuel()
	turtle.placeDown()
	turtle.refuel()
	lavaRefuel_downLoop()
end
function lavaRefuel_downLoop()
	wentDown = false
	if turtle.down() then
		wentDown = true
	else 
		wentDown = false
	end
	if not turtle.detectDown() then
		turtle.placeDown()
		turtle.refuel()
		lavaRefuel_downLoop()
	end
	if wentDown then
		turtle.up()
	end
end

-- Declare the initial turn as a left turn
local left = true
function turnToggle()
	if left then
		turtle.turnLeft()
		checkObsidian()
		turtle.forward()
		lavaRefuel()
		turtle.turnLeft()
		checkObsidian()
		turtle.forward()
		left = false
	else
		turtle.turnRight()
		checkObsidian()
		turtle.forward()
		lavaRefuel()
		turtle.turnRight()
		checkObsidian()
		turtle.forward()
		left = true
	end
end

-- If the fuel is mostly full, return true
function checkFuelFull()
	if turtle.getFuelLevel() > 19500 then
		return true
	else
		return false
	end
end

-- Main Loop
while not endLoop do
	lavaRefuel()
	-- if there is obsidian in front of the turtle, dig it.
	checkObsidian()
	-- If the turtle doesn't detect a block forward, move forward
	if not turtle.detect() then
		turtle.forward()
	else
		checkBoxedIn()
		if not endLoop then
			turnToggle()
		end
		if checkFuelFull() then
			endLoop = true
			if left then
				turtle.turnRight()
				while not turtle.detect() do
					turtle.forward()
				end
				turtle.turnRight()
				while not turtle.detect() do
					turtle.forward()
				end
			else
				turtle.turnLeft()
				while not turtle.detect() do
					turtle.forward()
				end
				turtle.turnRight()
				while not turtle.detect() do
					turtle.forward()
				end
			end
		end
	end
end

write("New Fuel Total: " .. turtle.getFuelLevel())



