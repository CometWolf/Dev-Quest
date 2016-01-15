--Blank boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.blankTile
class.type = "blank"
class.char = " "

--Public methods
function class:enter(entity,nMotionX,nMotionY)
  if self.item and entity.pickupItems then
    entity:addItem(self.item,self.item.pickup)
  end
  return true
end

return class