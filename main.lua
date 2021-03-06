--
-- Developing a game framework with LÖVE
--

require( 'lua.color' )
require( 'lua.audio' )
require( 'lua.input' )
require( 'lua.graphics' )
require( 'lua.battle.party' ) -- check
require( 'lua.scene_manager' )

function love.load()
  -------------------------------------------------------------------
  -- CONSTANTS
  WINDOW_WIDTH  = love.graphics:getWidth()
  WINDOW_HEIGHT = love.graphics:getHeight()
  FONT          = love.graphics.newFont( 'fonts/msgothic.ttc', 10 )
  GRAYSCALE     = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
      vec4 pixel = Texel( texture, tc );
      number gray =  0.30 * pixel.r + 0.59 * pixel.g + 0.11 * pixel.b;
      return vec4(vec3( gray, gray, gray ), pixel.a );
    }
  ]]
  show_dev = true
  
  -------------------------------------------------------------------
  -- DEFAULTS
  love.graphics.setBackgroundColor( 20, 20, 60 )
  love.graphics.setFont( FONT )
  
  dev_canvas = love.graphics.newCanvas()
  love.graphics.setCanvas( dev_canvas )
  local intel = 'Show/hide development intel with 0.\n' ..
                'Quit with ESC or Q.\n' ..
                'Scene selection: (1)free scene (2)title scene (3)battle scene'
  love.graphics.print_outline( intel, 'left', 'bottom' )
  love.graphics.setCanvas()
  
  -------------------------------------------------------------------
  -- OBJECT INITIALIZATION
  -- FIXME: This object shouldn't be initialized at startup, but rather
  --        after the player has created a new game file, or when a
  --        save game file is loaded.
  party = Party.new()
  troop = Troop.new()
  scene_manager = SceneManager.new()
end

---------------------------------------------------------------------
-- Frame update.
---------------------------------------------------------------------
function love.update( dt )
  scene_manager:update()
  
  -------------------------------------------------------------------
  -- PANIC EXIT -----------------------------------------------------
  if love.keyboard.isDown( 'escape', 'q' ) then 
    love.event.quit()
  end
end

---------------------------------------------------------------------
-- Frame draw.
---------------------------------------------------------------------
function love.draw()
  scene_manager:draw()

  --love.graphics.line( WINDOW_WIDTH / 2, 0, WINDOW_WIDTH / 2, WINDOW_HEIGHT )
  --love.graphics.line( 0, WINDOW_HEIGHT / 2, WINDOW_WIDTH, WINDOW_HEIGHT / 2 )
  
  -------------------------------------------------------------------
  -- DRAW FPS -------------------------------------------------------
  local fps = 'FPS: ' .. love.timer.getFPS()
  love.graphics.print_outline( fps, 'right', 'top' )
  
  -------------------------------------------------------------------
  -- DRAW CURRENT SCENE NAME ----------------------------------------
  if scene_manager:current() then
    local scene_name = scene_manager:current():upper() .. ' SCENE'
    love.graphics.print_outline( scene_name, 'center', 'top' )
  end

  if not show_dev then return end
  
  -------------------------------------------------------------------
  -- DRAW DEV INTEL -------------------------------------------------
  local original_color = { love.graphics.getColor() }
  love.graphics.setColor( Color.green )
  
  local x, y = love.mouse.getPosition()
  local text = 'Mouse cursor position: ' .. x .. 'x' .. y
  love.graphics.print_outline( text, 'left', 'top' )
  
  if scene_manager.scene and scene_manager.scene.name == 'free' then
    local cx, cy, cz = scene_manager.scene.player:coordinates()
    local text = 'Character Position: (' .. cx .. ', ' .. cy .. ', ' .. cz .. ')'
    love.graphics.print_outline( text, 'left', FONT:getHeight() + 8 )
  end
  
  -- local dt  = 'Δt: ' .. love.timer.getDelta()
  -- love.graphics.print_outline( dt, WINDOW_WIDTH - string.len( dt ) * 5 - 5, FONT:getHeight() + 8 )
  
  love.graphics.setBlendMode('alpha', 'premultiplied')
  love.graphics.draw( dev_canvas )
  love.graphics.setBlendMode('alpha')
  
  love.graphics.setColor( original_color )
end

---------------------------------------------------------------------
-- Keyboard callback
---------------------------------------------------------------------
function love.keypressed( key, isrepeat )
  scene_manager:keypressed( key, isrepeat )
  
  if key == '1' then
    scene_manager:change_to( 'map' )
  elseif key == '2' then
    scene_manager:change_to( 'title' )
  elseif key == '3' then
    scene_manager:change_to( 'battle' )
  end
  
  if key == '0' then
    show_dev = not show_dev
    --debug.debug()
  end
end

---------------------------------------------------------------------
-- * Mouse callback
---------------------------------------------------------------------
function love.mousepressed( ... )
  scene_manager:mousepressed( ... )
end

---------------------------------------------------------------------
-- * Assert that the mouse is within a certain clickable region.
---------------------------------------------------------------------
function within_area( mx, my, ax, ay, aw, ah )
  return mx >= ax - aw / 2 and
         mx <= ax + aw / 2 and
         my >= ay - ah / 2 and
         my <= ay + ah / 2
end
