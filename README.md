# raylib bindings for Jai 🎮

These are bindings of [raylib](https://github.com/raysan5/raylib) **5.5** for the Jai programming language.

<p align="center">
    <img src="https://img.shields.io/badge/Jai-bindings-8A2BE2?style=flat" />
    <img src="https://img.shields.io/badge/raylib-5.5-000000?style=flat-flat" />
    <img src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-success?style=flat" />
</p>

## 🚀 Getting started

Download the latest version of the module:

👉 [**Download ZIP**](https://github.com/St0wy/raylib-jai/archive/refs/heads/main.zip)

Copy the folder into your Jai `module/` directory (or wherever you keep your modules) and import it:


```jai
#import "raylib-jai";
// or
Raylib :: #import "raylib-jai";
```

## 📁 Examples

Here is a minimal example to get you started:

```jai
Raylib :: #import "raylib-jai";

main :: () {
    WINDOW_WIDTH :: 1024;
    WINDOW_HEIGHT :: 768;

	Raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "raylib [core] example - basic window");
	Raylib.SetTargetFPS(Raylib.GetMonitorRefreshRate(0));

	while !Raylib.WindowShouldClose() {
		Raylib.BeginDrawing();
		Raylib.ClearBackground(Raylib.RAYWHITE);
		Raylib.DrawText("Congrats! You created your first window!", 190, 200, 20, Raylib.LIGHTGRAY);
		Raylib.EndDrawing();
	}

	Raylib.CloseWindow();
}
```

Some of the official [raylib examples](https://www.raylib.com/examples.html) have been ported to Jai in the [`examples/`](https://github.com/St0wy/raylib-jai/tree/main/examples) folder.

If you’d like an example to be ported to Jai, feel free to open an Issue, it will be added!

> [!NOTE]
> In the examples, raylib is imported as
> `Raylib :: #import,file "../../module.jai";`
> This is only to make them work with the current folder structure.
> You should import the module as shown above.

## 🔧 Generating the bindings

If you want to regenerate the bindings (e.g., when upgrading raylib), follow these steps:

### Install:

- **Jai** — required to generate bindings
- **CMake** — only needed if you want to compile raylib

Download the raylib source code (version 5.5):

👉 https://github.com/raysan5/raylib/archive/refs/tags/5.5.zip

Extract it into the module directory under the name `raylib/`.

### ▶️ Generate only

```bash
jai generate.jai
```

### ▶️ Generate **and** compile raylib

```bash
jai generate.jai - -compile
```

> [!NOTE]
> The compilation currently uses CMake, but other build systems could be supported in the future.
Feel free to open an Issue or submit a PR to add more ways of building raylib. 🙌
