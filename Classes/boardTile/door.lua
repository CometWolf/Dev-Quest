--Door boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

--Public properties
class.objMt = {__index = class}

class.texture = tImages.blankTile
class.type = "door"

--public methods 
function class:enter(entity,nMotionX,nMotionY)
  return self.unlocked or entity.intangible
end

function class:lock()
  self.unlocked = false
end

function class:unlock()
  self.unlocked = true
end

return class