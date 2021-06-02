
# ASM-19

ASM-19 is a fantasy assembly language which has been created during the lockdown days of the COVID-19 virus.

This assembly language is executed by a virtual machine in a fantasy environment.

The ASM-19 machine has the following characteristics:

- A 64 kilo-bytes memory.
- Operates on 16-bit integer values.
- These values can be stored inside special memory called registers, or inside the normal 64kb memory.
- It has 8 registers: `A` `B` `C` `D` `T` `SP` `PP` `CK`, each one of them can store a 16-bit value

The 64kb memory is divided into bytes (8-bits), and so the memory has 65536 addresses.

A memory address is the number of a byte inside the memory.

The addresses start from 0 and end at 65535, and so they're an unsigned 16-bit values and can be stored in a register or inside the memory.

16-bit values are stored in the 64kb memory as 2 bytes, following the little-endian format.

Initially all the registers and the memory of the ASM-19 machine are set to 0.

The ASM-19 instructions set has 32 instructions that can be executed.

Each instruction has a specific behavior and must do a modification to the memory or registers (at least modify the `PP` register).

The 32 instructions vary in size and are stored inside the 64-kb memory as 1,2,3,4 and 5 bytes values, encoded with a specific format.

Instructions are referenced to by the address of their first byte (called the `Instruction Byte`).

The virtual machine operates by cycles, each cycle an instruction is executed.

In each cycle, the machine executes the instruction at the address stored inside the `PP` register (The **P**rogram **P**ointer register).

Because all the registers are initialized to 0 before the machine execution start, the first instruction has to be stored at the start of the memory (address 0).

Most of the 32 instructions update the `PP` register with the address of the instruction stored right after the currently executed one.

The instructions can have some "parameters", which are called as `operands`, thery're encoded with after the instruction byte in 1,2,3 or 4 bytes (called the `Operands Bytes`).

An operand can specifiy either a specific register, or a literal value, or a memory reference.

A memory reference is a specific register with an offset, during execution this type of operands is replaced with a literal value, detemined by taking in the value of the specified register and adding to it the offset value.

The memory reference offset is an integer value between -16 and 15.

The 32 instructions vary in the number of operands they take:

- There are 15 instructions which take 2 operands.
- There are 12 instructions which take 1 operand.
- There are 5 instructions which take no operands.

Each instruction is denoted by a 2-4 uppercase letters name.

The 32 instructions are:

```A19
HALT, NOP, ADD, SUB, MUL, DIV, MOD, SWIZ, NOT, AND, OR, XOR, SHL, SHR, SAR, SET, GET, PUSH, POP, CALL, RET, JMP, CMP, JG, JNG, JL, JNL, JE, JNE, EXTI, EXTA, EXTB
```

From the technical side, the first operand (`op1`) can always be a register, a literal value, or a memory reference.
And the second operand (`op2`) can always be a register or a literal value.

> The memory references during execution are always translated into a literal value.

From the behavior side there are 3 types of operands:

- **Source operands:** They represent a value:

  - If the operand is a `literal value` then it's that value.
  - But if the operand is a `register`, then it's the value inside that register.

- **Destination operands:** They represent the memory for the instruction to do it's operation on:

  - If it's a `register`, then the instruction would do it's operation on that register, altering it's value.
  - If it's a `literal value`, then it's a memory address, and the instruction will do it's operation on the value at that address.

- **Address operands:** They represent a memory address:

  - If it's a `register`, then the address is the value inside that register.
  - If it's a `literal value`, then the address is that value.

## Instruction Set

The instructions will be specified in this format:

```text
Instruction_Name Op1_behavior_type Op2_behavior_type
```

### Arithmetic Instructions

The following instructions operate on unsigned 16-bit integers, and so the result values are clamped between `0` and `65535`, there's not "Integer Overflow" behavior in this machine.

#### ADD destination source

Add `source` to `destination` (destination += source).

#### SUB destination source

Substract `source` from `destination` (destination -= source).

#### MUL destination source

Multiply `destination` by `source` (destination *= source).

#### DIV destination source

Divide `destination` by `source` (destination /= source).

> If `source` had the value of `0` then that will cause the machine to HALT.

#### MOD destination source

Store the division remained of `destination` by `source` (destination %= source).

#### SWIZ destination source

> This instruction took inspiration from the game [EXAPUNKS](http://www.zachtronics.com/exapunks/), give it a look, Zachtronics deserve the best.

Swizzle the value of the `destination` using the value of `source` and store the result back in `destination`.

The swizzle instruction can be used to rearrange and/or extract the digits in a number as show:

| Desination | Mask | Result |
| ---------- | ---- | ------ |
| 6789       | 4321 | 6789   |
| 6789       | 1234 | 9876   |
| 6789       | 3333 | 7777   |
| 6789       | 1211 | 9899   |
| 6789       | 2000 | 8000   |
| 6789       | 0001 | 0009   |

### Bitwise Instructions

#### NOT destination

Inverse all the bits in destination, all `1`s become `0`s, and all `0`s become `1`s.

#### AND destination source

Bitwise and of `destination` and `source` (destination &= source).

#### OR destination source

Bitwise or of `destination` and `source` (destination |= source).

#### XOR destination source

Bitwise exclusive or of `destination` and `source` (destination ^= source).

#### SHL destination source

Logical shift left of `destination` by `source` bits (destination <<= source).

#### SHR destination source

Logical shift right of `destination` by `source` bits (destination >>= source).

#### SAR destination source

Arithmetic shift right of `destination` by `source` bits (destination >>>= source).

### Miscellaneous Instructions

#### HALT

Halts the machine, stops the instructions execution.

> This instruction has the opcode 0 on propose, so when the program ends and no HALT instruction is there, then the machine will read a 0 byte and interpreter it as HALT.

#### NOP

Do nothing, waste the cycle.

### Transfer Instructions

Used to transfer values between registers and memory

#### SET destination source

Set `source` as the value of `destination` (destination := source).

#### GET address destination

Get the value from the specified `address` and store it in the `destination`.

### Control Instructions

The control instructions use the `T` register to determine their actions, and it's manipulated as a **signed** 16-bit integer.

> The value of `T` is clamped between `-32768` and `32767`.

#### CMP destination source

Used to compare 2 values, updates the `T` register.

```text
T = (value of destination) - source
```

#### JG address

**J**ump if **G**reater, jumps to address if `destination < source` when CMP was executed, in other words if `T > 0`.

#### JNG address

**J**ump if **N**ot **G**reater, jumps to address if `destination >= source` when CMP was executed, in other words if `T <= 0`.

#### JL address

**J**ump if **L**esser, jumps to address if `destination > source` when CMP was executed, in other words if `T < 0`.

#### JNL address

**J**ump if **N**ot **L**esser, jumps to address if `destination <= source` when CMP was executed, in other words if `T >= 0`.

#### JE address

**J**ump if **E**queal, jumps to address if `destination == source` when CMP was executed, in other words if `T == 0`.

#### JNE address

**J**ump if **N**ot **E**queal, jumps to address if `destination != source` when CMP was executed, in other words if `T != 0`.

#### JMP address

Unconditional jump.

### Stack Instructions

They store values in a stack structure, in which the first value in is the last value out (FILO).

When a value is added to the stack, it's stored in the memory at the address stored in register `SP` (**S**tack **P**ointer register) and then `SP` is increased by 2.

When a value is removed from the stack, the `SP` register is decreased by 2, and the value is retrieved from the address stored in `SP`.

#### PUSH source

Inserts the value to the stack.

#### POP destination

Removes a value from the stack.

#### CALL address

Inserts the address of the instruction after `CALL` to the stack, and jump to `address`.

#### RET

Removes a value from the stacks and jumps to it.

### Extensions Instructions

Those instructions allows modifying the virtual machine to add extra functionality to it.

#### EXTI source

Activate the extension with the ID of `source`.

#### EXTA

The extension instruction A, behaves depending on the activated extension, by default acts as `NOP`.

#### EXTB

The extension instruction B, behaves depending on the activated extension, by default acts as `NOP`.

## The 8 registers:

- **A, B, C, D:** They are general propose registers and can be used for any propose by the programmer.
- **T:** Used by the conditional instructions, contains the only signed value in the machine.
- **PP:** **P**rogram **P**ointer, contains the address of the current instruction.
- **SP:** **S**tack **P**ointer, contains the address for storing the next stack element in.
- **CK:** Clock register, increased by `1` each cycle, can be used for timers, stops increasing at 65535 due to 16-bits limit, must be reset by the program.
