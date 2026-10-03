const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const vendor_luau = b.path("vendor/luau");

    const luau_ast_mod = b.createModule(.{ .target = target, .optimize = optimize, .link_libcpp = true });
    luau_ast_mod.addIncludePath(b.path("vendor/luau/Ast/include"));
    luau_ast_mod.addIncludePath(b.path("vendor/luau/Common/include"));
    luau_ast_mod.addCSourceFiles(.{
        .root = vendor_luau,
        .language = .cpp,
        .files = &.{
            "Common/src/StringUtils.cpp",
            "Common/src/TimeTrace.cpp",
            "Ast/src/Allocator.cpp",
            "Ast/src/Ast.cpp",
            "Ast/src/Confusables.cpp",
            "Ast/src/Cst.cpp",
            "Ast/src/Lexer.cpp",
            "Ast/src/Location.cpp",
            "Ast/src/Parser.cpp",
            "Ast/src/PrettyPrinter.cpp",
        },
        .flags = &.{ "-std=c++17" }
    });

    const luau_ast = b.addLibrary(.{
        .name = "Luau.Ast",
        .root_module = luau_ast_mod,
        .linkage = .static
    });

    const syzygy_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });

    const exe = b.addExecutable(.{
        .name = "syzygy",
        .root_module = syzygy_mod,
    });

    syzygy_mod.addCSourceFiles(.{
        .root = b.path("src"),
        .language = .cpp,
        .files = &.{ "main.cpp" },
        .flags = &.{ "-std=c++17", "-Wall", "-Wextra" },
    });

    syzygy_mod.addIncludePath(b.path("include"));
    syzygy_mod.addSystemIncludePath(b.path("vendor/luau/Ast/include"));
    syzygy_mod.addSystemIncludePath(b.path("vendor/luau/Common/include"));
    syzygy_mod.linkLibrary(luau_ast);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);
}