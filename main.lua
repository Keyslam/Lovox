love.graphics.setBackgroundColor(225, 225, 225)
love.graphics.setDefaultFilter("nearest", "nearest")

-- Load Lovox
local Lovox     = require "lovox"
local ModelData = Lovox.modelData
local Model     = Lovox.model
local AnimModel = Lovox.animModel
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


-- Load cubes as a animation
local b1, b2, b3 = ModelData("cube/1"), ModelData("cube/2"), ModelData("cube/3")
local Cube       = AnimModel({b1, b2, b3}, 1)
Cube:setLooping(true)
Cube:play()


-- Load a model from a .vox
-- !! Slow !!
local vox = love.filesystem.newFile("barrier_bend.vox")
local BarrierData = ModelData.newFromVox(vox) -- newFromVox is required here.
local Barrier     = Model(BarrierData)

function love.update(dt)
   -- Rotate our circle
   CircleRot = CircleRot + dt

   Cube:update(dt)
end

function love.draw()
   -- Draw our models
   Boat:draw   (-200,    0, 0, nil,       4, 4)
   Circle:draw ( 200,    0, 0, CircleRot, 4, 4)
   Cube:draw   (   0, -200, 0, nil,       4, 4)
   Barrier:draw(   0,  200, 0, nil,       4, 4)

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
