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

    // TODO: detect if actual frame rate is falling below target, and adjust
    const target_fps = 60;
    const dt = 1.0 / @as(comptime_float, target_fps);
    rl.set_target_fps(target_fps);
    // TODO: now the only way to close the game is with the escape key since that, by default, tells raylib to close the window
    //       instead, we'll want a menu and to re-enable the mouse when in that menu, with a quit option
    rl.disable_cursor();

    const mouse_model = rl.load_model("assets/mouse7.glb");
    const mouse_bounds = rl.get_model_bounding_box(mouse_model);
    var mouse_position = rm.Vector3f.init(0, -mouse_bounds.min.y, 0);
    defer rl.unload_model(mouse_model);

    var camera = rl.Camera_3d{
        .fovy = 60,
        // TODO: predefined vectors for up, down, left, right, forwards, backwards
        .up = rm.Vector3f.init(0, 1, 0),
        .projection = .PERSPECTIVE,
        .position = rm.Vector3f.init(0, 0.5, 0.5),
        .target = mouse_position,
    };
    while (!rl.window_should_close()) {
        const mouse_speed = 0.3; // meters per second
        var movement = rm.Vector3f.zero();
        if (rl.is_key_down(.W)) {
            movement.z -= 1;
        }
        if (rl.is_key_down(.S)) {
            movement.z += 1;
        }
        if (rl.is_key_down(.A)) {
            movement.x -= 1;
        }
        if (rl.is_key_down(.D)) {
            movement.x += 1;
        }
        if (!movement.is_zero()) {
            mouse_position = mouse_position.add_elements(movement.normalize().scale(dt * mouse_speed));
        }

        camera.target = mouse_position;
        update_camera(&camera);

        rl.begin_drawing();
        defer rl.end_drawing();

        rl.clear_background(.DARKGRAY);

        {
            rl.begin_mode_3d(camera);
            defer rl.end_mode_3d();

            const plane_size = 2;
            // offset the plane ever so slightly below ground level so the grid is cleanly above it
            rl.draw_plane(rm.Vector3f.init(0, -0.01, 0), rm.Vector2f.init(plane_size, plane_size), .DARKBROWN);
            const grid_subdivisions = 2;
            rl.draw_grid(plane_size * grid_subdivisions, 1.0 / @as(comptime_float, grid_subdivisions));
            rl.draw_model(mouse_model, mouse_position, 1.0, .WHITE);
        }

        const font_size = 16;
        const text_pos = rm.Vector2i.init(5, 5);
        const camera_dir = camera.position.sub_elements(camera.target).normalize();
        rl.draw_text(text_format("Camera Pos: {f}", .{camera.position}), text_pos.x, text_pos.y + 0 * font_size, font_size, .WHITE);
        rl.draw_text(text_format("Camera Tgt: {f}", .{camera.target}), text_pos.x, text_pos.y + 1 * font_size, font_size, .WHITE);
        rl.draw_text(text_format("Camera Dir: {f}", .{camera_dir}), text_pos.x, text_pos.y + 2 * font_size, font_size, .WHITE);
    }
}

fn text_format(comptime format: []const u8, args: anytype) [:0]const u8 {
    const Static = struct {
        var heap = std.heap.DebugAllocator(.{}).init;
        var arena = std.heap.ArenaAllocator.init(heap.allocator());
        const allocator = arena.allocator();
    };

    _ = Static.arena.reset(.retain_capacity);
    const result = std.fmt.allocPrintSentinel(Static.allocator, format, args, 0) catch {
        return "<oom>";
    };
    return result;
}

// ripped and modified from https://github.com/raysan5/raylib/blob/master/src/rcamera.h
fn update_camera(camera: *rl.Camera_3d) void {
    const CAMERA_MOUSE_MOVE_SENSITIVITY = 0.003;

    const mouse_delta = rl.get_mouse_delta();

    const rotate_around_target = true;
    const lock_view = true;
    const rotate_up = false;

    rl.camera_yaw(camera, -mouse_delta.x * CAMERA_MOUSE_MOVE_SENSITIVITY, rotate_around_target);
    rl.camera_pitch(camera, -mouse_delta.y * CAMERA_MOUSE_MOVE_SENSITIVITY, lock_view, rotate_around_target, rotate_up);

    // TODO: gamepad support
    // if (IsGamepadAvailable(0))
    // {
    //     CameraYaw(camera, -(GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_X)*2)*CAMERA_MOUSE_MOVE_SENSITIVITY, rotateAroundTarget);
    //     CameraPitch(camera, -(GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_Y)*2)*CAMERA_MOUSE_MOVE_SENSITIVITY, lockView, rotateAroundTarget, rotateUp);
    // }

    // Zoom to target with mouse wheel
    // TODO: disallow moving inside the mesh, use mesh bounding box?
    // TODO: this doesn't seem like linear movement
    rl.camera_move_to_target(camera, -0.15 * rl.get_mouse_wheel_move());
}
