# raylib bindings for Jai

Theses are bindings of [raylib](https://github.com/raysan5/raylib) 5.5 for Jai. raylib is compiled and then the bindings are generated in `generate.jai`.

## Generating the bindings

Install :

- Jai (To generate the bindings)
- CMake (To compile raylib, not needed just to generate)

Then get the [source code](https://github.com/raysan5/raylib/archive/refs/tags/5.5.zip) from the release page and put them in this folder with the name `raylib/`.

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