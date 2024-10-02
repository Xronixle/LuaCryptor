local EncryptionModule = require("Contents.EncryptionModule")

local Message = "Hello, world!"
local Key = EncryptionModule.GetKey()

local Encrypted = EncryptionModule:Encrypt(Message, Key)
local Decrypted = EncryptionModule:Decrypt(Encrypted, Key)

if Decrypted == Message then
     print(Encrypted)
else
     print("Key isn't correct!")
end

print(Decrypted)
print(Key)