--AI file for level 1
local ai = {
  b = {
    type = "bug",
    ai = function(entity)
      entity.velocityX = entity.x > player.boardX and -1 or entity.x < player.boardX and 1 or 0
      entity.velocityY = entity.y > player.boardY and -1 or entity.y < player.boardY and 1 or 0
      entity:queueMotion()
    end
  },
  s = {
    type = "block"
  }
}

return ai