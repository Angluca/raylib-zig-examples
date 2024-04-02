const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "drop_files");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var file_paths = std.ArrayList([]const u8).init(allocator);
    defer file_paths.deinit();

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        if(rl.IsFileDropped()) {
            const dropped_files = rl.LoadDroppedFiles();
            defer rl.UnloadDroppedFiles(dropped_files);
            for(0..dropped_files.count)|i| {
                const path_src: [*:0]const u8 = dropped_files.paths[i];
                const path = std.fmt.allocPrintZ(allocator, "{s}", .{path_src}) catch @panic("Alloc failed");
                file_paths.append(path) catch unreachable;
            }
        }

        if(file_paths.items.len > 0 and rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT)) _ = file_paths.pop();

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);

            if(file_paths.items.len == 0)
                rl.DrawText("Drop your files to this window!", 100, 40, 20, rl.WHITE)
            else {
                rl.DrawText("Dropped files:", 100, 40, 20, rl.WHITE);
                for(file_paths.items, 0..)|path, i| {
                    if(i%2 == 0) rl.DrawRectangle(0, @intCast(85 + 40*i), screen_width, 40, rl.Fade(rl.LIGHTGRAY, 0.5))
                    else rl.DrawRectangle(0, @intCast(85 + 40*i), screen_width, 40, rl.Fade(rl.LIGHTGRAY, 0.3));

                    rl.DrawText(path.ptr, 120, @intCast(100 + 40*i), 10, rl.YELLOW);
                }
            }

        rl.EndDrawing();
    }
    //deinit --
}
