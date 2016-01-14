--Base player class

--Forward declarations
local class = {}

--Private properties
local transitionMoveTo = transition.moveTo

--Public properties
class.objMt = {__index = class} --metatable for created objects
class.width = tileHeight
class.height = tileWidth
class.moveTime = math.ceil(1000/display.fps)
class.moveX = 1
class.moveY = 1
class.momentumX = 0
class.momentumY = 0

--Class methods
function class:new(nColumn, nRow, parent)
  local obj
  obj = {
    --instance properties
    disp = display.newImageRect(self.texture, self.width, self.height),
    inventory = {},
    column = nColumn,
    row = nRow,
    tile = board[nColumn][nRow],
    inMotion = false,
    motionComplete = function()
      obj.inMotion = false
      local momX = obj.momentumX > 0 and 1 or obj.momentumX < 0 and -1
      local momY = obj.momentumY > 0 and 1 or obj.momentumY < 0 and -1
      if momX or momY then
        obj.momentumX = obj.momentumX-((momX or 0)*obj.moveX)
        obj.momentumY = obj.momentumY-((momY or 0)*obj.moveY)
        obj:tryMove(momX,momY)
      end
    end
  }
  obj.disp.x = (nColumn-1)*tileWidth
  obj.disp.y = (nRow-1)*tileHeight
  if parent then
    parent:insert(obj.disp)
  end
  return setmetatable(obj,self.objMt)
end

function class:inherit()
  return setmetatable({}, self.objMt)
end

--Public methods

function class:motion(nX, nY, bAbsolute)
  if self.inMotion then
    return false
  end
  if not bAbsolute then
    nX = self.x+(nX and nX or 0)
    nY = self.x+(nY and nY or 0)
  end
  self.inMotion = transitionMoveTo(
    self,
    {
      x = nX,
      y = nY,
      time = self.moveTime, 
      onComplete = self.motionComplete
    }
  )
end

function class:tryMove(nX,nY, bAbsolute)
  if self.inMotion then
    return
  end
  if bAbsolute then
    nX = nX or self.x-board.group.x
    nY = nY or self.y-board.group.y
  else
    nX = self.x-board.group.x+(nX or 0)
    nY = self.y-board.group.y+(nY or 0)
  end
  local column = math.floor(nX/tileWidth)+1
  local row = math.floor(nY/tileHeight)+1
  local motionX = nX-self.x+board.group.x
  local motionY = nY-self.y+board.group.y
  local tile = board[column][row]
  if tile ~= self.tile then
    if not tile:enter(self,motionX,motionY) then
      self.momentumX = 0
      self.momentumY = 0
      return false
    end
    self:move(nX, nY, true)
    self.tile = tile
    tile.entity = self
  else
    self:move(nX, nY, true)
  end
end

function class:addItem(item,nAmount)
  nAmount = nAmount or item.pickup or 1
  for k,v in pairs(self.inventory) do
    if v.name == item.name then
      if v.max > v.amount then
        v.amount = math.min(v.amount+nAmount,v.max)
        return true
      end
      return false
    end
  end
  local entityItem = table.copy(item)
  if item.amount > -1 then
    item.amount = item.amount-nAmount
    if item.amount == 0 then
      item.tile.item = nil
    end
  end
  entityItem.amount = nAmount or 1
  self.inventory[#self.inventory+1] = item
  entityItem.slot = self.inventory[#self.inventory]
  return true
end

return class