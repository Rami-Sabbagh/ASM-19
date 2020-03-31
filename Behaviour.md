
# ASM-19 machine behavior

The ASM-19 machine reads the binary encoded instructions from the memory.

At each cycle the instruction at the location stored in the `PP` register is executed.

All instructions (except `JMP, CALL, JG, JNG, JL, JNL, JE, JNE`) increase the `PP` register by the length of the instruction after their execution.

## Integers overflow

Whenever an arithmetic operation is made on integer values, and the result is out of the possible number range, the integer overflow behavior is followed.

## Operands

Operands are arguments which instructions take, they can be a register, a literal value, or a memory reference.

### Register operands

The instruction gets the ID of the register to do it's operation on.

### Literal values

A literal 16-bit value.

### Memory references

A memory reference includes a register, and an offset.
During the machine exection, the memory reference is parsed and converted into a literal value whenever the instruction is executed, the instruction behavior treats the memory reference as a literal value, and cannot know that it was a memory reference.

> **Only** the **first** operand of any instruction can be a memory reference.

#### Single register memory references

It's made of a register, and a literal offset in range `[-4096, 4096]` (12-bits signed).

The reference is replaced by the value of the register summed with the offset, 16-bit integer overflow behavior can happen here.

#### 2 registers memory references

It's made of 2 registers, addition or subtraction sign between the registers, and a literal offset in range `[-128, 127]` (8-bit signed).

The reference is replaced by the value of the first register, added to/substracted from the second register, then summed with the offset, during the 2 operations 16-bit integer overflow can happen.

## Operands by their usage

Operands are used in different ways by the instructions:

### Destination operands

- **If register**: The instruction does it's operation on the register. For example the `ADD` instruction, it would add to the register value.

- **If literal value or memory reference**: The instruction does it's operation on the memory address specified by the literal value.

### Source operands

- **If register**: The value of the register is used by the instruction.

- **If literal value or memory reference**: The literal value is used by the instruction, the memory is not accessed in this situation.

### Address operands

The operand in this case specifies a memory address.

- **If regsiter**: The memory address is the one stored inside the register.

- **If literal value or memory reference**: The memory address is the literal value.

## Instructions behaviors

### Arithmetic instructions

| Instruction name | First operand type | Second operand type | Behavior |
| ---------------- | ------------------ | ------------------- | -------- |
| NEG | destination | - | Inverses the value sign (XORs with `0x8000`) `destination *= -1` |
| ADD | destination | source | `destination += source` |
| SUB | destination | source | `destination -= source` |
| MUL | destination | source | `destination *= source` |
| DIV | destination | source | `destination \= source` |
| MOD | destination | source | `destination %= source` |
| SMUL | destination | source | (Signed) `destination *= source` |
| SDIV | destination | source | (Signed) `destination \= source` |
| SMOD | destination | source | (Signed) `destination %= source` |

> `DIV, MOD, SDIV, SMOD` will halt the processor if `source` had the value of `0`!

### Logic instructions

| Instruction name | First operand type | Second operand type | Behavior |
| ---------------- | ------------------ | ------------------- | -------- |
| NOT | destination | - | Inverse the destination bits (XOR with `0xFFFF`) |
| AND | destination | source | `destination &= source` |
| OR | destination | source | `destination |= source` |
| XOR | destination | source | `destination ^= source` |
| SHL | destination | source | `destination <<= source` |
| SHR | destination | source | `destination >>= source` |
| SAR | destination | source | `destination >>>= source` (Arithmetic shift right) |

### Control instructions

| Instruction name | First operand type | Second operand type | Behavior |
| ---------------- | ------------------ | ------------------- | -------- |
| CMP | destination | source | Calculates `destination - source`, clamps the value between `-32768` and `32767`, and stores the signed result in register `T` |
| JMP | address | - | Unconditional jump to the instruction at the given location (Sets the `PP` register without increasing it by the `JMP` instruction length) |
| JG | address | - | Jump if greater (if `destination` is greater than `source`) (`destination > source`) (`T > 0`) |
| JNG | address | - | Jump if not greater (`destination <= source`) (`T <= 0`) |
| JL | address | - | Jump if less (`destination < source`) (`T < 0`) |
| JNL | address | - | Jump if not less (`destination >= source`) (`T >= 0`) |
| JE | address | - | Jump if equal (`destination == source`) (`T == 0`) |
| JNE | address | - | Jump if not equal (`destination != source`) (`T != 0`) |

### Transfare instructions

| Instruction name | First operand type | Second operand type | Behavior |
| ---------------- | ------------------ | ------------------- | -------- |
| SET | destination | source | `destination := source` |
| GET | address | destination | `destination := memory[address]` |
| SWAP | destination | source | Swap the 2 values `destination := source & source := destination` |

### Stack instructions

| Instruction name | First operand type | Second operand type | Behavior |
| ---------------- | ------------------ | ------------------- | -------- |
| PUSH | source | - | Adds the value of `source` to the stack, and increases `SP` by 1 |
| POP | destination | - | Decreases `SP` by 1, and sets `destination` to the value poped from the stack |
| CALL | address | - | Adds a return address to the stack, and jumps to `address` |
| RET | - | - | Pops the return address from the stack, and jumps to it |
| VPUSH | source | - | Adds the value of `source` to the **v**stack, and increases `VP` by 1 |
| VPOP | destination | - | Decreases `VP` by 1, and sets `destination` to the value poped from the **v**stack |

### Miscellaneous instructions

| Instruction name | First operand type | Second operand type | Behavior |
| ---------------- | ------------------ | ------------------- | -------- |
| NOP | - | - | Does nothing, wasting the cycle for good. |
| HALT | - | - | Halts the machine. |
| EXTI | source | - | Selects the active machine extension, `0` for no extension. |
