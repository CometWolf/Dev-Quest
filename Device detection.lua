local device = {}
local model = system.getInfo( "model" )
local height = display.pixelHeight
if model:match"^iP" then
  device.os = "ios"
  if height < 1136 then
    device.model = "iphone 4"
    device.ppi = 326
  elseif height < 1334 then
    device.model = "iphone 5"
    device.ppi = 326
  elseif height < 1920 then
    device.model = "iphone 6"
    device.ppi = 326
  else
    device.model = "iphone 6+"
    device.ppi = 401
  end
else
  device.os = "android"
  device.ppi = system.getInfo("androidDisplayApproximateDpi")
end

return device