
# COASM-19 Instruction Set Architect

- 16-bit processor
- Supports memories with 8bits width.
- Supports memories up to 64kbytes.
- Dynamic instruction length.

## Registers (8 Registers)

- `SP` Stack pointer, points to the current position in the stack
- `PP` Program pointer, points to the next instruction to execute
- `CK` Clock register, increased by 1 each time an instruction is executed
- `T` Test register, used in the conditional jumps
- `A` General propose register.
- `B` General propose register.
- `C` General propose register.
- `D` General propose register.

## Instruction Set (32 Instructions)

### Arithmetic Instructions

- `ADD destination += source`
- `SUB destination -= source`
- `MUL destination *= source`
- `DIV destination /= source`
- `MOD destination %= source`
- `SWIZ destination #= mask` ( As in EXAPUNKS )

### Bitwise Instructions

- `NOT destination`
- `AND destination & source`
- `OR destination | source`
- `XOR destination ^ source`
- `SHL destination << source`
- `SHR destination >> source`
- `SAR destination >>> source` ( Arithmetic shift right )

### Transfare Instructions

- `SET destination <-- source`
- `GET destination --> source`
- `PUSH value`
- `POP value`
- `CALL address`
- `RET`

### Control Instructions

- `JMP destination` ( Unconditional jump )
- `CMP value1 ? value2` ( Sets the compare register )
- `JG destination` ( Jump if greater `<` )
- `JNG destination` ( Jump if not greater `!<` )
- `JL destination` ( Jump if lesser `>` )
- `JNL destination` ( Jump if not lesser `!>` )
- `JE destination` ( Jump if equal `==` )
- `JNE destination` ( Jump if not equal `!=` )

### Miscellaneuous Instructions

- `NOP` ( No operation )
- `HALT` ( Stop the processor )

### Extension Instructions

- `EXTI extension` ( Activate the extension instructions with the specified ID )
- `EXTA operands` ( Execute the first external instruction )
- `EXTB operands` ( Execute the second external instruction )
