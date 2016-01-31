--Up arrow boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.arrowTile
class.type = "arrow"
class.char = "v"
class.friction = 2

--Public methods 
function class:new(nColumn, nRow, parent)
  local obj = tClasses.boardTile.base.new(class, nColumn, nRow, parent)
  obj.disp.anchorX = 1
  obj.disp.anchorY = 1
  transition.to( obj.disp, {rotation = 180, time = 0})
  return obj
end

function class:enter(entity,nMotionX,nMotionY)
  entity.accelerationY = 2
  entity.accelerationX = 0
  return true
end

function class:inside(entity,nMotionX,nMotionY)
  entity.velocityY = 2
  return true
end

local exitBoost = math.round(tileHeight/2)
function class:leave(entity, nMotionX, nMotionY)
  entity.velocityY = entity.velocityY+(nMotionY > 0 and exitBoost or 0)
  return true
end

return class