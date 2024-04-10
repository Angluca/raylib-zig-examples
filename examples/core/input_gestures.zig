const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 800;
const screen_height = 450;

const max_gesture_strings = 20;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "input_gestures");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var gesture_strings = std.ArrayList([]const u8).init(allocator);
    defer gesture_strings.deinit();

    var touch_position: rl.Vector2 = .{};
    const touch_area = rl.Rectangle{.x=220, .y=10, .width=screen_width-230.0, .height=screen_height-20.0};
    var current_gesture: i32 = rl.GESTURE_NONE;
    var last_gesture: i32 = rl.GESTURE_NONE;

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        last_gesture = current_gesture;
        current_gesture = rl.GetGestureDetected();
        touch_position = rl.GetTouchPosition(0);
        if(rl.CheckCollisionPointRec(touch_position, touch_area) and
            (current_gesture != rl.GESTURE_NONE)) {
            if(current_gesture != last_gesture) {
                if(gesture_strings.items.len >= max_gesture_strings) {
                    gesture_strings.clearAndFree();
                }
                switch(current_gesture) {
                    rl.GESTURE_TAP => try gesture_strings.append("GESTURE TAP"),
                    rl.GESTURE_DOUBLETAP => try gesture_strings.append("GESTURE DOUBLETAP"),
                    rl.GESTURE_HOLD => try gesture_strings.append("GESTURE HOLD"),
                    rl.GESTURE_DRAG => try gesture_strings.append("GESTURE DRAG"),
                    rl.GESTURE_SWIPE_RIGHT => try gesture_strings.append("GESTURE SWIPE RIGHT"),
                    rl.GESTURE_SWIPE_LEFT => try gesture_strings.append("GESTURE SWIPE LEFT"),
                    rl.GESTURE_SWIPE_UP => try gesture_strings.append("GESTURE SWIPE UP"),
                    rl.GESTURE_SWIPE_DOWN => try gesture_strings.append("GESTURE SWIPE DOWN"),
                    rl.GESTURE_PINCH_IN => try gesture_strings.append("GESTURE PINCH IN"),
                    rl.GESTURE_PINCH_OUT => try gesture_strings.append("GESTURE PINCH OUT"),
                    else => {}
                }
            }
        }

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);

            rl.DrawRectangleRec(touch_area, rl.GRAY);
            rl.DrawRectangle(225, 15, screen_width - 240, screen_height - 30, rl.LIGHTGRAY);
            rl.DrawText("GESTURES TEST AREA", screen_width - 270, screen_height - 40, 20, rl.Fade(rl.GRAY, 0.5));

            for(gesture_strings.items, 0..)|str, _i| {
                const i: i32 = @intCast(_i);
                if(@rem(i, 2) == 0) rl.DrawRectangle(10, 30 + 20*i, 200, 20, rl.Fade(rl.LIGHTGRAY, 0.5))
                else rl.DrawRectangle(10, 30 + 20*i, 200, 20, rl.Fade(rl.LIGHTGRAY, 0.3));
                const count = gesture_strings.items.len - 1;
                if(i < count) rl.DrawText(@ptrCast(str), 35, 36 + 20*i, 10, rl.DARKGRAY)
                else rl.DrawText(@ptrCast(str), 35, 36 + 20*i, 10, rl.MAROON);
            }

            rl.DrawRectangleLines(10, 29, 200, screen_height - 50, rl.GRAY);
            rl.DrawText("DETECTED GESTURES", 50, 15, 10, rl.GRAY);
            if(current_gesture != rl.GESTURE_NONE) rl.DrawCircleV(touch_position, 30, rl.MAROON);

        rl.EndDrawing();
    }
    //deinit --
}
