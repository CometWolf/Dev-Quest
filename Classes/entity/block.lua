--Bug boardTile class

--Inheritance
local class = tClasses.entity.base:inherit()

--Public properties
class.objMt = {
  __index = function(t,k)
    return t.disp[k] or class[k]
  end
}
class.texture = tImages.blockTile
class.type = "block"

--Class methods
class.reaction = {
  any = function(self, entity, motionX, motionY)
    self.velocityX = self.velocityX+motionX
    self.velocityY = self.velocityY+motionY
    return false
  end
}

return class