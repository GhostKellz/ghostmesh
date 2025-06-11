const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Common module shared across GhostMesh components
    _ = b.addModule("common", .{
        .root_source_file = b.path("../common/src/lib.zig"),
    });

    // GhostGate relay binary
    const exe = b.addExecutable(.{
        .name = "ghostgate",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();

    b.installArtifact(exe);

    // `zig build run` support
    const run_cmd = b.addRunArtifact(exe);
    b.step("run", "Run ghostgate UDP relay").dependOn(&run_cmd.step);
}
