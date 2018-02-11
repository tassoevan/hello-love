local Intro = require('scenes/intro')
local Tiago = require('scenes/tiago')

local currentScene = Intro
Intro.onEnd = function ()
  currentScene = Tiago
  currentScene:load()
end

function love.load()
  currentScene:load()
end

function love.update(dt)
  currentScene:update(dt)
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print('FPS: ' .. love.timer.getFPS(), 0, 0)

  currentScene:draw()
end
