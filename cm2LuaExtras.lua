local extras={}

extras.cm2Lua={}

function extras:CLA(bits)
	if next(extras.cm2Lua)~=nil then	
		local cm2=extras.cm2Lua
	    -- made by hawk based on Kohtalee's
	    local save = cm2.Save:new()
	    
	    local carryNode = cm2.Block:new(15, bits+1, 0, bits+6)
	    local subNode = cm2.Block:new(15, -2, 0, 2)
	    local subToggle = cm2.Block:new(5, -2, 0, 0)

	    save:addBlocks(subNode, carryNode, subToggle)
	    save:addWire(subToggle, subNode)

	    for i = 0, bits - 1 do
	        local toggle1 = cm2.Block:new(5, i, 0, 0)
	        local toggle2 = cm2.Block:new(5, i, 1, 0)
	        local node1 = cm2.Block:new(15, i, 0, 2)
	        local node2 = cm2.Block:new(15, i, 1, 2)
	        
	        save:addBlocks(toggle1, toggle2, node1, node2)
	        save:addWire(toggle1, node1)
	        save:addWire(toggle2, node2)
	        
	        local xor2 = cm2.Block:new(3, i, 0, 3)
	        local and1 = cm2.Block:new(1, i, 0, 4)
	        
	        save:addBlocks(xor2, and1)
	        save:addWire(node1, xor2)
	        save:addWire(node2, xor2)
	        save:addWire(node1, and1)
	        save:addWire(node2, and1)
	        
	        local node3 = cm2.Block:new(15, i, 0, bits+5)
	        local xor3 = cm2.Block:new(3, i, 0, bits+6)
	        
	        save:addBlocks(node3, xor3)
	        save:addWire(xor2, xor3)
	        save:addWire(and1, node3)
	        
	        if i > 0 then
	            save:addWire(and1, node3)
	        else
	            save:addWire(subNode, xor3)
	        end
	    end
	    
	    save:addWire(save:findBlock(bits-1, 0, bits+5), carryNode)
	    
	    for i = 0, bits - 1 do
	        save:addWire(save:findBlock(i, 0, bits+5), save:findBlock(i+1, 0, bits+6))
	        
	        for j = 0, i do
	            local newAnd = cm2.Block:new(1, i, 0, 4 + bits - j)
	            save:addBlock(newAnd)
	            save:addWire(newAnd, save:findBlock(i, 0, bits+5))
	            
	            if j ~= i then
	                save:addWire(save:findBlock(i-j-1, 0, 4), newAnd)
	            end
	            
	            for l = 0, j do
	                save:addWire(save:findBlock(i-l, 0, 3), newAnd)
	            end
	            
	            if j == i then
	                save:addWire(subNode, newAnd)
	            end
	        end
	    end
	    
	    return save
	else
		print("{cm2Lua Extcras}: You need to set extras.cm2Lua before calling a function")
	end
end
function extras:text(text,seperateAmount)
	if next(extras.cm2Lua)==nil then print("{cm2Lua Extras}: You need to set extras.cm2Lua before calling a function") return end
	local cm2=extras.cm2Lua
    local save=cm2.Save:new()
    local cx=0
    local cy=0
    for i=1,#text do
        cx=cx+1
        local char=text:sub(i,i)
        if char=="\n" then
            cx=0
            cy=cy+1
        else
            local newBlock=cm2.Block:new(13,cx*(div or 0.5),0,cy)
            newBlock.args=string.byte(char)
            save:addBlock(newBlock)
        end
    end
    return save
end
function extras:hollow(save)
    if next(extras.cm2Lua) == nil then 
        print("{cm2Lua Extras}: You need to set extras.cm2Lua before calling a function") 
        return 
    end
    
    local cm2 = extras.cm2Lua
    local toRemove = {}

    for _, block in ipairs(save.blocks) do
        if save:findBlock(block.x + 1, block.y, block.z) ~= nil and 
           save:findBlock(block.x - 1, block.y, block.z) ~= nil and
           save:findBlock(block.x, block.y + 1, block.z) ~= nil and
           save:findBlock(block.x, block.y - 1, block.z) ~= nil and
           save:findBlock(block.x, block.y, block.z + 1) ~= nil and
           save:findBlock(block.x, block.y, block.z - 1) ~= nil then
            
            table.insert(toRemove, block.wid) 
        end
    end
    for i = #save.blocks, 1, -1 do 
        for _, wid in ipairs(toRemove) do
            if save.blocks[i].wid == wid then
                table.remove(save.blocks, i)
                break 
            end
        end
    end
end
function extras:photo(path,width,height)
	local function check_library(lib)
        local success, library = pcall(require, lib)
        if not success then
            error(" {" .. lib .. "} Is required for extras:photo()")
            return nil
        end
        return library
    end
    local function round(num)
	    return math.floor(num + 0.5)
	end
    local magick=check_library("magick")
    local save=extras.cm2Lua.Save:new()
    if magick then
    	local img = assert(magick.load_image(path))
    	img:resize(width or img:get_width(), height or img:get_height())
    	for x=1,img:get_width() do
    		for y=1,img:get_height() do
    			local r,g,b,_=img:get_pixel(x,y)
    			local newBlock=extras.cm2Lua.Block:new(14,x,img:get_height()-y)
    			newBlock.args=tostring(round(r*255)).."+"..tostring(round(g*255)).."+"..tostring(round(b*255)).."+1+0"
    			save:addBlock(newBlock)
    		end
    	end
    	img:destroy()
    	return save
    end
    return nil
end
function extras:decoder(bits,rect)
	local function check_library(lib)
        local success, library = pcall(require, lib)
        if not success then
            error(" {" .. lib .. "} Is required for extras:photo()")
            return nil
        end
        return library
    end
    local save=extras.cm2Lua.Save:new()
    local b=extras.cm2Lua.Block
    for i=0,bits-1 do
    	local newToggle=b:new(5,i,0,-2)
    	local newNode=b:new(15,i)
    	local newNot=b:new(0,i,0,1)
    	save:addBlocks(newToggle,newNode,newNot)
    	save:addWire(newToggle,newNode)
    	save:addWire(newNode,newNot)
    end
    for i=0,2^bits-1 do
    	local function toBin(number)
			  local remainder = ""
			  while number > 0 do
			        remainder = tostring(number % 2)..remainder
			        number = math.floor(number/2)
			  end
			  while #remainder<bits do
			  	remainder="0"..remainder
			  end
			  return remainder
			end
    	local r=rect or false
    	if r then
    		local mod=i-(i%bits)*bits
    		local newAnd=b:new(1,i%bits,math.floor(i/bits),3)
	    	save:addBlock(newAnd)
	    	local bin=toBin(i)
	    	for j=1,#bin do
	    		print(j)
	    		local x=(bin:sub(j,j)=="1" and 0) or 1
	    		save:addWire(save:findBlock(#bin-(j),0,x),newAnd)
	    	end
    	else
    		local newAnd=b:new(1,i,0,3)
	    	save:addBlock(newAnd)
	    	local bin=toBin(i)
	    	for j=1,#bin do
	    		print(j)
	    		local x=(bin:sub(j,j)=="1" and 0) or 1
	    		save:addWire(save:findBlock(#bin-(j),0,x),newAnd)
	    	end
    	end
    end
    return save
end

return extras
