const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("common", .{
        .root_source_file = b.path("../common/src/lib.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "ghostmesh",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    b.step("run", "Run the app").dependOn(&run_cmd.step);

    // ⬇️ New: test step, points to a dedicated test file or reuse main.zig
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.step("test", "Run unit tests").dependOn(&unit_tests.step);
}
