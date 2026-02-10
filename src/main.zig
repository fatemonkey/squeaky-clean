const std = @import("std");
const rl = @import("rayzig");
const gl = rl.gl;
const rm = rl.math;
const options = @import("options");

const log = std.log.scoped(.game);

pub fn main() !void {
    var heap = std.heap.DebugAllocator(.{}).init;
    defer _ = heap.deinit();
    const permanent_allocator = heap.allocator();

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

    const dirtiness_shader = rl.load_shader(null, "assets/texture_blend_mask.frag.glsl");
    defer rl.unload_shader(dirtiness_shader);

    const floor_texture = rl.load_texture("assets/thirdparty/wood5.png");
    defer rl.unload_texture(floor_texture);

    const dirt_texture = rl.load_texture("assets/thirdparty/Dirt_03.png");
    defer rl.unload_texture(dirt_texture);

    const mask_image_data = try permanent_allocator.alloc(u8, 256 * 256);
    defer permanent_allocator.free(mask_image_data);
    @memset(mask_image_data, 150);
    var mask_image = blk: {
        const mask_size = 256;
        break :blk rl.Image{
            .width = mask_size,
            .height = mask_size,
            .mipmaps = 1,
            .format = .UNCOMPRESSED_GRAYSCALE,
            .data = mask_image_data.ptr,
        };
    };
    const mask_texture = rl.load_texture_from_image(mask_image);

    const floor_texture_location = rl.get_shader_location(dirtiness_shader, "texture_a") orelse @panic("unhandled");
    const dirt_texture_location = rl.get_shader_location(dirtiness_shader, "texture_b") orelse @panic("unhandled");
    const mask_texture_location = rl.get_shader_location(dirtiness_shader, "texture_mask") orelse @panic("unhandled");

    const mouse_model = rl.load_model("assets/mouse7.glb");
    const mouse_bounds = rl.get_model_bounding_box(mouse_model);
    var mouse_position = rm.Vector3f.init(0, -mouse_bounds.min.y, 0);
    var mouse_yaw: f32 = 0;
    const mouse_speed = 0.3; // meters per second
    const mouse_turn_rate = 270.0; // degrees per second
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
    const camera_zoom_speed = 1.15;

    // offset the plane ever so slightly below ground level so the grid can be drawn cleanly above it
    const floor_position = rm.Vector3f.init(0, -0.001, 0);
    const floor_size = 2.0;
    // TODO: rectangle functions
    const floor_left = floor_position.x - (floor_size / 2);
    const floor_right = floor_position.x + (floor_size / 2);
    const floor_top = floor_position.z - (floor_size / 2);
    const floor_bottom = floor_position.z + (floor_size / 2);
    const floor_top_left_3d = rm.Vector3f.init(floor_left, floor_position.y, floor_top);

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
        const camera_yaw = normalize_angle(std.math.radiansToDegrees(std.math.atan2(-camera_forward_2d.z, camera_forward_2d.x)) - 90.0);

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
            const movement_2d = x_movement.add_elements(z_movement).normalize();
            mouse_position = mouse_position.add_elements(movement_2d.scale(dt * mouse_speed));

            // we want the mouse to face the direction of movement
            const mouse_yaw_target = std.math.radiansToDegrees(std.math.atan2(-movement_2d.z, movement_2d.x)) - 90.0;
            const needed_turn = closest_angle_distance(mouse_yaw_target, mouse_yaw);
            const turn_capability = mouse_turn_rate * dt;
            const delta = std.math.sign(needed_turn) * @min(turn_capability, @abs(needed_turn));
            mouse_yaw = normalize_angle(mouse_yaw + delta);
        }

        const mouse_floor_position_2d = rm.Vector3f.init(mouse_position.x - floor_left, 0, mouse_position.z - floor_top).scale(1.0 / floor_size);
        // TODO: rectangle functions
        const mouse_is_on_floor =
            mouse_floor_position_2d.x >= 0 and mouse_floor_position_2d.x <= 1 and mouse_floor_position_2d.z >= 0 and mouse_floor_position_2d.z <= 1;

        if (mouse_is_on_floor) {
            // Clean the mouse's spot on the image dirt mask
            const x: u32 = @intFromFloat(mouse_floor_position_2d.x * @as(f32, @floatFromInt(mask_image.width)));
            const y = mask_image.height - @as(u32, @intFromFloat(mouse_floor_position_2d.z * @as(f32, @floatFromInt(mask_image.height))));
            // TODO: account for alpha, don't just wipe the dirt completely off, allow partial cleaning
            rl.image_draw_circle(&mask_image, x, y, 8, .BLANK);
            // TODO: i'd prefer to use update_texture_rec to only update the part that's changing, but we can't set the stride
            // to tell it how to read from a subregion of the source image...
            rl.update_texture(mask_texture, mask_image.data.?);
        }

        const mouse_wheel = rl.get_mouse_wheel_move();
        // TODO: make sure its possible to get back perfectly to neutral/default zoom
        if (mouse_wheel > 0) {
            camera_zoom /= camera_zoom_speed;
        } else if (mouse_wheel < 0) {
            camera_zoom *= camera_zoom_speed;
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

            {
                rl.begin_shader_mode(dirtiness_shader);
                defer rl.end_shader_mode();

                const tr = rm.Vector3f.init(floor_right, floor_position.y, floor_top);
                const br = rm.Vector3f.init(floor_right, floor_position.y, floor_bottom);
                const bl = rm.Vector3f.init(floor_left, floor_position.y, floor_bottom);

                // The texture is multiplied by this tint
                const brightness = 0.5;
                gl.rlColor4f(brightness, brightness, brightness, 1.0);

                rl.set_shader_value_texture(dirtiness_shader, floor_texture_location, floor_texture);
                rl.set_shader_value_texture(dirtiness_shader, dirt_texture_location, dirt_texture);
                rl.set_shader_value_texture(dirtiness_shader, mask_texture_location, mask_texture);

                draw_3d_quad(floor_top_left_3d, bl, br, tr);
            }

            if (show_debug_overlay) {
                // where the mouse is relative to the floor
                if (mouse_is_on_floor) {
                    rl.draw_sphere(floor_top_left_3d.add_elements(mouse_floor_position_2d.scale(floor_size)), 0.01, .RED);
                }

                const grid_subdivisions = 2;
                rl.draw_grid(floor_size * grid_subdivisions, 1.0 / @as(comptime_float, grid_subdivisions));

                const debug_camera_forward_end = mouse_position.add_elements(camera_forward_2d);
                const debug_camera_right_end = mouse_position.add_elements(camera_right_2d);
                rl.draw_line_3d(mouse_position, debug_camera_forward_end, .GREEN);
                rl.draw_line_3d(mouse_position, debug_camera_right_end, .RED);
            }

            rl.draw_model_ex(mouse_model, mouse_position, camera.up, mouse_yaw, rm.Vector3f.one(), .WHITE);
        }

        if (show_debug_overlay) {
            rl.draw_text(text_format("Camera Pos: {f}", .{camera.position}), debug_text_pos.x, debug_text_pos.y + 0 * debug_font_size, debug_font_size, .WHITE);
            rl.draw_text(text_format("Camera Tgt: {f}", .{camera.target}), debug_text_pos.x, debug_text_pos.y + 1 * debug_font_size, debug_font_size, .WHITE);
            rl.draw_text(text_format("Camera Dir: {f}", .{camera_forward_2d}), debug_text_pos.x, debug_text_pos.y + 2 * debug_font_size, debug_font_size, .WHITE);
            rl.draw_text(text_format("Camera Yaw: {d:0.3}", .{camera_yaw}), debug_text_pos.x, debug_text_pos.y + 3 * debug_font_size, debug_font_size, .WHITE);
            rl.draw_text(text_format("Mouse Yaw: {d:0.3}", .{mouse_yaw}), debug_text_pos.x, debug_text_pos.y + 4 * debug_font_size, debug_font_size, .WHITE);
            rl.draw_text(text_format("Mouse Floor Pos: {f}", .{mouse_floor_position_2d}), debug_text_pos.x, debug_text_pos.y + 5 * debug_font_size, debug_font_size, .WHITE);
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

// Given two angles (in degrees), returns the smaller of the two distances between them around a circle
fn closest_angle_distance(a: f32, b: f32) f32 {
    return normalize_angle(a - b);
}

// Given an angle in degrees, normalizes it into the range -180 to 180
fn normalize_angle(angle: f32) f32 {
    return @mod(angle + 180, 360) - 180;
}

// tl = top left
// bl = bottom left
// br = bottom right
// tr = top right
fn draw_3d_quad(tl: rm.Vector3f, bl: rm.Vector3f, br: rm.Vector3f, tr: rm.Vector3f) void {
    gl.rlBegin(gl.RL_QUADS);
    defer gl.rlEnd();

    // "BL" triangle
    gl.rlTexCoord2f(0, 1);
    gl.rlVertex3f(tl.x, tl.y, tl.z);

    gl.rlTexCoord2f(0, 0);
    gl.rlVertex3f(bl.x, bl.y, bl.z);

    gl.rlTexCoord2f(1, 0);
    gl.rlVertex3f(br.x, br.y, br.z);

    // "TR" triangle
    gl.rlTexCoord2f(1, 1);
    gl.rlVertex3f(tr.x, tr.y, tr.z);
}
