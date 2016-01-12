--Door boardTile class

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