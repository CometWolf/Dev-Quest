--Player boardTile class

--Inheritance
local class = tClasses.entity.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.player
class.type = "player"
class.pickupItems = true
class.height = false
class.width = false

--Class methods
function class:new(nColumn, nRow, board)
  local obj = tClasses.entity.base.new(class, nColumn, nRow, board.container)
  obj.board = board
  obj.boardX = obj.disp.x
  obj.boardY = obj.disp.y
  board.group.x = board.view.middleX-obj.disp.x
  obj.disp.x = board.view.middleX
  board.group.y = board.view.middleY-obj.disp.y
  obj.disp.y = board.view.middleY
  return obj
end

function class:move(nX, nY, bAbsolute)
  if not bAbsolute then
    nX = nX and nX ~= 0 and self.boardX+nX
    nY = nY and nY ~= 0 and self.boardY+nY
  else
    nX = nX ~= self.boardX and nX
    nY = nY ~= self.boardY and nY
  end
  if nX then
    board.group.x = board.view.middleX-nX
    self.boardX = nX
  end
  if nY then  
    board.group.y = board.view.middleY-nY
    self.boardY = nY
  end
end

return class