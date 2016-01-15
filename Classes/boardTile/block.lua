--Block boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.blockTile
class.type = "block"
class.char = "x"

--Public methods 
function class:enter(entity,nMotionX,nMotionY)
  if nMotionX > 0 or nMotionX < 0 then
    entity.accelerationX = 0
    entity.velocityX = 0
  end
  if nMotionY > 0 or nMotionY < 0 then
    entity.accelerationY = 0
    entity.velocityY = 0
  end
  return false
end

return class