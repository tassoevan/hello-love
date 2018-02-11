local Intro = require('scenes/intro')
local Tiago = require('scenes/tiago')

local currentScene = nil
local nextScene = nil

function love.load()
  nextScene = Intro
  Intro.onEnd = function ()
    nextScene = Tiago
  end
end

function love.update(dt)
  if nextScene then
    if currentScene and currentScene.unload then currentScene.unload() end

    currentScene = nextScene
    nextScene = nil

    if currentScene.load then currentScene.load() end
  end

  if currentScene.update then currentScene.update(dt) end
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print('FPS: ' .. love.timer.getFPS(), 0, 0)

  if currentScene.draw then currentScene.draw() end
end
