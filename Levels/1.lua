--AI file for level 1
local trackedPlayer
local ai = {
  b = {
    type = "bug",
    ai = function(entity)
      if trackedPlayer then
        entity:moveTowards(math.random()*1000,math.random()*1000)
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