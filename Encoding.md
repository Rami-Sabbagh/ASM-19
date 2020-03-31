
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

| Opcode | Instruction name |
| ------:|:---------------- |
| 0x0000 | HALT             |
| 0x0001 | NOP              |
| 0x0002 | RET              |

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
