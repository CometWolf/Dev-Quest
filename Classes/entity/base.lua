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
class.velocityX = 0 --mass = 1, momentum = velocity
class.velocityY = 0
class.speedX = 1
class.speedY = 1
class.accelerationX = 0
class.accelerationY = 0

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
    computePhysics = function()
      obj.inMotion = false
      local accX = obj.accelerationX
      local accY = obj.accelerationY
      local velX = obj.velocityX+accX
      local velY = obj.velocityY+accY
      local friction = obj.tile.friction
      local motionX,motionY
      if velX ~= 0 then
        if velX > 0 then
          motionX = velX > obj.speedX and obj.speedX or velX
          obj.accelerationX = accX > friction and accX-friction or 0
        else
          motionX = velX < -obj.speedX and -obj.speedX or velX
          obj.accelerationX = accX < -friction and accX+friction or 0
        end
        obj.velocityX = velX-motionX
      end
      if velY ~= 0 then
        if velY > 0 then
          motionY = velY > obj.speedY and obj.speedY or velY
          obj.accelerationY = accY > friction and accY-friction or 0
        else
          motionY = velY < -obj.speedY and -obj.speedY or velY
          obj.accelerationY = accY < -friction and accY+friction or 0
        end
        obj.velocityY = velY-motionY
      end
      if motionX or motionY then
        obj:tryMove(motionX, motionY)
      end
    end
  }
  obj.disp.x = (nColumn-1)*tileWidth+tileWidth*0.5
  obj.disp.y = (nRow-1)*tileHeight+tileHeight*0.5
  obj.disp.anchorX = 0.5
  obj.disp.anchorY = 0.5
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
    nX = nX and (self.boardX or self.disp.x) + nX
    nY = nY and (self.boardY or self.disp.y) + nY
  end
  self.inMotion = transitionMoveTo(
    self.disp,
    {
      x = nX,
      y = nY,
      time = self.moveTime, 
      onComplete = self.computePhysics
    }
  )
end

function class:tryMove(nX,nY, bAbsolute)
  if self.inMotion then
    return
  end
  local selfX,selfY = self.boardX or self.disp.x, self.boardY or self.disp.y --player class stores it's location on the board in boardX and boardY
  if bAbsolute then
    nX = nX or selfX
    nY = nY or selfY
  else
    nX = selfX+(nX or 0)
    nY = selfY+(nY or 0)
  end
  print(nX,nY)
  local column = math.floor(nX/tileWidth)+1
  local row = math.floor(nY/tileHeight)+1
  local motionX = nX-selfX
  local motionY = nY-selfY
  local tile = board[column][row]
  if tile ~= self.tile then
    print("Entering: "..tile.type)
    if not tile:enter(self,motionX,motionY) then
      self.velocityX = 0
      self.velocityY = 0
      return false
    end
    self.tile = tile
    tile.entity = self
    self:move(nX, nY, true)
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