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
  if not entity.grip then
    entity.iceSlipX = entity.accelerationX == 0 and nMotionX or entity.accelerationX
    entity.iceSlipY = entity.accelerationY == 0 and nMotionY or entity.accelerationY
    entity.accelerationX = entity.iceSlipX
    entity.accelerationY = entity.iceSlipY
  end
  return true
end

function class:inside(entity, nMotionX, nMotionY)
  if not entity.grip then
    entity.accelerationX = entity.iceSlipX
    entity.accelerationY = entity.iceSlipY
  end
  return true
end

function class:leave(entity, nMotionX, nMotionY)
  entity.iceSlipY = nil
  entity.iceSlipX = nil
  return true
end

return class