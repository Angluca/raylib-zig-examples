const std = @import("std");
const m = std.math;
pub const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
    @cInclude("raygui.h");
});

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.SetTraceLogLevel(rl.LOG_WARNING);
    rl.InitWindow(screen_width, screen_height, "test3d");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT);
    var camera: rl.Camera = .{};
    camera.position = .{.x=40,.y=20,.z=0};
    camera.target = .{.x=0,.y=0,.z=0};
    camera.up = .{.x=0,.y=1,.z=0};
    //camera.up = rl.Vector3CrossProduct(rl.Vector3Subtract(
            //camera.target, camera.position), .{.x=0,.y=1,.z=0}
    //);
    camera.fovy = 70.0;
    camera.projection = rl.CAMERA_PERSPECTIVE;
    const mesh = rl.GenMeshCube(5, 5, 15);
    defer rl.UnloadMesh(mesh);
    var color_hue: f32 = 0;
    //rl.ShowCursor();
    //rl.HideCursor();
    rl.DisableCursor();

    //loops --
    var dt: f32 = 0;
    while (!rl.WindowShouldClose()) {
        //update --
        dt = @floatCast(rl.GetTime());

        rl.UpdateCamera(&camera, rl.CAMERA_FREE);
        rl.SetMousePosition(screen_width/2, screen_height/2);
        //rl.UpdateCamera(&camera, rl.CAMERA_FIRST_PERSON);
        //rl.UpdateCamera(&camera, rl.CAMERA_ORBITAL);
        //camera.position.x = m.cos(dt) * 25.0;
        //camera.position.z = m.sin(dt) * 40.0;
        //camera.up = rl.Vector3CrossProduct(rl.Vector3Subtract(
                //camera.target, camera.position), .{.x=0,.y=1,.z=0}
        //);

        color_hue = @mod((color_hue + 1), 360);
        const checked = rl.GenImageChecked(2,2,1,1,rl.ColorFromHSV(color_hue,1,1),rl.LIGHTGRAY);
        const texture = rl.LoadTextureFromImage(checked);
        defer rl.UnloadTexture(texture);
        rl.UnloadImage(checked);

        const material = rl.LoadMaterialDefault();
        material.maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture;
        defer rl.UnloadMaterial(material);
        const rotate_angle = dt * 0.3;
        //const transform = rl.MatrixRotateY(rotate_angle);
        const transform = rl.MatrixRotate(.{.x=0,.y=1,.z=0}, rotate_angle);

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);

            rl.BeginMode3D(camera);
                rl.DrawGrid(10, 6);
                rl.DrawLine3D(.{.x=0,.y=30,.z=0}, .{.x=0,.y=-30,.z=0}, rl.BLACK);
                rl.DrawCube(.{.x=0,.y=10,.z=0}, 10,10,10, rl.VIOLET);
                rl.DrawCubeWires(.{.x=0,.y=0,.z=0}, 10,10,10, rl.BLACK);
                rl.DrawSphere(.{.x=0,.y=-30,.z=0}, 10, rl.RED);
                rl.DrawSphereWires(.{.x=0,.y=-30,.z=0}, 10,10,10, rl.BLACK);
                //rl.DrawMesh(mesh, material, rl.MatrixIdentity());
                rl.DrawMesh(mesh, material, transform);

            rl.EndMode3D();
        rl.EndDrawing();
    }
    //deinit --
}
