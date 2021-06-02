
# Implementation 01

The first attempt at implementing the ASM-19 project.

It's made as a prototype, without any instructions on how to really use it and how it works.

And that makes it not usable by anyone except the one who wrote it.

## Issues

- The text format of ASM-19 programs was not documented.
- The machine design documents are not written with a good introduction / overview sections.
- The assembler and emulator's implementation must be read to know how to use them.

## Tools used

- `markdown` to write the machine design documents.
- `luajit` to implement the assembler and the emulator.
- `notepad++` for editting ASM-19 files.

## Project structure

- `docs`: Contains the written machine design documents.
- `scripts`: Contains the implemented Lua scripts.
- `misc`: Contains syntax highlighting definition for Notepad++ to highlight the ASM-19 program files.
