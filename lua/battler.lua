--[[=============================================================================== ** Battler v1.0 **  By Lysferd (C) 2015    This class simply draws the battler sprite onscreen.  No animations, no logic, no nothing.===============================================================================--]]----------------------------------------------------------------------- * Frame update.---------------------------------------------------------------------Battler = { }Battler.__index = Battlerfunction Battler.new( source, coordinates )  local obj = setmetatable( { }, Battler )    obj.source = love.graphics.newImage( source )  obj.x = coordinates[1]  obj.y = coordinates[2]  obj.w = obj.source:getWidth()  obj.h = obj.source:getHeight()    Battler.refresh( obj )    return objend----------------------------------------------------------------------- * Frame update.---------------------------------------------------------------------function Battler:update()end---------------------------------------------------------------------function Battler:draw()  love.graphics.draw( self.source, self.x, self.y, 0, 0.5, 0.5, self.w / 2, self.h / 2 )end