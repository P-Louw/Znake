const std = @import("std");
const Sdk = @import("libs/SDL.zig/Sdk.zig");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    // Zig sdl wrapper setup.
    const sdk = Sdk.init(b, null);

    const exe = b.addExecutable(.{
        .name = "Snake",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    sdk.link(exe, .dynamic);

    exe.addModule("sdl2-native", sdk.getNativeModule());
    exe.addModule("sdl2-zig", sdk.getWrapperModule());

    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2_ttf");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
