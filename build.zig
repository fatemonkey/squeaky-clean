const std = @import("std");
const zon = @import("build.zig.zon");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raw_options = b.addOptions();
    raw_options.addOption(std.SemanticVersion, "version", try std.SemanticVersion.parse(zon.version));
    const options = raw_options.createModule();

    const raylib = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib_lib = raylib.artifact("raylib");

    const raylib_h = b.addTranslateC(.{
        .root_source_file = raylib.path("src/raylib.h"),
        .target = target,
        .optimize = optimize,
    }).createModule();

    const rayzig = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/rayzig/rayzig.zig"),
        .imports = &.{
            .{ .name = "raylib", .module = raylib_h },
        },
    });
    rayzig.linkLibrary(raylib_lib);

    const exe = b.addExecutable(.{
        .name = "squeakyclean",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/main.zig"),
            .imports = &.{
                .{ .name = "rayzig", .module = rayzig },
                .{ .name = "options", .module = options },
            },
        }),
    });
    b.installArtifact(exe);

    const run_step = b.step("run", "run the game");
    const run_command = b.addRunArtifact(exe);
    run_step.dependOn(&run_command.step);
    run_step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_command.addArgs(args);
    }
}
