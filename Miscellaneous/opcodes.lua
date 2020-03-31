--This is a script used to generate the opcodes tables in the Encoding.md document

local bit = require("bit")
local band, rshift = bit.band, bit.rshift
local file = io.open("opcodes.txt", "w")

local nextOpcode = 0x0003

local set = {
    "NEG", "NOT", "PUSH", "POP", "VPUSH", "VPOP", "CALL", "JMP",
    "JG", "JNG", "JL", "JNL", "JE", "JNE", "EXTI"
}

local function writeOpcode(o)
    file:write(string.format("0x%X%X%X%X",
        band(rshift(o, 12), 0xF),
        band(rshift(o, 8), 0xF),
        band(rshift(o, 4), 0xF),
        band(o, 0xF)
    ))
end

for _,v in ipairs(set) do
    file:write("| `")
    writeOpcode(nextOpcode)
    file:write("`     | `")
    writeOpcode(nextOpcode+9)
    file:write("`   | ")
    file:write(v)
    file:write(string.rep(" ", string.len("----------------") - #v))
    file:write(" |\r\n")

    nextOpcode = nextOpcode+10
end

file:write("\r\n")

local set2 = {
    "ADD", "SUB", "MUL", "DIV", "MOD", "SMUL", "SDIV", "SMOD",
    "AND", "OR", "XOR", "SHL", "SHR", "SAR",
    "SET", "GET", "SWAP", "CMP"
}

for _,v in ipairs(set2) do
    file:write("| `")
    writeOpcode(nextOpcode)
    file:write("`     | `")
    writeOpcode(nextOpcode+89)
    file:write("`   | ")
    file:write(v)
    file:write(string.rep(" ", string.len("----------------") - #v))
    file:write(" |\r\n")

    nextOpcode = nextOpcode+90
end

file:close()