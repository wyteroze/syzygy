const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });

    const exe = b.addExecutable(.{
        .name = "syzygy",
        .root_module = mod,
    });

    mod.addCSourceFiles(.{
        .root = b.path("src/"),
        .language = .cpp,
        .files = &.{
            "main.cpp"
        },
        .flags = &.{
            "-std=c++17",
            "-Wall",
            "-Wextra"
        },
    });

    mod.addIncludePath(b.path("include/"));
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);
}