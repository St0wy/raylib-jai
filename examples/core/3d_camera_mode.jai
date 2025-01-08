using Basic :: #import "Basic";

Raylib :: #import,file "../../module.jai";

main :: () {
	SCREEN_WIDTH :: 800;
	SCREEN_HEIGHT :: 450;

	Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - 3d camera mode");
	defer Raylib.CloseWindow();

	camera := Raylib.Camera3D.{
		position = .{0, 10, 10},
		target = .{0, 0, 0},
		up = .{0, 1, 0},
		fovy = 45,
		projection = .PERSPECTIVE,
	};

	cube_position := Raylib.Vector3.{0, 0, 0};

	Raylib.SetTargetFPS(Raylib.GetMonitorRefreshRate(0));

	while !Raylib.WindowShouldClose() {
		Raylib.BeginDrawing();
		defer Raylib.EndDrawing();

		Raylib.ClearBackground(Raylib.RAYWHITE);

		{
			Raylib.BeginMode3D(camera);
			defer Raylib.EndMode3D();

			Raylib.DrawCube(cube_position, 2, 2, 2, Raylib.RED);
			Raylib.DrawCubeWires(cube_position, 2, 2, 2, Raylib.MAROON);

			Raylib.DrawGrid(10, 1);
		}

		Raylib.DrawText("Welcome to the third dimension!", 10, 40, 20, Raylib.DARKGRAY);

		Raylib.DrawFPS(10, 10);
	}
}