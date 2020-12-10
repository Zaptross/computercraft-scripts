---------------------------------------
--------- Config Variables
-- Number of trees per side ( i.e. 5 x 5 )
farmSize = 5
-- Minimum amount of movements to have after refueling
MinFuel = 800

----------------------------------------
--------- Control variables
-- Is currently at it's home square
isHome = true

-- Display functions
messageLevel = { DEBUG = 0, INFO = 1, WARNING = 2, ERROR = 3, FATAL = 4 }
status_STATE = "Status: "
status_FUEL = "Fuel: "
status_POS = "Position: "
statusLines = { BOT = 1, FUEL = 2, POSITION = 3, FACING = 4, STATUS = 6 }
stateLine = 2

function updateStatus(statusString, statusMessage, statusLevel, statusLine)
	term.setCursorPos(1, statusLine)
	term.clearLine()
	write(statusString)
	write(statusMessage)
	rednetMessage = status_FUEL..turtle.getFuelLevel().." "..statusString..statusMessage
	rednet.send(3, rednetMessage, "MAIN")
end

function updateStatusLine()
	updateStatus(status_STATE, getStateName(), messageLevel.INFO, statusLines.STATUS)
end

function updateFuel()
	updateStatus(status_FUEL, turtle.getFuelLevel(), messageLevel.INFO, statusLines.FUEL)
end

function updateFacingLine()
	if currentDirection == 0 then faceString = "EAST"
	elseif currentDirection == 1 then faceString = "SOUTH"
	elseif currentDirection == 2 then faceString = "WEST"
	elseif currentDirection == 3 then faceString = "NORTH"
	end
	faceString = faceString
	updateStatus("Facing: ", faceString, messageLevel.INFO, statusLines.FACING)
end

function updatePositionLine()
	positionString = "X: " .. curXPos .. " Y: " .. curYPos
	updateStatus(status_POS, positionString, messageLevel.INFO, statusLines.POSITION)
end


-- State functions
function getStateName()
	if currentState == 0 then return "WAITING"
	elseif currentState == 1 then return "FURNACING"
	elseif currentState == 2 then return "DROPPING"
	elseif currentState == 3 then return "RESTOCKING"
	elseif currentState == 4 then return "CHECKING"
	elseif currentState == 5 then return "CUTTING"
	elseif currentState == 6 then return "PLANTING"
	elseif currentState == 7 then return "CHECK_HOME"
	end
end
states = {WAITING = 0, FURNACING = 1, DROPPING = 2, RESTOCKING = 3, CHECKING = 4, CUTTING = 5, PLANTING = 6, CHECK_HOME = 7}
currentState = states.WAITING

function updateState(state)
	if currentState ~= state then
		currentState = state
		updateStatusLine()
	end
end

-- Check if home
function CheckHome()
	updateState(states.CHECK_HOME)
	turtle.select(slot.CHEST)
	mainChest = turtle.compare()
	turtle.turnRight()
	saplingChest = turtle.compare()
	turtle.turnLeft()
	turtle.turnLeft()
	furnace = not turtle.compare()
	if mainChest and saplingChest and furnace then
		return true
	else
		return false
	end
end

-- Furnace functions
function WoodIntoFurnace()
	turtle.up()
	turtle.forward()
	dropWood(useDirection.DOWN)
	turtle.suckDown(1)
	turtle.back()
	turtle.down()
end

function CharcoalIntoFurnace()
	turtle.down()
	turtle.forward()
	turtle.select(slot.CHARCOAL)
	dropAllButOne(useDirection.UP)
	turtle.back()
	turtle.up()
end

function CharcoalSuck()
	turtle.down()
	turtle.forward()
	
	turtle.select(slot.CHARCOAL)
	if turtle.getItemCount() < 64 then
		turtle.suckUp()
	end
	
	turtle.back()
	turtle.up()
end

function CheckAndRefuel()
	if turtle.getFuelLevel() < MinFuel then
		turtle.select(slot.CHARCOAL)
		while turtle.getFuelLevel() < MinFuel and turtle.getItemCount() > 1 do
			turtle.refuel(1)
		end
		return true
	end
	return false
end

function FurnaceLoop()
	updateState(states.FURNACING)
	--updateFuel()
	faceAfter = currentDirection	
	face(facing.NORTH)
	
	CharcoalSuck()
	if CheckAndRefuel() then
		CharcoalSuck()
	end
	WoodIntoFurnace()
	CharcoalIntoFurnace()
	
	face(faceAfter)
end


-- Drop Functions
slot = {WOOD=9, APPLE=10, LEAF=11, CHARCOAL=12, CHEST=13, DIRT=14, TORCH=15, SAPLING=16}
useDirection = {DOWN=0, FORWARD=1, UP=2}

function dropAllButOne(direction, dropAllButThis)
	dropAllButThis = dropAllButThis or 1
	if (turtle.getItemCount() - dropAllButThis) >= dropAllButThis then
		if direction == 0 then result = turtle.dropDown(turtle.getItemCount() - dropAllButThis)
		elseif direction == 1 then result = turtle.drop(turtle.getItemCount() - dropAllButThis)
		elseif direction == 2 then result = turtle.dropUp(turtle.getItemCount() - dropAllButThis)
		end
		return result
	end
end

function dropWood(direction)
	stackDownWood()
	for fromSlot=1,slot.WOOD do
		if turtle.getItemCount(fromSlot) > 1 then
			turtle.select(fromSlot)
		end
		if not dropAllButOne(direction) then
			fromSlot = slot.WOOD + 1
		end
	end
end

function stackDownWood()
	for toSlot=1,slot.WOOD do
		if turtle.getItemCount(toSlot) < 64 then
			for fromSlot=slot.WOOD,toSlot,-1 do
				if turtle.getItemCount(fromSlot) > 1 then
					turtle.select(fromSlot)
					turtle.transferTo(toSlot, turtle.getItemCount(fromSlot) - 1)
				end
			end
		end
	end
end

function dropExcess()
	-- drop all the wood profit
	dropWood(useDirection.FORWARD)
	-- drop all the apples
	turtle.select(slot.APPLE)
	dropAllButOne(useDirection.FORWARD)
	-- drop all the excess charcoal
	turtle.select(slot.CHARCOAL)
	dropAllButOne(useDirection.FORWARD, 10)
	-- drop all the excess saplings
	face(facing.SOUTH)
	turtle.select(slot.SAPLING)
	dropAllButOne(useDirection.FORWARD)
	
	face(facing.EAST)
end

-- Facing & movement functions
facing = {EAST=0, SOUTH=1, WEST=2, NORTH=3}
currentDirection = facing.EAST

curXPos = -3 
curYPos = 0

function move(direction)
	face(direction)
	-- X POSITION
	if direction == facing.EAST then
		if turtle.forward() then curXPos = curXPos - 1 else return false end
	elseif direction == facing.WEST then
		if turtle.forward() then curXPos = curXPos + 1 else return false end
	-- Y POSITION
	elseif direction == facing.SOUTH then
		if turtle.forward() then curYPos = curYPos + 1 else return false end
	elseif direction == facing.NORTH then
		if turtle.forward() then curYPos = curYPos - 1 else return false end
	end
	
	updatePositionLine()
	--updateFuel()
	return true
end

function turnLeft(times)
	times = times or 1
	if currentDirection == 0 then
		currentDirection = currentDirection + 3
	else
		currentDirection = (currentDirection - 1) % 4
	end
	for i=1,times do turtle.turnLeft() end
	
	updateFacingLine()
end
function turnRight(times)
	times = times or 1
	currentDirection = (currentDirection + 1) % 4
	for i=1,times do turtle.turnRight() end
	
	updateFacingLine()
end

function face(direction)
	while currentDirection ~= direction do
		if currentDirection == 3 and direction == 0 then
			turnRight()
		elseif  currentDirection - direction > 0 then
			turnLeft()
		else
			turnRight()
		end
	end
end

-- Compare functions
function checkBlock(blockSlot, direction)
	direction = direction or useDirection.FORWARD
	lastSlot = turtle.getSelectedSlot()
	turtle.select(blockSlot)
	
	if direction == useDirection.DOWN then result = turtle.compareDown()
	elseif direction == useDirection.FORWARD then result = turtle.compare()
	elseif direction == useDirection.UP then result = turtle.compareUp()
	end
	
	turtle.select(lastSlot)
	return result
end
function checkWood() return checkBlock(slot.WOOD) end
function checkWoodDown() return checkBlock(slot.WOOD, useDirection.DOWN) end
function checkWoodUp() return checkBlock(slot.WOOD, useDirection.UP) end

--------- Farming Functions

-- Sapling Functions
function PlantSapling()
	updateState(states.PLANTING)
	lastSlot = turtle.getSelectedSlot()
	turtle.select(slot.SAPLING)
	if turtle.getItemCount() > 1 then
		turtle.placeDown()
	end
	turtle.select(lastSlot)
end

function RestockSaplings()
	if turtle.getItemCount(slot.SAPLING) < 17 then
		faceAfter = currentDirection
		face(facing.SOUTH)
		turtle.suck(16)
		face(faceAfter)
	end
end

-- cutting functions

function cutLeaves()
	-- Y + 1
	turtle.dig()
	move(currentDirection)
	-- Y + 1, X - 1
	turnLeft()
	turtle.dig() turtle.digUp()
	move(currentDirection)
	-- X - 1
	turnLeft()
	turtle.dig() turtle.digUp()
	move(currentDirection)
	-- Y - 1, X - 1
	turtle.dig() turtle.digUp()
	move(currentDirection)
	-- Y - 1
	turnLeft()
	turtle.dig() turtle.digUp()
	move(currentDirection)
	-- X + 1, Y - 1
	turtle.dig() turtle.digUp()
	move(currentDirection)
	-- X + 1
	turnLeft()
	turtle.dig() turtle.digUp()
	move(currentDirection)
	-- X + 1, Y + 1
	turtle.dig() turtle.digUp()
	move(currentDirection)
	-- return and recenter
	turnLeft()
	move(currentDirection)
	turnLeft()
	move(currentDirection)
	turnLeft()
	turnLeft()
end

function digTree()
	if checkWood() then
		updateState(states.CUTTING)
		-- enter the tree
		turtle.dig()
		move(currentDirection)
		
		-- dig the surrounding leaves
		if checkBlock(slot.LEAF) then cutLeaves() end
		
		-- check there's wood down
		if checkWoodDown() then
			turtle.digDown()
			turtle.down()
			
			-- check there's dirt down
			if checkBlock(slot.DIRT, useDirection.DOWN) then
				-- if there is, plant a sapling
				turtle.up()
				PlantSapling()
			else
				-- if not, just move up
				turtle.up()
			end
		end
		
		updateState(states.CUTTING)
		-- while there is wood above
		while checkWoodUp() do
			-- dig then move up
			turtle.digUp()
			turtle.up()
			
			-- dig the surrounding leaves
			if checkBlock(slot.LEAF) then cutLeaves() end
		end
		
		-- return to normal height
		while not checkBlock(slot.SAPLING, useDirection.DOWN) do
			turtle.down()
		end
	end
end

function moveToNextTree()
	while not checkWood() and not checkBlock(slot.TORCH) do
		move(currentDirection)
		if checkBlock(slot.LEAF) then turtle.dig() end
	end
	if checkWood() then digTree() end
end

-----------------------------------------------------------------
------- MAIN LOOP
-- Initial Setup
term.clear()
term.setCursorPos(1,1)
term.write("--------  ANOTHER  --------\n")
--updateFuel()
updateFacingLine()
updatePositionLine()
updateStatusLine()

-- Start Loop
doMainLoop = true
rednet.open("right")

while doMainLoop do
	-- Face east and run the furnace loop
	if not currentDirection == facing.EAST then face(facing.EAST) end
	FurnaceLoop()
	dropExcess()
	RestockSaplings()
	
	while curXPos < 16 do
		-- Face west
		face(facing.WEST)
		if checkBlock(slot.LEAF) then turtle.dig() end
		move(currentDirection)
		if checkWood() then digTree() end
		
		-- at each row, cut down that row, then return
		if curXPos % 4 == 0 then
			-- face that row, then cut them down
			face(facing.SOUTH)
			while curYPos < 16 do
				if checkBlock(slot.LEAF) then turtle.dig() end
				move(currentDirection)
				if checkWood() then digTree() end
			end
			-- face back up that row, and return to the first tree
			face(facing.NORTH)
			while curYPos > 0 do
				if checkBlock(slot.LEAF) then turtle.dig() end
				move(currentDirection)
				if checkWood() then digTree() end
			end
		end
	end
	-- Return to home
	face(facing.EAST)
	while curXPos > -3 do
		if checkBlock(slot.LEAF) then turtle.dig() end
		move(currentDirection)
		if checkWood() then digTree() end		
	end
	
	-- Sleep for 1000 seconds
	updateState(states.WAITING)
	CheckAndRefuel()
	for sleepTime = 1, 1000 do
		sleepTimeString = getStateName()..": "..string.format(1000 - sleepTime)
		updateStatus(status_STATE, sleepTimeString, messageLevel.INFO, statusLines.STATUS)
		os.sleep(1)
	end
end



-- Cleanup after program
term.setCursorPos(1,5)



