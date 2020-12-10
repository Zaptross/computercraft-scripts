-- Mainframe Functions
function MF_sendFile(intRecipient)
end


---- Remote Device Functions ----
-- Update the mainframe with a message
function RD_upMain(strMessage)
	rednet.send(3, strMessage, "MAIN")
end

-- Update the mainframe with the current fuel level AND a message
function RD_upMainFuel(strMessage)
	local fuel = "Fuel: " + turtle.getFuelLevel()
	local message = fuel + strMessage
	RD_upMain(message)
end