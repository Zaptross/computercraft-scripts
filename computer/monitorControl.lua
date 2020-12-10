-- Setup 
args = { ... }
modem, monitor = API_perip.wrapSides()

-- Screen Variables
screenXmax, screenYmax = monitor.getSize()

---- Functions
-- ScreenLayout
function doMainFrameLayout()
	monitor.clear()
	monitor.setCursorPos(1,1)
	name = "+--- MAINFRAME ----"
	monitor.write(name)
	for i = 1, screenXmax - 20 do
		monitor.write("-")
	end
	monitor.write("+")
	for i = 2, screenYmax - 1 do
		monitor.setCursorPos(1, i)
		monitor.write("|")
		monitor.setCursorPos(screenXmax,i)
		monitor.write("|")
	end
	monitor.setCursorPos(1,screenYmax)
	monitor.write("+")
	for i = 1, screenXmax - 2 do
		monitor.write("-")
	end
	monitor.write("+")
end

function doReceivedLayouts()
	for i = 0, 3 do
		if lastMessage[i] ~= nil then
			stdLayout(i)
		end
	end
end

function stdLayout(num)
	monitor.setCursorPos(3, num * 3)
	monitor.write("-- "..lastSenderId[num].." --")
	monitor.setCursorPos(3, 1 + num * 3)
	monitor.write(lastMessage[num])
end

-- Rednet
layoutType = {	nil,		nil, 			nil, 		nil}
lastSenderId = {"PRIME", 	"TREE FARM", 	"Worker", 	"MAINFRAME"}
lastMessage = { nil, nil, nil, nil}
lastProtocol = {"", "", "", ""}

function receiveInfo()
	senderId, message, protocol = rednet.receive("MAIN", 10)
	if senderId ~= nil then
		senderId = senderId + 1
		lastMessage[senderId] = tostring(message)
		lastProtocol[senderId] = tostring(protocol)

		termLogX, termLogY = term.getCursorPos()
	
		term.setCursorPos(1,1)
		term.write("----------------------- LOG -----------------------\n")
	
		term.setCursorPos(1, 2 + (termLogY)%18)
		term.write(tostring(senderId).."\t"..tostring(message).."\t"..tostring(protocol).."\n")
		term.setCursorPos(1, 3 + (termLogY + 1)%17)
		term.clearLine()
		term.setCursorPos(1, 2 + (termLogY)%18)
	end
end



-- MAIN LOOP
while true do
	receiveInfo()
	doMainFrameLayout()
	doReceivedLayouts()
end