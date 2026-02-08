const std = @import("std");
const zon = @import("build.zig.zon");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const install_path = std.Build.LazyPath{ .cwd_relative = b.install_path };

    const version_string = blk: {
        const build_type_string = if (optimize == .Debug) "+debug" else "";
        break :blk try std.fmt.allocPrint(b.allocator, "v{s}{s}", .{ zon.version, build_type_string });
    };

    const raw_options = b.addOptions();
    raw_options.addOption([]const u8, "version_string", version_string);
    const options = raw_options.createModule();

    const raylib = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib_lib = raylib.artifact("raylib");

    const raylib_translate_c = b.addTranslateC(.{
        .root_source_file = b.path("src/rayzig/include.h"),
        .target = target,
        .optimize = optimize,
    });
    raylib_translate_c.addIncludePath(raylib.path("src"));
    const raylib_h = raylib_translate_c.createModule();

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
    // Override the default of using a "bin" directory for the executable as this is a game and we want the game's executable to just be at the top level
    b.getInstallStep().dependOn(&b.addInstallArtifact(exe, .{ .dest_dir = .{ .override = .prefix } }).step);

    // Install assets
    b.installDirectory(.{ .source_dir = b.path("src/assets"), .install_dir = .prefix, .install_subdir = "assets" });

    const run_step = b.step("run", "Run the game");
    const run_command = b.addRunArtifact(exe);
    run_command.step.dependOn(b.getInstallStep());
    run_command.setCwd(install_path);
    run_step.dependOn(&run_command.step);

    if (b.args) |args| {
        run_command.addArgs(args);
    }

    // TODO: figure out how to make the package step fail if the package already exists to prevent accidental overwriting
    // TODO: figure out how to clear/uninstall/remove the install directory before packaging to make sure everything that's packaged is fresh
    //       otherwise, the package might include old files

    const package_step = b.step("package", "Package a release of the game");
    const package_name = try std.fmt.allocPrint(b.allocator, "squeaky_clean-{s}", .{version_string});
    const package_file_name = try std.fmt.allocPrint(b.allocator, "releases/{s}.zip", .{package_name});

    // const prep_install_command = b.addRemoveDirTree(install_path);

    // Create a .zip archive of the game's install folder
    const package_command = b.addSystemCommand(&.{"7z"});
    package_command.addArg("a");
    package_command.addArg("-tzip");
    package_command.addArg(package_file_name);
    package_command.addDirectoryArg(install_path);
    package_command.step.dependOn(b.getInstallStep());

    // Rename the top-level directory in the package from the install path to the package name,
    // so that when someone extracts the package, the folder is named the same
    // TODO: make sure this doesnt rename subdirectories/files/whatever that might happen to be named the same thing
    const package_rename_command = b.addSystemCommand(&.{"7z"});
    package_rename_command.addArg("rn");
    package_rename_command.addArg(package_file_name);
    package_rename_command.addArg(std.fs.path.basename(b.install_path));
    package_rename_command.addArg(package_name);
    package_rename_command.step.dependOn(&package_command.step);
    package_step.dependOn(&package_rename_command.step);
}
