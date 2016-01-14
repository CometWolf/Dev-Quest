--Ice boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

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

class.texture = tImages.iceTile
class.type = "ice"
class.char = "i"

--Public methods 
function class:enter(entity,nMotionX,nMotionY)
  if not entity.grip then
    entity.momentumX = entity.momentumX+(nMotionX > 0 and tileWidth or nMotionX < 0 and -tileWidth or 0)*2
    entity.momentumY = entity.momentumY+(nMotionY > 0 and tileHeight or nMotionY < 0 and -tileHeight or 0)*2
  end
  return true
end

return class