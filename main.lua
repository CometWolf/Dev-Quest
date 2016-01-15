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
  tileWidth = screen.mmToPoints(5)
  tileHeight = screen.mmToPoints(5)
end

--[[------------------------------------------------------------------------------
Game file loading
--------------------------------------------------------------------------------]]
tClasses = {}
tImages = {}
tLevels = {}
do
  local resourceDirectory = system.getInfo( "platformName" ) ~= "Win" and system.pathForFile().."/" or ""
  local classFolder = "Classes"
  local imageFolder = "Images"
  local levelFolder = "Levels"
  local APIFolder = "APIs"
  local lfs = require("lfs")

  local getFiles
  getFiles = function(sPath,tTable)
    tTable = tTable or {}
    for filename in lfs.dir(resourceDirectory..sPath) do
      if filename ~= "." and filename ~= ".." and filename ~= ".DS_Store" then --why the hell does it return "." and ".."!?
        local filePath = sPath.."/"..filename
        if lfs.attributes(resourceDirectory..filePath,"mode") == "directory" then
          tTable[filename] = {}
          getFiles(filePath,tTable[filename])
        else
          tTable[filename] = filePath
        end
      end
    end
    return tTable
  end

  local processFiles
  processFiles = function(readTable, writeTable, fileFunc)
    for filename, path in pairs(readTable) do
      if type(path) == "string" then
        fileFunc(writeTable, filename, path)
      else
        writeTable[k] = {}
        processFiles(v, writeTable[k], fileFunc)
      end
    end
  end
  
  --Load APIs
  processFiles(
    getFiles(APIFolder),
    _G,
    function(tTable, sFilename, sPath)
      tTable[sFilename:match("(.-)%.lua$").."API"] = require(sPath:gsub("[/\\]","."):match("(.-)%.lua$")) --require uses '.' instead of '\'
    end
  )
  
    --Process image filepaths
  processFiles(
    getFiles(imageFolder),
    tImages,
    function(tTable, sFilename, sPath)
      tTable[sFilename:match("(.-)[@%dx]*%..-$")] = sPath --strip file extension and resolution suffix
    end
  )
  
  --Load classes
  local fileFunc = function(tTable, sFilename, sPath)
    tTable[sFilename:match("(.-)%.lua$")] = require(sPath:gsub("[/\\]","."):match("(.-)%.lua$"))
  end
  for k,v in pairs(getFiles(classFolder)) do
    tClasses[k] = {}
    fileFunc(tClasses[k], "base.lua", v["base.lua"]) --Base class must be loaded first
    processFiles(
      v,
      tClasses[k],
      fileFunc
    )
  end

--Process level filepaths
  processFiles(
    getFiles(levelFolder),
    tLevels,
    function(tTable, sFilename, sPath)
      sFilename = sFilename:match("(.)%.lvl$")
      if sFilename then
        local num = tonumber(sFilename)
        tTable[num and num or sFilename] = sPath
      end
    end
  )
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

  function loadBoard(sPath, tTable)
    local file,err = io.open(sPath)
    if not file then
      error(err)
    end
    local load = tTable or {}
    local columns, rows = 0,0
    local row = 1
    for line in file:lines() do
      rows = row > rows and row or rows
      local column = 1
      for char in line:gmatch"." do
        columns = column > columns and column or columns
        local tileClass = tTileChar[char]
        load[column] = load[column] or {}
        load[column][row] = tileClass
        column = column+1
      end
      row = row+1
    end
    load.columns = columns
    load.rows = rows
    load.spawnColumn = load.spawnColumn or 2
    load.spawnRow = load.spawnRow or 2
    return load
  end
end

--calculate playboard
board = {}
do
  local width = screen.width-gui.controlLeft.width-gui.controlRight.width
  local height = screen.height-gui.statusBar.height
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
    columns = columns,
    rows = rows,
    middleX = math.round(width/2),
    middleY = math.round(height/2),
  }
end

loadBoard(tLevels[1], board)

--Render play board
board.group = display.newGroup()
board.container:insert(board.group)
board.group.anchorChildren = true
do
  local width = tileWidth
  local height = tileHeight
  for iC = 1,board.columns do
    for iR = 1,board.rows do
      board[iC][iR] = board[iC][iR]:new(iC, iR, board.group)
    end
  end
end

--Render player
player = tClasses.entity.player:new(board.spawnColumn, board.spawnRow, board.container)

--[[------------------------------------------------------------------------------
Interactivity
--------------------------------------------------------------------------------]]
buttonAPI.hold(
  gui.controlLeft.button1,
  function()
    if player.inMotion then
      return
    end
    player.accelerationY = player.accelerationY-player.speedY
    player.computePhysics()
  end
)
buttonAPI.hold(
  gui.controlLeft.button2,
  function()
    if player.inMotion then
      return
    end
    player.accelerationX = player.accelerationX-player.speedX
    player.computePhysics()
  end
)
buttonAPI.hold(
  gui.controlLeft.button3,
  function()
    if player.inMotion then
      return
    end
    player.accelerationY = player.accelerationY+player.speedY
    player.computePhysics()
  end
)
buttonAPI.hold(
  gui.controlRight.button1,
  function()
    if player.inMotion then
      return
    end
    player.accelerationY = player.accelerationY-player.speedY
    player.computePhysics()
  end
)
buttonAPI.hold(
  gui.controlRight.button2,
  function()
    if player.inMotion then
      return
    end
    player.accelerationX = player.accelerationX+player.speedX
    player.computePhysics()
  end
)
buttonAPI.hold(
  gui.controlRight.button3,
  function()
    if player.inMotion then
      return
    end
    player.accelerationY = player.accelerationY+player.speedY
    player.computePhysics()
  end
)
