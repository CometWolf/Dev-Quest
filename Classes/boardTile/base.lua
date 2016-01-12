--Base boardTile class

--Forward declarations
local class = {}
local disp = {} --This needs to exist in every new object for metatable performance reasons

--Public properties
class.objMt = {__index = class} --metatable for created objects

--Public methods
function class:new()
  return setmetatable({disp = disp},self.objMt)
end

function class:render(nX,nY,parent)
  self.disp = display.newImageRect(self.texture, self.width, self.height)
  self.disp.x = nX or 0
  self.disp.y = nY or 0
  if parent then
    parent:insert(self.disp)
  end
end

function class:enter(entity)
  return true
end

return class