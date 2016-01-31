--Playboard class

--Forward declarations
local class = {}

--Public properties
class.objMt = {__index = class} --metatable for created objects

--Class methods
function class:new(sPath, tTable)
  local obj = tTable or {}
  if sPath then
    --load board file
    local tTileChar = {}
    for k,v in pairs(tClasses.boardTile) do
      if v.char then
        tTileChar[v.char] = v
      end
    end
    
    local file,err = io.open(sPath)
    if not file then
      error(err)
    end
    local columns, rows = 0,0
    local row = 1
    for line in file:lines() do
      rows = row > rows and row or rows
      local column = 1
      for char in line:gmatch"." do
        columns = column > columns and column or columns
        obj[column] = obj[column] or {}
        obj[column][row] = {
          tileClass = tTileChar[char]
        }
        column = column+1
      end
      row = row+1
    end
    
    obj.columns = columns
    obj.rows = rows
    
    local row = 1
    sPath = sPath:gsub("%.lvl",".ent")
    file,err = io.open(sPath)
    if file then
      local tEntity = require(sPath:gsub("[/\\]","."):sub(1,-5))
      for line in file:lines() do
        local column = 1
        for char in line:gmatch"." do
          if char ~= " " then
            obj[column][row].entityClass = tClasses.entity[tEntity[char].type]
            obj[column][row].entityAi = tEntity[char].ai or obj[column][row].entityClass.ai
          end
          column = column+1
        end
        row = row+1
      end
    end
    obj.spawnColumn = obj.spawnColumn or 2
    obj.spawnRow = obj.spawnRow or 2
  end
  return setmetatable(obj, self.objMt)
end

function class:render()
  --calculate view portion
  local width = screen.width-gui.controlLeft.width-gui.controlRight.width
  local height = screen.height-gui.statusBar.height
  local columns = math.floor(width/tileWidth)
  local rows = math.floor(height/tileHeight)
  local unusedX = math.floor(width%(tileWidth))
  local unusedY = math.floor(height%(tileHeight))
  self.container = display.newContainer(tileWidth*columns, tileHeight*rows)
  self.container:toBack()
  self.container.x = gui.controlLeft.edgeX+math.floor(unusedX/2)
  self.container.y = gui.statusBar.bottomY+math.floor(unusedY/2)
  self.container.anchorChildren = false
  self.view = {
    columns = columns,
    rows = rows,
    middleX = math.round(width/2),
    middleY = math.round(height/2),
  }
  --setup object group
  self.group = display.newGroup()
  self.container:insert(board.group)
  self.group.anchorChildren = true
  --populate board
  for iC = 1,self.columns do
    for iR = 1,self.rows do
      local tile = self[iC][iR]
      local tileObj = tile.tileClass:new(iC, iR, board.group)
      tile.tileClass = nil
      tileObj.disp:toBack()
      self[iC][iR] = tileObj
      if tile.entityClass then
        local entity = tile.entityClass:new(iC, iR, board.group)
        tile.entityClass = nil
        tileObj.entity[entity] = entity
        local ai = tile.entityAi
        tile.entityAi = nil
        if ai then
          entity:hookAi(ai)
        end
      end
    end
  end
end

return class