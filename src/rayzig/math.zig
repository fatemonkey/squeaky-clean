const std = @import("std");
const rl = @import("raylib");

// TODO: union to allow referencing the fields as rgba, uv??, ...?
// TODO: is there a way to not need to duplicate the implementations of each function for Vector2, Vector3, and Vector4?

fn Vector2(Element_Type: type) type {
    return extern struct {
        x: Element_Type,
        y: Element_Type,

        const This = @This();
        const Type = Element_Type;
        const DIMENSIONS = 2;

        pub fn init(x: Element_Type, y: Element_Type) This {
            return .{ .x = x, .y = y };
        }

        pub fn zero() This {
            return init(0, 0);
        }

        pub fn one() This {
            return init(1, 1);
        }

        pub fn is_zero(this: This) bool {
            return this.x == 0 and this.y == 0;
        }

        pub fn add_elements(this: This, rhs: This) This {
            return init(this.x + rhs.x, this.y + rhs.y);
        }

        pub fn sub_elements(this: This, rhs: This) This {
            return init(this.x - rhs.x, this.y - rhs.y);
        }

        pub fn mul_elements(this: This, rhs: This) This {
            return init(this.x * rhs.x, this.y * rhs.y);
        }

        pub fn div_elements(this: This, rhs: This) This {
            return init(this.x / rhs.x, this.y / rhs.y);
        }

        pub fn add_value(this: This, value: Element_Type) This {
            return init(this.x + value, this.y + value);
        }

        pub fn sub_value(this: This, value: Element_Type) This {
            return this.add_value(-value);
        }

        pub fn scale(this: This, factor: Element_Type) This {
            return init(this.x * factor, this.y * factor);
        }

        pub fn negate(this: This) This {
            return this.scale(-1);
        }

        pub fn normalize(this: This) This {
            return this.scale(1 / this.length());
        }

        pub fn dot_product(this: This, rhs: This) Element_Type {
            return this.x * rhs.x + this.y * rhs.y;
        }

        pub fn cross_product(this: This, rhs: This) This {
            _ = this;
            _ = rhs;
            @compileError("todo");
            // TODO: cross product
        }

        pub fn length(this: This) Element_Type {
            return @sqrt(this.length2());
        }

        pub fn length2(this: This) Element_Type {
            return this.x * this.x + this.y * this.y;
        }

        pub fn distance(this: This, rhs: This) Element_Type {
            return @sqrt(this.distance2(rhs));
        }

        pub fn distance2(this: This, rhs: This) Element_Type {
            const dx = this.x - rhs.x;
            const dy = this.y - rhs.y;
            return dx * dx + dy * dy;
        }

        pub fn swizzle(this: This, mask: []const u8) This {
            _ = this;
            _ = mask;
            @compileError("todo");
            // TODO: swizzling
        }

        pub fn to_rl(this: This) rl.Vector2 {
            return .{ .x = this.x, .y = this.y };
        }

        pub fn as(this: This, T: type) T {
            if (T.DIMENSIONS != DIMENSIONS) {
                // TODO: should this be supported?
                @compileError("can't cast vector to a different size");
            }
            if (@typeInfo(T.Type) == .float and @typeInfo(Type) == .int) {
                return T.init(@floatFromInt(this.x), @floatFromInt(this.y));
            } else if (@typeInfo(T.Type) == .int and @typeInfo(Type) == .float) {
                return T.init(@intFromFloat(this.x), @intFromFloat(this.y));
            }

            @compileError("unrecognized type to cast to");
        }

        pub fn format(this: This, writer: *std.Io.Writer) !void {
            const precision = 3;
            try writer.print("Vector2{{x={d:0.[2]}, y={d:0.[2]}}}", .{ this.x, this.y, precision });
        }
    };
}

fn Vector3(Element_Type: type) type {
    return extern struct {
        x: Element_Type,
        y: Element_Type,
        z: Element_Type,

        const This = @This();
        const Type = Element_Type;
        const DIMENSIONS = 3;

        pub fn init(x: Element_Type, y: Element_Type, z: Element_Type) This {
            return .{ .x = x, .y = y, .z = z };
        }

        pub fn zero() This {
            return init(0, 0, 0);
        }

        pub fn one() This {
            return init(1, 1, 1);
        }

        pub fn is_zero(this: This) bool {
            return this.x == 0 and this.y == 0 and this.z == 0;
        }

        pub fn add_elements(this: This, rhs: This) This {
            return init(this.x + rhs.x, this.y + rhs.y, this.z + rhs.z);
        }

        pub fn sub_elements(this: This, rhs: This) This {
            return init(this.x - rhs.x, this.y - rhs.y, this.z - rhs.z);
        }

        pub fn mul_elements(this: This, rhs: This) This {
            return init(this.x * rhs.x, this.y * rhs.y, this.z * rhs.z);
        }

        pub fn div_elements(this: This, rhs: This) This {
            return init(this.x / rhs.x, this.y / rhs.y, this.z / rhs.z);
        }

        pub fn add_value(this: This, value: Element_Type) This {
            return init(this.x + value, this.y + value, this.z + value);
        }

        pub fn sub_value(this: This, value: Element_Type) This {
            return this.add_value(-value);
        }

        pub fn scale(this: This, factor: Element_Type) This {
            return init(this.x * factor, this.y * factor, this.z * factor);
        }

        pub fn negate(this: This) This {
            return this.scale(-1);
        }

        pub fn normalize(this: This) This {
            return this.scale(1 / this.length());
        }

        pub fn dot_product(this: This, rhs: This) Element_Type {
            return this.x * rhs.x + this.y * rhs.y + this.z * rhs.z;
        }

        pub fn cross_product(this: This, rhs: This) This {
            _ = this;
            _ = rhs;
            @compileError("todo");
        }

        pub fn length(this: This) Element_Type {
            return @sqrt(this.length2());
        }

        pub fn length2(this: This) Element_Type {
            return this.x * this.x + this.y * this.y + this.z * this.z;
        }

        pub fn distance(this: This, rhs: This) Element_Type {
            return @sqrt(this.distance2(rhs));
        }

        pub fn distance2(this: This, rhs: This) Element_Type {
            const dx = this.x - rhs.x;
            const dy = this.y - rhs.y;
            const dz = this.z - rhs.z;
            return dx * dx + dy * dy + dz * dz;
        }

        pub fn to_rl(this: This) rl.Vector3 {
            return .{ .x = this.x, .y = this.y, .z = this.z };
        }

        pub fn as(this: This, T: type) T {
            if (T.DIMENSIONS != this.DIMENSIONS) {
                // TODO: should this be supported?
                @compileError("can't cast vector to a different size");
            }
            if (@typeInfo(T.Type) == .Float and @typeInfo(this.Type) == .Int) {
                return T.init(@floatFromInt(this.x), @floatFromInt(this.y), @floatFromInt(this.z), @floatFromInt(this.w));
            } else if (@typeInfo(T.Type) == .Int and @typeInfo(this.Type) == .Float) {
                return T.init(@intFromFloat(this.x), @intFromFloat(this.y), @intFromFloat(this.z), @intFromFloat(this.w));
            }

            @compileError("unrecognized type to cast to");
        }

        pub fn format(this: This, writer: *std.Io.Writer) !void {
            const precision = 3;
            try writer.print("Vector3{{x={d:0.[3]}, y={d:0.[3]}, z={d:0.[3]}}}", .{ this.x, this.y, this.z, precision });
        }
    };
}

fn Vector4(Element_Type: type) type {
    return extern struct {
        x: Element_Type,
        y: Element_Type,
        z: Element_Type,
        w: Element_Type,

        const This = @This();
        const Type = Element_Type;
        const DIMENSIONS = 4;

        pub fn init(x: Element_Type, y: Element_Type, z: Element_Type, w: Element_Type) This {
            return .{ .x = x, .y = y, .z = z, .w = w };
        }

        pub fn zero() This {
            return init(0, 0, 0, 0);
        }

        pub fn one() This {
            return init(1, 1, 1, 1);
        }

        pub fn is_zero(this: This) bool {
            return this.x == 0 and this.y == 0 and this.z == 0 and this.w == 0;
        }

        pub fn add_elements(this: This, rhs: This) This {
            return init(this.x + rhs.x, this.y + rhs.y, this.z + rhs.z, this.w + rhs.w);
        }

        pub fn sub_elements(this: This, rhs: This) This {
            return init(this.x - rhs.x, this.y - rhs.y, this.z - rhs.z, this.w - rhs.w);
        }

        pub fn mul_elements(this: This, rhs: This) This {
            return init(this.x * rhs.x, this.y * rhs.y, this.z * rhs.z, this.w * rhs.w);
        }

        pub fn div_elements(this: This, rhs: This) This {
            return init(this.x / rhs.x, this.y / rhs.y, this.z / rhs.z, this.w / rhs.w);
        }

        pub fn add_value(this: This, value: Element_Type) This {
            return init(this.x + value, this.y + value, this.z + value, this.w + value);
        }

        pub fn sub_value(this: This, value: Element_Type) This {
            return this.add_value(-value);
        }

        pub fn scale(this: This, factor: Element_Type) This {
            return init(this.x * factor, this.y * factor, this.z * factor, this.w * factor);
        }

        pub fn negate(this: This) This {
            return this.scale(-1);
        }

        pub fn normalize(this: This) This {
            return this.scale(1 / this.length());
        }

        pub fn dot_product(this: This, rhs: This) Element_Type {
            return this.x * rhs.x + this.y * rhs.y + this.z * rhs.z + this.w * rhs.w;
        }

        pub fn cross_product(this: This, rhs: This) This {
            _ = this;
            _ = rhs;
            @compileError("todo");
        }

        pub fn length(this: This) Element_Type {
            return @sqrt(this.length2());
        }

        pub fn length2(this: This) Element_Type {
            return this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w;
        }

        pub fn distance(this: This, rhs: This) Element_Type {
            return @sqrt(this.distance2(rhs));
        }

        pub fn distance2(this: This, rhs: This) Element_Type {
            const dx = this.x - rhs.x;
            const dy = this.y - rhs.y;
            const dz = this.z - rhs.z;
            const dw = this.w - rhs.w;
            return dx * dx + dy * dy + dz * dz + dw * dw;
        }

        pub fn to_rl(this: This) rl.Vector4 {
            return .{ .x = this.x, .y = this.y, .z = this.z, .w = this.w };
        }

        pub fn as(this: This, T: type) T {
            if (T.DIMENSIONS != this.DIMENSIONS) {
                // TODO: should this be supported?
                @compileError("can't cast vector to a different size");
            }
            if (@typeInfo(T.Type) == .Float and @typeInfo(this.Type) == .Int) {
                return T.init(@floatFromInt(this.x), @floatFromInt(this.y), @floatFromInt(this.z), @floatFromInt(this.w));
            } else if (@typeInfo(T.Type) == .Int and @typeInfo(this.Type) == .Float) {
                return T.init(@intFromFloat(this.x), @intFromFloat(this.y), @intFromFloat(this.z), @intFromFloat(this.w));
            }

            @compileError("unrecognized type to cast to");
        }

        pub fn format(this: This, writer: *std.Io.Writer) !void {
            const precision = 3;
            try writer.print("Vector4{{x={d:0.[4]}, y={d:0.[4]}, z={d:0.[4]}, w={d:0.[4]}}", .{ this.x, this.y, this.z, this.w, precision });
        }
    };
}

pub const Vector2f = Vector2(f32);
pub const Vector3f = Vector3(f32);
pub const Vector4f = Vector4(f32);

pub const Vector2i = Vector2(i32);
pub const Vector3i = Vector3(i32);
pub const Vector4i = Vector4(i32);

pub const Vector2u = Vector2(u32);
pub const Vector3u = Vector3(u32);
pub const Vector4u = Vector4(u32);

comptime {
    const assert = std.debug.assert;

    assert(@sizeOf(Vector2f) == @sizeOf(rl.Vector2));
    assert(@sizeOf(Vector3f) == @sizeOf(rl.Vector3));
    assert(@sizeOf(Vector4f) == @sizeOf(rl.Vector4));
}

pub fn remap(value: f32, old_min: f32, old_max: f32, new_min: f32, new_max: f32) f32 {
    const old_range = old_max - old_min;
    const new_range = new_max - new_min;
    const t = (value - old_min) / old_range;
    const result = t * new_range + new_min;
    return result;
}
