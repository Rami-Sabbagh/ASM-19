--ASM-19 Assembler

local assembler = {}

--Parse a line of assembly code
function assembler:parseLine(line)
    --Clear leading whitespace
    line = line:gsub("^%s*", "")

    --Clear leading newline characters
    line = line:gsub("[\r\n]*$", "")

    if line:sub(1,1) == "#" then return self:parseDirective(line) end
    if line:sub(1,1) == "." then return self:parseMacro(line) end
    return self:parseInstruction(line)
end

--Parse an assembler directive line
function assembler:parseDirective(line)
    --TODO: Wrote directives parser
    return "invalid", "wip"
end

--Parse an assember macro line
function assembler:parseMacro(line)
    --TODO: Write macros parser
    return "invalid", "wip"
end

--Parse an instruction line
function assembler:parseInstruction(line)
    --Clear comments and leading whitespace from the line
    line = line:gsub("%s*;.*$", "")

    --Empty line
    if #line == 0 then return "empty" end

    --Scoping line
    if line:sub(1,1) == "{" or line:sub(1,1) == "}" then
        if #line > 1 then return "invalid", "invalid-scoping-line" end

        if line == "{" then return "scope", "open"
        else return "scope", "close" end
    end

    --Instruction name
    local instructionName = line:match("[^%s,]*"):lower()
    if instructionName:match("%A") then return "invalid", "invalid-instruction-name" end
    line = line:sub(#instructionName+1, -1) --Remove the instruction name from the line

    local nextOperand = line:gmatch("%s*[,%s]%s*[^,%s]*")

    local operand1, operand2 = nextOperand(), nextOperand()
    if operand1 and operand2 and nextOperand() then return "invalid", "extra-operands" end

    if operand1 then
        operand1 = {self:parseOperand(operand1)}
        if operand1[1] == "invalid" then return "invalid", operand1[2], 1, unpack(operand1, 3) end
    end

    if operand2 then
        operand2 = {self:parseOperand(operand2)}
        if operand2[1] == "invalid" then return "invalid", operand2[2], 2, unpack(operand2, 3) end
    end

    return "instruction", instructionName, operand1, operand2
end

function assembler:parseOperand(operand)
    --Clear the leading ',' and whitespace
    operand = operand:gsub("^%s*[,%s]%s*", "")

    --Register operand
    if operand:match("^%a") then
        if operand:match("%A") then return "invalid", "invalid-register-name" end
        return "register", operand
    end

    --Literal number value
    if operand:match("^%d") then
        --Hexademical number
        if operand:match("0[xX]") then
            operand = tonumber(operand, 16)
            if not operand then return "invalid", "invalid-hex-value" end
            return "literal", operand
        end

        --Binary number
        if operand:match("0[bB]") then
            operand = tonumber(operand, 2)
            if not operand then return "invalid", "invalid-bin-value" end
            return "literal", operand
        end

        --Decimal number
        operand = tonumber(operand, 10)
        if not operand then return "invalid", "invalid-dec-value" end
        return "literal", operand
    end

    --Label operand
    if operand:sub(1,1) == "(" then
        if operand:sub(-1,-1) ~= ")" then return "invalid", "label-operand-not-closed" end
        --Clear () and the whitespace between them
        operand = operand:gsub("^%(%s*"):gsub("%s*%)$")
        --Missing label name
        if #operand == 0 then return "invalid", "missing-label-name" end
        --Match a label name, must give a nil if it's an invalid name
        operand = operand:match("^[_%$%a][_%$%a%d]*$")
        if not operand then return "invalid", "invalid-label-name" end

        return "label", operand:lower()
    end

    --Memory reference
    if operand:sub(1,1) == "[" then
        if operand:sub(-1,-1) ~= "]" then return "invalid", "memref-operand-not-closed" end

        --TODO: Write the missing code here.
        return "invalid", "wip"
    end

    --Invalid operand, didn't fit any known type
    return "invalid", "invalid-operand"
end


function assembler:parseLine(line)
    line:gsub("^%s*", "") --Clear leading whitespace

    if line:sub(1,1) == "#" then --Assembler directive
        local directiveName = line:match("^#%S*"):lower()
        local directiveArguments = line:sub(#directiveName+2, -1)

        if directiveName == "#" then return "invalid", "directive-name-expected" end

        return "directive", directiveName, directiveArguments
    elseif line:sub(1,1) == "." then --Assembler macro
        local macroName = line:match("^%.%S*"):lower()
        local macroArguments = line:sub(#macroName+2, -1)

        if macroName == "." then return "invalid", "macro-name-expected" end

        return "macro", macroName, macroArguments
    else --Normal line
        --Clear comments from the line
        line = line:gsub(";.*$", "")

        --Clear trailing whitespace
        line = line:gsub("%s*$", "")

        --Empty line
        if line == "" then return "empty" end

        --Open/Close sopce
        if line:sub(1,1) == "{" then
            if line == "{" then return "open-scope" end
            return "invalid", "open-scope-trailing-garbage"
        elseif line:sub(1,1) == "}" then
            if line == "}" then return "close-scope"end
            return "invalid", "close-scope-trailing-garbage"
        end

        --Instruction line
        local instructionName = line:match("^[^,%s]+"):lower()
        local nextOperand = line:sub(#instructionName+1,-1):gmatch("[,%s]%s*[^,%s]*")
        local operand1 = nextOperand()
        if not operand1 then return "instruction", instructionName end
        operand1 = operand1:gsub("^[,%s]+", "")

        if operand1:match("^%(.*)$") then --Label operand
            operand1 = operand1:gsub("^%(%s*", "") --Clear the leading whitespace and ( from the label name
            operand1 = operand1:gsub("%s*%)$", "") --Clear the trailing whitespace and ) from the label name
            operand1 = operand1:lower()

            if operand1 == "" then return "invalid", "missing-label-name" end
            if not operand1:match("^[_%a]") then return "invalid", "invalid-label-name" end
            if not operand1:match("^[_%a%d]+$") then return "invalid", "invalid-label-name" end

            operand1 = {"label", operand1}

        elseif operand1:match("^[.*]$") then --Memory reference operand
            
        end

        local operand2 = nextOperand()
        if not operand2 then return "instruction", instructionName, operand1 end
        operand2 = operand2:gsub("^[,%s]+", "")

        if nextOperand() then return "invalid", "extra-operands" end

        return "instruction", instructionName, operand1, operand2
    end
end

return assembler