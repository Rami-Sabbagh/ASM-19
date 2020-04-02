
--Extend the package path to find the Assembler module inside the working directory
package.path = "./?/init.lua;"..package.path

local assembler = require("Assembler")

local testCode = {
    "#test directive",
    ".test macro",
    "RET,op1,op2,op3"
}

for _, line in ipairs(testCode) do
    print("decoded", assembler:parseLine(line))
end
