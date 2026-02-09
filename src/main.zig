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

    rl.init_window(1280, 720, title);
    defer rl.close_window();

    // TODO: detect if actual frame rate is falling below target, and adjust
    const target_fps = 60;
    const dt = 1.0 / @as(comptime_float, target_fps);
    rl.set_target_fps(target_fps);

    var show_debug_overlay = false;

    // TODO: now the only way to close the game is with the escape key since that, by default, tells raylib to close the window
    //       instead, we'll want a menu and to re-enable the mouse when in that menu, with a quit option
    var cursor_enabled = false;
    rl.disable_cursor();

    const mouse_model = rl.load_model("assets/mouse7.glb");
    const mouse_bounds = rl.get_model_bounding_box(mouse_model);
    var mouse_position = rm.Vector3f.init(0, -mouse_bounds.min.y, 0);
    const mouse_closest_zoom_radius: f32 = blk: {
        const furthest_extremity = @max(
            @abs(mouse_bounds.max.x),
            @abs(mouse_bounds.max.y),
            @abs(mouse_bounds.max.z),
            @abs(mouse_bounds.min.x),
            @abs(mouse_bounds.min.y),
            @abs(mouse_bounds.min.z),
        );
        // Give some extra margin
        break :blk furthest_extremity + 0.1;
    };
    defer rl.unload_model(mouse_model);

    var camera = rl.Camera_3d{
        .fovy = 60,
        // TODO: predefined vectors for up, down, left, right, forwards, backwards
        .up = rm.Vector3f.init(0, 1, 0),
        .projection = .PERSPECTIVE,
        .position = rm.Vector3f.init(0, 0.5, 0.5),
        .target = mouse_position,
    };
    var camera_zoom: f32 = 1.0;
    const max_camera_zoom = 3;
    while (!rl.window_should_close()) {
        rl.begin_drawing();
        defer rl.end_drawing();

        const debug_font_size = 16;
        const debug_text_pos = rm.Vector2i.init(5, 5);

        if (rl.is_key_pressed(.TAB)) {
            if (cursor_enabled) {
                rl.disable_cursor();
                cursor_enabled = false;
            } else {
                rl.enable_cursor();
                cursor_enabled = true;
            }
        }

        if (rl.is_key_pressed(.F1)) {
            show_debug_overlay = !show_debug_overlay;
        }

        // TODO: swizzle function
        // drop the vertical component of the camera direction so we can get the camera's direction just along the xz plane
        const camera_dir_unnormalized = camera.target.sub_elements(camera.position);
        const camera_dir = camera_dir_unnormalized.normalize();
        const camera_forward_2d = rm.Vector3f.init(camera_dir_unnormalized.x, 0, camera_dir_unnormalized.z).normalize();
        const camera_right_2d = camera_forward_2d.cross_product(camera.up).normalize();

        // subtract 90 to correct for 0 degrees being to the right, whereas we want 0 degrees to be considered "no rotation" and thus camera forward,
        // in the z direction
        // z is negated since z is positive coming out of the screen (backwards) and negative going into the screen (forwards)
        const camera_yaw = std.math.radiansToDegrees(std.math.atan2(-camera_forward_2d.z, camera_forward_2d.x)) - 90.0;

        const mouse_speed = 0.3; // meters per second
        var movement = rm.Vector3f.zero();
        if (rl.is_key_down(.W)) {
            movement.z += 1;
        }
        if (rl.is_key_down(.S)) {
            movement.z -= 1;
        }
        if (rl.is_key_down(.A)) {
            movement.x -= 1;
        }
        if (rl.is_key_down(.D)) {
            movement.x += 1;
        }
        if (!movement.is_zero()) {
            const z_movement = camera_forward_2d.scale(movement.z);
            const x_movement = camera_right_2d.scale(movement.x);
            const movement_2d = x_movement.add_elements(z_movement);
            mouse_position = mouse_position.add_elements(movement_2d.normalize().scale(dt * mouse_speed));
        }

        const mouse_wheel = rl.get_mouse_wheel_move();
        // TODO: make sure its possible to get back perfectly to neutral/default zoom
        if (mouse_wheel > 0) {
            camera_zoom /= 1.1;
        } else if (mouse_wheel < 0) {
            camera_zoom *= 1.1;
        }
        if (camera_zoom > max_camera_zoom) {
            camera_zoom = max_camera_zoom;
        }
        if (camera_zoom < mouse_closest_zoom_radius) {
            camera_zoom = mouse_closest_zoom_radius;
        }

        camera.target = mouse_position;
        camera.position = mouse_position.sub_elements(camera_dir.scale(camera_zoom));
        if (!cursor_enabled) {
            update_camera(&camera);
        }

        rl.clear_background(.DARKGRAY);

        {
            rl.begin_mode_3d(camera);
            defer rl.end_mode_3d();

            const plane_size = 2;
            // offset the plane ever so slightly below ground level so the grid is cleanly above it
            rl.draw_plane(rm.Vector3f.init(0, -0.01, 0), rm.Vector2f.init(plane_size, plane_size), .DARKBROWN);
            const grid_subdivisions = 2;

            if (show_debug_overlay) {
                rl.draw_grid(plane_size * grid_subdivisions, 1.0 / @as(comptime_float, grid_subdivisions));

                const debug_camera_forward_end = mouse_position.add_elements(camera_forward_2d);
                const debug_camera_right_end = mouse_position.add_elements(camera_right_2d);
                rl.draw_line_3d(mouse_position, debug_camera_forward_end, .GREEN);
                rl.draw_line_3d(mouse_position, debug_camera_right_end, .RED);
            }
            rl.draw_model_ex(mouse_model, mouse_position, camera.up, camera_yaw, rm.Vector3f.one(), .WHITE);
        }

        if (show_debug_overlay) {
            rl.draw_text(text_format("Camera Pos: {f}", .{camera.position}), debug_text_pos.x, debug_text_pos.y + 0 * debug_font_size, debug_font_size, .WHITE);
            rl.draw_text(text_format("Camera Tgt: {f}", .{camera.target}), debug_text_pos.x, debug_text_pos.y + 1 * debug_font_size, debug_font_size, .WHITE);
            rl.draw_text(text_format("Camera Dir: {f}", .{camera_forward_2d}), debug_text_pos.x, debug_text_pos.y + 2 * debug_font_size, debug_font_size, .WHITE);
            rl.draw_text(text_format("Camera Yaw: {d:0.3}", .{camera_yaw}), debug_text_pos.x, debug_text_pos.y + 3 * debug_font_size, debug_font_size, .WHITE);
        }
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
}
