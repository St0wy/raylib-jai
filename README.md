# raylib bindings for Jai

Theses are bindings of [raylib](https://github.com/raysan5/raylib) 5.5 for Jai. raylib is compiled and then the bindings are generated in `generate.jai`.

> [!WARNING]  
> These bindings don't include `raymath.h` because Clang doesn't seem to include `math.h` ? 
> Thankfully, Jai includes a lot of the functionality from that module. 
> If you know how to fix this, feel free to submit a PR.

These bindings use RGFW as a backend, meaning that the function `SetGamepadVibration` is missing.

If you want to generate the bindings, you can get the [source code](https://github.com/raysan5/raylib/archive/refs/tags/5.5.zip) from the release page and put them in this folder with the name `raylib/`.