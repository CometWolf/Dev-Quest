--Ice boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.iceTile
class.type = "ice"
class.char = "i"
class.friction = 0

--Public methods 
function class:enter(entity,nMotionX,nMotionY)
  if not entity.grip then
    entity.accelerationX = entity.accelerationX == 0 and (nMotionX > 0 and 1 or nMotionX < 0 and -1) or entity.accelerationX
    entity.accelerationY = entity.accelerationY == 0 and (nMotionY > 0 and 1 or nMotionY < 0 and -1) or entity.accelerationY
  end
  return true
end
class.inside = class.enter

return class