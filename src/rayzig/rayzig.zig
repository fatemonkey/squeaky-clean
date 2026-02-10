const std = @import("std");
const rl = @import("raylib");
pub const math = @import("math.zig");

// TODO: wrapper around this instead of just exporting it
pub const gl = @import("rlgl");

// TODO: should we make all rayzig structures binary compatibile with raylib so we can easily just cast between them...?

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    const This = @This();

    pub const LIGHTGRAY = This{ .r = rl.LIGHTGRAY.r, .g = rl.LIGHTGRAY.g, .b = rl.LIGHTGRAY.b, .a = rl.LIGHTGRAY.a };
    pub const GRAY = This{ .r = rl.GRAY.r, .g = rl.GRAY.g, .b = rl.GRAY.b, .a = rl.GRAY.a };
    pub const DARKGRAY = This{ .r = rl.DARKGRAY.r, .g = rl.DARKGRAY.g, .b = rl.DARKGRAY.b, .a = rl.DARKGRAY.a };
    pub const YELLOW = This{ .r = rl.YELLOW.r, .g = rl.YELLOW.g, .b = rl.YELLOW.b, .a = rl.YELLOW.a };
    pub const GOLD = This{ .r = rl.GOLD.r, .g = rl.GOLD.g, .b = rl.GOLD.b, .a = rl.GOLD.a };
    pub const ORANGE = This{ .r = rl.ORANGE.r, .g = rl.ORANGE.g, .b = rl.ORANGE.b, .a = rl.ORANGE.a };
    pub const PINK = This{ .r = rl.PINK.r, .g = rl.PINK.g, .b = rl.PINK.b, .a = rl.PINK.a };
    pub const RED = This{ .r = rl.RED.r, .g = rl.RED.g, .b = rl.RED.b, .a = rl.RED.a };
    pub const MAROON = This{ .r = rl.MAROON.r, .g = rl.MAROON.g, .b = rl.MAROON.b, .a = rl.MAROON.a };
    pub const GREEN = This{ .r = rl.GREEN.r, .g = rl.GREEN.g, .b = rl.GREEN.b, .a = rl.GREEN.a };
    pub const LIME = This{ .r = rl.LIME.r, .g = rl.LIME.g, .b = rl.LIME.b, .a = rl.LIME.a };
    pub const DARKGREEN = This{ .r = rl.DARKGREEN.r, .g = rl.DARKGREEN.g, .b = rl.DARKGREEN.b, .a = rl.DARKGREEN.a };
    pub const SKYBLUE = This{ .r = rl.SKYBLUE.r, .g = rl.SKYBLUE.g, .b = rl.SKYBLUE.b, .a = rl.SKYBLUE.a };
    pub const BLUE = This{ .r = rl.BLUE.r, .g = rl.BLUE.g, .b = rl.BLUE.b, .a = rl.BLUE.a };
    pub const DARKBLUE = This{ .r = rl.DARKBLUE.r, .g = rl.DARKBLUE.g, .b = rl.DARKBLUE.b, .a = rl.DARKBLUE.a };
    pub const PURPLE = This{ .r = rl.PURPLE.r, .g = rl.PURPLE.g, .b = rl.PURPLE.b, .a = rl.PURPLE.a };
    pub const VIOLET = This{ .r = rl.VIOLET.r, .g = rl.VIOLET.g, .b = rl.VIOLET.b, .a = rl.VIOLET.a };
    pub const DARKPURPLE = This{ .r = rl.DARKPURPLE.r, .g = rl.DARKPURPLE.g, .b = rl.DARKPURPLE.b, .a = rl.DARKPURPLE.a };
    pub const BEIGE = This{ .r = rl.BEIGE.r, .g = rl.BEIGE.g, .b = rl.BEIGE.b, .a = rl.BEIGE.a };
    pub const BROWN = This{ .r = rl.BROWN.r, .g = rl.BROWN.g, .b = rl.BROWN.b, .a = rl.BROWN.a };
    pub const DARKBROWN = This{ .r = rl.DARKBROWN.r, .g = rl.DARKBROWN.g, .b = rl.DARKBROWN.b, .a = rl.DARKBROWN.a };
    pub const WHITE = This{ .r = rl.WHITE.r, .g = rl.WHITE.g, .b = rl.WHITE.b, .a = rl.WHITE.a };
    pub const BLACK = This{ .r = rl.BLACK.r, .g = rl.BLACK.g, .b = rl.BLACK.b, .a = rl.BLACK.a };
    pub const BLANK = This{ .r = rl.BLANK.r, .g = rl.BLANK.g, .b = rl.BLANK.b, .a = rl.BLANK.a };
    pub const MAGENTA = This{ .r = rl.MAGENTA.r, .g = rl.MAGENTA.g, .b = rl.MAGENTA.b, .a = rl.MAGENTA.a };
    pub const RAYWHITE = This{ .r = rl.RAYWHITE.r, .g = rl.RAYWHITE.g, .b = rl.RAYWHITE.b, .a = rl.RAYWHITE.a };

    // 0-255
    pub fn init_u8(r: u8, g: u8, b: u8, a: u8) Color {
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    // Normalized from 0-1
    pub fn init_f32(r: f32, g: f32, b: f32, a: f32) Color {
        const rc = std.math.clamp(r, 0.0, 1.0);
        const gc = std.math.clamp(g, 0.0, 1.0);
        const bc = std.math.clamp(b, 0.0, 1.0);
        const ac = std.math.clamp(a, 0.0, 1.0);
        const ri: u8 = @intFromFloat(rc * 255.0);
        const gi: u8 = @intFromFloat(gc * 255.0);
        const bi: u8 = @intFromFloat(bc * 255.0);
        const ai: u8 = @intFromFloat(ac * 255.0);
        return init_u8(ri, gi, bi, ai);
    }

    pub fn random(rng: std.Random) Color {
        const r = rng.intRangeAtMost(u8, 0, 255);
        const g = rng.intRangeAtMost(u8, 0, 255);
        const b = rng.intRangeAtMost(u8, 0, 255);
        const a = 255;
        return init_u8(r, g, b, a);
    }

    fn to_rl(this: This) rl.Color {
        return .{ .r = this.r, .g = this.g, .b = this.b, .a = this.a };
    }
};

pub const Key = enum(rl.KeyboardKey) {
    NULL = rl.KEY_NULL,
    APOSTROPHE = rl.KEY_APOSTROPHE,
    COMMA = rl.KEY_COMMA,
    MINUS = rl.KEY_MINUS,
    PERIOD = rl.KEY_PERIOD,
    SLASH = rl.KEY_SLASH,
    ZERO = rl.KEY_ZERO,
    ONE = rl.KEY_ONE,
    TWO = rl.KEY_TWO,
    THREE = rl.KEY_THREE,
    FOUR = rl.KEY_FOUR,
    FIVE = rl.KEY_FIVE,
    SIX = rl.KEY_SIX,
    SEVEN = rl.KEY_SEVEN,
    EIGHT = rl.KEY_EIGHT,
    NINE = rl.KEY_NINE,
    SEMICOLON = rl.KEY_SEMICOLON,
    EQUAL = rl.KEY_EQUAL,
    A = rl.KEY_A,
    B = rl.KEY_B,
    C = rl.KEY_C,
    D = rl.KEY_D,
    E = rl.KEY_E,
    F = rl.KEY_F,
    G = rl.KEY_G,
    H = rl.KEY_H,
    I = rl.KEY_I,
    J = rl.KEY_J,
    K = rl.KEY_K,
    L = rl.KEY_L,
    M = rl.KEY_M,
    N = rl.KEY_N,
    O = rl.KEY_O,
    P = rl.KEY_P,
    Q = rl.KEY_Q,
    R = rl.KEY_R,
    S = rl.KEY_S,
    T = rl.KEY_T,
    U = rl.KEY_U,
    V = rl.KEY_V,
    W = rl.KEY_W,
    X = rl.KEY_X,
    Y = rl.KEY_Y,
    Z = rl.KEY_Z,
    LEFT_BRACKET = rl.KEY_LEFT_BRACKET,
    BACKSLASH = rl.KEY_BACKSLASH,
    RIGHT_BRACKET = rl.KEY_RIGHT_BRACKET,
    GRAVE = rl.KEY_GRAVE,
    SPACE = rl.KEY_SPACE,
    ESCAPE = rl.KEY_ESCAPE,
    ENTER = rl.KEY_ENTER,
    TAB = rl.KEY_TAB,
    BACKSPACE = rl.KEY_BACKSPACE,
    INSERT = rl.KEY_INSERT,
    DELETE = rl.KEY_DELETE,
    RIGHT = rl.KEY_RIGHT,
    LEFT = rl.KEY_LEFT,
    DOWN = rl.KEY_DOWN,
    UP = rl.KEY_UP,
    PAGE_UP = rl.KEY_PAGE_UP,
    PAGE_DOWN = rl.KEY_PAGE_DOWN,
    HOME = rl.KEY_HOME,
    END = rl.KEY_END,
    CAPS_LOCK = rl.KEY_CAPS_LOCK,
    SCROLL_LOCK = rl.KEY_SCROLL_LOCK,
    NUM_LOCK = rl.KEY_NUM_LOCK,
    PRINT_SCREEN = rl.KEY_PRINT_SCREEN,
    PAUSE = rl.KEY_PAUSE,
    F1 = rl.KEY_F1,
    F2 = rl.KEY_F2,
    F3 = rl.KEY_F3,
    F4 = rl.KEY_F4,
    F5 = rl.KEY_F5,
    F6 = rl.KEY_F6,
    F7 = rl.KEY_F7,
    F8 = rl.KEY_F8,
    F9 = rl.KEY_F9,
    F10 = rl.KEY_F10,
    F11 = rl.KEY_F11,
    F12 = rl.KEY_F12,
    LEFT_SHIFT = rl.KEY_LEFT_SHIFT,
    LEFT_CONTROL = rl.KEY_LEFT_CONTROL,
    LEFT_ALT = rl.KEY_LEFT_ALT,
    LEFT_SUPER = rl.KEY_LEFT_SUPER,
    RIGHT_SHIFT = rl.KEY_RIGHT_SHIFT,
    RIGHT_CONTROL = rl.KEY_RIGHT_CONTROL,
    RIGHT_ALT = rl.KEY_RIGHT_ALT,
    RIGHT_SUPER = rl.KEY_RIGHT_SUPER,
    KB_MENU = rl.KEY_KB_MENU,
    KP_0 = rl.KEY_KP_0,
    KP_1 = rl.KEY_KP_1,
    KP_2 = rl.KEY_KP_2,
    KP_3 = rl.KEY_KP_3,
    KP_4 = rl.KEY_KP_4,
    KP_5 = rl.KEY_KP_5,
    KP_6 = rl.KEY_KP_6,
    KP_7 = rl.KEY_KP_7,
    KP_8 = rl.KEY_KP_8,
    KP_9 = rl.KEY_KP_9,
    KP_DECIMAL = rl.KEY_KP_DECIMAL,
    KP_DIVIDE = rl.KEY_KP_DIVIDE,
    KP_MULTIPLY = rl.KEY_KP_MULTIPLY,
    KP_SUBTRACT = rl.KEY_KP_SUBTRACT,
    KP_ADD = rl.KEY_KP_ADD,
    KP_ENTER = rl.KEY_KP_ENTER,
    KP_EQUAL = rl.KEY_KP_EQUAL,
    BACK = rl.KEY_BACK,
    MENU = rl.KEY_MENU,
    VOLUME_UP = rl.KEY_VOLUME_UP,
    VOLUME_DOWN = rl.KEY_VOLUME_DOWN,

    fn to_rl(this: @This()) rl.KeyboardKey {
        return @intFromEnum(this);
    }
};

// TODO: nochicken store the fields instead of byte array
pub const Model = extern struct {
    // transform: Matrix,
    // mesh_count: c_int,
    // material_count: c_int,
    // meshes: [*c]Mesh,
    // materials: [*c]Material,
    // mesh_material: [*c]c_int,
    // bone_count: c_int,
    // bones: [*c]BoneInfo,
    // bind_pose: [*c]Transform,

    bytes: [@sizeOf(rl.Model)]u8,

    pub fn to_rl(this: @This()) rl.Model {
        return @bitCast(this);
    }
};

// TODO: should this store C types or Zig types?
pub const Texture_2d = extern struct {
    id: c_uint,
    width: c_int,
    height: c_int,
    mipmaps: c_int,
    format: c_int,

    pub fn to_rl(this: @This()) rl.Texture2D {
        return @bitCast(this);
    }
};

pub const Camera_Projection = enum(rl.CameraProjection) {
    PERSPECTIVE = rl.CAMERA_PERSPECTIVE,
    ORTHOGRAPHIC = rl.CAMERA_ORTHOGRAPHIC,

    fn to_rl(this: @This()) rl.CameraProjection {
        return @intFromEnum(this);
    }
};

pub const Camera_Mode = enum(rl.CameraMode) {
    CUSTOM = rl.CAMERA_CUSTOM, // Camera custom, controlled by user (UpdateCamera() does nothing)
    FREE = rl.CAMERA_FREE,
    ORBITAL = rl.CAMERA_ORBITAL, // Camera orbital, around target, zoom supported
    FIRST_PERSON = rl.CAMERA_FIRST_PERSON,
    THIRD_PERSON = rl.CAMERA_THIRD_PERSON,

    fn to_rl(this: @This()) rl.CameraMode {
        return @intFromEnum(this);
    }
};

pub const Camera_3d = extern struct {
    position: math.Vector3f,
    target: math.Vector3f,
    up: math.Vector3f,
    // TODO: helper for converting between vertical and horizontal fov
    fovy: f32,
    projection: Camera_Projection,

    fn to_rl(this: *const Camera_3d) *const rl.Camera3D {
        return @ptrCast(this);
    }

    fn to_rl_mut(this: *Camera_3d) *rl.Camera3D {
        return @ptrCast(this);
    }
};

pub const Bounding_Box = extern struct {
    min: math.Vector3f,
    max: math.Vector3f,
};

// TODO: should this store C types or Zig types?
pub const Shader = extern struct {
    id: c_uint,
    locs: [*c]c_int,

    fn to_rl(this: @This()) rl.Shader {
        return @bitCast(this);
    }
};

pub const Pixel_Format = enum(rl.PixelFormat) {
    UNCOMPRESSED_GRAYSCALE = 1,
    UNCOMPRESSED_GRAY_ALPHA = 2,
    UNCOMPRESSED_R5G6B5 = 3,
    UNCOMPRESSED_R8G8B8 = 4,
    UNCOMPRESSED_R5G5B5A1 = 5,
    UNCOMPRESSED_R4G4B4A4 = 6,
    UNCOMPRESSED_R8G8B8A8 = 7,
    UNCOMPRESSED_R32 = 8,
    UNCOMPRESSED_R32G32B32 = 9,
    UNCOMPRESSED_R32G32B32A32 = 10,
    UNCOMPRESSED_R16 = 11,
    UNCOMPRESSED_R16G16B16 = 12,
    UNCOMPRESSED_R16G16B16A16 = 13,
    COMPRESSED_DXT1_RGB = 14,
    COMPRESSED_DXT1_RGBA = 15,
    COMPRESSED_DXT3_RGBA = 16,
    COMPRESSED_DXT5_RGBA = 17,
    COMPRESSED_ETC1_RGB = 18,
    COMPRESSED_ETC2_RGB = 19,
    COMPRESSED_ETC2_EAC_RGBA = 20,
    COMPRESSED_PVRT_RGB = 21,
    COMPRESSED_PVRT_RGBA = 22,
    COMPRESSED_ASTC_4x4_RGBA = 23,
    COMPRESSED_ASTC_8x8_RGBA = 24,
};

// TODO: should this store C types or Zig types?
pub const Image = extern struct {
    data: ?*anyopaque,
    width: u32,
    height: u32,
    mipmaps: u32,
    format: Pixel_Format,

    fn to_rl(this: *const @This()) *const rl.Image {
        return @ptrCast(this);
    }

    fn to_rl_mut(this: *@This()) *rl.Image {
        return @ptrCast(this);
    }
};

// TODO: should this be moved to the math module?
pub const Rectangle = extern struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    fn to_rl(this: @This()) rl.Rectangle {
        return @bitCast(this);
    }
};

comptime {
    const assert = std.debug.assert;

    assert(@sizeOf(Camera_3d) == @sizeOf(rl.Camera3D));
    assert(@sizeOf(Model) == @sizeOf(rl.Model));
    assert(@sizeOf(Texture_2d) == @sizeOf(rl.Texture2D));
    assert(@sizeOf(Shader) == @sizeOf(rl.Shader));
    assert(@sizeOf(Image) == @sizeOf(rl.Image));
    assert(@sizeOf(Rectangle) == @sizeOf(rl.Rectangle));
    assert(@sizeOf(Bounding_Box) == @sizeOf(rl.BoundingBox));
}

pub fn init_window(width: u32, height: u32, title: [:0]const u8) void {
    rl.InitWindow(@intCast(width), @intCast(height), title);
}

pub fn close_window() void {
    rl.CloseWindow();
}

pub fn window_should_close() bool {
    return rl.WindowShouldClose();
}

pub fn set_target_fps(fps: u32) void {
    rl.SetTargetFPS(@intCast(fps));
}

pub fn get_frame_time() f32 {
    return rl.GetFrameTime();
}

pub fn begin_drawing() void {
    rl.BeginDrawing();
}

pub fn end_drawing() void {
    rl.EndDrawing();
}

pub fn clear_background(color: Color) void {
    rl.ClearBackground(color.to_rl());
}

// TODO: support simple text formatting
// pub fn text_format(format: [*c]const u8, ...) callconv(.{ .x86_64_win = .{} }) [*c]const u8 {
//     const args = @cVaStart();
//     defer @cVaEnd(args);

//     const result = rl.TextFormat(format, args);
//     return std.mem.span(result);
// }

pub fn draw_text(text: [:0]const u8, x: i32, y: i32, font_size: u32, color: Color) void {
    rl.DrawText(text, x, y, @intCast(font_size), color.to_rl());
}

pub fn draw_rectangle(x: f32, y: f32, width: f32, height: f32, color: Color) void {
    rl.DrawRectangleV(.{ .x = x, .y = y }, .{ .x = width, .y = height }, color.to_rl());
}

pub fn draw_rectangle_v(position: math.Vector2f, size: math.Vector2f, color: Color) void {
    rl.DrawRectangleV(position.to_rl(), size.to_rl(), color.to_rl());
}

pub fn draw_sphere(center: math.Vector3f, radius: f32, color: Color) void {
    rl.DrawSphere(center.to_rl(), radius, color.to_rl());
}

pub fn draw_plane(center: math.Vector3f, size: math.Vector2f, color: Color) void {
    rl.DrawPlane(center.to_rl(), size.to_rl(), color.to_rl());
}

pub fn draw_grid(slices: u32, spacing: f32) void {
    rl.DrawGrid(@intCast(slices), spacing);
}

pub fn draw_line_3d(start: math.Vector3f, end: math.Vector3f, color: Color) void {
    rl.DrawLine3D(start.to_rl(), end.to_rl(), color.to_rl());
}

pub fn is_key_pressed(key: Key) bool {
    return rl.IsKeyPressed(@intCast(key.to_rl()));
}

pub fn is_key_down(key: Key) bool {
    return rl.IsKeyDown(@intCast(key.to_rl()));
}

pub fn is_key_pressed_repeating(key: Key) bool {
    return rl.IsKeyPressedRepeat(@intCast(key.to_rl()));
}

pub fn is_key_released(key: Key) bool {
    return rl.IsKeyReleased(@intCast(key.to_rl()));
}

pub fn is_key_up(key: Key) bool {
    return rl.IsKeyUp(@intCast(key.to_rl()));
}

pub fn get_mouse_wheel_move() f32 {
    return rl.GetMouseWheelMove();
}

pub fn begin_mode_3d(camera: Camera_3d) void {
    rl.BeginMode3D(camera.to_rl().*);
}

pub fn end_mode_3d() void {
    rl.EndMode3D();
}

pub fn load_texture(path: [:0]const u8) Texture_2d {
    const texture = rl.LoadTexture(path);
    return @bitCast(texture);
}

pub fn load_texture_from_image(image: Image) Texture_2d {
    const texture = rl.LoadTextureFromImage(image.to_rl().*);
    return @bitCast(texture);
}

pub fn unload_texture(texture: Texture_2d) void {
    rl.UnloadTexture(texture.to_rl());
}

pub fn update_texture(texture: Texture_2d, pixels: *anyopaque) void {
    rl.UpdateTexture(texture.to_rl(), pixels);
}

pub fn update_texture_rec(texture: Texture_2d, rectangle: Rectangle, pixels: *anyopaque) void {
    rl.UpdateTextureRec(texture.to_rl(), rectangle.to_rl(), pixels);
}

pub fn load_shader(vertex_shader_path: ?[:0]const u8, fragment_shader_path: ?[:0]const u8) Shader {
    const shader = rl.LoadShader(vertex_shader_path orelse null, fragment_shader_path orelse null);
    return @bitCast(shader);
}

pub fn gen_image_color(width: u32, height: u32, color: Color) Image {
    const image = rl.GenImageColor(@intCast(width), @intCast(height), color.to_rl());
    return @bitCast(image);
}

pub fn image_draw_circle(image: *Image, center_x: u32, center_y: u32, radius: u32, color: Color) void {
    rl.ImageDrawCircle(image.to_rl_mut(), @intCast(center_x), @intCast(center_y), @intCast(radius), color.to_rl());
}

pub fn unload_shader(shader: Shader) void {
    rl.UnloadShader(shader.to_rl());
}

pub fn begin_shader_mode(shader: Shader) void {
    rl.BeginShaderMode(shader.to_rl());
}

pub fn end_shader_mode() void {
    rl.EndShaderMode();
}

pub fn get_shader_location(shader: Shader, uniform_name: [:0]const u8) ?u32 {
    const location = rl.GetShaderLocation(shader.to_rl(), uniform_name);
    if (location == -1) {
        return null;
    }
    return @bitCast(location);
}

pub fn set_shader_value_texture(shader: Shader, location: u32, texture: Texture_2d) void {
    rl.SetShaderValueTexture(shader.to_rl(), @bitCast(location), texture.to_rl());
}

pub fn load_model(path: [:0]const u8) Model {
    const model = rl.LoadModel(path);
    return @bitCast(model);
}

pub fn unload_model(model: Model) void {
    rl.UnloadModel(model.to_rl());
}

pub fn draw_model(model: Model, position: math.Vector3f, scale: f32, tint: Color) void {
    rl.DrawModel(model.to_rl(), position.to_rl(), scale, tint.to_rl());
}

pub fn draw_model_ex(model: Model, position: math.Vector3f, rotation_axis: math.Vector3f, rotation_angle: f32, scale: math.Vector3f, tint: Color) void {
    rl.DrawModelEx(model.to_rl(), position.to_rl(), rotation_axis.to_rl(), rotation_angle, scale.to_rl(), tint.to_rl());
}

pub fn get_model_bounding_box(model: Model) Bounding_Box {
    const bounding_box = rl.GetModelBoundingBox(model.to_rl());
    return @bitCast(bounding_box);
}

pub fn disable_cursor() void {
    rl.DisableCursor();
}

pub fn enable_cursor() void {
    rl.EnableCursor();
}

pub fn get_mouse_delta() math.Vector2f {
    const delta = rl.GetMouseDelta();
    return @bitCast(delta);
}

pub fn update_camera(camera: *Camera_3d, mode: Camera_Mode) void {
    rl.UpdateCamera(camera.to_rl_mut(), @intCast(mode.to_rl()));
}

// TODO: move functions from rcamera to separate module?

pub fn camera_move_to_target(camera: *Camera_3d, delta: f32) void {
    rl.CameraMoveToTarget(camera.to_rl_mut(), delta);
}

pub fn camera_yaw(camera: *Camera_3d, angle: f32, rotate_around_target: bool) void {
    rl.CameraYaw(camera.to_rl_mut(), angle, rotate_around_target);
}

pub fn camera_pitch(camera: *Camera_3d, angle: f32, lock_view: bool, rotate_around_target: bool, rotate_up: bool) void {
    rl.CameraPitch(camera.to_rl_mut(), angle, lock_view, rotate_around_target, rotate_up);
}
