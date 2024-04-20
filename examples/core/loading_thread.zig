const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "loading_thread");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var thr: std.Thread = undefined;
    var state = enum { waiting, loading, finished, }.waiting;
    var is_data_loaded = std.atomic.Value(bool).init(false);
    var data_progress = std.atomic.Value(i64).init(0);
    var frames_counter: u32 = 0;

    while (!rl.WindowShouldClose()) {
        //update --
        switch(state) {
            .waiting => {
                if(rl.IsKeyPressed(rl.KEY_ENTER)) {
                    thr = try std.Thread.spawn(.{}, loadDataThread, .{&is_data_loaded, &data_progress});
                    defer thr.detach();
                    rl.TraceLog(rl.LOG_INFO, "Loading thread initialized successfully");
                    state = .loading;
                }
            },
            .loading => {
                frames_counter += 1;
                if(is_data_loaded.load(.unordered)) {
                    frames_counter = 0;
                    rl.TraceLog(rl.LOG_INFO, "Loading thread terminated successfully");
                    state = .finished;
                }
            },
            .finished => {
                if(rl.IsKeyPressed(rl.KEY_ENTER)) {
                    is_data_loaded.store(false, .monotonic);
                    data_progress.store(0, .monotonic);
                    state = .waiting;
                }
            },
        }

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.GRAY);
            switch(state) {
                .waiting => rl.DrawText("PRESS ENTER to START LOADING DATA", 150, 170, 20, rl.DARKGRAY),
                .loading => {
                    rl.DrawRectangle(150, 200, @intCast(data_progress.load(.unordered)), 60, rl.SKYBLUE);
                    if ((frames_counter/15)%2 > 0) rl.DrawText("LOADING DATA...", 240, 210, 40, rl.DARKBLUE);
                },
                .finished => {
                    rl.DrawRectangle(150, 200, 500, 60, rl.LIME);
                    rl.DrawText("DATA LOADED!", 250, 210, 40, rl.GREEN);
                }
            }
            rl.DrawRectangleLines(150, 200, 500, 60, rl.DARKGRAY);

        rl.EndDrawing();
    }
    //deinit --
}

fn loadDataThread(is_data_loaded: anytype, data_progress: anytype) !void {
    var time_counter: i64 = 0;
    const prev_time = std.time.microTimestamp();

    while(time_counter < 5000) {
        const cur_time = std.time.microTimestamp() - prev_time;
        time_counter = @divTrunc(cur_time, 1000);
        data_progress.store(@divTrunc(time_counter, 10), .monotonic);
    }
    is_data_loaded.store(true, .monotonic);
}

