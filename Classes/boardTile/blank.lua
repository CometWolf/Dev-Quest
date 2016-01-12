--Blank boardTile class

--Inheritance
local class = tClasses.boardTile.base:new()

--Public properties
class.objMt = {
  __index = function(t,k)
    return t.disp[k] or class[k]
  end,
  __newindex = function(t,k,v)
    if t.disp[k] ~= nil then
      t.disp[k] = v
    else
      rawset(t,k,v)
    end
  end
}

class.texture = tImages.blankTile
class.type = "blank"
class.char = " "

--public methods 
function class:enter(entity,nMotionX,nMotionY)
  if self.item and entity.pickupItems then
    entity:addItem(item)
    if not self.item.unlimited then
      self.item = nil
    end
  end
  return true
end

return class