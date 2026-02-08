const std = @import("std");
const rl = @import("raylib");
pub const math = @import("math.zig");

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

// TODO: nochicken extern
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

    // TODO: nochicken
    bytes: [@sizeOf(rl.Model)]u8,
};

pub const Camera_Projection = enum(rl.CameraProjection) {
    PERSPECTIVE = rl.CAMERA_PERSPECTIVE,
    ORTHOGRAPHIC = rl.CAMERA_ORTHOGRAPHIC,

    fn to_rl(this: @This()) rl.CameraProjection {
        return @intFromEnum(this);
    }
};

pub const Camera_Mode = enum(rl.CameraMode) {
    CAMERA_CUSTOM = rl.CAMERA_CUSTOM, // Camera custom, controlled by user (UpdateCamera() does nothing)
    CAMERA_FREE = rl.CAMERA_FREE,
    CAMERA_ORBITAL = rl.CAMERA_ORBITAL, // Camera orbital, around target, zoom supported
    CAMERA_FIRST_PERSON = rl.CAMERA_FIRST_PERSON,
    CAMERA_THIRD_PERSON = rl.CAMERA_THIRD_PERSON,

    fn to_rl(this: @This()) rl.CameraMode {
        return @intFromEnum(this);
    }
};

pub const Camera_3d = struct {
    position: math.Vector3f,
    target: math.Vector3f,
    up: math.Vector3f,
    fovy: f32,
    projection: Camera_Projection,

    fn to_rl(this: Camera_3d) rl.Camera3D {
        return .{
            // TODO: helper for converting between vertical and horizontal fov
            .fovy = this.fovy,
            .projection = @bitCast(this.projection.to_rl()),
            .position = this.position.to_rl(),
            .target = this.target.to_rl(),
            .up = this.up.to_rl(),
        };
    }
};

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

pub fn begin_drawing() void {
    rl.BeginDrawing();
}

pub fn end_drawing() void {
    rl.EndDrawing();
}

pub fn clear_background(color: Color) void {
    rl.ClearBackground(color.to_rl());
}

pub fn draw_rectangle(x: f32, y: f32, width: f32, height: f32, color: Color) void {
    rl.DrawRectangleV(.{ .x = x, .y = y }, .{ .x = width, .y = height }, color.to_rl());
}

pub fn draw_rectangle_v(position: math.Vector2f, size: math.Vector2f, color: Color) void {
    rl.DrawRectangleV(position.to_rl(), size.to_rl(), color.to_rl());
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

pub fn begin_mode_3d(camera: Camera_3d) void {
    rl.BeginMode3D(camera.to_rl());
}

pub fn end_mode_3d() void {
    rl.EndMode3D();
}

pub fn load_model(path: [:0]const u8) Model {
    const model = rl.LoadModel(path);
    // TODO: nochicken bitcast
    return @bitCast(model);
}

pub fn unload_model(model: Model) void {
    // TODO: nochicken bitcast
    rl.UnloadModel(@bitCast(model));
}

pub fn draw_model(model: Model, position: math.Vector3f, scale: f32, tint: Color) void {
    // TODO: nochicken bitcast
    rl.DrawModel(@bitCast(model), position.to_rl(), scale, tint.to_rl());
}
