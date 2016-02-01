--Ice boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.iceTile
class.type = "ice"
class.char = "i"
class.friction = 0
class.traction = 0

--Public methods
function class:enter(entity, nMotionX, nMotionY)
  if not entity.iceSkates then
    entity.grip = 0
    entity.accelerationX = entity.accelerationX == 0 and nMotionX or entity.accelerationX
    entity.accelerationY = entity.accelerationY == 0 and nMotionY or entity.accelerationY
  end
  return true
end

function class:leave(entity, nMotionX, nMotionY)
  entity.grip = entity.defaultGrip
  return true
end

return class