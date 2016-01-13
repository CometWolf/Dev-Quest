--Base player class

--Forward declarations
local class = {}
local disp = {} --This needs to exist in every new object for metatable performance reasons

--Public properties
class.objMt = {__index = class} --metatable for created objects
class.width = 32
class.height = 32
class.inventory = {

}

--Public methods
function class:new(nColumn, nRow)
  return setmetatable(
    {
      disp = disp,
      column = nColumn,
      row = nRow,
    },
    self.objMt
  )
end

function class:render(nX,nY,parent)
  self.disp = display.newImageRect(self.texture, self.width, self.height)
  self.disp.x = nX or (self.column-1)*board.tileWidth
  self.disp.y = nY or (self.row-1)*board.tileHeight
  if parent then
    parent:insert(self.disp)
  end
end

function class:checkMove(nColumn, nRow, bAbsolute)
  if bAbsolute then
    nRow = nRow > 0 and nRow or 1
    nColumn = nColumn > 0 and nColumn or 1
  else
    nRow = math.max(1, self.row + nRow)
    nColumn = math.max(1, self.column + nColumn)
  end
  local motionX = nColumn-self.column
  local motionY = nRow-self.row
  local allowMove, columnOffset, rowOffset = board[nColumn][nRow]:enter(self,motionX,motionY)
  columnOffset = columnOffset or 0
  rowOffset = rowOffset or 0
  if allowMove then
    return allowMove
  elseif nColumn == 0 and nRow == 0 then
    return false, 0, 0
  else
    return allowMove, columnOffset+(bAbsolute and  nColumn or 0), rowOffset+(bAbsolute and nRow or 0)
  end
end

function class:tryMove(nColumn, nRow, bAbsolute)
  local allowed, newColumn, newRow
  allowed, newColumn, newRow = self:checkMove(nColumn, nRow, bAbsolute)
  if allowed then
    self:move(nColumn, nRow, bAbsolute)
  elseif newColumn ~= 0 or newRow ~= 0 then
    self:move(nColumn, nRow, bAbsolute)
    self:tryMove(newColumn, newRow, bAbsolute)
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