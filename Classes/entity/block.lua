--Bug boardTile class

--Inheritance
local class = tClasses.entity.base:inherit()

--Public properties
class.objMt = {__index = class}
class.texture = tImages.blockTile
class.type = "block"
class.speed = 10
class.pushable = true

--Class methods


return class