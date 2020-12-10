local cobble = 1
local dirt = 2
local gravel = 3
local brick = 4
local mossbrick = 5

function dropAllButOne()
	if (turtle.getItemCount() - 1) > 0 then
		turtle.dropUp(turtle.getItemCount() - 1)
	end
end

function updateStatus(statusString)
	term.clearLine()
	xCur, yCur = term.getCursorPos()
	term.setCursorPos(1, yCur)
	write("Status: ")
	write(statusString)
end

function checkFacing()
	turtle.select(cobble)
	while not turtle.compare() do
		turtle.turnLeft()
	end
	turtle.turnLeft()
end

-- Write quarry droid to the screen
term.clear()
write("Quarry Sorting Droid \n ------------------------ \n")

-- Mainloop
local consecutiveFails = 0

checkFacing()

while true do
	suckCount = 0
	continueSuck = true
	-- Face Input Chest and suck as much as possible
	updateStatus("Sucking up objects...")
	while continueSuck do
		-- if items are sucked up
		if turtle.suck() then
			suckCount = suckCount + 1
		else
			continueSuck = false
			if suckCount == 0 then
				consecutiveFails = consecutiveFails + 1
			else
				consecutiveFails = 0
			end
		end
	end
	-- Face goodstuff chest
	updateStatus("Sorting objects away...")
	turtle.turnLeft()
	-- For each slot
	for currentSlot=16,1,-1 do
		-- Select that slot
		turtle.select(currentSlot)
		
		-- if that slot isn't cobble
		if not turtle.compareTo(cobble) then
		
			-- if that slot isn't dirt
			if not turtle.compareTo(dirt) then
			
				-- if that slot isn't gravel
				if not turtle.compareTo(gravel) then
				
					-- if that slot isn't brick
					if not turtle.compareTo(brick) then
					
						-- if that slot isn't mossbrick ( or any other waste block )
						if not turtle.compareTo(mossbrick) then
							turtle.drop() -- drop it into the goodstuff chest
						else
							if currentSlot == mossbrick then
								dropAllButOne()
							else
								turtle.dropUp()
							end
						end
					else
						if currentSlot == brick then
							dropAllButOne()
						else
							turtle.dropUp()
						end
					end
				else
					if currentSlot == gravel then
						dropAllButOne()
					else
						turtle.dropUp()
					end
				end
			else
				if currentSlot == dirt then
					dropAllButOne()
				else
					turtle.dropUp()
				end
			end
		else
			if currentSlot == cobble then
				dropAllButOne()
			else
				turtle.dropUp()
			end
		end
	end
	-- Face the input chest again
	updateStatus("Resetting...")
	turtle.turnRight()
	
	if consecutiveFails >= 3 then
		for cycles=1,100 do
			updateStatus("Sleeping for " .. string.format(100 - cycles) .. " seconds...")
			os.sleep(1)
		end
	end
end