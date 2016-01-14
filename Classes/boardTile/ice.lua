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
  return entity.grip, nMotionX > 0 and 1 or nMotionX < 0 and -1 or 0, nMotionY > 0 and 1 or nMotionY < 0 and -1 or 0
end

return class