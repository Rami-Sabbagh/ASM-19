--ASM-19 Emulator

local bit = require("bit")
local band, bor, bxor, lshift, rshift = bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift

local registers = { [0] = 0; 0, 0, 0, 0, 0, 0, 0 } --8 Registers
local memory = {} --64KB memory
for i=0, 0xFFFF do memory[i] = 0 end -- Set memory to initial state
local halt = false --Stop the execution

--Load the initial memory rom
do
    local file = io.open(table.concat({...}, " "), "rb")

    local function nextByte()
        local char = file:read(1)
        return char and string.byte(char)
    end

    local address = 0

    for byte in nextByte do
        memory[address] = byte
        address = address + 1
    end

    file:close()
end

--The instructions types
local instructionsSet = {
    --[1]: No operands instructions
    {"RET", "NOP", "HALT"},

    --[2]: 1 operand instructions
    {"NOT", "PUSH", "POP", "CALL", "JMP", "JG", "JNG", "JL", "JNL", "JE", "JNE", "EXTI"},

    --[3]: 2 operands instructions
    {"ADD", "SUB", "MUL", "DIV", "MOD", "SWIZ", "AND", "OR", "XOR", "SHL", "SHR", "SAR", "SET", "GET", "CMP"},

    --[4]: Special instructions
    {"EXTA", "EXTB"}
}

for itype, instructions in ipairs(instructionsSet) do
    for _, instruction in ipairs(instructions) do
        instructionsSet[instruction] = itype
    end
end

--The instructions encoded id
local instructionsNumeration = {
    "HALT", "NOP", --Miscellaneuous
    "ADD", "SUB", "MUL", "DIV", "MOD", "SWIZ", --Arithmetic
    "NOT", "AND", "OR", "XOR", "SHL", "SHR", "SAR", --Bitwise
    "SET", "GET", "PUSH", "POP", "CALL", "RET", --Transfare
    "JMP", "CMP", "JG", "JNG", "JL", "JNL", "JE", "JNE", --Control
    "EXTI", "EXTA", "EXTB" --Extension
}

--Get a short integer from memory
local function getShort(address)
    return memory[address] + lshift(memory[math.min(address+1, 0xFFFF)], 8)
end

--Set a short integer in memory
local function setShort(address, value)
    memory[address], memory[math.min(address+1), 0xFFFF] = band(value, 0xFF), rshift(value, 8)
end

local instructionsBehaviour = {
    function() -- 0 HALT
        halt = true
    end,

    function() -- 1 NOP
        --NO OPERATION
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- 2 ADD
        local value = isRegister2 and registers[operand2] or operand2

        if isRegister1 then
            registers[operand1] = math.min(registers[operand1] + value, 0xFFFF)
        else
            setShort(operand1, math.min(getShort(operand1) + value, 0xFFFF))
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- 3 SUB
        local value = isRegister2 and registers[operand2] or operand2

        if isRegister1 then
            registers[operand1] = math.max(registers[operand1] - value, 0)
        else
            setShort(operand1, math.max(getShort(operand1) - value, 0))
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- 4 MUL
        local value = isRegister2 and registers[operand2] or operand2

        if isRegister1 then
            registers[operand1] = math.min(registers[operand1] * value, 0xFFFF)
        else
            setShort(operand1, math.min(getShort(operand1) * value, 0xFFFF))
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- 5 DIV
        local value = isRegister2 and registers[operand2] or operand2
        if value == 0 then halt = true return end --Abort instruction execution

        if isRegister1 then
            registers[operand1] = math.floor(registers[operand1] / value)
        else
            setShort(operand1, math.floor(getShort(operand1) / value))
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- 6 MOD
        local value = isRegister2 and registers[operand2] or operand2
        if value == 0 then halt = true return end --Abort instruction execution

        if isRegister1 then
            registers[operand1] = registers[operand1] % value
        else
            setShort(operand1, getShort(operand1) % value)
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- 7 SWIZ
        local mask = isRegister2 and registers[operand2] or operand2
        local value = isRegister1 and registers[operand1] or getShort(operand1)

        local digits = {0,0,0,0,0}
        for i=1, 5 do
            digits[i] = value % 10
            value = math.floor(value / 10)
        end

        for i=0, 4 do
            value = value + (digits[mask % 10] or 0) * (10 ^ i)
            mask = math.floor(mask / 10)
        end

        if isRegister1 then registers[operand1] = value
        else setShort(operand1, value) end
    end,

    function(isRegister1, operand1) -- 8 NOT
        if isRegister1 then
            registers[operand1] = bxor(0xFFFF, registers[operand1])
        else
            setShort(operand1, bxor(0xFFFF, getShort(operand1)))
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- 9 OR
        local value = isRegister2 and registers[operand2] or operand2

        if isRegister1 then
            registers[operand1] = bor(registers[operand1], value)
        else
            setShort(operand1, band(getShort(operand1), value))
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- 9 OR
        local value = isRegister2 and registers[operand2] or operand2

        if isRegister1 then
            registers[operand1] = bor(registers[operand1], value)
        else
            setShort(operand1, bor(getShort(operand1), value))
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- XOR
        local value = isRegister2 and registers[operand2] or operand2

        if isRegister1 then
            registers[operand1] = bxor(registers[operand1], value)
        else
            setShort(operand1, bxor(getShort(operand1), value))
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- SHL
        local value = isRegister2 and registers[operand2] or operand2

        if isRegister1 then
            registers[operand1] = band(lshift(registers[operand1], value), 0xFFFF)
        else
            setShort(operand1, band(lshift(getShort(operand1), value)), 0xFFFF)
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- SHR
        local value = isRegister2 and registers[operand2] or operand2

        if isRegister1 then
            registers[operand1] = rshift(registers[operand1], value)
        else
            setShort(operand1, rshift(getShort(operand1), value))
        end
    end,

    --TODO: Test the arithmetic shift if it works correctly
    function(isRegister1, operand1, isRegister2, operand2) -- SAR
        local bits = isRegister2 and registers[operand2] or operand2
        local value = isRegister1 and registers[operand1] or getShort(operand1)

        if value >= 0x8000 then
            value = band(0xFFFF, rshift(value, bits))
        else
            value = rshift(value, bits)
        end

        if isRegister1 then registers[operand1] = value
        else setShort(operand1, value) end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- SET
        local value = isRegister2 and registers[operand2] or operand2

        if isRegister1 then
            registers[operand1] = value
        else
            setShort(operand1, value)
        end
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- GET
        local value = isRegister1 and getShort(registers[operand1]) or getShort(operand1)

        if isRegister2 then
            registers[operand2] = value
        else
            setShort(operand2, value)
        end
    end,

    function(isRegister1, operand1) -- PUSH
        setShort(registers[5], isRegister1 and registers[operand1] or operand1)
        registers[5] = math.min(registers[5]+2, 0xFFFF)
    end,

    function(isRegister1, operand1) -- POP
        registers[5] = math.max(registers[5]-2, 0)

        if isRegister1 then
            registers[operand1] = getShort(registers[5])
        else
            setShort(operand1, getShort(registers[5]))
        end
    end,

    function(isRegister1, operand1, _, _, byteCount) -- CALL
        setShort(registers[5], math.min(registers[6]+byteCount, 0xFFFF))
        registers[5] = math.min(registers[5]+2, 0xFFFF)
        registers[6] = isRegister1 and registers[operand1] or operand1
        return true
    end,

    function() -- RET
        registers[5] = math.max(registers[5]-2, 0)
        registers[6] = getShort(registers[5])
        return true
    end,

    function(isRegister1, operand1) -- JMP
        registers[6] = isRegister1 and registers[operand1] or operand1
        return true
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- CMP
        local value1 = isRegister1 and registers[operand1] or getShort(operand1)
        local value2 = isRegister2 and registers[operand2] or operand2

        local comp = math.max(math.min(value2 - value1, 0x7FFF), -0x8000)
        if comp < 0 then comp = 0xFFFF - comp end

        registers[4] = comp
    end,

    function(isRegister1, operand1) -- JG
        if registers[4] > 0x7FFF or registers[4] == 0 then return end
        registers[6] = isRegister1 and registers[operand1] or operand1
        return true
    end,

    function(isRegister1, operand1) -- JNG
        if registers[4] <= 0x7FFF and registers[4] ~= 0 then return end
        registers[6] = isRegister1 and registers[operand1] or operand1
        return true
    end,

    function(isRegister1, operand1) -- JL
        if registers[4] <= 0x7FFF or registers[4] == 0 then return end
        registers[6] = isRegister1 and registers[operand1] or operand1
        return true
    end,

    function(isRegister1, operand1) -- JNL
        if registers[4] > 0x7FFF and registers[4] ~= 0 then return end
        registers[6] = isRegister1 and registers[operand1] or operand1
        return true
    end,

    function(isRegister1, operand1) -- JE
        if registers[4] ~= 0 then return end
        registers[6] = isRegister1 and registers[operand1] or operand1
        return true
    end,

    function(isRegister1, operand1) -- JNE
        if registers[4] ~= 0 then return end
        registers[6] = isRegister1 and registers[operand1] or operand1
        return true
    end,

    function(isRegister1, operand1, isRegister2, operand2) -- EXTI

    end,

    function(isRegister1, operand1, isRegister2, operand2) -- EXTA

    end,

    function(isRegister1, operand1, isRegister2, operand2) -- EXTB

    end
}

local function executeCycle()
    local nextByteAddress = registers[6] -- THe program pointer register (PP)
    local bytesRead = 0
    local function nextByte()
        --TODO: document the memory end collision behaviour

        local byte = memory[nextByteAddress]
        bytesRead = bytesRead + 1
        nextByteAddress = math.min(nextByteAddress+1, 0xFFFF)

        return byte
    end

    local instructionByte = nextByte()
    local instructionID = band(instructionByte, 0x1F)
    local instructionName = instructionsNumeration[instructionID+1]
    local instructionType = instructionsSet[instructionName]

    local operand1Type = band(rshift(instructionByte, 5), 0x3)
    local operand2Type = rshift(instructionByte, 7)

    local isRegister1, isRegister2 = (operand1Type == 0), (operand2Type == 0)
    local operand1, operand2 = 0, 0

    if instructionType == 3 and isRegister1 and isRegister2 then
        local registersByte = nextByte()
        operand1 = band(registersByte, 7)
        operand2 = band(rshift(registersByte, 4), 7)
    elseif instructionType ~= 4 then
        if instructionType == 2 or instructionType == 3 then
            if isRegister1 then --Register
                operand1 = band(nextByte(), 7)
            elseif operand1Type == 1 then --Literal Value
                operand1 = nextByte() + lshift(nextByte(), 8)
            else --Memory reference
                local referenceByte = nextByte()
                local register = band(referenceByte, 7)
                local offset = rshift(referenceByte, 3)
                if offset > 15 then offset = -(32-offset) end

                operand1 = getShort(math.max(math.min(registers[register]+offset, 0xFFFF), 0))
            end
        end

        if instructionType == 3 then
            if isRegister2 then --Register
                operand2 = band(nextByte(), 7)
            else --Literal Value
                operand2 = nextByte() + lshift(nextByte(), 8)
            end
        end
    end

    print("Instruction", instructionName, operand1Type, operand1, operand2Type, operand2)

    local skipPointerUpdate = instructionsBehaviour[instructionID+1](isRegister1, operand1, isRegister2, operand2, bytesRead)
    if not skipPointerUpdate then
        registers[6] = math.min(registers[6] + bytesRead, 0xFFFF) --Increase PP by the amount of bytes read
    end

    registers[7] = math.min(registers[7] + 1, 0xFFFF) -- increase the clock value by 1 -- last thing after execution of instruction
end

--The machine behaviour at each cycle
--[[
When a cycle is executed, the following steps are followed by the processor:
1-Read the instruction at the location pointed by the register PP (Program Pointer)
1.1- The first byte would be read from the instruction
1.2- The first 5 bits will be extracted, they contain the instruction ID
1.3- We lookup how many operands does this instruction have
1.4- Get the operands types from the instruction byte we have read (if there are any operands in this instruction)
If the instruction doesn't have any operands, we don't have to read the operands types
1.5- If there are operands, we read the bytes after the intruction byte, they contain the operands values
We store somewhere how many bytes this instruction was
2- We execute the instruction behaviour
3- We increase the PP register with the number of bytes we read for this instruction
4- We increase CK by one (The clock register)
]]

local cyclesCounter = 0

print("Instruction", "InsName", "Op1Type", "Op1", "Op2Type", "Op2")

while not halt do
    executeCycle()
    print(string.format("Cycle #%d: A:%d B:%d C:%d D:%d T:%d SP:%d PP:%d CK:%d", cyclesCounter, registers[0], unpack(registers)))
    cyclesCounter = cyclesCounter+1
end
