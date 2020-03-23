--COASM-19 Assembler

local bit = require("bit")
local band, lshift, rshift = bit.band, bit.lshift, bit.rshift

--== ISA Variables ==--

--The assembler error messages, they're passed to string.format
--So take care of the special character %
local errorMessages = {
    "Label identifier can't start with a digit", --1
    "Label identifier can't start with a '['", --2
    "Label identifier can't contain + or -", --3
    "Label identifier can't be a register name (%s)", --4, String (Register name)

    "Invalid literal value", --5
    "Signed number out of range [-32768, 32767]", --6
    "Unsigned number out of range [0, 65535]", --7

    "Invalid memory reference", --8
    "Invalid register (%s)", --9, String (Register name)

    "Invalid instruction (%s)", --10, String (Instruction name)
    "The instruction (%s) must not have any operands", --11, String (Instruction name)
    "The instruction (%s) must have a single operand", --12, String (Instruction name)
    "The instruction (%s) must have two operands", --13, String (Instruction name)
    "Invalid external instruction operand", --14
    "The external instruction operand can't be more than ? bits", --15
    "Label already marked at line %d", --16, Number (Line number)
    "The instruction (DATA) must have at least one operand", --17
    "Label (%s) is not marked anywhere", --18, String (Label name)

    "Offset out of range [-16, 15]", --19 TODO: move this message up
}

--The ISA registers
local registers = {
    "A", "B", "C", "D", "T", "SP", "PP", "CK"
}

for id, register in ipairs(registers) do
    registers[register] = id-1
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
    {"EXTA", "EXTB", "MARK", "NOTE", "DATA"}
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
    "NOT", "OR", "XOR", "SHL", "SHR", "SAR", --Bitwise
    "SET", "GET", "PUSH", "POP", "CALL", "RET", --Transfare
    "JMP", "CMP", "JG", "JNG", "JL", "JNL", "JE", "JNE", --Control
    "EXTI", "EXTA", "EXTB" --Extension
}

for id, instruction in ipairs(instructionsNumeration) do
    instructionsNumeration[instruction] = id-1
end

--== Assembler Variables ==--

local lineNumber, operandNumber, nextAddress = 0, 0, 0

local program = {} --Contains the instructions and labels of the program we're compiling
local labels = {}
local usedLabels = {}

--== Assembler Functions ==--

local function fail(errorcode, ...)
    local msg = {"Error", "", "", ": ", string.format(errorMessages[errorcode] or "Unknown error #"..errorcode, ...)}

    if lineNumber ~= 0 then
        msg[2] = string.format(" line #%d", lineNumber)
    end

    if operandNumber ~= 0 then
        msg[3] = string.format(" operand #%d", operandNumber)
    end

    msg = table.concat(msg)

    io.stderr:write(msg, "\n")
    os.exit(errorcode)
end

local function validateLabelName(operand)
    if operand:match("^%d") then
        fail(1)
    elseif operand:sub(1,1) == "[" then
        fail(2)
    elseif operand:find("[%+%-]") then
        fail(3)
    elseif registers[operand] then
        fail(4, operand)
    end
end

--Returns the validated number if it was a literal number
local function validateLiteralValue(operand)
    --Must be a label name
    if operand:match("^%D") then
        return validateLabelName(operand)
    end

    local signed, value = false

    if operand:match("^0[xX]%x+$") then --Hexadecimal number
        value = tonumber(operand:sub(3, -1), 16)
    elseif operand:match("^0[bB][01]+$") then --Binary number
        value = tonumber(operand:sub(3, -1), 2)
    elseif operand:match("^%-?%d+$") then --Signed decimal number
        signed, value = true, tonumber(operand, 10)
    elseif operand:match("^%d+[uU]$") then --Unsigned decimal number
        value = tonumber(operand:sub(1,-2), 10)
    else --Invalid literal value
        fail(5)
    end

    --Check value range
    if signed and (value < -32768 or value > 32767) then
        fail(6)
    elseif not signed and (value < 0 or value > 65535) then
        fail(7)
    end

    --Encode signed short
    if signed and value < 0 then
        value = 0xFFFF + value + 1
    end

    return value
end

--Returns the validated register and offset
local function validateMemoryReference(operand)
    --Some regex witchery
    if not operand:match("^%[%S-[%+%-]?%d*%]$") then fail(8) end

    local offset = operand:match("[%+%-]%d*%]$") or "]"
    local register = operand:sub(2, -#offset-1)

    if #register == 0 or #offset == 2 then fail(8) end
    if not registers[register] then fail(9, register) end

    if #offset ~= 1 then
        if offset:sub(1,1) == "+" then
            offset = tonumber(offset:sub(2,-2), 10)
            if offset > 15 then fail(19) end
        else
            offset = tonumber(offset:sub(1,-2), 10)
            if offset < -16 then fail(19) end
        end
    else
        offset = 0
    end

    return register, offset
end

local function assembleLine(line)
    local nextOperand = line:gmatch("%S+")
    local instruction = nextOperand():upper()
    local instructionType = instructionsSet[instruction]

    --Unknown instruction
    if not instructionType then fail(10, instruction) end

    if instructionType == 1 then --[1]: No operands instructions
        if nextOperand() then fail(11, instruction) end
        table.insert(program, {instruction})
        nextAddress = nextAddress + 1 --1 byte instruction

    elseif instructionType == 2 then --[2]: 1 operand instructions
        operandNumber = operandNumber + 1
        local operand1 = nextOperand() or fail(12, instruction)
        if nextOperand() then fail(12, instruction) end

        if registers[operand1] then
            operand1 = {0, operand1}

            nextAddress = nextAddress + 2 --2 bytes instruction
        elseif operand1:sub(1,1) == "[" then
            local register, offset = validateMemoryReference(operand1)
            operand1 = {2, register, offset}

            nextAddress = nextAddress + 3 --3 bytes instruction
        else
            local value = validateLiteralValue(operand1)

            if not value then --A label
                usedLabels[operand1] = usedLabels[operand1] or {}

                table.insert(usedLabels[operand1], {
                    line = lineNumber,
                    operand = operandNumber,
                    instruction = #program + 1
                })
            end

            operand1 = {1, value or operand1}

            nextAddress = nextAddress + 3 --3 bytes instruction
        end

        table.insert(program, {instruction, operand1})

    elseif instructionType == 3 then --[3]: 2 operands instructions
        operandNumber = operandNumber + 1
        local operand1 = nextOperand() or fail(13, instruction)
        operandNumber = operandNumber + 1
        local operand2 = nextOperand() or fail(13, instruction)
        if nextOperand() then fail(13, instruction) end

        if registers[operand1] then
            operand1 = {0, operand1}

            nextAddress = nextAddress + 1
        elseif operand1:sub(1,1) == "[" then
            local register, offset = validateMemoryReference(operand1)
            operand1 = {2, register, offset}

            nextAddress = nextAddress + 1
        else
            local value = validateLiteralValue(operand1)

            if not value then --A label
                usedLabels[operand1] = usedLabels[operand1] or {}

                table.insert(usedLabels[operand1], {
                    line = lineNumber,
                    operand = operandNumber-1,
                    instruction = #program + 1
                })
            end

            operand1 = {1, value or operand1}

            nextAddress = nextAddress + 2
        end

        if registers[operand2] then
            operand2 = {0, operand2}

            nextAddress = nextAddress + 1
        else
            local value = validateLiteralValue(operand2)

            if not value then --A label
                usedLabels[operand2] = usedLabels[operand2] or {}

                table.insert(usedLabels[operand2], {
                    line = lineNumber,
                    operand = operandNumber,
                    instruction = #program + 1
                })
            end

            operand2 = {1, value or operand2}

            nextAddress = nextAddress + 2
        end

        if operand1[1] ~= 0 or operand2[1] ~= 0 then
            nextAddress = nextAddress + 1
        end

        table.insert(program, {instruction, operand1, operand2})

    elseif instructionType == 4 then --[4]: Special instructions

        if instruction == "EXTA" or instruction == "EXTB" then
            operandNumber = operandNumber + 1
            local bits = nextOperand() or fail(12, instruction)
            if nextOperand() then fail(12, instruction) end

            --TODO: Implement extension instructions assembling

        elseif instruction == "MARK" then
            operandNumber = operandNumber + 1
            local label = nextOperand() or fail(12, instruction)
            if nextOperand() then fail(12, instruction) end

            validateLabelName(label)

            if labels[label] then fail(16, labels[label].line) end

            labels[label] = {
                line=lineNumber,
                address=nextAddress
            }

        elseif instruction == "DATA" then

            local parsed = {instruction}

            for operand in nextOperand do
                operandNumber = operandNumber + 1
                local value = validateLiteralValue(operand)

                if not value then --A label
                    usedLabels[operand] = usedLabels[operand] or {}

                    table.insert(usedLabels[operand], {
                        line = lineNumber,
                        operand = operandNumber,
                        instruction = #program + 1
                    })
                end

                table.insert(parsed, {1, value or operand})
            end

            if operandNumber == 0 then fail(17) end

            table.insert(program, parsed)

            nextAddress = nextAddress + operandNumber*2 --2 bytes for each value

        end
    end
end

--== Assembler ==--

--TODO: Actual arguments parsing
local source, destination = ...

if not source or not destination then
    print("Usage: assembler.lua <source> <destination>")
    os.exit(0)
end

local sourceFile = assert(io.open(source, "r"))
local destinationFile = assert(io.open(destination, "wb"))

for line in sourceFile:lines() do
    lineNumber = lineNumber + 1
    if not line:match("^%s*$") then
        operandNumber = 0

        assembleLine(line)
    end
end

--Replace labels with their actual values and check for non existing labels
for label, usedIn in pairs(usedLabels) do
    if not labels[label] then
        lineNumber = usedIn[1].line
        operandNumber = usedIn[1].operand
        fail(18, label)
    end

    for _, replaceAt in ipairs(usedIn) do
        program[replaceAt.instruction][replaceAt.operand+1][2] = labels[label].address
    end
end

sourceFile:close()

--Encode the binary

for _, instruction in ipairs(program) do
    local instructionType = instructionsSet[instruction[1]]

    if instructionType == 1 then --[1]: No operands instructions
        destinationFile:write(string.char(instructionsNumeration[instruction[1]]))
    elseif instructionType == 2 then --[2]: 1 operand instructions
        destinationFile:write(string.char(
            instructionsNumeration[instruction[1]] + lshift(instruction[2][1], 5)
        ))

        if instruction[2][1] == 0 then --Register
            destinationFile:write(string.char(registers[instruction[2][2]]))
        elseif instruction[2][1] == 1 then --Literal value
            destinationFile:write(string.char(
                band(instruction[2][2], 0xFF),
                rshift(instruction[2][2], 8)
            ))
        elseif instruction[2][1] == 2 then --Memory reference
            local offset = instruction[2][3]
            if offset < 0 then offset = 0x1F + offset + 1 end
            destinationFile:write(string.char(
                registers[instruction[2][2]] + lshift(offset, 3)
            ))
        end

    elseif instructionType == 3 then --[3]: 2 operands instructions
        destinationFile:write(string.char(
            instructionsNumeration[instruction[1]] + lshift(instruction[2][1], 5) + lshift(instruction[3][1], 7)
        ))

        if instruction[2][1] == 0 and instruction[3][1] == 0 then
            destinationFile:write(string.char(
                registers[instruction[2][2]] + lshift(registers[instruction[3][2]], 4)
            ))

        else
            if instruction[2][1] == 0 then --Register
                destinationFile:write(string.char(registers[instruction[2][2]]))
            elseif instruction[2][1] == 1 then --Literal value
                destinationFile:write(string.char(
                    band(instruction[2][2], 0xFF),
                    rshift(instruction[2][2], 8)
                ))
            elseif instruction[2][1] == 2 then --Memory reference
                local offset = instruction[2][3]
                if offset < 0 then offset = 0x1F + offset + 1 end
                destinationFile:write(string.char(
                    registers[instruction[2][2]] + lshift(offset, 3)
                ))
            end

            if instruction[3][1] == 0 then --Register
                destinationFile:write(string.char(registers[instruction[3][2]]))
            elseif instruction[3][1] == 1 then --Literal value
                destinationFile:write(string.char(
                    band(instruction[3][2], 0xFF),
                    rshift(instruction[3][2], 8)
                ))
            end
        end

    elseif instructionType == 4 then --[4]: Special instructions
        local instructionName = instruction[1]

        if instructionName == "EXTA" or instructionName == "EXTB" then
            --TODO: Extension instructions encoding
        elseif instructionName == "DATA" then
            for i=2, #instruction do
                destinationFile:write(string.char(
                    band(instruction[i][2], 0xFF),
                    rshift(instruction[i][2], 8)
                ))
            end
        end

    end

end

destinationFile:close()