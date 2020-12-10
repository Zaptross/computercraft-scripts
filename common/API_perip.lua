---- CALL IN EACH SCRIPT FUNCTIONS ----

function wrapSides()
    modem = nil
	monitor = nil
	sides = {"top", "right", "left", "front", "back", "bottom"}
	for side = 1, 6 do
		if peripheral.getType(sides[side]) == "monitor" then
			monitor = peripheral.wrap(sides[side])
		elseif peripheral.getType(sides[side]) == "modem" then
			modem = peripheral.wrap(sides[side])
			rednet.open(sides[side])
		end
	end
	return modem, monitor
end