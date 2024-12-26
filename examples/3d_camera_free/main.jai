using Basic :: #import "Basic";

Raylib :: #import,file "../../module.jai";

main :: () {
    WINDOW_WIDTH : s32 = 800;
    WINDOW_HEIGHT : s32 = 450;

    Raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "raylib [core] example - 3d camera free");
    defer Raylib.CloseWindow();

    camera := Raylib.Camera3D.{
        position = .{10, 10, 10},
        target = .{0, 0, 0},
        up = .{0, 1, 0},
        fovy = 45,
        projection = .PERSPECTIVE,
    };

    cube_position := Raylib.Vector3.{0, 0, 0};

    Raylib.DisableCursor();

    Raylib.SetTargetFPS(60);

    frame_count := 0;

    while !Raylib.WindowShouldClose() {
        print("Running frame %\n", frame_count);
        Raylib.UpdateCamera(*camera, Raylib.CameraMode.FREE);

        if Raylib.IsKeyPressed(.Z) then camera.target = Raylib.Vector3.{0, 0, 0};

        {
            Raylib.BeginDrawing();
            defer Raylib.EndDrawing();

            Raylib.ClearBackground(Raylib.RAYWHITE);

            {
                Raylib.BeginMode3D(camera);
                defer Raylib.EndMode3D();

                Raylib.DrawCube(cube_position, 2.0, 2.0, 2.0, Raylib.RED);
                Raylib.DrawCubeWires(cube_position, 2.0, 2.0, 2.0, Raylib.MAROON);

                Raylib.DrawGrid(10, 1.0);
            }

            Raylib.DrawRectangle(10, 10, 320, 93, Raylib.Fade(Raylib.SKYBLUE, 0.5));
            Raylib.DrawRectangleLines(10, 10, 320, 93, Raylib.BLUE);

            Raylib.DrawText("Free camera default controls:", 20, 20, 10, Raylib.BLACK);
            Raylib.DrawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, Raylib.DARKGRAY);
            Raylib.DrawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, Raylib.DARKGRAY);
            Raylib.DrawText("- Z to zoom to (0, 0, 0)", 40, 80, 10, Raylib.DARKGRAY);
        }

        frame_count += 1;
    }
}