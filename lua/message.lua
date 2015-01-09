--[[
===============================================================================
 ** Message v1.1 **
  By Lysferd (C) 2014
 
 Summary:
  The standard message box.
 
 Features:
  - Implements letter-by-letter animation.

 ToDos:
  - Rich text

===============================================================================
--]]

require( 'lua.box' )

---------------------------------------------------------------------
-- * Declare Message.
---------------------------------------------------------------------
Message = { }
Message.__index = Message

function Message.new()
  local obj = { }
  setmetatable( obj, Message )

  local w, h = 480, 86
  local x, y = WINDOW_WIDTH / 2, WINDOW_HEIGHT - h

  obj.box           = Box.new( 'graphics/box_skin.png', x, y, w, h )
  obj.font          = FONT
  obj.contents_x    = x - w / 2 + 8
  obj.contents_y    = y - h / 2 + 8
  obj.message_shown = ''
  obj.line_count    = 0
  obj.dump          = { }
  
  return obj
end

---------------------------------------------------------------------
-- * Frame update.
---------------------------------------------------------------------
function Message:update()
  self.box:update()
end

---------------------------------------------------------------------
-- * Frame draw.
---------------------------------------------------------------------
function Message:draw()
  self.box:draw()
  
  if not self.box.open then return end
  
  local empty = false
  local next = next
  if next( self.dump ) == nil then empty = true end
  
  if not empty then
    local c = table.remove( self.dump, 1 )
    if c:match( '\\c%[([a-f%d]+)%]' ) then
      -- CHANGE COLOR
    end
    self.message_shown = self.message_shown .. c
  end
  
  local f = love.graphics.getFont()
  love.graphics.setFont( self.font )
  love.graphics.print( self.message_shown, self.contents_x, self.contents_y )
  love.graphics.setFont( f )
end

---------------------------------------------------------------------
-- * Show message.
---------------------------------------------------------------------
function Message:show( s )
  if s == '' or self.box.open then
    return
  end
  for c in s:gmatch( '.' ) do
    if c == '\n' then
      self.line_count = self.line_count + 1
    --elseif c == '\\'
    end
    table.insert( self.dump, c )
    --self.dump:insert( c )
  end
  
  if not ( self.box.open or self.box.opening ) then
    self.box:open_box()
  end
end

---------------------------------------------------------------------
-- * Defines the clickable region of the message box.
---------------------------------------------------------------------
function Message:clickableArea()
  return self.box:x(), self.box:y(), self.box.canvas:getDimensions()
end


-- DEBUG --
function Message:keypressed( key, isrepeat )
  if key == 'o' then
    self:show( 'Message box test. Click anywhere in the box to close it.' )
  end
end

function Message:mousepressed( x, y )
  self.message_shown = ''
  self.box:close_box()
end
-- DEBUG