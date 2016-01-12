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
tLevels = {}
do
  local classFolder = "Classes"
  local imageFolder = "Images"
  local levelFolder = "Levels"
  local lfs = require("lfs")

  local findFiles
  findFiles = function(sPath,tTable)
    for fileName in lfs.dir(sPath) do
      if fileName ~= "." and fileName ~= ".." then --why the hell does it return "." and ".."!?
        local filePath = sPath.."/"..fileName
        if lfs.attributes(filePath,"mode") == "directory" then
          tTable[fileName] = {}
          findImages(filePath,tTable[fileName])
        else
          fileName = fileName:match("(.-)%..-$")
          local num = tonumber(fileName)
          print(fileName)
          tTable[num and num or fileName] = filePath
        end
      end
    end
  end
  findFiles(levelFolder,tLevels)

  local findImages
  findImages = function(sPath,tTable)
    for fileName in lfs.dir(sPath) do
      if fileName ~= "." and fileName ~= ".." then
        local filePath = sPath.."/"..fileName
        if lfs.attributes(filePath,"mode") == "directory" then
          tTable[fileName] = {}
          findImages(filePath,tTable[fileName])
        else
          tTable[fileName:match("(.-)[@%dx]*%..-$")] = filePath --strip file extension and resolution prefix
        end
      end
    end
  end
  findImages(imageFolder,tImages)

  local loadClass
  loadClass = function(sPath,tTable)
    local tFile = {}
    local tDir = {}
    for fileName in lfs.dir(sPath) do
      if fileName ~= "." and fileName ~= ".." then  
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
  gui.statusBar:toFront()
end

--[[------------------------------------------------------------------------------
Play board
--------------------------------------------------------------------------------]]
do
  local tTileChar = {}
  for k,v in pairs(tClasses.boardTile) do
    if v.char then
      tTileChar[v.char] = v
    end
  end

  function loadBoard(sPath)
    local file,err = io.open(sPath)
    if not file then
      error(err)
    end
    local load = {}
    local i = 1
    for line in file:lines() do
      load[i] = {}
      local j = 1
      for char in line:gmatch"." do
        load[i][j] = tTileChar[char]
        j = j+1
      end
      i = i+1
    end
    return load
  end
end

board = loadBoard(tLevels[1])

--calculate playboard
do
  local width = screen.width-gui.controlLeft.width-gui.controlRight.width
  local height = screen.height-gui.statusBar.height
  local tileWidth = screen.mmToPoints(5)
  local tileHeight = screen.mmToPoints(5)
  local columns = math.floor(width/tileWidth)
  local rows = math.floor(height/tileHeight)
  local unusedX = math.floor(width%(tileWidth))
  local unusedY = math.floor(height%(tileHeight))
  board.container = display.newContainer(tileWidth*columns, tileHeight*rows)
  board.container:toBack()
  board.container.x = gui.controlLeft.edgeX+math.floor(unusedX/2)
  board.container.y = gui.statusBar.bottomY+math.floor(unusedY/2)
  board.container.anchorChildren = false
  board.view = {
    rows = rows,
    columns = columns,
    middleRow = math.floor(rows/2)+1,
    middleColumn = math.floor(columns/2)+1,
  }
  board.tileWidth = tileWidth
  board.tileHeight = tileHeight
  board.columns = #board
  board.rows = #board[1]
  tClasses.boardTile.base.width = tileWidth
  tClasses.boardTile.base.height = tileHeight
end

--Render play board
board.group = display.newGroup()
board.container:insert(board.group)
board.group.anchorChildren = true
do
  local tileClass = tClasses.boardTile.blank
  local width = tClasses.boardTile.base.width
  local height = tClasses.boardTile.base.height
  for iC = 1,board.columns do
    for iR = 1,board.rows do
      local tile = board[iC][iR]:new()
      tile:render((iC-1)*width, (iR-1)*height, board.group)
      board[iC][iR] = tile
    end
  end
end

--Render player
player = tClasses.entity.player:new(2,2)
player:render(nil,nil,board.container)

--[[------------------------------------------------------------------------------
Interactivity
--------------------------------------------------------------------------------]]
gui.controlRight.button2:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      player:tryMove(1,0)
    end
  end
)
gui.controlLeft.button2:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      player:tryMove(-1,0)
    end
  end
)
gui.controlLeft.button1:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      player:tryMove(0,-1)
    end
  end
)
gui.controlLeft.button3:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      player:tryMove(0,1)
    end
  end
)
gui.controlRight.button1:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      player:tryMove(0,-1)
    end
  end
)
gui.controlRight.button3:addEventListener(
  "touch",
  function(event)
    if event.phase == "began" then
      player:tryMove(0,1)
    end
  end
)