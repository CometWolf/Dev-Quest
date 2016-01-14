--Button handling API

--Forward declarations
local API = {}

--Public methods
API.hold = function(displayObj, func)
  displayObj:addEventListener(
    "touch",
    function(event)
      if event.phase == "began" then
        displayObj.held = true
      elseif event.phase == "ended" or event.phase == "cancelled" then
        displayObj.held = false
      end
    end
  )
  Runtime:addEventListener(
    "enterFrame",
    function()
      if displayObj.held then
        func()
      end
    end
  )
end

return API