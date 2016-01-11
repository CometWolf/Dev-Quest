--Base boardTile class

--Forward declarations

local class = {}

--Private properties

local objMt = {__index = class}

--Public properties

class.rendered = false
class.texture = false
class.type = false
class.width = 0 --Width and height is initialized while rendering the board
class.height = 0
class.event = {
  player = {
    __index = function(t,k)
      error("No player "..k.." event defined for this class",2)
    end
  },
  entity = {
    __index = function(t,k)
      error("No entity "..k.." event defined for this class",2)
    end
  },
  touch = {
    __index = function(t,k)
      error("No touch "..k.." event defined for this class",2)
    end
  },
}
class.contains = {
  player = false,
  entity = false,
  item = false
}

--Object creation

class.new = function()
  local object = {}
  setmetatable(object,objMt)
  return object
end

return class