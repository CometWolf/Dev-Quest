--Up arrow boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.arrowTile
class.type = "arrow"
class.char = "^"
class.friction = 0

--Public methods 
function class:enter(entity,nMotionX,nMotionY)
  entity.accelerationY = -1
  --entity.accelerationX = 0
  return true
end
class.inside = class.enter

return class