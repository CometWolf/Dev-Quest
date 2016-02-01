--Base player class

--Forward declarations
local class = {}

--Private properties
--motion handler
local motionQueue = { --order dependent
  size = 0,
  ids = {

  }
}
Runtime:addEventListener(
  "enterFrame",
  function()
    if motionQueue.size > 0 then
      local queue = motionQueue
      motionQueue = { --create new queue
        size = 0,
        ids = {

        }
      }
      for i = 1,queue.size do  --process current queue
        local motion = queue[i]
        if motion then
          motionQueue[i] = nil
          motionQueue.ids[motion.id] = nil
          local entity = motion.entity
          if motion.func then
            motion.func(entity)
          end
          entity:calculateMotion()
        end
      end
    end
  end
)

--ai handler
local tAi = {

}
Runtime:addEventListener(
  "enterFrame",
  function()
    for k,v in pairs(tAi) do
      v(k)
    end
  end
)

--Public properties
class.objMt = {__index = class} --metatable for created objects
class.velocityX = 0 --mass = 1, momentum = velocity
class.velocityY = 0
class.speed = 1 --pix/frame
class.accelerationX = 0 --note that friction (tile classes) also applies acceleration opposite of motion
class.accelerationY = 0
class.height = tileHeight/2
class.width = tileWidth/2
class.pushable = false

--Class methods
function class:new(nColumn, nRow, parent)
  local obj = {
    --instance properties
    disp = self.height and self.width and display.newImageRect(self.texture, self.height, self.width) or display.newImage(self.texture),
    inventory = {},
    column = nColumn,
    row = nRow,
    tile = board[nColumn][nRow],
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
--motion
function class:queueMotion(fMotion, id)
  id = id or self
  if motionQueue.ids[id] and (not fMotion or fMotion == motionQueue.ids[id].func) then
    return
  end
  motionQueue.size = motionQueue.size+1
  local tMotion = {
    func = fMotion,
    id = id,
    entity = self,
    num = motionQueue.size
  }
  motionQueue.ids[id] = tMotion
  motionQueue[motionQueue.size] = tMotion
end

function class:removeMotion(id)
  id = id or self
  local motion = motionQueue.ids[id]
  if motion then
    motionQueue.ids[id] = nil
    motionQueue[motion.num] = nil
    return motion
  end
end

function class:calculateMotion()
  local accX = self.accelerationX
  local accY = self.accelerationY
  local velX = self.velocityX+accX
  local velY = self.velocityY+accY
  local friction = self.tile.friction
  local motionX,motionY
  if velX ~= 0 then
    if velX > 0 then
      motionX = velX > self.speed and self.speed or velX
      self.accelerationX = accX > friction and accX-friction or 0
    else
      motionX = velX < -self.speed and -self.speed or velX
      self.accelerationX = accX < -friction and accX+friction or 0
    end
    self.velocityX = velX-motionX
  end
  if velY ~= 0 then
    if velY > 0 then
      motionY = velY > self.speed and self.speed or velY
      self.accelerationY = accY > friction and accY-friction or 0
    else
      motionY = velY < -self.speed and -self.speed or velY
      self.accelerationY = accY < -friction and accY+friction or 0
    end
    self.velocityY = velY-motionY
  end
  if motionX or motionY then
    self:queueMotion()
    return self:tryMove(motionX, motionY)
  end
  return true
end

function class:tryMove(nX, nY, bAbsolute)
  local selfX,selfY = self.boardX or self.disp.x, self.boardY or self.disp.y --player class stores it's location on the board in boardX and boardY
  if bAbsolute then
    nX = nX or selfX
    nY = nY or selfY
  else
    nX = selfX+(nX or 0)
    nY = selfY+(nY or 0)
  end
  local column = math.floor(nX/tileWidth)+1
  local row = math.floor(nY/tileHeight)+1
  local motionX = nX-selfX
  local motionY = nY-selfY
  local tile = board[column][row]
  if tile ~= self.tile then
    if not tile:enter(self,motionX,motionY) or not self.tile:leave(self,motionX,motionY) then
      return false
    end
    for i=-1,1 do
      for j=-1,1 do
        if not board[column+i][row+j]:entityInteraction(self,motionX,motionY) then
          return false
        end
      end
    end
    self.tile.entity[self] = nil
    self.tile = tile
    tile.entity[self] = self
    self:move(nX, nY, true)
  elseif tile:inside(self,motionX,motionY) then
    for i=-1,1 do
      for j=-1,1 do
        if not board[column+i][row+j]:entityInteraction(self,motionX,motionY) then
          return false
        end
      end
    end
    self:move(nX, nY, true)
  else
    return false
  end
  return true
end

function class:move(nX, nY, bAbsolute)
  if not bAbsolute then
    nX = nX and nX ~= 0 and self.disp.x+nX
    nY = nY and nY ~= 0 and self.disp.y+nY
  else
    nX = nX ~= self.disp.x and nX
    nY = nY ~= self.disp.y and nY
  end
  if nX then
    self.disp.x = nX
  end
  if nY then
    self.disp.y = nY
  end
end

function class:control(nX,nY)
  if nX and nX ~= 0 then
    nX = nX*self.tile.traction
    local velX = self.velocityX
    if velX > 0 then
      self.velocityX = nX > 0 and (nX > velX and nX or velX) or velX+nX
    elseif velX < 0 then
      self.velocityX = nX < 0 and (nX < velX and nX or velX) or velX+nX
    else
      self.velocityX = nX
    end
  end
  if nY and nY ~= 0 then
    nY=nY*self.tile.traction
    local velY = self.velocityY
    if velY > 0 then
      self.velocityY = nY > 0 and (nY > velY and nY or velY) or velY+nY
    elseif velY < 0 then
      self.velocityY = nY < 0 and (nY < velY and nY or velY) or velY+nY
    else
      self.velocityY = nY
    end
  end
  self:queueMotion()
end

function class:moveTowards(targetX, targetY)
  local selfX = self.boardX or self.disp.x
  local selfY = self.boardY or self.disp.y
  if type(targetX) == "table" then
    local entity = targetX
    targetX = entity.boardX or entity.disp.x
    targetY = entity.boardY or entity.disp.y
  end
  local distX = targetX and targetX-selfX or 0
  local distY = targetY and targetY-selfY or 0
  if distX == 0 and distY == 0 then
    return true
  end
  local motionX = (
    distX > 0 and (self.speed <= distX and self.speed or distX)
    or distX < 0 and (-self.speed >= distX and -self.speed or distX)
  )
  local motionY = (
    distY > 0 and (self.speed <= distY and self.speed or distY)
    or distY < 0 and (-self.speed >= distY and -self.speed or distY)
  )
  self:control(motionX,motionY)
end

--ai
function class:hookAi(fAi)
  tAi[self] = fAi
end

function class:die()
  self.tile.entity[self] = nil
  self.tile = nil
  self.disp:removeSelf()
  self.disp = nil
  self:removeMotion()
  tAi[self] = nil
  --inventory cleanup must be implemented!
end

--items
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

--interaction
class.interaction = {

}

class.reaction = {
  any = function(self, entity, motionX, motionY)
    self.velocityX = self.velocityX+motionX
    self.velocityY = self.velocityY+motionY
    if self.pushable then
      return self:calculateMotion()
    else
      self:queueMotion()
      return false
    end
  end
}

return class