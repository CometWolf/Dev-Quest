--Up arrow boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.arrowTile
class.type = "arrow"
class.char = ">"
class.friction = 2

--Public methods 
function class:new(nColumn, nRow, parent)
  local obj = tClasses.boardTile.base.new(class, nColumn, nRow, parent)
  obj.disp.anchorY = 1
  transition.to( obj.disp, {rotation = 90, time = 0})
  return obj
end

function class:enter(entity,nMotionX,nMotionY)
  entity.accelerationX = 2
  entity.accelerationY = 0
  return true
end

function class:inside(entity,nMotionX,nMotionY)
  entity.velocityX = 2
  return true
end

local exitBoost = math.round(tileWidth/2)
function class:leave(entity, nMotionX, nMotionY)
  entity.velocityX = entity.velocityX+(nMotionX > 0 and exitBoost or 0)
  return true
end

return class