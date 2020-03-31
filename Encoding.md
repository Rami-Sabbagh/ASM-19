
# ASM-19 Instructions Encoding

The instructions in the ASM-19 machine are stored with a specific binary format inside the machine's 128KB memory.

> Please remember that ASM-19's memory has the width of 16-bit unlike most of computers memories.

## Instructions length and format

Instructions vary in their length, some instructions take 1 address to be encoded, some take 2, and some take 3.

### 3 Addresses long instructions

| Address `PP+0`     | Address `PP+1` | Address `PP+2` |
| ------------------ | -------------- | -------------- |
| Instruction opcode | Operand 1      | Operand 2      |

### 2 Addresses long instructions

| Address `PP+0`     | Address `PP+1` |
| ------------------ | -------------- |
| Instruction opcode | Operand 1/2    |

### 1 Address long instructions

| Address `PP+0`     |
| ------------------ |
| Instruction opcode |

## Instructions opcodes

The instruction type, length, and arguments type are determind by what's called the `Instruction Opcode`.

The opcode is a 16-bit value, an ID between `0` and `65535` (`65536` opcodes).

- Instructions that take no operands needs only 1 opcode.
- Instructions that take 1 operand need 10 opcodes.
- Instructions that take 2 operands need 90 opcodes.

### Instruction set opcodes table

#### Instructions with no operands

| Opcode   | Instruction name |
| -------- | ---------------- |
| `0x0000` | HALT             |
| `0x0001` | NOP              |
| `0x0002` | RET              |

#### Instructions with 1 operand

| Start opcode | End opcode | Instruction name |
| ------------ | ---------- | ---------------- |
| `0x0003`     | `0x000C`   | NEG              |
| `0x000D`     | `0x0016`   | NOT              |
| `0x0017`     | `0x0020`   | PUSH             |
| `0x0021`     | `0x002A`   | POP              |
| `0x002B`     | `0x0034`   | VPUSH            |
| `0x0035`     | `0x003E`   | VPOP             |
| `0x003F`     | `0x0048`   | CALL             |
| `0x0049`     | `0x0052`   | JMP              |
| `0x0053`     | `0x005C`   | JG               |
| `0x005D`     | `0x0066`   | JNG              |
| `0x0067`     | `0x0070`   | JL               |
| `0x0071`     | `0x007A`   | JNL              |
| `0x007B`     | `0x0084`   | JE               |
| `0x0085`     | `0x008E`   | JNE              |
| `0x008F`     | `0x0098`   | EXTI             |

#### Instructions with 2 operands

| Start opcode | End opcode | Instruction name |
| ------------ | ---------- | ---------------- |
| `0x0099`     | `0x00F2`   | ADD              |
| `0x00F3`     | `0x014C`   | SUB              |
| `0x014D`     | `0x01A6`   | MUL              |
| `0x01A7`     | `0x0200`   | DIV              |
| `0x0201`     | `0x025A`   | MOD              |
| `0x025B`     | `0x02B4`   | SMUL             |
| `0x02B5`     | `0x030E`   | SDIV             |
| `0x030F`     | `0x0368`   | SMOD             |
| `0x0369`     | `0x03C2`   | AND              |
| `0x03C3`     | `0x041C`   | OR               |
| `0x041D`     | `0x0476`   | XOR              |
| `0x0477`     | `0x04D0`   | SHL              |
| `0x04D1`     | `0x052A`   | SHR              |
| `0x052B`     | `0x0584`   | SAR              |
| `0x0585`     | `0x05DE`   | SET              |
| `0x05DF`     | `0x0638`   | GET              |
| `0x0639`     | `0x0692`   | SWAP             |
| `0x0693`     | `0x06EC`   | CMP              |

## Operand types

| ID  | Type                              |
|:---:|:--------------------------------- |
| `0` | Register A                        |
| `1` | Register B                        |
| `2` | Register C                        |
| `3` | Register T                        |
| `4` | Register SP                       |
| `5` | Register VP                       |
| `6` | Register PP                       |
| `7` | Register FL                       |
| `8` | Literal value                     |
| `9` | Memory reference (Operand 1 only) |

## Determining the operands types and instruction length from the opcode

### For instructions with 1 operand

Substract the start opcode of the instruction, and the result is the operand type.

If the operand type is `8` or `9` then it's a 2 addresses long instruction, and the operand value is in the next address.

### For instructions with 2 operands

Substact the start opcode of the instruction.

- `result % 10` is the first operand type.
- `result / 10` is the second operand type.

> The second operand type can't be ever `9`.

If operand 1 type is `8` or `9`, then the next address after the opcode contains the operand value.

If operand 2 type is `8` then the next address after the opcode (and after operand 1 if it was `8` or `9`) contains the operand value.

So if both operand 1 and operand 2 had the type `8` or higher, then the instruction is 3 addresses long.

And if 1 of them had the type `8` or higher, then the instruction is 2 addresses long.

Otherwise the instruction is 1 address long.

## Operands values in seperate addresses

### Literal value

The value is stored as it is in the operand address

### Memory reference

Number the bits from the right to the left, by number from 1 to 16.

#### Memory references with 1 register

The 4th bit must be `0`, which tells this reference has only 1 register

- Bits `1 -> 3` are the register ID, they represent an operand type for the same register (A number between `0` and `7`).
- Bits `5 -> 16` represent a 12-bit signed integer, which is the offset value.

#### Memory references with 2 registers

The 4th bit must be `1`, which tells this reference has 2 registers

- Bits `1 -> 3` are the first register ID, they represent an operand for the same register (A number between `0` and `7`).
- Bits `5 -> 7` are the second register ID, they represent an operand for the same register (A number between `0` and `7`).
- Bit `8`: If `0`, then the 2 registers are summed. If `1`, then the second register is substracted from the first register `reg1 - reg2`.
- Bits `8 -> 16` represent a 8-bit signed integer, which is the offset value.
