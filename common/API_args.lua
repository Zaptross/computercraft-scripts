function parseArgs(args, tbl_args)
	parsedArgs = {}
	args_rem = true
	args_curr = 1
	while args_rem do
		if args[args_curr] ~= nil then
			-- write(args[args_curr].."\n") -- Debugging line
			
			--[[ 	Check if the args contain the current argument, 
					and append the arg and success to the output table 
			]]--
			table.insert(parsedArgs, {args[args_curr], contains(tbl_args, args[args_curr])})
			
			args_curr = args_curr + 1
		else
			args_rem = false
		end
	end
	
	return parsedArgs
end

function contains(...)
	chkTable = arg[1]
	contValue = arg[2]	
	
	-- intMode 1: if one or more, return true instantly
	-- intMode 2: if one or more, return count at end
	if notNil(arg[3]) then
		intMode = arg[3]
	else
		intMode = 1
	end
	
	itemNo = 1
	itemRem = true
	itemCount = 0
	while itemRem do
		
		if chkTable[itemNo] ~= nil then
			
			if chkTable[itemNo] == contValue then
			
				if intMode == 1 then
					return true
				elseif intMode == 2 then
					itemCount = itemCount + 1					
				end
				
			end
			itemNo = itemNo + 1
		else
			itemRem = false
		end
	end
	
	if intMode == 1 then
		return false
	elseif intMode == 2 then
		return itemCount
	end
end

function notNil(chkNotNil)
	if chkNotNil ~= nil then
		return true
	end
	return false
end