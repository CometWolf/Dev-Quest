--AI file for level 1
local trackedPlayer
local ai = {
  b = {
    type = "bug",
    ai = function(entity)
      if trackedPlayer then
        entity:die()
      else
        local playerDistX, playerDistY = entity:moveTowards(player)
        if entity.tile == player.tile then
          trackedPlayer = true
        end
      end
    end
  },
  s = {
    type = "block"
  }
}

return ai