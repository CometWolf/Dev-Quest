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
  screen.middleX = screen.width*0.5
  screen.middleY = screen.height*0.5
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
  
--Player control touch overlay
  gui.controlOverlay = display.newRect(0, 0, screen.width, screen.height)
  gui.controlOverlay.isVisible = false
  gui.controlOverlay.isHitTestable = true
  gui.statusBar:toFront()
end

--[[------------------------------------------------------------------------------
Play board
--------------------------------------------------------------------------------]]

board = tClasses.board:new(tLevels[1])
board:render()

--Render player
player = tClasses.entity.player:new(board.spawnColumn, board.spawnRow, board) --player:new is assigned to _G.player internally

--[[------------------------------------------------------------------------------
Interactivity
--------------------------------------------------------------------------------]]
do
  local yOffset = gui.statusBar.contentHeight/2
  local middleX, middleY = screen.middleX, screen.middleY+yOffset
  local playerSpeed = player.speed
  local x,y = 0,0
  local controlled
  gui.controlOverlay:addEventListener(
    "touch",
    function(event)
      x = (event.x-middleX)/middleX
      y = (event.y-middleY)/middleY
      
      if x > 0.25 then
        x = (x <= 0.7 and x + 0.7 or 1)*playerSpeed
      elseif x < -0.25 then
        x = (x >= -0.7 and x - 0.7 or -1)*playerSpeed
      else
        x = x*playerSpeed*2.8
      end
      
      if y > 0.25 then
        y = (y <= 0.7 and y + 0.7 or 1)*playerSpeed
      elseif y < -0.25 then
        y = (y >= -0.7 and y - 0.7 or -1)*playerSpeed
      else
        y = y*playerSpeed*2.8
      end
      
      controlled = event.phase ~= "ended"
    end
  )
  player:hookAi(
    function(entity)
      if controlled then
        entity:control(x*playerSpeed,y*playerSpeed)
      end
    end
  )
end