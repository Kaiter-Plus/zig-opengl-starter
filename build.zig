const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "zig_opengl_starter",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.addIncludePath(b.path("3rd-party/include"));
    exe.addObjectFile(b.path("3rd-party/lib/libglfw3.a"));
    exe.addCSourceFile(.{
        .file = b.path("3rd-party/lib/glad/src/glad.c"),
        .flags = &.{},
    });
    exe.linkLibC(); // C标准库
    exe.linkSystemLibrary("gdi32"); // 窗口管理
    exe.linkSystemLibrary("winmm"); // 多媒体
    exe.linkSystemLibrary("opengl32"); // OpenGL
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
