local Intro = {}

local introDuration = 4
local w, h
local stars = {}
local evanBrosText
local t = 0

function Intro.load()
  w = love.graphics.getWidth()
  h = love.graphics.getHeight()

  love.graphics.setBackgroundColor(0, 0, 0)
  evanBrosText = love.graphics.newText(love.graphics.newFont(32), 'EvanBros™')

  for i = 1, math.pow(w * h, .5) do
    stars[i] = {}
    stars[i].x = math.random()
    stars[i].y = math.random()
    stars[i].z = math.random()
  end
end

function Intro.update(dt)
  if t > 1 then
    if Intro.onEnd then Intro.onEnd() else return end
  else
    t = t + (1 / introDuration)  * dt
  end

  for i, star in pairs(stars) do
    star.y = star.y + .1 * star.z * dt
    if star.y >= 1 then star.y = star.y - 1 end
  end
end

function Intro.draw()
  local alphaText = math.pow(math.sin(math.pi * t), 10)
  local alphaStars = math.pow(math.sin(math.pi * t), 2)

  love.graphics.setColor(0, 127, 255, 255 * alphaText)
  love.graphics.draw(evanBrosText, w / 2 - evanBrosText:getWidth() / 2, h / 2 - evanBrosText:getHeight() / 2)

  for i, star in pairs(stars) do
    love.graphics.setColor(255, 255, 255, 127 * alphaStars * star.z)
    love.graphics.circle('fill', star.x * w, star.y * h, 1)
  end
end

return Intro
