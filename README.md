# LuaEncryption
An encryptor and decryptor created in Lua.

Comes with a demonstration file ([demo.lua](<https://github.com/Xronixle/LuaEncryption/blob/main/demo.lua>)) to showcase what it does and a benchmarking file ([benchmark.lua](<https://github.com/Xronixle/LuaEncryption/blob/main/benchmark.lua>)) to see if it's something you'd be interested in.

This spawned from a failed concept for another way of encrypting messages that came to me at 4 a.m one day.

# How does it work?
In very short form, the encryption is performed using the key's binary and the key's PRNG (Pseudo-random number generator.) A character set is created using the key's PRNG to shuffle the characters around while a piece of the key's binary is used as a salt. The decryption process essentially is the reverse of this; decryption removes the salt then unshuffles the message.

The PRNG used in this repository was created just for better consistency instead of using math.random and math.randomseed every time a call was required. While it works, I am unsure if it is a decent way to generated random numbers for this sort of thing; feel free to change how they're generated how you see fit.
