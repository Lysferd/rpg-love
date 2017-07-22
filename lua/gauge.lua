
Gauge = { }

function Gauge:new()
  obj = obj or { }
  setmetatable( obj, self )
  self.__index = self

  obj.filled = 1.0
  obj.color = 'green'

  return obj
end

function Gauge:update()
end
