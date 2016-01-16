--Spawn boardTile class

--Inheritance
local class = tClasses.boardTile.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.blankTile
class.type = "spawn"
class.char = "s"

--Public methods
function class:new(nColumn, nRow, parent)
  local obj = tClasses.boardTile.base.new(class, nColumn, nRow, parent)
  board.spawnColumn = nColumn
  board.spawnRow = nRow
  return obj
end

return class