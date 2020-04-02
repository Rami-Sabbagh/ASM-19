local errors = {
    ["open-scope-trailing-garbage"] = "Nothing can be written after { except comments.",
    ["close-scope-trailing-garbage"] = "Nothing can be written after } except comments.",
    ["directive-name-expected"] = "Assembler directive name expected after #.",
    ["extra-operands"] = "An instruction can't have more than 2 operands.",
    ["missing-label-name"] = "Label name expected between ( and ).",
    ["invalid-label-name"] = "Label name can be only made of letters, digits and underscores, and cannot start with a digit."
}

local exitcodes = {}

for k,_ in pairs(errors) do
    table.insert(exitcodes, k)
    exitcodes[k] = #exitcodes
end

return {errors, exitcodes}