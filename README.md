# raylib bindings for Jai

Theses are bindings of [raylib](https://github.com/raysan5/raylib) 5.5 for Jai. raylib is compiled and then the bindings are generated in `generate.jai`.

> [!WARNING]  
> These bindings don't include `raymath.h` because Clang doesn't seem to include `math.h` ? 
> Thankfully, Jai includes a lot of the functionality from that module. 
> If you know how to fix this, feel free to submit a PR.

If you want to generate the bindings, you can get the [source code](https://github.com/raysan5/raylib/archive/refs/tags/5.5.zip) from the release page and put them in this folder with the name `raylib/`.

## Generating the bindings

Install :

- Jai (To generate the bindings)
- CMake (To compile raylib, not needed just to generate)

To generate the bindings, just run 

```bash
jai generate.jai
```

If you want to also compile raylib, run

```bash
jai generate.jai - -compile
```

Note that for now the compilation uses CMake, but other build systems could be supported if needed.
Feel free to create an issue or send a PR to add more ways of building raylib.