const std = @import("std");
const rl = @import("rayzig");
const options = @import("options");

const log = std.log.scoped(.game);

pub fn main() void {
    const version = options.version;

    var title_buffer: [64]u8 = undefined;
    const title = std.fmt.bufPrintZ(&title_buffer, "Squeaky Clean v{f}", .{version}) catch blk: {
        log.warn("Failed to format title", .{});
        break :blk "<title>";
    };

    rl.init_window(800, 600, title);
    defer rl.close_window();

    while (!rl.window_should_close()) {
        rl.begin_drawing();
        defer rl.end_drawing();

        rl.draw_rectangle(10, 10, 32, 32, .RED);
    }
}
