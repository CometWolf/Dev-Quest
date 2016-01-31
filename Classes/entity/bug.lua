--Bug boardTile class

--Inheritance
local class = tClasses.entity.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.player
class.type = "bug"

--Class methods

return class