local g = love.graphics
local phys = love.physics

local Map = {}
Map.__index = Map

function Map.new(filepath)
  local dirpath = filepath:match('^.*[/\\]')
  local chunk, errormsg = love.filesystem.load(filepath)
  local self = chunk()
  setmetatable(self, Map)

  self.tiles = {}

  for i,tileset in pairs(self.tilesets) do
    local tilesetname = tileset.image:match('.*/(.*)$')
    tileset.image = g.newImage('assets/tilesets/' .. tilesetname)

    local lastgid = tileset.firstgid + tileset.tilecount - 1

    for id = tileset.firstgid,lastgid do
      local tile = {}

      for j,tile_ in pairs(tileset.tiles) do
        if id == tile_.id then
          tile = tile_
          break
        end
      end

      tile.image = tileset.image

      local x = (id - tileset.firstgid) % (tileset.imagewidth / tileset.tilewidth)
      local y = math.floor((id - tileset.firstgid) / (tileset.imagewidth / tileset.tilewidth))

      tile.quad = g.newQuad(x * tileset.tilewidth, y * tileset.tileheight, tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight)

      self.tiles[id] = tile
    end
  end

  self.world = phys.newWorld(0, 9.81, true)

  for i,layer in pairs(self.layers) do
    for j,id in pairs(layer.data) do
      local tile = self.tiles[id]

      if tile then
        local x = (layer.offsetx + (j - 1) % layer.width) * self.tilewidth
        local y = (layer.offsety + math.floor((j - 1) / layer.width)) * self.tilewidth
        self:createBlock(tile, x, y)
      end
    end
  end

  return self
end

function Map:destroy()
  for i,tileset in pairs(self.tilesets) do
    tileset.image:release()
  end
end

function Map:createBlock(tile, x, y)
  local body = phys.newBody(self.world, x, y, 'kinematic')
  local fixture = phys.newFixture(body, phys.newRectangleShape(0, 0, self.tilewidth, self.tileheight), 1)

  body:setFixedRotation(true)
  fixture:setRestitution(0)
  fixture:setFriction(1)
  fixture:setUserData(tile)
end

function Map:update(dt)
  self.world:update(dt)
end

function Map:draw()
  self.world:queryBoundingBox(0, 0, self.width * self.tilewidth, self.height * self.tileheight, function (fixture)
    local body = fixture:getBody()
    local shape = fixture:getShape()
    local tile = fixture:getUserData()

    g.setColor(255, 0, 0)
    g.circle('fill', body:getX(), body:getY(), 1)

    g.setColor(255, 255, 255)
    g.draw(tile.image, tile.quad, body:getX() - self.tilewidth / 2, body:getY() - self.tileheight / 2)

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

return Map
