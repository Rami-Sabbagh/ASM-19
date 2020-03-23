--Simple script for displaying a binary file
local file = io.open(..., "rb")

local bit = require("bit")
local band, rshift = bit.band, bit.rshift

local function nextByte()
    local char = file:read(1)
    return char and string.byte(char)
end

for byte in nextByte do
    io.write(string.format("%X%X ", rshift(byte, 4), band(byte, 0xF)))
end

io.write("\n")
file:close()