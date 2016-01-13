--Player boardTile class

--Inheritance
local class = tClasses.entity.base:new()

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

--public methods
function class:move(nColumn, nRow)
  if nRow ~= self.row then
    if nRow <= board.view.middleRow then
      self.y = (nRow-1)*board.tileHeight
      board.group.y = 0
    else
      self.y = (board.view.middleRow-1)*board.tileHeight
      board.group.y = (board.view.middleRow-nRow)*board.tileHeight
    end
    self.row = nRow
  end
  if nColumn ~= self.column then
    if nColumn <= board.view.middleColumn then
      self.x = (nColumn-1)*board.tileWidth
      board.group.x = 0
    else
      self.x = (board.view.middleColumn-1)*board.tileWidth
      board.group.x = (board.view.middleColumn-nColumn)*board.tileWidth
    end
    self.column = nColumn
  end
  local tile = board[nColumn][nRow]
  tile.entity = player
  self.tile = tile
end

return class