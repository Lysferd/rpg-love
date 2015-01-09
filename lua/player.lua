--[[
===============================================================================
 ** Player v1.1 **
  By Lysferd (C) 2014
 
 Summary:
  The playable character.
 
 Features:
  - Implements movement by key press.

 ToDos:
  - Collision detection
  - Mouse movement

===============================================================================
--]]

require( 'lua.sprite' )

---------------------------------------------------------------------
-- * Declare Player.
---------------------------------------------------------------------
Player = { }
Player.__index = Player

function Player.new()
  local obj = { }
  setmetatable( obj, Player )
  
  obj.sprite = Sprite.new( 'graphics/char2.png' )
  
  return obj
end

---------------------------------------------------------------------
-- * Frame update.
---------------------------------------------------------------------
function Player:update()
  if love.keyboard.isDown( 'w', 's', 'a', 'd' ) then
    self.sprite.sprinting = love.keyboard.isDown( 'lshift' )
    
    if love.keyboard.isDown( 'w' ) then
      if love.keyboard.isDown( 'a' ) then
        self.sprite:move( 'upper_left' )
      elseif love.keyboard.isDown( 'd' ) then
        self.sprite:move( 'upper_right' )
      else
        self.sprite:move( 'up' )
      end
    elseif love.keyboard.isDown( 's' ) then
      if love.keyboard.isDown( 'a' ) then
        self.sprite:move( 'bottom_left' )
      elseif love.keyboard.isDown( 'd' ) then
        self.sprite:move( 'bottom_right' )
      else
        self.sprite:move( 'down' )
      end
    elseif love.keyboard.isDown( 'a' ) then
      self.sprite:move( 'left' )
    elseif love.keyboard.isDown( 'd' ) then
      self.sprite:move( 'right' )
    end
    
    
    self.sprite:animate()
  else
    self.sprite:straighten()
  end
  
  self.sprite:update()
end

---------------------------------------------------------------------
-- * Frame draw.
---------------------------------------------------------------------
function Player:draw()
  self.sprite:draw()
end


---------------------------------------------------------------------
-- * Frame update.
---------------------------------------------------------------------
function Player:keypressed( key, isrepeat )
  if key == ' ' and not self.sprite.jumping then
    self.sprite:jump()
  end
end


---------------------------------------------------------------------
-- * Frame update.
---------------------------------------------------------------------
function Player:coordinates()
  return self.sprite.x, self.sprite.y, self.sprite.z
end
