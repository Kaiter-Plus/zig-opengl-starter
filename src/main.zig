//! OpenGL 初始化示例 - 使用 GLFW 和 GLAD
//! 本程序演示了如何在 Zig 中设置 OpenGL 上下文，包括:
//! - GLFW 窗口系统初始化
//! - GLAD 函数加载器配置
//! - 基本输入处理和窗口回调
//! - 资源安全清理
//!
//! 注意: 本代码针对 Zig 0.15.2 版本编写，指针转换语法在不同 Zig 版本间可能有变化

const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("glad/glad.h"); // GLAD OpenGL 函数加载器
    @cInclude("GLFW/glfw3.h"); // GLFW 窗口和输入管理
});

/// 窗口尺寸常量
const SCR_WIDTH = 800;
const SCR_HEIGHT = 600;

/// 程序入口点 - 初始化 OpenGL 上下文并运行主循环
pub fn main() !void {
    // 初始化 GLFW 库
    // 注意: _ = 用于忽略返回值，因为我们通过后续检查窗口创建来验证初始化
    _ = c.glfwInit();
    // 确保程序退出前终止 GLFW - 使用 defer 保证资源安全清理
    defer c.glfwTerminate();
    // 配置 GLFW 使用的 OpenGL 版本(这里使用 OpenGL 3.3 版本)和配置文件(这里使用 Core-Profile)
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3); // 主版本 3
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3); // 次版本 3
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE); // 核心配置文件

    // 创建 GLFW 窗口，使用 orelse 处理可能的创建失败
    const window = c.glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "学习 OpenGL", null, null) orelse {
        std.debug.print("错误: 无法创建 GLFW 窗口\n", .{});
        c.glfwTerminate(); // 清理 GLFW 资源
        return error.FailedToCreateWindow; // 返回自定义错误
    };
    // 设置当前线程的 OpenGL 上下文为新创建的窗口
    c.glfwMakeContextCurrent(window);

    // 注册窗口大小变化回调函数
    // 注意: 回调函数必须使用 callconv(.c) 以匹配 C 调用约定
    _ = c.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    // 初始化 GLAD
    if (c.gladLoadGLLoader(@ptrCast(&c.glfwGetProcAddress)) == 0) {
        std.debug.print("错误: 无法初始化 GLAD\n", .{});
        return error.FailedToInitializeGLAD;
    }

    // 主渲染循环
    while (c.glfwWindowShouldClose(window) == 0) {
        // 输入(Input)
        processInput(window); // 处理用户输入
        // 渲染(Render)
        c.glClearColor(0.2, 0.3, 0.3, 1.0); // glClearColor 为 状态设置函数，这里设置了清屏颜色
        c.glClear(c.GL_COLOR_BUFFER_BIT); // glClear 为 状态使用函数，调用清除颜色缓冲之后，整个颜色缓冲都会被填充为 glClearColor 里所设置的颜色
        // glfw
        c.glfwSwapBuffers(window); // 交换前后缓冲区 (双缓冲)
        c.glfwPollEvents(); // 处理IO事件队列。按键按下或者释放，鼠标移动等事件的处理
    }
}

/// 处理用户输入
/// @param window 指向 GLFW 窗口的指针 (非空)
fn processInput(window: *c.GLFWwindow) void {
    // 检查 ESC 键是否被按下
    // 注意: GLFW_PRESS 是整数值，不是布尔值
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
        // 设置窗口应关闭标志
        // 注意: 使用 1 (GLFW_TRUE) 而不是 true，因为这是 C API
        c.glfwSetWindowShouldClose(window, c.GLFW_TRUE);
    }
}

/// 窗口大小变化回调函数
/// 当窗口大小改变时由 GLFW 自动调用
/// @param window 窗口指针 (此示例中未使用)
/// @param width 新的宽度 (像素)
/// @param height 新的高度 (像素)
fn framebuffer_size_callback(_: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.c) void {
    // 更新 OpenGL 视口以匹配新窗口大小
    c.glViewport(0, 0, width, height);
}
