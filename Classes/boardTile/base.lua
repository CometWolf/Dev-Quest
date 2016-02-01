--Base boardTile class

--Forward declarations
local class = {}

--Public properties
class.objMt = {__index = class} --metatable for created objects
class.width = tileWidth
class.height = tileHeight
class.friction = 1

--Class methods
function class:new(nColumn, nRow, parent)
  local obj = {
    disp = display.newImageRect(self.texture, self.width, self.height),
    column = nColumn,
    row = nRow,
    entity = { --table listing entities on the tile

    },
  }
  obj.disp.x = (nColumn-1)*self.width
  obj.disp.y = (nRow-1)*self.height
  if parent then
    parent:insert(obj.disp)
  end
  return setmetatable(obj, self.objMt)
end

function class:inherit()
  return setmetatable({}, self.objMt)
end

--Public methods
function class:enter(entity,nMotionX,nMotionY)
  return true
end

function class:inside(entity,nMotionX,nMotionY)
  return true
end

function class:leave(entity,nMotionX,nMotionY)
  return true
end

function class:entityInteraction(interactingEntity,motionX,motionY) --handles entity interaction on the tile
  local allowMotion = true
  for k,interactedEntity in pairs(self.entity) do
    if interactingEntity ~= interactedEntity then
      local action = interactingEntity.interaction[interactedEntity.type] or interactingEntity.interaction.any
      local reaction = interactedEntity.reaction[interactingEntity.type] or interactedEntity.reaction.any
      if action or reaction then
        local interactingX = (interactingEntity.boardX or interactingEntity.disp.x)+motionX
        local interactingY = (interactingEntity.boardY or interactingEntity.disp.y)+motionY
        local interactedX = interactedEntity.boardX  or interactedEntity.disp.x
        local interactedY = interactedEntity.boardY  or interactedEntity.disp.y
        if (
          interactingX < interactedX + interactedEntity.disp.contentWidth
          and interactingX + interactingEntity.disp.contentWidth > interactedX
          and interactingY < interactedY + interactedEntity.disp.contentHeight
          and interactingY + interactingEntity.disp.contentHeight > interactedY
          )
        then
          local res
          if action then
            if action(interactingEntity, interactedEntity, motionX, motionY) == false then
              allowMotion = false
            end
          end
          if reaction then
            if reaction(interactedEntity, interactingEntity, motionX, motionY) == false then
              allowMotion = false
            end
          end
        end
      end
    end
  end
  return allowMotion
end

return class