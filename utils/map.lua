local g = love.graphics

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

    local tiles = { unpack(tileset.tiles) }

    tileset.tiles = {}

    for j,tile in pairs(tiles) do
      tileset.tiles[tile.id - tileset.firstgid + 1] = tile
    end

    for y = 1,tileset.imageheight,tileset.tileheight do
      for x = 1,tileset.imagewidth,tileset.tilewidth do
        local tile = tileset.tiles[#tileset.tiles]
        if not tile then tile = {} end

        tile.quad = g.newQuad(x, y, tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight)
        tileset.tiles[#tileset.tiles + 1] = tile
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

function Map:getTile(id)
  if self.tiles[id] then
    return self.tiles[id]
  end

  for i,tileset in pairs(self.tilesets) do
    local lastgid = tileset.firstgid + tileset.tilecount - 1

    if id >= tileset.firstgid and id <= lastgid then
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

      return tile
    end
  end

  return nil
end

function Map:update(dt)
end

function Map:draw()
  for i,layer in pairs(self.layers) do
    for j,id in pairs(layer.data) do
      local tile = self:getTile(id)

      if tile then
        local x = (layer.offsetx + (j - 1) % layer.width) * self.tilewidth
        local y = (layer.offsety + math.floor((j - 1) / layer.width)) * self.tilewidth
        g.draw(tile.image, tile.quad, x, y)
      end
    end
  end
end

return Map
