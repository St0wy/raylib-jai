Raylib :: #import,file "../../module.jai";

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