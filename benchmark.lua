-- Benchmarking file
local EncryptionModule = require("Contents.EncryptionModule")

local Message = "Hello, world!"
local Calls = 5
local MaxCharsShown = 200

local Keys = {}

local EncryptStart = os.clock()
local EncryptedMessage = Message
for i = 1, Calls, 1 do
     local NewKey = EncryptionModule.GetKey()
     EncryptedMessage = EncryptionModule:Encrypt(EncryptedMessage, NewKey)

     Keys[i] = NewKey
end
local EncryptRuntime = os.clock() - EncryptStart


local DecryptStart = os.clock()
local DecryptedMessage = EncryptedMessage
for i = #Keys, 1, -1 do
     local CurrentKey = Keys[i]
     DecryptedMessage = EncryptionModule:Decrypt(DecryptedMessage, CurrentKey)
end
local DecryptRuntime = os.clock() - DecryptStart

local Truncated = string.sub(EncryptedMessage, 1, MaxCharsShown)

if DecryptedMessage == Message then
     local Trimmed = string.len(EncryptedMessage) > MaxCharsShown and string.len(EncryptedMessage) - MaxCharsShown or 0
     local Concat = Trimmed > 0 and string.format("... (%i characters trimmed)", Trimmed) or ""
     print(Truncated .. Concat)
else
     print("Didn't get a proper key on one of the calls.")
end

print(DecryptedMessage)

print("Calls:", Calls)
print("Total runtime:", EncryptRuntime + DecryptRuntime, "seconds")
print("Encryption performed in", EncryptRuntime, "seconds")
print("Decryption performed in", DecryptRuntime, "seconds")