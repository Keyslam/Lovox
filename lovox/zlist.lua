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

local function add(self, object, z)
   local i = #self.numerical + 1
   self.numerical[i] = object
   self.zlist[i] = z

   if self.pointer == 0 then
      self.pointer = 1
      self.points[1] = 0
   else
      local place   = 0
      local pointer = self.pointer

      while pointer ~= 0 and self.zlist[pointer] < z do
         place = pointer
         pointer = self.points[pointer]
      end

      self.points[i] = pointer

      if place == 0 then
         self.pointer = i
      else
         self.points[place] = i
      end
   end
end

local function clear(self)
   self.numerical = {}
   self.zlist     = {}
   self.points    = {}
   self.pointer   = 0
end

local function forEach(self, func, ...)
   local next = self.pointer
   while next ~= 0 do
      func(self.numerical[next], ...)
      next = self.points[next]
   end
end

local function new()
   return {
      numerical = {},
      zlist     = {},
      points    = {},
      pointer   = 0,

      add     = add,
      clear   = clear,
      forEach = forEach,
   }
end

return setmetatable({
   new     = new,
   add     = add,
   clear   = clear,
   forEach = forEach,
}, {
   __call = new,
})
