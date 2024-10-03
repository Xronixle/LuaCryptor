-- Modules
local Random = require("Contents.Random")
local BinaryHandler = require("Contents.BinaryHandler")
local CharacterHandler = require("Contents.CharacterHandler")


-- Upvalues
local MaxNumberForKey = 2 ^ 52


-- Private functions
local function GetByteSum(str)
     local Bytes = { string.byte(str, 1, string.len(str)) }
     local Sum = 0

     for i, v in pairs(Bytes) do
          Sum = Sum + v
     end

     return math.max(Sum, 1)
end

local function Clamp(num, min, max)
     return math.floor(math.max(min, math.min(num, max)))
end


-- Module methods/functions
local EncryptionModule = {}


--[[
     Generates a key that is used to encrypt and decrypt data in other functions this module has.
     The "data" parameter can be anything, but it will be converted into a string to create a key number.
     NOTE: keys generated with a data parameter WILL NEVER BE NEGATIVE! You should probably handle if a key is positive or negative using data yourself for better security.
]]
function EncryptionModule.GenerateKey(data)
     local Key = 0

     if data ~= nil then
          data = tostring(data)

          local MainByteSum = GetByteSum(data)
          local Bits = BinaryHandler:GetBitSize(MainByteSum)
          local RandomizerKey = MainByteSum * Bits
          local Randomizer = Random.new(RandomizerKey)
          local ConstantByte = Randomizer:NextInteger(2, 50)

          Key = (2 ^ ConstantByte) + (math.max(RandomizerKey, 1)) * (string.len(data) + 1)
     else
          local Randomizer = Random.new(os.time())
          local RandomSum = 0
          for i = 1, Randomizer:NextInteger(1, 40) do
               RandomSum = RandomSum + ((2 ^ i) + i)
          end

          Key = (2 ^ Randomizer:NextInteger(2, 52)) + RandomSum + Randomizer:NextInteger(1, 2 ^ 9)

          if Randomizer:NextInteger(-10, -1) + Randomizer:NextInteger(1, 10) < 0 then -- I think this line is funny so I'm keeping it
               Key = -Key
          end
     end

     return Clamp(Key, -MaxNumberForKey, MaxNumberForKey)
end

--[[
     Checks if the given message is able to be encrypted and decrypted.
]]
function EncryptionModule:IsValidData(data)
     local Valid = true

     for i, v in pairs(CharacterHandler:SplitString(data)) do
          if Valid == true then else break end

          if CharacterHandler:GetNumber(v) then else
               Valid = false
          end
     end

     return Valid
end

--[[
     Returns a portion of the given binary number at a random section using the given randomizer or key.
	Has padding to return a 14 bit binary no matter what.
]]
function EncryptionModule:GetRandomPartOfBinary(bin, randomizer, key)
     local Randomizer = Random.new(key)

     if randomizer ~= nil then
          Randomizer = randomizer
     end

     local Start = Randomizer:NextInteger(1, string.len(bin))
     local Next = Randomizer:NextInteger(1, 11)
     local Sub = string.sub(bin, Start, Start + Next)

     for i = 1, 12 - string.len(Sub), 1 do
          if i % 2 == 0 then
               Sub = Sub .. tostring(Randomizer:NextInteger(0, 1))
          else
               Sub = tostring(Randomizer:NextInteger(0, 1)) .. Sub
          end
     end

     Sub = "00" .. Sub

     return Sub
end


--[[
     Performs obfuscation on the given string with the given key.
     Will return the same result if the same key is used on the same data.
]]
function EncryptionModule:Encrypt(stringData, key)
     if EncryptionModule:IsValidData(stringData) then else
          warn("!!Cannot encrypt the given data! Invalid values!")
          return stringData
     end

     local CharacterSet   = CharacterHandler:CreateCharacterSet(key)
     local BreakCharacter = CharacterHandler:GetBreakCharacter(key)

     local EncryptedData  = ""
     local Randomizer     = Random.new(key)
     local KeyBinary      = BinaryHandler:GetBinary(key)

     local Split          = CharacterHandler:SplitString(stringData)
     for i = 1, #Split, 2 do
          local firstChar = Split[i]

          if i == #Split then
               local n = CharacterHandler:GetNumber(firstChar)
               local newChar = CharacterHandler:GetCharacter(n, CharacterSet)

               EncryptedData = EncryptedData .. BreakCharacter .. newChar
          else
               local secondChar    = Split[i + 1]

               local FirstCharNum  = CharacterHandler:GetNumber(firstChar)
               local SecondCharNum = CharacterHandler:GetNumber(secondChar)
     
               local ExtraKeyBin   = EncryptionModule:GetRandomPartOfBinary(KeyBinary, Randomizer)
               local ExtraKeyNum   = BinaryHandler:BinaryToNumber(ExtraKeyBin)
     
               local Total         = FirstCharNum + SecondCharNum + ExtraKeyNum
               local TotalBinary   = BinaryHandler:GetBinary(Total, 14)
     
               local Chunks        = BinaryHandler:ChunkBinary(TotalBinary, 7, true)

               for i, bin in pairs(Chunks) do
                    local num = BinaryHandler:BinaryToNumber(bin)
                    local newChar = CharacterHandler:GetCharacter(num, CharacterSet)
     
                    EncryptedData = EncryptedData .. newChar
               end
     
               local FirstChar = CharacterHandler:GetCharacter(FirstCharNum, CharacterSet)
               EncryptedData = EncryptedData .. FirstChar
          end
     end

     return EncryptedData
end


--[[
     Performs deobfuscation on the given obfuscated data with the given key.
     If the key is same key that was used for obfuscation, it'll return the correct result.
]]
function EncryptionModule:Decrypt(encData, key)
     if EncryptionModule:IsValidData(encData) then else
          warn("!!Cannot decrypt the given data! Invalid values!")
          return encData
     end

     local CharacterSet    = CharacterHandler:CreateCharacterSet(key)
     local BreakCharacter  = nil

     local DecryptedData   = ""
     local Randomizer      = Random.new(key)
     local KeyBinary       = BinaryHandler:GetBinary(key)

     local Split           = CharacterHandler:SplitString(encData)
     local EstimatedLength = string.len(encData) * (2 / 3)

     if EstimatedLength > math.floor(EstimatedLength) then
          BreakCharacter = CharacterHandler:GetBreakCharacter(key)
     end

     for i = 1, #Split, 3 do
          local firstChar = Split[i]

          if i == (#Split - 1) and BreakCharacter ~= nil then
               local FinalChar = Split[#Split]
               local Number    = CharacterHandler:GetNumber(FinalChar, CharacterSet)
               local RealChar  = CharacterHandler:GetCharacter(Number)

               DecryptedData   = DecryptedData .. RealChar
               break
          end

          local ExtraKeyBin         = EncryptionModule:GetRandomPartOfBinary(KeyBinary, Randomizer)
          local ExtraKeyNum         = BinaryHandler:BinaryToNumber(ExtraKeyBin)

          local secondChar          = Split[i + 1]
          local thirdChar           = Split[i + 2]

          local FirstCharNum        = CharacterHandler:GetNumber(firstChar, CharacterSet)
          local FirstCharBin        = BinaryHandler:GetBinary(FirstCharNum, 7)

          local SecondCharNum       = CharacterHandler:GetNumber(secondChar, CharacterSet)
          local SecondCharBin       = BinaryHandler:GetBinary(SecondCharNum, 7)

          local ThirdCharNum        = CharacterHandler:GetNumber(thirdChar, CharacterSet)

          local TotalBinary         = (FirstCharBin .. SecondCharBin)
          local TotalNumber         = BinaryHandler:BinaryToNumber(TotalBinary)
          local TotalWithoutKey     = (TotalNumber - ExtraKeyNum)

          local RealSecondCharNum   = (TotalWithoutKey - ThirdCharNum)

          local RealFirstCharacter  = CharacterHandler:GetCharacter(ThirdCharNum) or ""
          local RealSecondCharacter = CharacterHandler:GetCharacter(RealSecondCharNum) or ""

          DecryptedData             = DecryptedData .. RealFirstCharacter .. RealSecondCharacter
     end

     return DecryptedData
end


return EncryptionModule