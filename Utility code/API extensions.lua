local copyTable
copyTable = function(t,bDeep)
  local copy = {}
  for k,v in pairs(t) do
    if type(v) == "table" and bDeep then
      copy[k] = copyTable(v)
    else
      copy[k] = v
    end
  end
  return copy
end
table.copy = copyTable

math.round = function(n)
  return math.floor((math.floor(n*2) + 1)/2)
end