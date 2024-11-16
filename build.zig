const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(
        std.builtin.LinkMode,
        "linkage",
        "Specify static or dynamic linkage",
    ) orelse .dynamic;
    const upstream = b.dependency("ament_index", .{});

    var ament_index_cpp = std.Build.Step.Compile.create(b, .{
        .root_module = .{
            .target = target,
            .optimize = optimize,
            .pic = if (linkage == .dynamic) true else null,
        },
        .name = "ament_index_cpp",
        .kind = .lib,
        .linkage = linkage,
    });

    ament_index_cpp.linkLibCpp();

    ament_index_cpp.addIncludePath(upstream.path("ament_index_cpp/include"));
    ament_index_cpp.installHeadersDirectory(
        upstream.path("ament_index_cpp/include"),
        "",
        .{ .include_extensions = &.{ ".h", ".hpp" } },
    );

    ament_index_cpp.addCSourceFiles(.{
        .root = upstream.path("ament_index_cpp"),
        .files = &.{
            "src/get_package_prefix.cpp",
            "src/get_package_share_directory.cpp",
            "src/get_packages_with_prefixes.cpp",
            "src/get_resource.cpp",
            "src/get_resources.cpp",
            "src/get_search_paths.cpp",
            "src/has_resource.cpp",
        },
        .flags = &.{
            "--std=c++17",
            // "-fvisibility=hidden", // TODO this breaks this package
            // "-fvisibility-inlines-hidden",
        },
    });
    b.installArtifact(ament_index_cpp);
}
