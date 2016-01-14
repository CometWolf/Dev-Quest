--Fire boardTile class

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

class.texture = tImages.blankTile
class.type = "fire"

--public methods 
function class:enter(entity,nMotionX,nMotionY)
  return entity.fireProof or entity.intangible
end

return class