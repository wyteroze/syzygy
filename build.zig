// Copyright 2026 wyteroze. Licensed under the Apache-2.0 license.

const std = @import("std");

// Regenerate the file using this command:
// {
//   (cd vendor/binaryen/src && \
//    echo "pub const files = [_][]const u8{" && \
//    find asmjs cfg emscripten-optimizer ir parser passes support wasm -name '*.cpp' | sort | sed 's/.*/    "&",/' && \
//    echo '    "binaryen-c.cpp",' && \
//    echo "};")
//   echo
//   (cd vendor/binaryen/third_party/llvm-project && \
//    echo "pub const llvm_files = [_][]const u8{" && \
//    find . -maxdepth 1 -name '*.cpp' | sort | sed 's|^\./|    "|; s|$|",|' && \
//    echo "};")
// } > binaryen_sources.zig
const binaryen_src = @import("binaryen_sources.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Syzygy
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

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    // Luau
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

    syzygy_mod.linkLibrary(luau_ast);
    syzygy_mod.addSystemIncludePath(b.path("vendor/luau/Ast/include"));
    syzygy_mod.addSystemIncludePath(b.path("vendor/luau/Common/include"));

    // Binaryen
    const binaryen_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true
    });
    binaryen_mod.addIncludePath(b.path("vendor/binaryen/src"));
    binaryen_mod.addIncludePath(b.path("vendor/binaryen/third_party/FP16/include"));
    binaryen_mod.addIncludePath(b.path("vendor/binaryen/third_party/llvm-project/include"));
    binaryen_mod.addCSourceFiles(.{
        .root = b.path("vendor/binaryen/src"),
        .language = .cpp,
        .files = &binaryen_src.files,
        .flags = &.{ "-std=c++20" },
    });
    binaryen_mod.addCSourceFiles(.{
        .root = b.path("vendor/binaryen/third_party/llvm-project"),
        .language = .cpp,
        .files = &binaryen_src.llvm_files,
        .flags = &.{ "-std=c++20", "-w" },
    });

    const config_h = b.addConfigHeader(.{
        .style = .{ .cmake = b.path("vendor/binaryen/config.h.in") },
        .include_path = "config.h"
    }, .{
        .PROJECT_VERSION = "0.0.0"
    });
    binaryen_mod.addConfigHeader(config_h);

    const binaryen = b.addLibrary(.{
        .name = "binaryen",
        .root_module = binaryen_mod,
        .linkage = .static,
    });

    syzygy_mod.linkLibrary(binaryen);
    syzygy_mod.addSystemIncludePath(b.path("vendor/binaryen/src"));
}