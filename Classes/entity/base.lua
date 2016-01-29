--Base player class

--Forward declarations
local class = {}

--Private properties
local transitionMoveTo = transition.moveTo

--Public properties
class.objMt = {__index = class} --metatable for created objects
class.moveTime = math.ceil(1000/(display.fps))
class.velocityX = 0 --mass = 1, momentum = velocity
class.velocityY = 0
class.speed = math.round((tileWidth+tileHeight)/30)
class.accelerationX = 0
class.accelerationY = 0
class.height = tileHeight/2
class.width = tileWidth/2
class.interaction = {}
class.reaction = {}
class.motionQueue = {
  ids = {
    
  }
},
Runtime:addEventListener(
  "enterFrame",
  function()
    local motionQueue = class.motionQueue
    for i=1,#motionQueue do
      local motion = table.remove(motionQueue,1)
      motionQueue.ids[motion.id] = nil
      local entity = motion.entity
      if motion.func then
        motion.func(entity)
      end
      local accX = entity.accelerationX
      local accY = entity.accelerationY
      local velX = entity.velocityX+accX
      local velY = entity.velocityY+accY
      local friction = entity.tile.friction*entity.speed
      local motionX,motionY
      if velX ~= 0 then
        if velX > 0 then
          motionX = velX > entity.speed and entity.speed or velX
          entity.accelerationX = accX > friction and accX-friction or 0
        else
          motionX = velX < -entity.speed and -entity.speed or velX
          entity.accelerationX = accX < -friction and accX+friction or 0
        end
        entity.velocityX = velX-motionX
      end
      if velY ~= 0 then
        if velY > 0 then
          motionY = velY > entity.speed and entity.speed or velY
          entity.accelerationY = accY > friction and accY-friction or 0
        else
          motionY = velY < -entity.speed and -entity.speed or velY
          entity.accelerationY = accY < -friction and accY+friction or 0
        end
        entity.velocityY = velY-motionY
      end
      if motionX or motionY then
        entity:tryMove(motionX,motionY)
        entity:queueMotion()
      end
    end
  end
)

--Class methods
function class:new(nColumn, nRow, parent)
  local obj
  obj = {
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

function class:motion(nX, nY, bAbsolute)
  if not bAbsolute then
    nX = nX and (self.boardX or self.disp.x) + nX
    nY = nY and (self.boardY or self.disp.y) + nY
  end
  transitionMoveTo(
    self.disp,
    {
      x = nX,
      y = nY,
      time = self.moveTime
    }
  )
end

function class:move(nX, nY, bAbsolute)
  if not bAbsolute then
    nX = nX and nX ~= 0 and self.disp.x+nX
    nY = nY and nY ~= 0 and self.disp.y+nY
  else
    nX = nX ~= self.disp.x and nX
    nY = nY ~= self.disp.y and nY
  end
  self:motion(nX,nY,true)
end

function class:tryMove(nX,nY, bAbsolute)
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
  end
  return true
end

function class:queueMotion(fMotion,id)
  id = id or fMotion or self
  if class.motionQueue.ids[id] then
    return
  end
  local tMotion = {
    func = fMotion,
    id = id,
    entity = self
  }
  class.motionQueue.ids[id] = tMotion
  table.insert(class.motionQueue,tMotion)
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