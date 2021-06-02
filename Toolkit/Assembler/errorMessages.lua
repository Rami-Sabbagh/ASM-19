local errors = {
    ["open-scope-trailing-garbage"] = "Nothing can be written after { except comments.",
    ["close-scope-trailing-garbage"] = "Nothing can be written after } except comments.",
    ["directive-name-expected"] = "Assembler directive name expected after #.",
    ["extra-operands"] = "An instruction can't have more than 2 operands.",
    ["missing-label-name"] = "Label name expected between ( and ).",
    ["invalid-label-name"] = "Label name can be only made of letters, digits and underscores, and cannot start with a digit."
}

local e2 = {
    ["invalid-scoping-line"] = "Invalid scoping line, the line should only contain { or } and an optional comment.",
    ["invalid-instruction-name"] = "Invalid instruction name, the instruction name can only contain letters.",
    ["extra-operands"] = "Instructions can't accept more than 2 operands.",
    ["invalid-register-name"] = "operand #%d: Invalid register name, the register name can only contain letters.",
    ["invalid-hex-value"] = "operand #%d: Invalid hexadecimal value.",
    ["invalid-bin-value"] = "operand #%d: Invalid binary value.",
    ["invalid-dec-value"] = "operand #%d: Invalid decimal value.",
    ["label-operand-not-closed"] = "operand #%d: Label operand missing closing ')'.",
    ["missing-label-name"] = "operand #%d: Missing label name.",
    ["invalid-label-name"] = "operand #%d: Invalid label name, it can be only made of letters, digits, dollar signs and underscores, and cannot start with a digit.",
    ["memref-operand-not-closed"] = "operand #%d: Memory reference operand missing closing ']'.",

    ["invalid-operand"] = "operand #%d: Invalid operand.",

    ["wip"] = "The assembler is still work in progress!",
}

local exitcodes = {}

for k,_ in pairs(errors) do
    table.insert(exitcodes, k)
    exitcodes[k] = #exitcodes
end

return {errors, exitcodes}