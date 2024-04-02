const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 800;
const screen_height = 450;

const storage_file_path = "storage.data";
const StorageData = enum {
    score,
    hiscore,
};

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "storage_values");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var score: i32 = 0;
    var hiscore: i32 = 0;
    var frame_counter: i32 = 0;

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        if(rl.IsKeyPressed(rl.KEY_SPACE)) {
            score = rl.GetRandomValue(100, 2000);
            hiscore = rl.GetRandomValue(2000, 4000);
        }

        if(rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT)) {
            saveStorageValue(StorageData.score, score);
            saveStorageValue(StorageData.hiscore, hiscore);

        } else if(rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
            score = loadStorageValue(StorageData.score);
            hiscore = loadStorageValue(StorageData.hiscore);
        }
        frame_counter += 1;

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);

            rl.DrawText(rl.TextFormat("SCORE: %i", score), 280, 130, 40, rl.MAROON);
            rl.DrawText(rl.TextFormat("HI-SCORE: %i", hiscore), 210, 200, 50, rl.BLACK);

            rl.DrawText(rl.TextFormat("frames: %i", frame_counter), 10, 10, 20, rl.LIME);

            rl.DrawText("Press SPACE to generate random numbers", 220, 40, 20, rl.LIGHTGRAY);
            rl.DrawText("Press Mouse_Right to SAVE values", 250, 310, 20, rl.LIGHTGRAY);
            rl.DrawText("Press Mouse_Left to LOAD values", 252, 350, 20, rl.LIGHTGRAY);

        rl.EndDrawing();
    }
    //deinit --
}

fn saveStorageValue(self: StorageData, value: i32) void {
    var values = loadStorageValues() catch .{0, 0};
    switch(self) {
        .score => values[0] = value,
        .hiscore => values[1] = value,
    }
    const file = std.fs.cwd().createFile(
        storage_file_path, .{.read = true},
    ) catch unreachable;
    defer file.close();
    const ptr = @as([*]const u8, @ptrCast(&values))[0..8];
    _ = file.writeAll(ptr) catch unreachable;
    rl.TraceLog(rl.LOG_INFO, "FILEIO: [%s] Saved storage value: %i", storage_file_path, value);
}

fn loadStorageValue(self: StorageData) i32 {
    _ = &self;
    var ret: i32 = 0; _ = &ret;
    const values = loadStorageValues() catch return -1;
    ret = switch (self) {
        .score => values[0],
        .hiscore => values[1],
    };
    rl.TraceLog(rl.LOG_INFO, "FILEIO: [%s] Loaded storage value: %i", storage_file_path, ret);
    return ret;
}

fn loadStorageValues() ![2]i32 {
    var file = try std.fs.cwd().openFile(storage_file_path, .{});
    defer file.close();
    var ret = [2]i32{0, 0}; _ = &ret;
    const ptr = @as([*]u8, @ptrCast(&ret))[0..8];
    _ = try file.readAll(ptr);
    return ret;
}
