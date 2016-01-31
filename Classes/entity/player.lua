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
function class:new(nColumn, nRow, parent)
  local obj = tClasses.entity.base.new(class, nColumn, nRow, parent)
  obj.boardX = obj.disp.x
  obj.boardY = obj.disp.y
  if obj.disp.x > board.view.middleX then
    board.group.x = board.view.middleX-obj.disp.x
    obj.disp.x = board.view.middleX
  end
  if obj.disp.y > board.view.middleY then
    board.group.y = board.view.middleY-obj.disp.y
    obj.disp.y = board.view.middleY
  end
  return obj
end

local baseMove = class.move --Used in the override function
function class:move(nX, nY, bAbsolute)
  if not bAbsolute then
    nX = nX and nX ~= 0 and self.boardX+nX
    nY = nY and nY ~= 0 and self.boardY+nY
  else
    nX = nX ~= self.boardX and nX
    nY = nY ~= self.boardY and nY
  end
  local groupX = nX and board.view.middleX-nX or 0
  local groupY = nY and board.view.middleY-nY or 0
  groupX = groupX < 0 and groupX
  groupY = groupY < 0 and groupY
  if groupX or groupY  then
    self.disp.x = groupX and board.view.middleX or self.disp.x
    self.disp.y = groupY and board.view.middleY or self.disp.y
    if not groupX then
      board.group.y = groupY
      baseMove(self,nX,nil,true)
    elseif groupX and not groupY then
      board.group.x = groupX
      baseMove(self,nil,nY,true)
    else
      board.group.x = groupX
      board.group.y = groupY
    end
  else
    baseMove(self,nX,nY,true)
  end
  self.boardX = nX and nX or self.boardX
  self.boardY = nY and nY or self.boardY
end

return class