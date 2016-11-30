--[[
   Copyright (c) 2016 Justin van der Leij 'Tjakka5'

   Permission is hereby granted, free of charge, to any person
   obtaining a copy of this software and associated documentation
   files (the "Software"), to deal in the Software without
   restriction, including without limitation the rights to use,
   copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the
   Software is furnished to do so, subject to the following
   conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
   OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   OTHER DEALINGS IN THE SOFTWARE.
]]

local _PATH     = (...):gsub('%.[^%.]+$', '')
local ModelData = require(_PATH..".modelData")
local Camera    = require(_PATH..".camera")

-- Fill a model's spritebatch
local function setup(self)
   self.spritebatch = love.graphics.newSpriteBatch(self.texture, self.frames)

   for frame = 1, self.frames do
      self.ids[frame] = self.spritebatch:add(self.quads[frame])
   end
end

-- Draw a model and add it to the zbuffer
local function draw(self, x, y, z, rotation, xScale, yScale)
   x, y, z        = x, y, z or 0, 0, 0
   rotation       = rotation or 0
   xScale, yScale = xScale or 1, yScale or 1

   self.x, self.y, self.z = x, y, z
   self.rotation          = rotation + Camera.rotation
   self.depth             = Camera:getDepth(x, y, z)

   -- Only re-render when needed
   if self.rotation ~= self.oldRotation or self.xScale ~= self.oldxScale or self.yScale ~= self.oldyScale then
      -- Loop trough all textures and draw them with a offset
      for frame = 1, self.frames do
         self.spritebatch:set(
            self.ids[frame],
            self.quads[frame],
            0, 0 - frame * yScale,
            self.rotation,
            xScale, yScale,
            self.width  / 2,
            self.height / 2
         )
      end

      -- Log the rotation and scale
      self.oldRotation = self.rotation
      self.oldxScale   = self.xScale
      self.oldyScale   = self.yScale
   end

   -- Tell the camera to draw this model
   Camera:draw(self)
end

-- Create a new model object
local function new(modelData)
   local model = setmetatable({
      x = 0, y = 0, z = 0,
      rotation = 0,
      depth    = 0,

      spritebatch = nil,
      ids         = {},

      oldRotation = math.huge,
      oldxScale   = math.huge,
      oldyScale   = math.huge,

      setup  = setup,
      draw   = draw,
   }, {
      __index = modelData
   })

   model:setup()
   return model
end

-- Return module
return setmetatable({
   new    = new,
   draw   = draw,
}, {
   __call = function(_, ...) return new(...) end
})
