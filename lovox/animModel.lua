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

local _PATH = (...):gsub('%.[^%.]+$', '')
local Model = require(_PATH..".model")

local function setLooping(self, v) self.looping = v end
local function isLooping(self) return self.looping end

local function setPlaybackSpeed(self, s) self.playbackSpeed = #self.frames / s end
local function getPlaybackSpeed(self) return self.playbackSpeed * #self.frames end

local function isPlaying() return self.playing end
local function isPaused() return self.paused end

local function play(self)
   self.playing = true
   self.paused  = false
end

local function stop(self)
   self.playing = false
   self:rewind()
end

local function pause(self)
   self.playing = false
   self.paused  = true
end

local function resume(self)
   self.playing = true
   self.paused  = false
end

local function rewind(self)
   self.currentTime  = 0
   self.currentFrame = 1
end

local function update(self, dt)
   if self.playing and not self.paused then
      self.currentTime = self.currentTime + dt
      if self.currentTime >= self.playbackSpeed then
         self.currentTime = self.currentTime - self.playbackSpeed
         self.currentFrame = self.currentFrame + 1
         if self.currentFrame > #self.frames then
            if self.looping then
               self.currentFrame = 1
            else
               self:stop()
            end
         end
      end
   end
end

local function draw(self, ...)
   self.frames[self.currentFrame]:draw(...)
end


local function new(frames, playbackSpeed)
   local animModel = {
      frames        = {},
      playbackSpeed = playbackSpeed / #frames,

      playing      = false,
      paused       = false,
      looping      = false,
      currentFrame = 1,
      currentTime  = 0,

      setLooping = setLooping,
      isLooping  = isLooping,

      setPlaybackSpeed = setPlaybackSpeed,
      getPlaybackSpeed = getPlaybackSpeed,

      isPlaying = isPlaying,
      isPaused  = isPaused,

      play   = play,
      pause  = pause,
      stop   = stop,
      rewind = rewind,
      resume = resume,

      update = update,
      draw   = draw,
   }

   for i = 1, #frames do
      animModel.frames[i] = Model(frames[i])
   end

   return animModel
end

return setmetatable({
   new = new,

   setLooping = setLooping,
   isLooping  = isLooping,

   setPlaybackSpeed = setPlaybackSpeed,
   getPlaybackSpeed = getPlaybackSpeed,

   isPlaying = isPlaying,
   isPaused  = isPaused,

   play   = play,
   pause  = pause,
   stop   = stop,
   rewind = rewind,
   resume = resume,

   update = update,
   draw   = draw,
}, {
   __call = function(_, ...) return new(...) end,
})
