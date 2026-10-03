<!--
 Copyright 2026 wyteroze. Licensed under the Apache-2.0 license.
-->

# syzygy

## About
Luau to WebAssembly AOT compiler (experimental). Still WIP.

## Build
1. Clone repo (it uses submodules): `git clone --recurse-submodules https://github.com/wyteroze/syzygy.git`
2. Install Zig toolchain (0.17.0 as of writing): https://ziglang.org/download/
3. Navigate to repo root and build: `cd syzygy && zig build`
4. The built executable can be found in `zig-out/bin/syzygy/`
5. You can alternatively build and run in the same command using `zig build run -- <args>`

## Software licenses
* [Syzygy](LICENSE) (Apache-2.0)
* [Luau](vendor/luau/LICENSE.txt) (MIT)
* [Binaryen](vendor/binaryen/LICENSE) (Apache-2.0)
* [flag.h](https://github.com/tsoding/flag.h/blob/master/LICENSE) (MIT)