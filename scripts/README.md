
# Scripts

A collection of scripts for various tasks.

## Execution

The scripts only need [LuaJIT](https://luajit.org/) to be run.

## `assembler.lua`

A single-file implementation of an assembler for ASM-19 v1.

> Unfortunately, the `.a19` files format is not documented.

### Usage

```txt
luajit assembler.lua <source> <destination>
```

- `<source>`: The source `.a19` file containing the plain-text ASM-19 v1 code.
- `<destination>`: The output `.bin` file, which is a memory image with the assembled instructions.

#### Example

```sh
luajit assembler.lua program.a19 program.bin
```

### Output

A `<destination>` file, or error messages into the terminal on failure.

## `emulator.lua`

A single-file implementation of an emulator for ASM-19 v1.

### Usage

```txt
luajit emulator.lua <memory-image>
```

- `<memory-image>`: A path (can container whitespaces) to a `.bin` file containing the memory image to initialize the emulator with, which can be obtained by using the assembler script.

#### Example

```sh
luajit emulator.lua program.bin
```

### Output

The registers values into the terminal at each processor cycle, until the processor halts.

## `showbin.lua`

A simple script for displaying the content of a binary file formatted as hexadecimal bytes.

### Usage

```txt
luajit showbin.lua <target>
```

- `<target>`: The target binary file to display.

#### Example

```sh
luajit showbin.lua program.bin
```

### Output

The content of the binary file formatted as pairs of hexadecimal digits.
