--[[=============================================================================== ** SceneTitle v1.0 **  By Lysferd (C) 2014  Summary:  Manages the title screen.  Features:  - ... ToDos:  - ...===============================================================================--]]require( 'lua.map.menu' )SceneTitle = { }SceneTitle.__index = SceneTitlefunction SceneTitle.new()  local obj = setmetatable( { }, SceneTitle )    obj.name = 'title'  obj.font = love.graphics.newFont( 24 )    return objendfunction SceneTitle:update()  endfunction SceneTitle:draw()endfunction SceneTitle:terminate()  -- bodyendfunction SceneTitle:keypressed( ... )  endfunction SceneTitle:mousepressed( ... )end