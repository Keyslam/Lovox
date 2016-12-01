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

local _PATH  = (...):gsub('%.[^%.]+$', '')
local Zlist  = require(_PATH..".zlist")

-- Localized cos and sin for performance improvement in worldToScreen & screenToWorld
-- Also used in getBoundingBox and update
local cos, sin = math.cos, math.sin

-- Internally used to render a model, can be used to directly draw a model without using the z-buffer
local function renderModel(model, self)
   local newx, newy = self:worldToScreen(model.x, model.y, model.z)
   love.graphics.draw(model.spritebatch, newx, newy, nil, self.scale, self.scale)
end

-- Setters for position
local function move(self, dx, dy) self.x, self.y = self.x + dx, self.y + dy end
local function moveTo(self, x, y) self.x, self.y = x, y end

-- Setters for rotation
local function rotate(self, r)   self.rotation = self.rotation + r end
local function rotateTo(self, r) self.rotation = r end

-- Setters for scale
local function zoom(self, s)   self.scale = self.scale + s end
local function zoomTo(self, s) self.scale = s end


-- Returns a 'Depth value'. Value is small when close to the bottom of the screen
local function getDepth(self, x, y, z)
   return x * self.ximportance + y * self.yimportance + z
end

-- Returns x, y, w, h of the camera as a bounding box
local function getBoundingBox(self)
   local s, c = sin(self.rotation), cos(self.rotation)
   if s < 0 then s = -s end
   if c < 0 then c = -c end
   return self.x, self.y, self.h * s + self.w * c, self.h * c + self.w * s
end

-- Translates x, y, z in the world into x, y on the screen.
-- !! Code taken from Hump's camera. Credit goes to vrld !!
local function worldToScreen(self, x, y, z)
	local c, s = cos(self.rotation), sin(self.rotation)
	x, y = x - self.x, y - self.y
	x, y = c * x - s * y, s * x + c * y
	return x * self.scale + self.w / 2, y * self.scale + self.h / 2 - z
end

-- Translates x, y on the screen into x, y, z in the world. z is 0
-- !! Code taken from Hump's camera. Credit goes to vrld !!
local function screenToWorld(self, x, y)
	local c, s = cos(-self.rotation), sin(-self.rotation)
	x, y = (x - self.w / 2) / self.scale, (y - self.h / 2) / self.scale
	x, y = c * x - s * y, s * x + c * y
	return x + self.x, y + self.y, 0
end

-- Adds a model to the z-buffer
local function draw(self, model)
   self.buffer:add(model, model.depth)
end

-- Updates the camera importance values
local function update(self, dt)
   self.ximportance = -sin(self.rotation)
   self.yimportance =  cos(self.rotation)
end

-- Renders all the models and clears the z-buffer
local function render(self)
   local r, g, b, a = love.graphics.getColor()
   love.graphics.setColor(255, 255, 255)

   self.buffer:forEach(renderModel, self)
   self.buffer:clear()

   love.graphics.setColor(r, g, b, a)
end

-- Resizes the camera size to the screen size
local function resize(self, w, h)
   self.w = w
   self.h = h
end

-- Constructor
local function new()
   return {
      x = 0,
      y = 0,
      w = love.graphics.getWidth(),
      h = love.graphics.getHeight(),
      rotation    = 0,
      scale       = 1,
      ximportance = 0,
      yimportance = 0,
      buffer      = Zlist(),

      move     = move,
      moveTo   = moveTo,
      rotate   = rotate,
      rotateTo = rotateTo,
      zoom     = zoom,
      zoomTo   = zoomTo,

      getDepth       = getDepth,
      getBoundingBox = getBoundingBox,
      worldToScreen  = worldToScreen,
      screenToWorld  = screenToWorld,

      draw   = draw,
      update = update,
      render = render,
      resize = resize,

      renderModel = renderModel,
   }
end

-- Return a camera
return new()
