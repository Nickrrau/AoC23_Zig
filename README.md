# Advent of Code 2023 - Zig

Simple solutions to AoC'23 problems, mostly another excuse to write some ugly Zig code.
This includes a rather over-complicated way of generating code scaffolding and downloading each days input.

Once the day unlocks you can simply run `zig build new -Dday=<x>` and it will collect the day's input and produce a basic zig file that embeds the file, and an optional sample file for each part.
This also spits out a template zig file pre-filled out with minimal process functions which are all called by a shared main.

Once ready you can then run `zig build day_<x>` which will build a dedicated executable for that day. This is done by creating a private module locally using each day's main zig file which has the required methods.


| Day | Part 1 | Part 2 |
| - | - | - |
| 1 | :star: | :star: |
| 2 | :star: | :star: |
| 3 |  |  |
| 4 | :star: | :star: |
| 5 | :star: | |
| 6 | :star: | :star: |
