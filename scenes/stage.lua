local Map = require('../utils/map')

local g = love.graphics
local phys = love.physics

local Stage = {}

local map

function Stage.load()
  map = Map.new('assets/maps/scene0.lua')
end

function Stage.unload()
  map:destroy()
end

function Stage.update(dt)
  map:update(dt)
end

function Stage.draw()
  map:draw()
end

return Stage
