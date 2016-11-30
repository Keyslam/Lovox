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

-- Generates new modelData from a path
local function newFromPath(path)
   local modelData    = dofile(path.."/flags.lua")
   modelData.texture  = love.graphics.newImage(path.."/texture.png")
   modelData.quads    = {}

   -- Setup quads
   local w, h = modelData.texture:getDimensions()
   for i = 0, modelData.frames - 1 do
      modelData.quads[i + 1] = love.graphics.newQuad(i * modelData.width, 0, modelData.width, modelData.height, w, h)
   end

   return modelData
end

-- Generates new modelData from an image
local function newFromImage(imageData)
   local w, h = imageData:getDimensions()
   local size = w * h

   -- Map texture from source
   local texture = love.image.newImageData(size, 1)
   for x = 0, w - 1 do
      for y = 0, h - 1 do
         local r, g, b, a = imageData:getPixel(x, y)
         texture:setPixel(size - 1 - (x + (y * w)), 0, r, g, b, a)
      end
   end

   texture = love.graphics.newImage(texture)

   -- Create new modelData
   local modelData = {
      width  = w,
      height = 1,
      frames = h,
      quads  = {},
      texture = texture,
   }
   modelData.spritebatch = love.graphics.newSpriteBatch(modelData.texture, modelData.frames)

   -- Setup quads
   for i = 0, modelData.frames - 1 do
      modelData.quads[i + 1] = love.graphics.newQuad(i * modelData.width, 0, modelData.width, modelData.height, w * h, 1)
   end

   -- Return new modelData
   return modelData
end

-- Generates new modelData from a function
local function newFromFunc(func, w, h)
   local c = love.graphics.newCanvas(w, h)
   love.graphics.setCanvas(c)
      func()
   love.graphics.setCanvas()
   love.graphics.setColor(255, 255, 255)

   return newFromImage(c:newImageData())
end

-- Super constructor
local function new(source, w, h)
   local t = type(source)

   if t == "string" then return newFromPath(source)
   elseif t == "userdata" then return newFromImage(source)
   elseif t == "function" then return newFromFunc(source, w, h) end

   error("Wrong source type. Expected 'string' or 'userdata' or 'function'. Got '"..t.."'.")
end

-- Return module
return setmetatable({
   new          = new,
   newFromPath  = newFromPath,
   newFromImage = newFromImage,
   newFromFunc  = newFromFunc,
}, {
   __call = function(_, ...) return new(...) end
})
