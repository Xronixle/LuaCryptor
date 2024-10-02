-- Upvalues
local BatchesForKey = {}


-- Private functions
local function Lerp(a, b, t)
     return a + (b - a) * t
end


-- Module functions
local Random = {}

function Random.__index(tbl, i)
     local tblFind = rawget(tbl, i)
     local mainFind = rawget(Random, i)

     if tblFind ~= nil then
          return tblFind
     elseif mainFind ~= nil then
          return mainFind
     end
end

function Random.__call(tbl, typeWanted)
     local TypeFound = rawget(tbl, "__Type") or "source"
     return TypeFound == typeWanted
end


--[[
     Constructor
     Takes a seed number and uses it for grabbing random numbers.
]]
function Random.new(seed)
     seed = type(seed) == "number" and seed or math.random(-1 * (2^16), 2^16)

     -----------------------------

     local RandomData = {}
     RandomData.__Type = "Random"

     RandomData.Seed = seed
     RandomData.Batch = BatchesForKey[seed] or {}
     RandomData.Calls = 0

     -----------------------------
     RandomData = setmetatable(RandomData, Random)
     RandomData:__AddToBatch()

     return RandomData
end


--[[
     Internal function for adding more floats to the randomizer's batch.
]]
function Random:__AddToBatch()
     if self("Random") then else return end

     local Total = #self.Batch
     math.randomseed(self.Seed)

     for i = 1, 500, 1 do
          self.Batch[Total + i] = math.random(0, 1e6) / 1e6
     end

     if BatchesForKey[self.Seed] == nil or #BatchesForKey[self.Seed] < #self.Batch then
          BatchesForKey[self.Seed] = self.Batch
     end
end


--[[
     Grabs a number from within the given range.
]]
function Random:NextInteger(min, max)
     if self("Random") then else return 0 end

     self.Calls = self.Calls + 1
     if self.Batch ~= BatchesForKey[self.Seed] then
          self.Batch = BatchesForKey[self.Seed]
     end
     
     if #self.Batch < self.Calls then
          self:__AddToBatch()
     end

     local Float = self.Batch[self.Calls]

     local FoundNumber = Lerp(min, max, Float)
     FoundNumber = math.floor(FoundNumber + 0.5)
     
     return FoundNumber
end


--[[
     Shuffles the given table in what should be o(n) time.
     Uses the Fisher-Yates Shuffle method.
]]
function Random:ShuffleTable(tbl)
     if self("Random") then else return end

     for i = #tbl, 1, -1 do
          local RandomNumber = self:NextInteger(1, i)

          if i ~= RandomNumber then
               local Old = tbl[i]
          
               tbl[i] = tbl[RandomNumber]
               tbl[RandomNumber] = Old
          end
     end

     return tbl
end


return setmetatable(Random, Random)