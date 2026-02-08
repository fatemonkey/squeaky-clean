const std = @import("std");
const rl = @import("rayzig");
const rm = rl.math;
const options = @import("options");

const log = std.log.scoped(.game);

pub fn main() void {
    const version = options.version_string;

    var title_buffer: [64]u8 = undefined;
    const title = std.fmt.bufPrintZ(&title_buffer, "Squeaky Clean {s}", .{version}) catch blk: {
        log.warn("Failed to format title", .{});
        break :blk "<title>";
    };

    rl.init_window(800, 600, title);
    defer rl.close_window();

    rl.set_target_fps(60);

    // TODO: for some reason model loading is *EXTREMELY* slow
    const model = rl.load_model("assets/fate_mouse_static.obj");
    defer rl.unload_model(model);

    const camera = rl.Camera_3d{
        .fovy = 60,
        // TODO: predefined vectors for up, down, left, right, forwards, backwards
        // TODO: pretty sure up should be y=-1, just using 1 for now to fix the model being upside down
        .up = rm.Vector3f.init(0, 1, 0),
        .projection = .PERSPECTIVE,
        .position = rm.Vector3f.init(0, 0, -1),
        .target = rm.Vector3f.init(0, 0, 0),
    };
    while (!rl.window_should_close()) {
        rl.begin_drawing();
        defer rl.end_drawing();

        rl.clear_background(.BLACK);

        {
            rl.begin_mode_3d(camera);
            defer rl.end_mode_3d();

            rl.draw_model(model, rm.Vector3f.zero(), 0.5, .WHITE);
        }
    }
}
