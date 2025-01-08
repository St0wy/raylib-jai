using Basic :: #import "Basic";
String :: #import "String";

Raylib :: #import,file "../../module.jai";

XBOX_ALIAS_1 :: "xbox";
XBOX_ALIAS_2 :: "x-box";

main :: () {
	SCREEN_WIDTH :: 800;
	SCREEN_HEIGHT :: 450;

	Raylib.SetConfigFlags(.MSAA_4X_HINT);

	Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - gamepad input");
	defer Raylib.CloseWindow();

	tex_ps3_pad := Raylib.LoadTexture("resources/ps3.png");
	defer Raylib.UnloadTexture(tex_ps3_pad);
	tex_xbox_pad := Raylib.LoadTexture("resources/xbox.png");
	defer Raylib.UnloadTexture(tex_xbox_pad);

	LEFT_STICK_DEADZONE_X :: 0.1;
	LEFT_STICK_DEADZONE_Y :: 0.1;
	RIGHT_STICK_DEADZONE_X :: 0.1;
	RIGHT_STICK_DEADZONE_Y :: 0.1;
	LEFT_TRIGGER_DEADZONE :: -0.9;
	RIGHT_TRIGGER_DEADZONE :: -0.9;

	Raylib.SetTargetFPS(Raylib.GetMonitorRefreshRate(0));

	gamepad: s32 = 0;

	while !Raylib.WindowShouldClose() {
		defer reset_temporary_storage();

		Raylib.BeginDrawing();
		defer Raylib.EndDrawing();

		Raylib.ClearBackground(Raylib.RAYWHITE);

		if Raylib.IsKeyPressed(.LEFT) && gamepad > 0 then gamepad -= 1;
		if Raylib.IsKeyPressed(.RIGHT) then gamepad += 1;

		if !Raylib.IsGamepadAvailable(gamepad) {
			gamepad_text := tprint("GP%: NOT DETECTED\0", gamepad);
			Raylib.DrawText(gamepad_text.data, 10, 10, 10, Raylib.GRAY);

			Raylib.DrawTexture(tex_xbox_pad, 0, 0, Raylib.LIGHTGRAY);

			continue;
		}

		c_style_gamepad_name := Raylib.GetGamepadName(gamepad);
		len := c_style_strlen(c_style_gamepad_name);
		gamepad_name := string.{len, c_style_gamepad_name};

		gamepad_text := tprint("GP%: %\0", gamepad, gamepad_name);
		Raylib.DrawText(gamepad_text.data, 10, 10, 10, Raylib.BLACK);

		left_stick_x := Raylib.GetGamepadAxisMovement(gamepad, .LEFT_X);
		left_stick_y := Raylib.GetGamepadAxisMovement(gamepad, .LEFT_Y);
		right_stick_x := Raylib.GetGamepadAxisMovement(gamepad, .RIGHT_X);
		right_stick_y := Raylib.GetGamepadAxisMovement(gamepad, .RIGHT_Y);
		left_trigger := Raylib.GetGamepadAxisMovement(gamepad, .LEFT_TRIGGER);
		right_trigger := Raylib.GetGamepadAxisMovement(gamepad, .RIGHT_TRIGGER);

		if left_stick_x > -LEFT_STICK_DEADZONE_X && left_stick_x < LEFT_STICK_DEADZONE_X then left_stick_x = 0;
		if left_stick_y > -LEFT_STICK_DEADZONE_Y && left_stick_y < LEFT_STICK_DEADZONE_Y then left_stick_y = 0;
		if right_stick_x > -RIGHT_STICK_DEADZONE_X && right_stick_x < RIGHT_STICK_DEADZONE_X then right_stick_x = 0;
		if right_stick_y > -RIGHT_STICK_DEADZONE_Y && right_stick_y < RIGHT_STICK_DEADZONE_Y then right_stick_y = 0;
		if left_trigger < LEFT_TRIGGER_DEADZONE then left_trigger = -1.0;
		if right_trigger < RIGHT_TRIGGER_DEADZONE then right_trigger = -1.0;

		lower_gamepad := String.to_lower_copy(gamepad_name,, temp);
		is_first_xbox := String.find_index_from_left(lower_gamepad, XBOX_ALIAS_1) > -1;
		is_second_xbox := String.find_index_from_left(lower_gamepad, XBOX_ALIAS_2) > -1;

		// TODO: Xbox doesn't work on MacOS for now, test that later
		if is_first_xbox || is_second_xbox {
			Raylib.DrawTexture(tex_xbox_pad, 0, 0, Raylib.DARKGRAY);

			// XBOX Home
			if Raylib.IsGamepadButtonDown(gamepad, .MIDDLE) then Raylib.DrawCircle(394, 89, 19, Raylib.RED);

			// Basic buttons
			if Raylib.IsGamepadButtonDown(gamepad, .MIDDLE_RIGHT) then Raylib.DrawCircle(436, 150, 9, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .MIDDLE_LEFT) then Raylib.DrawCircle(352, 150, 9, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_LEFT) then Raylib.DrawCircle(501, 151, 15, Raylib.BLUE);
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_DOWN) then Raylib.DrawCircle(536, 187, 15, Raylib.LIME);
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_RIGHT) then Raylib.DrawCircle(572, 151, 15, Raylib.MAROON);
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_UP) then Raylib.DrawCircle(536, 115, 15, Raylib.GOLD);

			// D-pad
			Raylib.DrawRectangle(317, 202, 19, 71, Raylib.BLACK);
			Raylib.DrawRectangle(293, 228, 69, 19, Raylib.BLACK);
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_UP) then Raylib.DrawRectangle(317, 202, 19, 26, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_DOWN) then Raylib.DrawRectangle(317, 202 + 45, 19, 26, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_LEFT) then Raylib.DrawRectangle(292, 228, 25, 19, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_RIGHT) then Raylib.DrawRectangle(292 + 44, 228, 26, 19, Raylib.RED);

			// Left-right back
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_TRIGGER_1) then Raylib.DrawCircle(259, 61, 20, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_TRIGGER_1) then Raylib.DrawCircle(536, 61, 20, Raylib.RED);

			// Left joystick
			left_gamepad_color := Raylib.BLACK;
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_THUMB) then left_gamepad_color = Raylib.RED;
			Raylib.DrawCircle(259, 152, 39, Raylib.BLACK);
			Raylib.DrawCircle(259, 152, 34, Raylib.LIGHTGRAY);
			Raylib.DrawCircle(259 + cast(s32, left_stick_x * 20),
				152 + cast(s32, left_stick_y * 20), 25, left_gamepad_color);

			// Right joystick
			right_gamepad_color := Raylib.BLACK;
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_THUMB) then right_gamepad_color = Raylib.RED;
			Raylib.DrawCircle(461, 237, 38, Raylib.BLACK);
			Raylib.DrawCircle(461, 237, 33, Raylib.LIGHTGRAY);
			Raylib.DrawCircle(461 + cast(s32, right_stick_x * 20),
				237 + cast(s32, right_stick_y * 20), 25, right_gamepad_color);

			// Left-right trigger
			Raylib.DrawRectangle(170, 30, 15, 70, Raylib.GRAY);
			Raylib.DrawRectangle(604, 30, 15, 70, Raylib.GRAY);
			Raylib.DrawRectangle(170, 30, 15, cast(s32, ((1 + left_trigger) / 2) * 70), Raylib.RED);
			Raylib.DrawRectangle(604, 30, 15, cast(s32, ((1 + right_trigger) / 2) * 70), Raylib.RED);
		} else {
			            // Draw background: generic
			Raylib.DrawRectangleRounded(.{175, 110, 460, 220}, 0.3, 16, Raylib.DARKGRAY);

			// Basic buttons
			Raylib.DrawCircle(365, 170, 12, Raylib.RAYWHITE);
			Raylib.DrawCircle(405, 170, 12, Raylib.RAYWHITE);
			Raylib.DrawCircle(445, 170, 12, Raylib.RAYWHITE);
			Raylib.DrawCircle(516, 191, 17, Raylib.RAYWHITE);
			Raylib.DrawCircle(551, 227, 17, Raylib.RAYWHITE);
			Raylib.DrawCircle(587, 191, 17, Raylib.RAYWHITE);
			Raylib.DrawCircle(551, 155, 17, Raylib.RAYWHITE);
			if Raylib.IsGamepadButtonDown(gamepad, .MIDDLE_LEFT) then Raylib.DrawCircle(365, 170, 10, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .MIDDLE) then Raylib.DrawCircle(405, 170, 10, Raylib.GREEN);
			if Raylib.IsGamepadButtonDown(gamepad, .MIDDLE_RIGHT) then Raylib.DrawCircle(445, 170, 10, Raylib.BLUE);
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_LEFT) then Raylib.DrawCircle(516, 191, 15, Raylib.GOLD);
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_DOWN) then Raylib.DrawCircle(551, 227, 15, Raylib.BLUE);
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_RIGHT) then Raylib.DrawCircle(587, 191, 15, Raylib.GREEN);
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_UP) then Raylib.DrawCircle(551, 155, 15, Raylib.RED);

			// D-pad
			Raylib.DrawRectangle(245, 145, 28, 88, Raylib.RAYWHITE);
			Raylib.DrawRectangle(215, 174, 88, 29, Raylib.RAYWHITE);
			Raylib.DrawRectangle(247, 147, 24, 84, Raylib.BLACK);
			Raylib.DrawRectangle(217, 176, 84, 25, Raylib.BLACK);
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_UP) then Raylib.DrawRectangle(247, 147, 24, 29, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_DOWN) then Raylib.DrawRectangle(247, 147 + 54, 24, 30, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_LEFT) then Raylib.DrawRectangle(217, 176, 30, 25, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_RIGHT) then Raylib.DrawRectangle(217 + 54, 176, 30, 25, Raylib.RED);

			// Left-right back
			Raylib.DrawRectangleRounded(.{215, 98, 100, 10}, 0.5, 16, Raylib.DARKGRAY);
			Raylib.DrawRectangleRounded(.{495, 98, 100, 10}, 0.5, 16, Raylib.DARKGRAY);
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_TRIGGER_1) then Raylib.DrawRectangleRounded(.{215, 98, 100, 10}, 0.5, 16, Raylib.RED);
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_TRIGGER_1) then Raylib.DrawRectangleRounded(.{495, 98, 100, 10}, 0.5, 16, Raylib.RED);

			// Left joystick
			left_gamepad_color := Raylib.BLACK;
			if Raylib.IsGamepadButtonDown(gamepad, .LEFT_THUMB) then left_gamepad_color = Raylib.RED;
			Raylib.DrawCircle(345, 260, 40, Raylib.BLACK);
			Raylib.DrawCircle(345, 260, 35, Raylib.LIGHTGRAY);
			Raylib.DrawCircle(345 + cast(s32, left_stick_x * 20),
				260 + cast(s32, left_stick_y * 20), 25, left_gamepad_color);

			// Right joystick
			right_gamepad_color := Raylib.BLACK;
			if Raylib.IsGamepadButtonDown(gamepad, .RIGHT_THUMB) then right_gamepad_color = Raylib.RED;
			Raylib.DrawCircle(465, 260, 40, Raylib.BLACK);
			Raylib.DrawCircle(465, 260, 35, Raylib.LIGHTGRAY);
			Raylib.DrawCircle(465 + cast(s32, right_stick_x * 20),
				260 + cast(s32, right_stick_y * 20), 25, right_gamepad_color);

			// Left-right triggers
			Raylib.DrawRectangle(151, 110, 15, 70, Raylib.GRAY);
			Raylib.DrawRectangle(644, 110, 15, 70, Raylib.GRAY);
			Raylib.DrawRectangle(151, 110, 15, cast(s32, ((1 + left_trigger) / 2) * 70), Raylib.RED);
			Raylib.DrawRectangle(644, 110, 15, cast(s32, ((1 + right_trigger) / 2) * 70), Raylib.RED);
		}

		detected_axis := tprint("DETECTED_AXIS [%]:\0", Raylib.GetGamepadAxisCount(0));
		Raylib.DrawText(detected_axis.data, 10, 50, 10, Raylib.MAROON);

		for 0..Raylib.GetGamepadAxisCount(0) - 1 {
			axis_text := tprint("AXIS %: % \0", it, Raylib.GetGamepadAxisMovement(0, it));
			Raylib.DrawText(axis_text.data, 20, 70 + 20 * it, 10, Raylib.DARKGRAY);
		}

		button_text := tprint("DETECTED BUTTON: %\0", Raylib.GetGamepadButtonPressed());
		if Raylib.GetGamepadButtonPressed() != .UNKNOWN then Raylib.DrawText(button_text.data, 10, 430, 10, Raylib.RED);
		else Raylib.DrawText("DETECTED BUTTON: NONE", 10, 430, 10, Raylib.GRAY);
	}

}