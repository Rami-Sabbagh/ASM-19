
# ASM-19

ASM-19 is a "fantasy" instruction set architecture, which is never made to be built into real hardware.

## Implementations

- [implementation-01](https://github.com/Rami-Sabbagh/ASM-19/tree/implementation-01)
- [implementation-02](https://github.com/Rami-Sabbagh/ASM-19/tree/implementation-02) 

## Motivation

It was made as a challenge project during the lockdown days of the COVID-19 virus inorder to pass time.

## Objectives

- Create a set of instructions, which must be [turing complete / computationally universal](https://en.wikipedia.org/wiki/Turing_completeness), so it can "simulate any Turing machine" like our personal computers.

- Create a text format for representing a program.

- Define the architecture of a virtual processor which:

  - Runs the ASM-19 instructions.
  - Stores the program instructions using a binary format in memory.

- Create an assembler which assembles programs from the text format into the binary format, as memory images for the virtual processor.

- Create an emulator of the virtual processor that can load and run the memory images.

## Gained values

- Learnt much deeper low-level knowledge on how a real machine is built.
- Learnt how assemblers and emulators can be made.
- Respect the huge architectural work done on computers.
