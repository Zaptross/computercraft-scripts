-- Startup arguments
args = { ... }

if args[1] == nil or args[1] == "h" or args[1] == "H" or args[1] == "-h" or args[1] == "-H" then
	term.write("Syntax: buildArea.lua (1/0:doDigs) (1/0:doPlaceUp) (1/0:doPlaceDown) (int:sideLength[default:23])\n")
	syntaxCheck = true
end

doDigs = args[1] > 0
doPlaceUp = args[2] > 0
doPlaceDown = args[3] > 0
sideLength = args[4] or 23

local dirt = 16

function selectCobble()
	for iSlot=1,9 do
		if turtle.getItemCount(iSlot) > 0 then
			turtle.select(iSlot)
			return true
		end
	end
end

-- if the user didn't check syntax
if not syntaxCheck then
	turtle.forward()

	-- main build loop
	for xPosition = 1,sideLength do
		if turtle.detect() and doDigs then
			turtle.dig()
		end
		-- every odd row
		if xPosition % 2 == 1 then
			for yPosition = 1,sideLength do
				-- if doDigs, check forward, up and down
				if turtle.detect() and doDigs then turtle.dig() end
				if turtle.detectUp() and doDigs then turtle.digUp() end
				if turtle.detectDown() and doDigs then turtle.digDown() end
				-- every fourth block, select the alternate block type
				if xPosition % 4 == 0 and yPosition % 4 == 0 then
					turtle.select(dirt)
				else
					selectCobble()
				end
				-- if each condition is true, place blocks accordingly
				if doPlaceUp then turtle.placeUp() end
				if doPlaceDown then selectCobble() turtle.placeDown() end
				
				turtle.forward()
			end
			-- at the end of a row, do a turn and place blocks, then complete the turn
			turtle.turnLeft()
			if turtle.detect() and doDigs then turtle.dig() end
			if turtle.detectUp() and doDigs then turtle.digUp() end
			if turtle.detectDown() and doDigs then turtle.digDown() end
			if doPlaceUp then turtle.placeUp() end
			if doPlaceDown then turtle.placeDown() end
			turtle.forward()
			turtle.turnLeft()
		else
			-- every even row
			for yPosition = 1,sideLength do
				-- if doDigs, check forward, up and down
				if turtle.detect() and doDigs then turtle.dig() end
				if turtle.detectUp() and doDigs then turtle.digUp() end
				if turtle.detectDown() and doDigs then turtle.digDown() end
				-- every fourth block, select the alternate block type
				if xPosition % 4 == 0 and yPosition % 4 == 0 then
					turtle.select(dirt)
				else
					selectCobble()
				end
				-- if each condition is true, place blocks accordingly
				if doPlaceUp then turtle.placeUp() end
				if doPlaceDown then selectCobble() turtle.placeDown() end
				
				turtle.forward())
			end
			-- at the end of a row, do a turn and place blocks, then complete the turn
			turtle.turnRight()
			if turtle.detect() and doDigs then turtle.dig() end
			if turtle.detectUp() and doDigs then turtle.digUp() end
			if turtle.detectDown() and doDigs then turtle.digDown() end
			if doPlaceUp then turtle.placeUp() end
			if doPlaceDown then turtle.placeDown() end
			turtle.forward()
			turtle.turnRight()
		end
	end

	-- return to the start
	turtle.turnLeft()
	for xPosition = 1,sideLength do
		turtle.forward()
	end
	turtle.turnRight()
	for yPosition = 1,sideLength do
		turtle.forward()
	end
end