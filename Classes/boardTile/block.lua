--Block boardTile class

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

class.texture = tImages.blockTile
class.type = "block"
class.char = "x"

--Public methods 
function class:enter(entity,nMotionX,nMotionY)
  return false
end

return class