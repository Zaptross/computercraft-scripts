
-- CURRENT BUG: CheckForUpdates updates last update date of ALL files every time

-- Check ScriptLength file exists, if not make one
local UpdateFileName = "LastUpdateFile.txt"
function CheckScriptFile()

    -- If the file doesn't exist, make it
    if (not fs.exists(UpdateFileName)) then
        file = fs.open(UpdateFileName, "w")
        file.close()
        return true
    else
        return true
    end
    return false -- Should be unreachable
end

-- NOTE: FILE LENGTHS STORED AS "fileName,fileSize,lastUpdated"

-- Check all API and scripts, write their character lengths to a file
function MF_CheckForUpdates(debugArg)
    
    -- Updates stored as 
    local updates = {}
    
    -- Check the file exists
    if CheckScriptFile() then
        
        local storedLengths = ReadLastUpdates()
        local currentLengths = GetCurrentSizes()

        local file = fs.open(UpdateFileName, "w")

        print(#storedLengths.." :(s:c): "..#currentLengths)

        -- for each current file
        for i, currentFile in ipairs(currentLengths) do

            -- if debugging
            if (debugArg == 1) then print("Current:"..currentFile[1]..","..currentFile[2]..","..currentFile[3].."\n") end

            if (#storedLengths == 0) then storedLengths[1] = {"API_update",0,0} end

            -- for each stored file
            for j, storedFile in ipairs(storedLengths) do

                -- if debugging
                if (debugArg == 1) then print("Stored:"..storedFile[1][1]..","..storedFile[1][2]..","..storedFile[1][3].."\n") end
                
                -- If this is the same named file
                if storedFile[1][1] == currentFile[1] then

                    print("Matched filenames\n")

                    -- If they don't have the same fileSize
                    if storedFile[1][2] ~= currentFile[2] then
                        
                        -- store the name,size,date of the updated file
                        updates[#updates + 1] = currentFile

                        print("Stored updated file\n")
                                            
                    else -- If this is the same name, but they do have the same file size

                        -- Store the older update
                        updates[#updates + 1] = storedFile[1]
                        print("Stored non-updated file\n")
                    end

                    break -- if this filename was found, skip the rest of the stored pairs
                end

                -- If this element isn't the right one AND is the last element
                if (storedFile[1][1] ~= currentFile[1] and j == #storedLengths) then

                    -- And the file currently exists
                    if (fs.exists(currentFile[1])) then

                        -- This must be a new file, add it to the updates list with the current date as last update
                        updates[#updates + 1] = currentFile

                    end -- Catches and deletes files which no longer exist
                end
            end

            -- if debugging
            --if (debugArg == 1) then term.write("Updated:"..updates[#updates][1]..updates[#updates][2]..updates[#updates][3]) end
        end

        -- for all files, store the updated code checks
        for i, update in ipairs(updates) do
            file.writeLine(update)
        end
        
        print("UpdateLines: "..#updates)

        -- Close the scriptsize file
        file.close()
        print("Closed")
    end    

    return updates
end

function GetCurrentSizes()
    local lengths = {}

    local currentDateTime = GetDateTime()
    
    -- Get a table with all the files and directories available
    local FileList = fs.list("")
    
    --For each file, store the fileName, and discard each key "_"
    for i, fileName in ipairs(FileList) do
        
        -- store the fileName and size
        lengths[i] = {fileName, fs.getSize(fileName), currentDateTime}

    end

    return lengths
end

function ReadLastUpdates()
    -- Records in lengths stored as lengths[i] = {str, size, "date"}
    local lengths = {}
        
    -- Open the file for reading
    local file = fs.open(UpdateFileName, "r")

    local index = 0
    local fileEnd = false

    while not fileEnd do
        
        -- Get the next line
        line = file.readLine()
        
        -- If this isn't the last line
        if line ~= nil then
            index = index + 1

            -- Split that line into name and fileSize
            name, fileSize, lastUp = splitStr(line, ",")

            -- Store those as a table containing a string and a number
            lengths[index] = {name, tonumber(fileSize), tonumber(lastUp)}
        else
            -- If this is the end of the file, end this loop and close the file
            fileEnd = true
            file.close()
        end            

    end

    print(#lengths)
    return lengths
end

-- Get custom formatted datetime
function GetDateTime()
    local time = os.time()
    local date = os.day()

    return date * 24 + time
end


-- Thanks Egor Skriptunoff for a line counter
function CountLines(path)
    local counter = 0
    for _ in io.lines(path) do
        counter = counter + 1
    end
    return counter
end

-- split a string on it's separator, return each part, recursively 
function splitStr(str, sep)
    local sep, outFields = sep or ",", {}
    
    local index = string.find(str, sep)

    outFields[1] = string.sub(str, 1, index - 1)
    outFields[2] = string.sub(str, index + 1)
    
    -- If this string could be split again
    if not (string.find(outFields[2], sep) == nil) then
        
        -- Recursively split that string
        local recFields = splitStr(outFields[2], sep)

        -- For each field found, add them to the output fields
        for _, field in ipairs(recFields) do
            outFields[#outFields + 1] = field
        end

    end

    return outFields
 end