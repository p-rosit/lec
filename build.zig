const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gci = b.dependency("gci", .{
        .target = target,
        .optimize = optimize,
    });
    const con = b.dependency("con", .{
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
    mod.addIncludePath(gci.path("src"));
    mod.addIncludePath(gci.path("src/interface"));
    mod.addIncludePath(gci.path("src/implementation"));

    const lib = b.addStaticLibrary(.{
        .name = "lec",
        .root_source_file = b.path("src/lec.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    mod.linkLibrary(lib);
    lib.linkLibrary(gci.artifact("gci"));
    lib.linkLibrary(con.artifact("con-deserialize"));
    lib.addIncludePath(b.path("src"));
    lib.addIncludePath(gci.path("src"));
    lib.addIncludePath(gci.path("src/interface"));
    lib.addIncludePath(gci.path("src/implementation"));
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
    lib_unit_tests.addIncludePath(gci.path("src"));
    lib_unit_tests.addIncludePath(gci.path("src/interface"));
    lib_unit_tests.addIncludePath(gci.path("src/implementation"));
    lib_unit_tests.root_module.addImport("gci", gci.module("gci"));
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const json_tests = b.addTest(.{
        .root_source_file = b.path("src/lec.zig"),
        .test_runner = b.path("src/lexer/test/test.zig"),
        .link_libc = true,
    });
    json_tests.linkLibrary(lib);
    json_tests.addIncludePath(b.path("src"));
    json_tests.addIncludePath(gci.path("src"));
    json_tests.addIncludePath(gci.path("src/interface"));
    json_tests.addIncludePath(gci.path("src/implementation"));
    json_tests.root_module.addImport("gci", gci.module("gci"));
    json_tests.root_module.addImport("con", con.module("con"));
    const run_json_tests = b.addRunArtifact(json_tests);
    run_json_tests.has_side_effects = true;

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_json_tests.step);
}
