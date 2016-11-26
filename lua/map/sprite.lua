--[[
===============================================================================
 ** Sprite v1.2 **
  By Lysferd (C) 2014
 
 Summary:
  Generates and draws movable characters on the map.
 
 Features:
  - Sprite movement and facing directions are based on graphical source
  - Movement in 8 directions
  - Supports charactersets with all 8 directions

 ToDos:
  - Collision detection

===============================================================================
--]]

---------------------------------------------------------------------
-- * Declare Sprite.
---------------------------------------------------------------------
Sprite = { }
Sprite.__index = Sprite

function Sprite.new( filename )
  local obj = setmetatable( { }, Sprite )
  
  -- Initialise Sprite's bitmap data.
  obj.bitmap = love.graphics.newImage( filename )
  
  --
  -- Get the default coordinates.
  obj.x  = WINDOW_WIDTH / 2   -- fixme: this should be given by the caller
  obj.y  = WINDOW_HEIGHT / 2  -- fixme: this should be given by the caller
  obj.z  = 1                  -- Over ground level
  
  obj.ow = obj.bitmap:getWidth()
  obj.oh = obj.bitmap:getHeight()
  obj.w  = obj.ow / 3
  obj.h  = obj.oh / 4 -- 8 if with diagonal sprite
  
  --
  -- Initialise flow control variables.
  obj.sprinting   = false  -- triggers sprinting
  obj.jumping     = false  -- triggers jumping
  
  obj.jump_height       = 0      -- jump height
  obj.jump_state        = nil    -- jump animation state
  obj.maximum_height    = obj.h  -- maximum jump height is its own height
  obj.total_jump_frames = 6      -- total number of animation frames
  obj.jump_sound        = love.audio.newSource( 'audio/se/Jump1.ogg', 'static' )
  
  obj.anime_frame  = 0      -- start frame count at 0
  obj.total_frames = 3      -- maximum animation frames
  
  obj.move_freq   = 5      -- 1 step each 5 frames
  obj.move_vel    = 1      -- 1 pixel per step
  
  obj.step_frame  = 1      -- current frame in the step animation
  obj.last_step   = 0      -- last frame in the step animation
  obj.direction   = 'down' -- Sprite current direction
  obj.turn_rule   = { down  = 0,
                      left  = 1,
                      right = 2,
                      up    = 3
                      --[[bottom_left  = 0,
                      down         = 1,
                      bottom_right = 2,
                      left         = 3,
                      right        = 4,
                      upper_left   = 5,
                      up           = 6,
                      upper_right  = 7 ]] }
  
  obj.quad = love.graphics.newQuad( 32 * obj.step_frame,
                                32 * obj.turn_rule[obj.direction],
                                32, 32, obj.ow, obj.oh )
  
  return obj
end

---------------------------------------------------------------------
-- * Frame update.
---------------------------------------------------------------------
function Sprite:update()
  if self.jumping then
    if self.jump_state == 'ascending' then
      self.jump_height = self.jump_height + ( self.maximum_height / self.total_jump_frames )
      if self.jump_height >= self.maximum_height then
        self.jump_height = self.maximum_height
        self.jump_state = 'descending'
      end
    elseif self.jump_state == 'descending' then
      self.jump_height = self.jump_height - ( self.maximum_height / self.total_jump_frames )
      if self.jump_height <= 0 then
        self.jump_height = 0
        self.jumping = false
        self.z = 1
      end
    end
  end
end

---------------------------------------------------------------------
-- * Frame draw.
---------------------------------------------------------------------
function Sprite:draw()
  love.graphics.draw( self.bitmap,
                      self.quad,
                      self.x,
                      self.y - self.jump_height,
                      0,
                      1,
                      1,
                      self.w / 2,
                      self.h / 2 )
end

---------------------------------------------------------------------
-- * Make Sprite face a certain direction.
---------------------------------------------------------------------
function Sprite:turn( direction )
  local vx, vy, vw, vh = self.quad:getViewport()
  self.quad:setViewport( vx, 32 * self.turn_rule[direction], vw, vh )
end

---------------------------------------------------------------------
-- * Move Sprite around.
---------------------------------------------------------------------
function Sprite:move( direction )
  self:turn( direction )
  local speed = 1
  if self.sprinting then speed = 2 end
  
  if direction == 'up' then
    self.y = self.y - 1 * speed
  elseif direction == 'down' then
    self.y = self.y + 1 * speed
  elseif direction == 'left' then
    self.x = self.x - 1 * speed
  elseif direction == 'right' then
    self.x = self.x + 1 * speed
  elseif direction == 'bottom_left' then
    self.x = self.x - 1 * speed
    self.y = self.y + 1 * speed
  elseif direction == 'bottom_right' then
    self.x = self.x + 1 * speed
    self.y = self.y + 1 * speed
  elseif direction == 'upper_left' then
    self.x = self.x - 1 * speed
    self.y = self.y - 1 * speed
  elseif direction == 'upper_right' then
    self.x = self.x + 1 * speed
    self.y = self.y - 1 * speed
  end
end

---------------------------------------------------------------------
-- * Frame update.
---------------------------------------------------------------------
function Sprite:jump()
  self.jump_sound:play()
  self.jumping = true
  self.jump_state = 'ascending'
  self.z = self.z + 1
end

---------------------------------------------------------------------
-- * Animate Sprite walking.
---------------------------------------------------------------------
function Sprite:animate()
  local speed = 1
  if self.sprinting then speed = 2 end
  
  if self.animate then self.anime_frame = self.anime_frame + self.move_vel * speed end
  
  if self.anime_frame >= self.move_freq then
    if self.step_frame == 1 then
      if self.last_step == 0 then
        self.step_frame = 2
      else
        self.step_frame = 0
      end
    else
      self.last_step = self.step_frame
      self.step_frame = 1
    end
    local vx, vy, vw, vh = self.quad:getViewport()
    self.quad:setViewport( 32 * self.step_frame, vy, vw, vh )
    self.anime_frame = self.anime_frame - self.move_freq
  end
end

---------------------------------------------------------------------
-- * Resets to standing position at movement stop.
---------------------------------------------------------------------
function Sprite:straighten()
  self.last_step = self.step_frame
  self.step_frame = 1
  local vx, vy, vw, vh = self.quad:getViewport()
  self.quad:setViewport( 32 * self.step_frame, vy, vw, vh )
end