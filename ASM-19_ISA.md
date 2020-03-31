
# ASM-19 Instruction Set Architect

- 16-bit Architecture
- Made for memories with 16-bit width
- Supports memories up to 128KB (~64K Addresses)
- Designed to be used by programmers and embedded in games
- Not tied to the real processors limitations, instead it takes advantage of it's virtual existance

## Registers (8 Registers)

| Register identifier | Register name | Register propose |
|:------------------- |:------------- |:---------------- |
| A | A | General propose register |
| B | B | General propose register |
| C | C | General propose register |
| T | Test | Used by `CMP, JG, JNG, JL, JNL, JE, JNE` instructions |
| SP | Stack pointer | Points to the location where a new stack element would be added |
| VP | Values stack pointer | Points to the location where a new VStack element would be added |
| PP | Program pointer | Points to the current instruction location |
| FL | Flags | Contains the flag bits |

## Instructions Set Overview (30 Instructions)

### Arithmetic Instructions

| Instruction name | Number of operands | Short description |
|:---------------- |:------------------:|:----------------- |
| ADD | 2 | Addition |
| SUB | 2 | Subtraction |
| MUL | 2 | Multiplication |
| DIV | 2 | Division |
| MOD | 2 | Modulo |

### Logic Instructions

| Instruction name | Number of operands | Short description |
|:---------------- |:------------------:|:----------------- |
| NOT | 1 | Bitwise NOT |
| AND | 2 | Bitwise AND |
| OR | 2 | Bitwise OR |
| XOR | 2 | Bitwise exclusive OR |
| SHL | 2 | Bitwise logical shift left |
| SHR | 2 | Bitwise logical shift right |
| SAR | 2 | Bitwise arithmetic shift right |

### Control Instructions

| Instruction name | Number of operands | Short description |
|:---------------- |:------------------:|:----------------- |
| CMP | 2 | Compare |
| JG | 1 | Jump if greater |
| JNG | 1 | Jump if not greater |
| JL | 1 | Jump if less |
| JNL | 1 | Jump if not less |
| JE | 1 | Jump if equal |
| JNE | 1 | Jump if not equal |
| JMP | 1 | Unconditional jump |

### Transfare Insturctions

| Instruction name | Number of operands | Short description |
|:---------------- |:------------------:|:----------------- |
| SET | 2 | Set a literal value or the value of a register to a register or a memory location |
| GET | 2 | Get a value from memory into a register or other memory location |
| SWAP | 2 | Swap the values of either 2 registers, 2 memory locations, or a register and a memory location |

### Stack Instructions

| Instruction name | Number of operands | Short description |
|:---------------- |:------------------:|:----------------- |
| PUSH | 1 | Push a value to the stack |
| POP | 1 | Pop a value from the stack |
| CALL | 1 | Jump and store the push the return location to the stack |
| RET | 0 | Pop the return location from the stack and jump to it |
| VPUSH | 1 | Push a value to the Vstack |
| VPOP | 1 | Pop a value from the Vstack |

### Miscellaneous Instructions

| Instruction name | Number of operands | Short description |
|:---------------- |:------------------:|:----------------- |
| NOP | 0 | No operation |
| HALT | 0 | Halt the machine |
| EXTI | 1 | Enable a specific machine extension |
