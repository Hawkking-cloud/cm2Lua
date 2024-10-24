# cm2Lua

### Overview
`cm2Lua` is a high-level savestring manipulator for the Roblox game [Circuit Maker 2](https://www.roblox.com/games/6652606416/Circuit-Maker-2). It allows players to create and manipulate circuits programmatically.

## Documentation
[Save](#save)
- [Save:new()](#savenew)
- [Save:addBlock()](#saveaddblock)
- [Save:addBlocks()](#saveaddblocks)
- [Save:addBlockTable()](#saveaddblocktable)
- [Save:addWire()](#saveaddwire)
- [Save:findBlock()](#savefindblock)
- [Save:import()](#saveimport)
- [Save:export()](#saveexport)
- [Save:exportToDpaste()](#saveexporttodpaste)

[Block](#block)
- [Block:new()](#blocknew)
## Save
Save is the way you create a new instance of a savestring to append blocks and connections to
### Save:new()
`Save:new()` creates a new instance of a Save
Example:
```lua
local newSave=cm2Lua.Save:new()
```

### Save:addBlock()
`Save:addBlock()` works by either inputting a new block or the arguments for a new block
Example:
```lua
local newBlock = cm2Lua.Block:new(5,0,0,0)
local newSave = cm2Lua.Save:new()
newSave:addBlock(newBlock)
newSave:addBlock(5,1,0,0)
```

### Save:addBlocks()
`Save:addBlocks()` works by assuming each block is a block, adding them
> [!TIP]
> Slightly more optimized rather than for looping [Save:addBlock()](#saveaddblock)

Example:
```lua
local newBlock1 = cm2Lua.Block:new(5,1,0,0)
local newBlock2 = cm2Lua.Block:new(5,2,0,0)
local newBlock3 = cm2Lua.Block:new(5,3,0,0)
local newSave = cm2Lua.Save:new()
newSave:addBlocks(newBlock1,newBlock2,newBlock3)
```

### Save:addBlockTable()
`Save:addBlockTable()` Iterates through the inputted table and adds each block, assuming each item is a valid block
Example:
```lua
local newBlock1 = cm2Lua.Block:new(5,1,0,0)
local newBlock2 = cm2Lua.Block:new(5,2,0,0)
local newBlock3 = cm2Lua.Block:new(5,3,0,0)
local newSave = cm2Lua.Save:new()
newSave:addBlockTable({newBlock1,newBlock2,newBlock3})
```

### Save:addBlockTable()
`Save:addBlockTable()` Iterates through the inputted table and adds each block, assuming each item is a valid block
Example:
```lua
local newBlock1 = cm2Lua.Block:new(5,1,0,0)
local newBlock2 = cm2Lua.Block:new(5,2,0,0)
local newBlock3 = cm2Lua.Block:new(5,3,0,0)
local newSave = cm2Lua.Save:new()
newSave:addBlockTable({newBlock1,newBlock2,newBlock3})
```

### Save:addWire()
`Save:addWire()` can have 2 valid argument types, `Block, Block` or `ID1, ID2`
In this case ID is reffering to the blocks index within the save
> [!NOTE]
> Blocks need to be added before making connections

Example:
```lua
local block1=cm2Lua.Block:new(5,1,0,0)
local block2=cm2Lua.Block:new(5,2,0,0)

local exampleSave1=cm2Lua.Save:new()
local exampleSave2=cm2Lua.Save:new()

exampleSave1:addBlocks(block1,block2)
exampleSave2:addBlocks(block1,block2)

exampleSave1:addWire(block1,block2)
exampleSave2:addWire(1,2)
```

### Save:findBlock()
`Save:findBlock()` inputs strictly `x, y, z`, and parses all the blocks in the save to see if it matches that **exact** position, returns the block if found, returns `nil` if no block found

Example:
```lua
local newBlock=cm2Lua.Block:new(5,1,0,0)

local newSave=cm2Lua.Save:new()
newSave:addBlock(newBlock)
print(newSave:findBlock(1,0,0))
```

### Save:import()
`Save:import()` inputs a `savestring, x, y, z`, specifically a CM2 savestring
> [!TIP]
> only the savestring argument is required, X,Y,Z will autofill to 0 with no input

> [!IMPORTANT]
> Can only handle blocks and connections at the moment

Example:
```lua
local newSave=cm2Lua.Save:new()

newSave:import("5,0,0,0,0,???")

print(newSave:export())
```

### Save:export()
`Save:export()` exports the data in the save to a CM2 savestring
Example:
```lua
local newSave=cm2Lua.Save:new()

newSave:addBlock(5,1,0,0)

print(newSave:export())
```

### Save:exportToDpaste()
`Save:exportToDpaste()` **attempts** to export the exported data to a dpaste link, if it fails you can set `cm2Lua.dpasteFallback` to true for the function to revert back to normal cm2Lua:export()
> [!IMPORTANT]
> this requires the libraries `socket.http` and `ltn12`

Example:
```lua
local newSave=cm2Lua.Save:new()

newSave:addBlock(5,1,0,0)

print(newSave:export())
```

## Block
Block is a block you append to a (Save)[#save]

### Block:new()
`Block:new()` inputs `id, x, y, z` and outputs a table with data for appending to a string within it
> [!TIP]
> only the id argument is required, X,Y,Z will autofill to 0 with no input

Example:
```lua
local newSave=cm2Lua.Save:new()

newSave:addBlock(5,1,0,0)

print(newSave:export())
```
