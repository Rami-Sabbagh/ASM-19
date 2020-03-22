
# COASM-19 Instructions Encoding

## Standard instructions with 2 oprands

They would take 2, 3 or 4 bytes:

### The instruction byte:

Bits numbering: `7 6 5 4 - 3 2 1 0`

- Bits `4 - 3 2 1 0` -> The instruction ID.
- Bits `6 5` -> Operand-1 type.
- Bit `7` -> Operand-2 type.

#### Operand-1 types:

- `00` -> A register.
- `01` -> RESERVED (Treated as `00` for now).
- `10` -> Literal value.
- `11` -> Memory pointer.

#### Operand-2 types:

- `0` -> A register.
- `1` -> Literal value.

### Registers pair byte

If both operand-1 and operand-2 are registers, then the instruction is followed
by a single byte (making it 2 bytes instruction) with the following format:

Bits numbering: `7 6 5 4 - 3 2 1 0`

- Bits `2 1 0` -> operand-1 register.
- Bit `3` -> RESERVED (Ignored for now).
- Bits `6 5 4` -> operand-2 register.
- Bit `7` -> RESERVED (Ignored for now).

### Operands bytes

If one of the operands is not a register, then the instruction is followed by
2 or 3 bytes (making it a 3 or 4 bytes instruction), operand-1 bytes follow first, then operand-2 bytes.

#### Register operand (1 byte)

Bits numbering: `7 6 5 4 - 3 2 1 0`

- Bits `2 1 0` -> operand register.
- Bits `7 6 5 4 - 3` -> RESERVED (Ingnored for now).

#### Memory pointer operand (1 byte)

Bits numbering: `7 6 5 4 - 3 2 1 0`

- Bits `2 1 0` -> operand register.
- Bits `7 6 5 4 - 3` -> offset (a signed nibble).

#### Literal value operand (2 bytes)

2 bytes containing the literal value.

### Standard instructions with 1 operand

They follow the same encoding of instructions with 2 operands, except that everything related to the operand-2 are RESERVED and ignored.

They take 2 or 3 bytes.

### Standard instructions with no operands

They follow the same enocindg of the instructions with 1/2 operands, except that everything related to the operands are RESERVED and ignored.

(There would be only the instruction ID infact).

They take 1 byte.

### Extension instructions

Extension instructions can take as many bytes as they want, there's only the instruction byte that has a defined structure:

Bits numbering: `7 6 5 4 - 3 2 1 0`

- Bits `4 - 3 2 1`: Used by the ISA to indicate the instruction ID.
- Bits `7 6 5`: Left for the extension to define.

> TODO: This is a behaviour note, should be moved into the machine behaviour document.

> The modified execution machine would know how to parse the extension instruction, otherwise it's treated as a NOP instruction.
