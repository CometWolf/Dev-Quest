--Bug boardTile class

--Inheritance
local class = tClasses.entity.base:inherit()

--Public properties
class.objMt = {
  __index = function(t,k)
    return t.disp[k] or class[k]
  end
}
class.texture = tImages.player
class.type = "bug"

--Class methods
class.interaction = {
  player = function(self, entity, motionX, motionY)
    entity.velocityX = 10*motionX
    entity.velocityY = 10*motionY
    return false
  end,
}

return class