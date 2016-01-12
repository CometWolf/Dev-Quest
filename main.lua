--[[------------------------------------------------------------------------------
main.lua
--------------------------------------------------------------------------------]]
--[[------------------------------------------------------------------------------
Utility loading
--------------------------------------------------------------------------------]]
do
  local utilityFolder = "Utility code."
  device = require(utilityFolder.."Device detection")
  require(utilityFolder.."API extensions")
end

--[[------------------------------------------------------------------------------
Game file loading
--------------------------------------------------------------------------------]]
tClasses = {}
tImages = {}
do
  local classFolder = "Classes"
  local imageFolder = "Images"
  local lfs = require("lfs")

  local loadClass
  loadClass = function(sPath,tTable)
    local tFile = {}
    local tDir = {}
    for fileName in lfs.dir(sPath) do
      if fileName ~= "." and fileName ~= ".." then  --why the hell does it return "." and ".."!?
        local filePath = sPath.."/"..fileName
        if lfs.attributes(filePath,"mode") == "directory" then
          tDir[fileName] = filePath
        else
          fileName = fileName:match("(.+)%..-$") --strip file extension
          tFile[fileName] = sPath:gsub("/","\.").."."..fileName --require uses '.' instead of "/" ...WTF!?
        end
      end
    end
    if tFile.base then
      tTable.base = require(tFile.base)
    end
    for k,v in pairs(tFile) do
      if k ~= "base" then
        tTable[k] = require(v)
      end
    end
    for k,v in pairs(tDir) do
      tTable[k] = {}
      loadClass(v,tTable[k])
    end
  end
  loadClass(classFolder,tClasses)

  local findImages
  findImages = function(sPath,tTable)
    for fileName in lfs.dir(sPath) do
      if fileName ~= "." and fileName ~= ".." then
        local filePath = sPath.."/"..fileName
        if lfs.attributes(filePath,"mode") == "directory" then
          tTable[fileName] = {}
          findImages(filePath,tTable[fileName])
        else
          tTable[fileName:match("(.+)%..-$")] = filePath
        end
      end
    end
  end
  findImages(imageFolder,tImages)
end

--[[------------------------------------------------------------------------------
Display setup
--------------------------------------------------------------------------------]]
display.setStatusBar(display.HiddenStatusBar)
display.setDefault( "anchorX", 0 )
display.setDefault( "anchorY", 0 )

screen = {}
do
  screen.width = display.contentWidth
  screen.height = display.contentHeight
  local inchInMm = 25.4
  local pointsPerInch = 163
  local pointsPerMm = pointsPerInch/25.4
  screen.mmToPoints = function(nMilimeter)
    return math.round(nMilimeter*pointsPerMm)
  end
  screen.inchToPoints = function(nInch)
    return math.round(nInch*pointsPerInch)
  end
end

--[[------------------------------------------------------------------------------
GUI
--------------------------------------------------------------------------------]]
gui = {}
do
--statusbar
  local statusBarHeight = math.ceil(screen.mmToPoints(5))
  gui.statusBar = display.newContainer(screen.width, statusBarHeight)
  gui.statusBar.anchorChildren = false
  gui.statusBar.background = display.newRect(gui.statusBar, 0, 0, screen.width, statusBarHeight)
  gui.statusBar.bottomY = gui.statusBar.y+statusBarHeight
--side control bars
  local controlWidth = math.floor(screen.mmToPoints(10))
  local controlHeight = screen.height-gui.statusBar.bottomY

  gui.controlLeft = display.newContainer(controlWidth, controlHeight)
  gui.controlLeft.x = 0
  gui.controlLeft.y = gui.statusBar.bottomY
  gui.controlLeft.edgeX = gui.controlLeft.x+gui.controlLeft.width
  gui.controlLeft.anchorChildren = false
  gui.controlLeft.background = display.newRect(gui.controlLeft, 0, 0, controlWidth, controlHeight)

  gui.controlRight = display.newContainer(controlWidth,controlHeight)
  gui.controlRight.x = screen.width-controlWidth
  gui.controlRight.y = gui.statusBar.bottomY
  gui.controlRight.anchorChildren = false
  gui.controlRight.background = display.newRect(gui.controlRight, 0, 0, controlWidth, controlHeight)

--buttons
  local buttonHeight = screen.mmToPoints(12)
  local buttonWidth = screen.mmToPoints(8)
  print(buttonWidth.."x"..buttonHeight)
  local buttonX = math.round(controlWidth/2)
  local buttonOffsetY = buttonHeight+screen.mmToPoints(3)
  local controlMiddle = math.round(controlHeight/2)
  local buttonFirstY = controlMiddle-buttonOffsetY
  for _i,side in ipairs({gui.controlLeft,gui.controlRight}) do
    for i=0,2 do
      local button = display.newRoundedRect(side, buttonX, buttonFirstY+buttonOffsetY*i, buttonWidth, buttonHeight, 5)
      button.fill = {
        type = "image",
        filename = tImages.rightArrow,
      }
      button.anchorX = 0.5
      button.anchorY = 0.5
      side["button"..i+1] = button
    end
  end
end

--[[------------------------------------------------------------------------------
Play board
--------------------------------------------------------------------------------]]
--calculate playboard
board = {}
do
  local width = screen.width-gui.controlLeft.width-gui.controlRight.width
  local height = screen.height-gui.statusBar.height
  local tileWidth = screen.mmToPoints(5)
  local tileHeight = screen.mmToPoints(5)
  local columns = math.floor(width/tileWidth)
  local rows = math.floor(height/tileHeight)
  --print(tileWidth.."x"..tileHeight)
  --print(rows.."x"..columns)
  local unusedX = math.floor(width%(tileWidth))
  local unusedY = math.floor(height%(tileHeight))
  board.container = display.newContainer(tileWidth*columns, tileHeight*rows)
  board.container.x = gui.controlLeft.edgeX+1+math.floor(unusedX/2)
  board.container.y = gui.statusBar.bottomY+1+math.floor(unusedY/2)
  board.container.anchorChildren = false
  board.view = {
    rows = rows,
    columns = columns,
    middleRow = math.floor(rows/2),
    middleColumn = math.floor(columns/2),
    playerRowOffset = 0,
    playerColumnOffset = 0,
    scrollRow = 0,
    scrollColumn = 0,
  }
  board.tileWidth = tileWidth
  board.tileHeight = tileHeight
  tClasses.boardTile.base.width = tileWidth
  tClasses.boardTile.base.height = tileHeight
end

--Render play board
board.group = display.newGroup()
for iC = 0,board.view.columns-1+20 do
  board[iR] = {}
  for iY = 0,board.view.rows-1+20 do
    local tile = tClasses.boardTile.blank.new(iR*(tClasses.boardTile.base.width), iC*(tClasses.boardTile.base.height))
    board[iR][iC] = tile
    board.group:insert(tile.disp)
  end
end
board.container:toBack()
board.group:toBack()

--Render player
board.player = display.newImage(board.container, tImages.player, 0, 0)
board.player.row = 1
board.player.column = 1


--[[------------------------------------------------------------------------------
Interactivity
--------------------------------------------------------------------------------]]
local movePlayer = function(nColumn, nRow, bAbsolute)
  local newRow, newColumn
  if bAbsolute then
    newRow = math.max(1, nRow)
    newColumn = math.max(1, nColumn)
  else
    newRow = math.max(1, board.player.row + nRow)
    newColumn = math.max(1, board.player.column + nColumn)
  end
  if newRow ~= board.player.row then
    if newRow <= board.view.middleRow then
      board.player.y = (newRow-1)*board.tileHeight
      board.group.y = 0
    else
      board.player.y = board.view.middleRow*board.tileHeight
      board.group.y = (newRow-board.view.middleRow)*board.tileHeight
    end
    board.player.row = newRow
  end
  if newColumn ~= board.player.column then
    if newColumn <= board.view.middleColumn then
      board.player.x = (newColumn-1)*board.tileWidth
      board.group.x = 0
    else
      board.player.x = board.view.middleColumn*board.tileWidth
      board.group.x = (newColumn-board.view.middleColumn)*board.tileWidth
    end
    board.player.column = newColumn
  end
  board.player.onTile = board.group[newColumn][newRow]
end
gui.controlRight.button2:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      movePlayer(1,0)
    end
  end
)
gui.controlLeft.button2:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      movePlayer(-1,0)
    end
  end
)
gui.controlLeft.button1:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      movePlayer(0,-1)
    end
  end
)
gui.controlLeft.button3:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      movePlayer(0,1)
    end
  end
)
gui.controlRight.button1:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      movePlayer(0,-1)
    end
  end
)
gui.controlRight.button3:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      movePlayer(0,1)
    end
  end
)