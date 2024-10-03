-- Modules
local CharacterHandler = require("Contents.CharacterHandler")


-- Module Data
local BinaryModule = {}


--[[
	Returns how many bits are needed to represent the given number.
]]
function BinaryModule:GetBitSize(num)
     return math.floor(math.log(num, 2)) + 1
end


--[[
	Converts the given number into a binary string.
]]
function BinaryModule:GetBinary(num, bits)
     local Binary = ""

     local BitsFound = BinaryModule:GetBitSize(num)
	local CalculatedBits = math.max(BitsFound, 1)

     bits = bits or 0
     bits = bits >= CalculatedBits and bits or CalculatedBits

     local BitsList = {}

     for b = bits, 1, -1 do
          local Bit = math.fmod(num, 2)
          BitsList[b] = Bit == Bit and Bit or 0

          num = math.floor((num - BitsList[b]) / 2)
     end

     local BinString = table.concat(BitsList, "")
     return string.sub(BinString, 1, bits)
end


--[[
	Chunks the given binary number into smaller binary numbers with the given amount of bits.
	"padding" indicates whether or not there should be a pad of 0s at the left of the new binary.
	Returns a table with all chunks
]]
function BinaryModule:ChunkBinary(bin, bits, padding)
     local ChunkAmount = bits or 7
     local Chunks      = {}

     local ReversedBin = string.reverse(bin)
     local Split       = CharacterHandler:SplitString(ReversedBin)

     for i = 1, string.len(ReversedBin), ChunkAmount do
          local TextChunk = string.sub(ReversedBin, i, i + ChunkAmount - 1)

          if padding == true then
               local AmountToAdd = ChunkAmount - string.len(TextChunk)
               for int = 1, AmountToAdd, 1 do
                    TextChunk = TextChunk .. "0"
               end
          end

          local Fixed = string.reverse(TextChunk)
          table.insert(Chunks, 1, Fixed)
     end

     return Chunks
end

--[[
	Converts the given binary string to a number.
]]
function BinaryModule:BinaryToNumber(bin)
     local BinaryString = string.reverse(bin)
     local Num = 0

     local Pieces = CharacterHandler:SplitString(BinaryString)

     for i, bit in pairs(Pieces) do
          if bit == "1" then
               if i == 1 then
                    Num = Num + 1
               else
                    Num = Num + ((2 ^ i) / 2)
               end
          end
     end

     return Num
end


return BinaryModule
