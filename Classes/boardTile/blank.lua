--Blank boardTile class

--Inheritance

local class = setmetatable({},{__index = tClasses.boardTile.base})

--Private variables

local objMt = {
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

local dispProp = {
  fill = {0.8}, --lightGray
}

--Public variables

class.type = "blank"

--Object creation

class.new = function(...)
  local parent,nX,nY
  local object = tClasses.boardTile.base.new()
  if type(arg[1]) == "number" then
    object.disp = display.newRect(arg[1],arg[2],object.width,object.height)
  else
    object.disp = display.newRect(arg[1],arg[2],arg[3],object.width,object.height)
  end
  for k,v in pairs(dispProp) do
    object.disp[k] = v
  end
  setmetatable(object,objMt)
  return object
end

return class