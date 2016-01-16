--Up arrow boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.arrowTile
class.type = "arrow"
class.char = "v"
class.friction = 0

--Public methods 
function class:new(nColumn, nRow, parent)
  local obj = tClasses.boardTile.base.new(class, nColumn, nRow, parent)
  obj.disp.anchorX = 1
  obj.disp.anchorY = 1
  transition.to( obj.disp, {rotation = 180})
  return obj
end

function class:enter(entity,nMotionX,nMotionY)
  entity.accelerationY = 1
  --entity.accelerationX = 0
  return true
end
class.inside = class.enter

return class