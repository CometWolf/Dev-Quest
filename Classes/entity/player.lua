--Player boardTile class

--Inheritance
local class = tClasses.entity.base:inherit()

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

class.texture = tImages.player
class.type = "player"
class.pickupItems = true

--Class methods
function class:new(nColumn, nRow, parent)
  local obj = tClasses.entity.base.new(class, nColumn, nRow, parent)
  obj.playX = obj.x
  obj.playY = obj.y
  if obj.disp.x > board.view.middleX then
    board.group.x = board.view.middleX-obj.x
    obj.disp.x = board.view.middleX
  end
  if obj.y > board.view.middleY then
    board.group.y = board.view.middleY-obj.y
    obj.y = board.view.middleY
  end
  return obj
end

--public methods
-- function class:move(nColumn, nRow, bAbsolute)
--   if not bAbsolute then
--     nColumn = self.column+nColumn
--     nRow = self.row+nRow
--   end
--   if nRow ~= self.row then
--     if nRow <= board.view.middleRow then
--       self.y = (nRow-1)*tileHeight
--       board.group.y = 0
--     else
--       self.y = (board.view.middleRow-1)*tileHeight
--       board.group.y = (board.view.middleRow-nRow)*tileHeight
--     end
--     self.row = nRow
--   end
--   if nColumn ~= self.column then
--     if nColumn <= board.view.middleColumn then
--       self.x = (nColumn-1)*tileWidth
--       board.group.x = 0
--     else
--       self.x = (board.view.middleColumn-1)*tileWidth
--       board.group.x = (board.view.middleColumn-nColumn)*tileWidth
--     end
--     self.column = nColumn
--   end
--   local tile = board[nColumn][nRow]
--   tile.entity = player
--   self.tile = tile
-- end

function class:move(nX, nY, bAbsolute)
  if not bAbsolute then
    nX = nX and nX ~= 0 and self.playX+nX
    nY = nY and nY ~= 0 and self.playY+nY
  else
    nX = nX ~= self.playX and nX
    nY = nY ~= self.playY and nY
  end
  local groupX = nX and board.view.middleX-nX or 0
  local groupY = nY and board.view.middleY-nY or 0
  groupX = groupX < 0 and groupX
  groupY = groupY < 0 and groupY
  if groupX or groupY  then
    self.disp.x = groupX and board.view.middleX or self.disp.x
    self.disp.y = groupY and board.view.middleY or self.disp.y
    self.inMotion = transition.moveTo(
      board.group,
      {
        x = groupX,
        y = groupY,
        time = self.moveTime, 
        onComplete = self.motionComplete
      }
    )
    self.playX = nX and nX or self.playX
    self.playY = nY and nY or self.playY
  else
    self:motion(nX,nY,true)
    self.playX = nX and nX or self.playX
    self.playY = nY and nY or self.playY
  end
end

return class