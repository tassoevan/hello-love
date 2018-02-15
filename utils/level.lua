local g = love.graphics
local phys = love.physics

local Level = {}
Level.__index = Level

local blockSize = 0.5

function Level.new()
  local self = {}
  setmetatable(self, Level)

  self.world = phys.newWorld(0, 9.81, true)

  self.left = 0
  self.top = 0
  self.right = 0
  self.bottom = 0

  self.templateBlocks = {}
  self.objects = {}

  return self
end

function Level:destroy()
  self.world:destroy()
end

function Level:addTemplateBlock(id)
  local block = {}

  table.insert(self.templateBlocks, block)
end

function Level:add(x, y, spriteNum)
  local object = {
    x = x,
    y = y,
    spriteNum = spriteNum
  }

  self.left = math.min(self.left, x - 0.5)
  self.right = math.max(self.right, x + 0.5)
  self.top = math.min(self.top, y - 0.5)
  self.bottom = math.max(self.bottom, y + 0.5)

  object.body = phys.newBody(self.world, blockSize * x, blockSize * y, 'kinematic')
  object.fixture = phys.newFixture(object.body, phys.newRectangleShape(0, 0, blockSize, blockSize), 1)
  object.body:setFixedRotation(true)
  object.fixture:setRestitution(0)
  object.fixture:setFriction(1)
  object.fixture:setUserData(object)

  table.insert(self.objects, object)
end

function Level:getWidth()
  return self.right - self.left
end

function Level:getHeight()
  return self.bottom - self.top
end

function Level:update(dt)
  self.world:update(dt)
end

function Level:draw()
  g.setColor(255, 255, 255)
  g.print(self:getWidth() .. 'x' .. self:getHeight(), 0, 12)

  local cx = 0
  local cy = 0

  local m = phys.getMeter()
  local w = (self.right - self.left) * m
  local h = (self.bottom - self.top) * m

  self.world:queryBoundingBox(0, 0, w, h, function (fixture)
    local body = fixture:getBody()
    local shape = fixture:getShape()
    local object = fixture:getUserData()

    g.setColor(255, 0, 0)
    g.circle('fill', body:getX(), body:getY(), 1)

    if shape:getType() == 'polygon' then
      g.setColor(255, 0, 0, 127)
      g.polygon('fill', body:getWorldPoints(shape:getPoints()))
      g.setColor(255, 0, 0)
      g.polygon('line', body:getWorldPoints(shape:getPoints()))
    elseif shape:getType() == 'edge' then
      g.setColor(0, 255, 0)
      g.line(body:getWorldPoints(shape:getPoints()))
    elseif shape:getType() == 'circle' then
      g.setColor(0, 0, 255, 127)
      g.circle('fill', body:getX(), body:getY(), shape:getRadius())
    end

    return true
  end)
end

return Level
