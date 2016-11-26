--[[
===============================================================================
 ** Box v1.0 **
  By Lysferd (C) 2015
  
  `Box' is the basic object for any kind of window.
  A Box window is actually made by 9 parts: 4 corners, 4 sides and 1 fill.
===============================================================================
--]]

Box = { }
Box.__index = Box

----------------------------------------------------------------------------
-- * Object Initialisation
--  This function initialises the Box object and its internal variables.
-- param ::= skin_filename (string) - Path to the box skin image.
-- param ::= x (numeric) - X position of the box.
-- param ::= y (numeric) - Y position of the box.
-- param ::= width (numeric) - Width size of the box.
-- param ::= height (numeric) - Height size of the box.
----------------------------------------------------------------------------
function Box.new( skin_filename, x, y, width, height )
  local obj = setmetatable( { }, Box )

  -- Load the skin.
  obj.box_skin = love.graphics.newImage( skin_filename )

  -- Box dimensions/control variables.
  obj.std_w      = width -- size of the box
  obj.std_h      = height
  obj.std_x      = x
  obj.std_y      = y
  obj.skin_w     = obj.box_skin:getWidth() -- size of the skin's total size
  obj.skin_h     = obj.box_skin:getHeight()
  obj.piece_w    = obj.skin_w / 3 -- size of the skin's smallest piece
  obj.piece_h    = obj.skin_h / 3
  obj.open       = false
  obj.opening    = false
  obj.closed     = true -- box is closed by default
  obj.closing    = false
  obj.zoom       = 0 -- initial zoom factor
  obj.zoom_speed = 2 -- zoom animation multiplier
  obj.canvas     = love.graphics.newCanvas()
  Box.refresh_quads(obj)
  Box.refresh(obj)
  
  return obj
end


---------------------------------------------------------------------
-- * Frame update.
---------------------------------------------------------------------
function Box:update()
  if self.opening and not self.open then
    self.zoom = self.zoom + 0.1 * self.zoom_speed
    if self.zoom >= 1 then
      self.zoom = 1
      self.open = true
      self.opening = false
    end
    --Box:update_open()
  elseif self.closing and not self.closed then
    self.zoom = self.zoom - 0.1 * self.zoom_speed
    if self.zoom <= 0 then
      self.zoom = 0
      self.closed = true
      self.closing = false
    end
    --Box:update_close()
  end
end


---------------------------------------------------------------------
-- * Frame update.
---------------------------------------------------------------------
function Box:draw()
  love.graphics.setBlendMode('alpha', 'premultiplied')
  love.graphics.draw( self.canvas, self.std_x, self.std_y, 0, self.zoom, self.zoom, self.std_w / 2, self.std_h / 2 )
  love.graphics.setBlendMode('alpha')
end


---------------------------------------------------------------------
-- * Redraw box.
---------------------------------------------------------------------
function Box:refresh()
  love.graphics.setCanvas( self.canvas )
  love.graphics.setBlendMode( 'alpha' )
  
  love.graphics.draw( self.box_skin,   self.upper_left_corner_quad,                         0,                         0 )
  love.graphics.draw( self.box_skin,  self.upper_right_corner_quad, self.std_w - self.piece_w,                         0 )
  love.graphics.draw( self.box_skin,  self.bottom_left_corner_quad,                         0, self.std_h - self.piece_h )
  love.graphics.draw( self.box_skin, self.bottom_right_corner_quad, self.std_w - self.piece_w, self.std_h - self.piece_w )
  
  love.graphics.draw( self.box_skin, self.up_side_quad, self.piece_w, 0, 0, ( self.std_w - self.piece_w * 2 ) / self.piece_w, 1 )
  love.graphics.draw( self.box_skin, self.left_side_quad, 0, self.piece_h, 0, 1, ( self.std_h - self.piece_h * 2 ) / self.piece_h )
  love.graphics.draw( self.box_skin, self.right_side_quad, self.std_w - self.piece_w, self.piece_h, 0, 1, ( self.std_h - self.piece_h * 2 ) / self.piece_h )
  love.graphics.draw( self.box_skin, self.down_side_quad, self.piece_w, self.std_h - self.piece_h, 0, ( self.std_w - self.piece_w * 2 ) / self.piece_w, 1 )
  
  love.graphics.draw( self.box_skin, self.fill_quad, 4, 4, 0, ( self.std_w - self.piece_w * 2 ) / self.piece_w, ( self.std_h - self.piece_h * 2 ) / self.piece_h, 0, 0 )

  love.graphics.setCanvas()
end


---------------------------------------------------------------------
-- * Redraw quad graphics.
---------------------------------------------------------------------
function Box:refresh_quads()
  -- Corners:
  self.upper_left_corner_quad   = love.graphics.newQuad(                0,                0, self.piece_w, self.piece_h, self.skin_w, self.skin_h )
  self.upper_right_corner_quad  = love.graphics.newQuad( self.piece_w * 2,                0, self.piece_w, self.piece_h, self.skin_w, self.skin_h )
  self.bottom_left_corner_quad  = love.graphics.newQuad(                0, self.piece_h * 2, self.piece_w, self.piece_h, self.skin_w, self.skin_h )
  self.bottom_right_corner_quad = love.graphics.newQuad( self.piece_w * 2, self.piece_h * 2, self.piece_w, self.piece_h, self.skin_w, self.skin_h )
  
  
  -- Sides:
  self.up_side_quad    = love.graphics.newQuad(     self.piece_w,                0, self.piece_w, self.piece_h, self.skin_w, self.skin_h )
  self.down_side_quad  = love.graphics.newQuad(     self.piece_w, self.piece_h * 2, self.piece_w, self.piece_h, self.skin_w, self.skin_h )
  self.right_side_quad = love.graphics.newQuad( self.piece_w * 2,     self.piece_h, self.piece_w, self.piece_h, self.skin_w, self.skin_h )
  self.left_side_quad  = love.graphics.newQuad(                0,     self.piece_w, self.piece_w, self.piece_h, self.skin_w, self.skin_h )
  
  
  -- Filling:
  self.fill_quad = love.graphics.newQuad( self.piece_w, self.piece_h, self.piece_w, self.piece_h, self.skin_w, self.skin_h )
  
  
  -- Canvas:
  self.canvas = love.graphics.newCanvas( self.std_w, self.std_h )
end


---------------------------------------------------------------------
-- * Open box.
---------------------------------------------------------------------
function Box:open_box()
  self.opening = true
  self.closed = false
  self.closing = false
end


---------------------------------------------------------------------
-- * Close box.
---------------------------------------------------------------------
function Box:close_box()
  self.closing = true
  self.open = false
  self.opening = false
end


---------------------------------------------------------------------
-- * Get box x-axis position value.
---------------------------------------------------------------------
function Box:x()
  return self.std_x
end


---------------------------------------------------------------------
-- * Get box y-axis position value.
---------------------------------------------------------------------
function Box:y()
  return self.std_y
end
