--Base player class

--Forward declarations
local class = {}
local disp = {} --This needs to exist in every new object for metatable performance reasons

--Public properties
class.objMt = {__index = class} --metatable for created objects
class.width = 32
class.height = 32

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

function class:tryMove(nColumn, nRow, bAbsolute)
  if bAbsolute then
    nRow = nRow > 0 and nRow or 1
    nColumn = nColumn > 0 and nColumn or 1
  else
    nRow = math.max(1, self.row + nRow)
    nColumn = math.max(1, self.column + nColumn)
  end
  return board[nColumn][nRow]:enter(self),nColumn,nRow
end

function class:doMove(nColumn, nRow, bAbsolute)
  local move, column, row = self:tryMove(nColumn, nRow, bAbsolute)
  if move then
    self:move(column,row)
    return true
  end
  return false
end

return class