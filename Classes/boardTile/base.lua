--Base boardTile class

--Forward declarations
local class = {}

--Public properties
class.objMt = {__index = class} --metatable for created objects
class.width = tileWidth
class.height = tileHeight

--Class methods
function class:new(nColumn, nRow, parent)
  local obj = {
    disp = display.newImageRect(self.texture, self.width, self.height),
    column = nColumn,
    row = nRow,
  }
  print()
  obj.disp.x = (nColumn-1)*self.width
  obj.disp.y = (nRow-1)*self.height
  if parent then
    parent:insert(obj.disp)
  end
  return setmetatable(obj, self.objMt)
end

function class:inherit()
  return setmetatable({}, self.objMt)
end

--Public methods
function class:enter(entity,nMotionX,nMotionY)
  return true, 0, 0
end

return class