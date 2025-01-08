using Basic :: #import "Basic";

Raylib :: #import,file "../../module.jai";

GameScreen :: enum {
    LOGO;
    TITLE;
    GAMEPLAY;
    ENDING;
}

main :: () {
    SCREEN_WIDTH :: 800;
    SCREEN_HEIGHT :: 450;

    Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic screen manager");
    defer Raylib.CloseWindow();
    monitor_refresh_rate := Raylib.GetMonitorRefreshRate(0);
    Raylib.SetTargetFPS(monitor_refresh_rate);

    current_screen := GameScreen.LOGO;

    frames_counter := 0;

    while !Raylib.WindowShouldClose() {
    	if #complete current_screen == {
    	case .LOGO;
    		frames_counter += 1;
    		if frames_counter > monitor_refresh_rate * 2 then current_screen = .TITLE;
    	case .TITLE;
    		if Raylib.IsKeyPressed(.ENTER) || Raylib.IsGestureDetected(.TAP) {
    			current_screen = .GAMEPLAY;
    		}
    	case .GAMEPLAY;
    		if Raylib.IsKeyPressed(.ENTER) || Raylib.IsGestureDetected(.TAP) {
    			current_screen = .ENDING;
    		}
    	case .ENDING;
    		if Raylib.IsKeyPressed(.ENTER) || Raylib.IsGestureDetected(.TAP) {
    			current_screen = .TITLE;
    		}
    	}

    	Raylib.BeginDrawing();
    	defer Raylib.EndDrawing();

    	Raylib.ClearBackground(Raylib.RAYWHITE);

    	if current_screen == {
    	case .LOGO;
    		Raylib.DrawText("LOGO SCREEN", 20, 20, 40, Raylib.LIGHTGRAY);
    		Raylib.DrawText("WAIT for 2 SECONDS...", 290, 220, 20, Raylib.GRAY);
    	case .TITLE;
    		Raylib.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Raylib.GREEN);
    		Raylib.DrawText("TITLE SCREEN", 20, 20, 40, Raylib.DARKGREEN);
    		Raylib.DrawText("PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN", 120, 220, 20, Raylib.DARKGREEN);
    	case .GAMEPLAY;
    		Raylib.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Raylib.PURPLE);
    		Raylib.DrawText("GAMEPLAY SCREEN", 20, 20, 40, Raylib.MAROON);
    		Raylib.DrawText("PRESS ENTER or TAP to JUMP to ENDING SCREEN", 130, 220, 20, Raylib.MAROON);
    	case .ENDING;
    		Raylib.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Raylib.BLUE);
    		Raylib.DrawText("PRESS ENTER or TAP to JUMP to TITLE SCREEN", 120, 220, 20, Raylib.DARKBLUE);
    		Raylib.DrawText("ENDING SCREEN", 20, 20, 40, Raylib.DARKBLUE);
    	}
    }
}