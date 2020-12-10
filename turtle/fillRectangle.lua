local continue = true
local slot = 2
local endCondition = 0

turtle.select(slot)

while continue do

    if not turtle.detectDown() then

        endCondition = 0
        
        -- check that there is an item to place
        if turtle.getItemCount(slot) == 0 then
            slot = slot + 1
            turtle.select(slot)
        end
        
        -- place down and move forward
        turtle.placeDown()
        turtle.forward()

    else

        -- turn left and circle in
        turtle.back()
        turtle.turnLeft()

        -- Place a glowstone here
        turtle.digDown()
        turtle.select(1)
        turtle.placeDown()
        turtle.select(slot)

        -- get going again
        turtle.forward()

        endCondition = endCondition + 1
    end

    -- If the turtle as turned 3 times consecutively without placing, end the script
    if endCondition > 3 then 
        continue = false
    end

end