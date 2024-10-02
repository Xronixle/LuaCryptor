-- Modules
local Random = require("Contents.Random")


-- Upvalues and whatnot
local DefaultCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=!@#$%^&*()_+;',./?<>:\"| "

for i = 132, 172, 1 do -- To total 128 total characters.
	DefaultCharacters = DefaultCharacters .. string.char(i)
end


-- Module methods/functions
local CharacterHandler = {}


--[[
     Lua doesn't have a split method yet for strings apparently.
]]
function CharacterHandler:SplitString(str)
     local tbl = {}

     for i = 1, string.len(str), 1 do
          tbl[i] = string.sub(str, i, i)
     end

     return tbl
end


--[[
     Mainly used to specify what character is going to be used near the end of the given data to note that it doesn't have an additional character to decrypt with.
]]
function CharacterHandler:GetBreakCharacter(key)
     local Randomizer = Random.new(key)

     for i = 1, Randomizer:NextInteger(10, 20) do
		Randomizer:NextInteger(1, 10)
	end

	local Index = Randomizer:NextInteger(1, string.len(DefaultCharacters))
	local BreakCharacter = string.sub(DefaultCharacters, Index, Index)

     return BreakCharacter
end


--[[
     Creates a table of all characters given in DefaultCharacters, shuffled with the given key.
]]
function CharacterHandler:CreateCharacterSet(key)
     local Randomizer = Random.new(key)

	local CharactersInList  = CharacterHandler:SplitString(DefaultCharacters)
	Randomizer:ShuffleTable(CharactersInList)

	local NewCharacters = table.concat(CharactersInList, "", 1, #CharactersInList)

	return NewCharacters
end


--[[
     Gets the character whose index is the given number.
     If charSet is given, it'll check that character set instead of DefaultCharacters.
]]
function CharacterHandler:GetCharacter(num, charSet)
     local Searching = DefaultCharacters
     if type(charSet) == "string" then
          Searching = charSet
     end

	num = num % string.len(Searching)

	local Found = string.sub(Searching, num + 1, num + 1)

	return Found
end


--[[
     Essentially the opposite of CharacterHandler:GetCharacter; gets the number of the given character.
]]
function CharacterHandler:GetNumber(char, charSet)
     local Searching = DefaultCharacters
     if type(charSet) == "string" then
          Searching = charSet
     end

	local Index = string.find(Searching, char or "", 1, true)

	if Index == nil then
		Index = math.random(1, string.len(Searching) - 1)
	end

	return (Index - 1)
end


return CharacterHandler