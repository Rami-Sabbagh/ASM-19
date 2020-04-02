--ASM-19 Assembler

local assembler = {}

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