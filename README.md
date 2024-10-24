# cm2Lua
### cm2Lua is a high level savestring manipulator for the Roblox game [Circuit Maker 2](https://www.roblox.com/games/6652606416/Circuit-Maker-2)

## Documentation
### Save
Save is the way you create a new instance of a savestring to append blocks and connections to
To create a save you would use
```lua
cm2Lua.Save:new()
```
-# note that `cm2Lua.Save.new()` or `new cm2Lua.Save()` would not work
### Save:addBlock()
Save:addBlock() works by either inputting a new block or the arguments for a new block
Example:
```lua
local newBlock = cm2Lua.Block:new(5,0,0,0)
local newSave = cm2Lua.Save:new()
newSave:addBlock(newBlock)
newSave:addBlock(5,1,0,0)
```
