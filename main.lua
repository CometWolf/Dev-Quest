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
File loading
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
      tTable[sFilename:match("(.-)%.lua$").."API"] = require(sPath:gsub("[/\\]","."):sub(1,-5)) --require uses '.' instead of '\'
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
    tTable[sFilename:match("(.-)%.lua$")] = require(sPath:gsub("[/\\]","."):sub(1,-5))
  end
  for k,v in pairs(getFiles(classFolder)) do
    if type(v) == "table" then
      tClasses[k] = {}
      fileFunc(tClasses[k], "base.lua", v["base.lua"]) --Base class must be loaded first
      processFiles(
        v,
        tClasses[k],
        fileFunc
      )
    else
      fileFunc(tClasses,k,v)
    end
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

board = tClasses.board:new(tLevels[1])
board:render()

--Render player
tClasses.entity.player:new(board.spawnColumn, board.spawnRow, board.container) --player:new is assigned to _G.player internally

--[[------------------------------------------------------------------------------
Interactivity
--------------------------------------------------------------------------------]]
buttonAPI.hold(
  gui.controlLeft.button1,
  function()
    player:control(nil,-player.speed)
  end
)
buttonAPI.hold(
  gui.controlLeft.button2,
  function()
    player:control(-player.speed)
  end
)
buttonAPI.hold(
  gui.controlLeft.button3,
  function()
    player:control(nil,player.speed)
  end
)
buttonAPI.hold(
  gui.controlRight.button1,
  function()
    player:control(nil,-player.speed)
  end
)
buttonAPI.hold(
  gui.controlRight.button2,
  function()
    player:control(player.speed)
  end
)
buttonAPI.hold(
  gui.controlRight.button3,
  function()
    player:control(nil,player.speed)
  end
)
