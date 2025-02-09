--- cm2Memory: A lua cm2 memory data generator
-- @module: cm2Memory
local mem = {}

--- Generate data for MassMemory
-- @param data A list containing all the numbers for data
-- @return A string containing the outputted data
function mem:MassMemory(data)
    if type(data) ~= "table" then
        error("[cm2Memory] Error: Data must be a table (array format).")
    end
    local length = #data
    local tokens = {}
    for i=1, length do 
        tokens[i]=string.format("%02x",data[i])
    end
    return table.concat(tokens)..string.rep("00",4096-length)
end

--- Generate data for MassiveMemory
-- @param data A list containing all the numbers for data
-- @return A string containing the outputted data
function mem:MassiveMemory(data)
    if type(data)~="table" then
        error("[cm2Memory] Error: Data must be a table (array format).")
    end
    local format = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local length = #data
    local tokens = {}
    for i=1,length do 
        local num=data[i];
        local token=""
        local tokenLength=0
        while num>0 do
            local remainder = num % 64
            token=token..format:sub(remainder+1,remainder+1)
            tokenLength=tokenLength+1
            num=math.floor(num/64)
        end
        tokens[i]=token..string.rep("A",3-tokenLength)
    end
    return table.concat(tokens)..string.rep("AAA",4096-length)
end

--- Generate data for DualMemory
-- @param data A list containing all the numbers for data
-- @return A string containing the outputted data
function mem:DualMemory(data)
    if type(data)~="table" then
        error("[cm2Memory] Error: Data must be a table (array format).")
    end
    return mem:MassMemory(data)
end

return mem
