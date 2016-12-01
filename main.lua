love.graphics.setBackgroundColor(225, 225, 225)
love.graphics.setDefaultFilter("nearest", "nearest")

-- Load Lovox
local Lovox     = require "lovox"
local ModelData = Lovox.modelData
local Model     = Lovox.model
local Camera    = Lovox.camera

-- Load a boat
local BoatData = ModelData("boat")
local Boat     = Model(BoatData)

-- Load a model from a function
local func = function()
   love.graphics.setColor(255, 30, 30)
   love.graphics.circle("fill", 25, 25, 25)
end

local CircleData = ModelData(func, 50, 50)
local Circle     = Model(CircleData)
local CircleRot  = 0

function love.update(dt)
   -- Rotate our circle
   CircleRot = CircleRot + dt

   -- Update the camera
   Camera:update(dt)
end

function love.draw()
   -- Draw our models
   Boat:draw(-200, 0, 0, nil, 4, 4)
   Circle:draw( 200, 0, 0, CircleRot, 4, 4)

   -- Render all our models
   Camera:render()
end

function love.mousemoved(x, y, dx, dy)
   -- Rotate the camera by click-dragging
   if love.mouse.isDown(1) then
      Camera:rotate(-(dx / 100))
   end
end

function love.resize(w, h)
   Camera:resize(w, h)
end

-- Replace the circle model with the dropped model
function love.filedropped(file)
    Circle = Model(ModelData.newFromVox(file))
end
