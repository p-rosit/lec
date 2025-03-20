const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gci = b.dependency("gci", .{
        .target = target,
        .optimize = optimize,
    });

    const mod = b.addModule("lec", .{
        .root_source_file = b.path("src/lec.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "gci", .module = gci.module("gci") }},
    });
    mod.addIncludePath(b.path("src"));
    mod.addIncludePath(gci.path("src/interface"));

    const lib = b.addStaticLibrary(.{
        .name = "lec",
        .root_source_file = b.path("src/lec.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    mod.linkLibrary(lib);
    lib.linkLibrary(gci.artifact("gci"));
    lib.addIncludePath(b.path("src"));
    lib.addIncludePath(gci.path("src/interface"));
    b.installArtifact(lib);

    lib.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{ "arena/arena.c", "lexer/lexer.c" },
    });

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/lec.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib_unit_tests.linkLibrary(lib);
    lib_unit_tests.addIncludePath(b.path("src"));
    lib_unit_tests.addIncludePath(gci.path("src/interface"));
    lib_unit_tests.root_module.addImport("gci", gci.module("gci"));
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
