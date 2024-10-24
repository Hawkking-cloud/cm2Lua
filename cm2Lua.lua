local cm2Lua = {}
local ipairs = ipairs

cm2Lua.silenceErrors = false
cm2Lua.dpasteFallback = false
local function error(text)
    if os then
        if os.getenv("TERM") ~= nil and os.getenv("TERM") ~= "dumb" then
            print("\27[31m[CM2LUA Error]: " .. text .. "\27[0m")
            return
        end
    end
    print("[CM2LUA Error]: " .. text)
end
cm2Lua.Save = {
    blocks = {},
    connections = {},
    buildings = {},
    wid = 0,
    ca=0, -- runtime, dont recommend touching this
}
cm2Lua.Save.__index = cm2Lua.Save
function cm2Lua.Save:new()
    return setmetatable({}, cm2Lua.Save)
end
function cm2Lua.Save:addBlock(...)
    local args = {...}
    if type(args[1]) == "table" then
        for _, block in ipairs(args) do
            if block.id then
                self.wid = self.wid + 1
                block.wid = self.wid
                self.blocks[self.wid] = block
            end
        end
    else
        local newBlock = cm2Lua.Block:new(args[1], args[2], args[3], args[4])
        if newBlock then
            self.wid = self.wid + 1
            newBlock.wid = self.wid
            self.blocks[self.wid] = newBlock
        end
    end
end

function cm2Lua.Save:addBlocks(...)
    local args = {...}
    for _, block in ipairs(args) do
        self.wid = self.wid + 1
        block.wid = self.wid
        self.blocks[self.wid] = block
    end
end
function cm2Lua.Save:addBlockTable(table)
    local blocks = self.blocks
    local wid = self.wid
    for _, block in ipairs(table) do
        wid = wid + 1
        block.wid = wid
        blocks[wid] = block
    end
end
function cm2Lua.Save:addWire(arg1,arg2)
    if type(arg1) == "table" and arg1.wid and arg1.wid ~= 0 then
        if type(arg2) == "table" and arg2.wid and arg2.wid ~= 0 then
            self.ca=self.ca+1
            self.connections[self.ca]={b1=arg1,b2=arg2}
        end
    elseif type(arg1) == "number" then
    	self.ca=self.ca+1
    	self.connections[self.ca]={b1=self.blocks[arg1],b2=self.blocks[arg2]}
    end
end
function cm2Lua.Save:findBlock(x,y,z)	
	local x=x or 0
	local y=y or 0
	local z=z or 0
	for _,block in ipairs(self.blocks) do
		if block.x==x and block.y==y and block.z==z then
			return block
		end
	end
	return nil
end
function cm2Lua.Save:import(savestring,x,y,z)
	local x=x or 0
	local y=y or 0
	local z=z or 0
	local function splitString(inputStr, delimiter)
	    local result = {}
	    for part in string.gmatch(inputStr, "[^" .. delimiter .. "]+") do
	        table.insert(result, part)
	    end
	    return result
	end
	for _,blockText in ipairs(splitString(splitString(savestring,"?")[1],";"))do
		local args=splitString(blockText,",")
		local newBlock=cm2Lua.Block:new(tonumber(args[1])+x,tonumber(args[3])+y,tonumber(args[4])+z,tonumber(args[5]))
		newBlock.active=(args[2]=="1")
		newBlock.args=args[6]
		self:addBlock(newBlock)
	end
	for _,conText in ipairs(splitString(splitString(savestring,"?")[2] or "",";"))do
		self:addWire(tonumber(splitString(conText,",")[1]),tonumber(splitString(conText,",")[2]))
	end
end
function cm2Lua.Save:export()
    local blockTokens={}
    local index1=0
    local conTokens={}
    local index2=0
    for _,block in ipairs(self.blocks) do
    	blockTokens[index1+1]=block.id
    	blockTokens[index1+2]=","
    	blockTokens[index1+3]=block.active and "1" or "0"
    	blockTokens[index1+4]=","
    	blockTokens[index1+5]=block.x or "0"
    	blockTokens[index1+6]=","
    	blockTokens[index1+7]=block.y or "0"
    	blockTokens[index1+8]=","
    	blockTokens[index1+9]=block.z or "0"
    	blockTokens[index1+10]=","
    	blockTokens[index1+11]=block.args or ""
    	blockTokens[index1+12]=";"
    	index1=index1+12
    end
	for _,con in ipairs(self.connections) do
    	conTokens[index2+1]=con.b1.wid
    	conTokens[index2+2]=","
    	conTokens[index2+3]=con.b2.wid
    	conTokens[index2+4]=";"
    	index2=index2+4
    end
    if blockTokens[index1]==";" then blockTokens[index1]=nil end
    if conTokens[index2]==";" then conTokens[index2]=nil end
    return table.concat(blockTokens) .. "?" .. table.concat(conTokens) .. "??"
end
function cm2Lua.Save:exportToDpaste()
    local function check_library(lib)
        local success, library = pcall(require, lib)
        if not success then
            error(" {" .. lib .. "} Is required for cm2Lua.Save:exportToDpaste()")
            return nil
        end
        return library
    end
    local http = check_library("socket.http")
    local ltn12 = check_library("ltn12")

    local ssl = check_library("ssl")
    local exported = self:export()
    if http and ltn12 and ssl then
        local req = "format=url&expires=2592000&content=" .. exported
        local headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["Content-Length"] = tostring(#req)
        }
        local resBody = {}
        local res, code, headers, status =
            http.request {
            url = "https://dpaste.org/api/",
            method = "POST",
            content = exported,
            headers = headers,
            source = ltn12.source.string(req),
            sink = ltn12.sink.table(resBody)
        }
        if code == 200 then
            return resBody[1]:gsub("%s+", "") .. "/raw"
        else
            if cm2Lua.dpasteFallback then
                error("Export to dpaste failed," .. status .. ", falling back")
                return exported
            else
                error("Export to dpaste failed, " .. status .. " set cm2Lua.dpasteFallback to true to resort to {cm2Lua:export() by default")
                return nil  
            end
        end
    else
        error(" Missing dependencies could be solved by running luarocks install luasocket and luarocks install luasec")
    end
end

cm2Lua.Block = {
    id = 0,
    active = false,
    x = 0,
    y = 0,
    z = 0,
    args = "",
    wid = 0
}
cm2Lua.Block.__index = cm2Lua.Block

function cm2Lua.Block:new(id, x, y, z)
    local newBlock = setmetatable({}, cm2Lua.Block)
    if not id then
        error("Block function needs atleast ID parameter")
        return
    end
    newBlock.id = id
    newBlock.x = x or 0
    newBlock.y = y or 0
    newBlock.z = z or 0
    return newBlock
end
	
return cm2Lua
