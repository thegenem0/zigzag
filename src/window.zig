const std = @import("std");
const Render = @import("./renderer.zig");
const Input = @import("./input.zig");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

export fn errorCallback(_: i32, description: [*c]const u8) callconv(.C) void {
    std.debug.panic("Error: {s}\n", .{description});
}

pub fn createWindow(width: i32, height: i32, title: [*c]const u8) !*c.GLFWwindow {
    if (c.glfwInit() == c.GLFW_FALSE) {
        return error.GLFWInitError;
    }

    _ = c.glfwSetErrorCallback(errorCallback);

    const window = c.glfwCreateWindow(width, height, title, null, null) orelse {
        std.debug.print("Failed to create window\n", .{});
        return error.GLFWWindowCreationError;
    };
    c.glfwMakeContextCurrent(window);

    if (c.gladLoadGLLoader(@ptrCast(&c.glfwGetProcAddress)) == c.GLFW_FALSE) {
        std.debug.print("Failed to initialize GLAD\n", .{});
        return error.GLADInitError;
    }

    return window;
}

pub fn runWindowLoop(window: *c.GLFWwindow) !void {
    const version = c.glGetString(c.GL_VERSION);
    std.debug.print("OpenGL Version: {s}\n", .{version});

    var windowWidth: i32 = 0;
    var windowHeight: i32 = 0;
    c.glfwGetWindowSize(window, &windowWidth, &windowHeight);
    c.glViewport(0, 0, windowHeight, windowWidth);

    var renderer: Render.Renderer = undefined;
    defer renderer.deinit();

    try renderer.init(std.heap.page_allocator);

    Input.InputHandler.setupCallbacks(window);

    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
        try renderer.render(window);
    }
}

pub fn destroyWindow(window: *c.GLFWwindow) void {
    c.glfwDestroyWindow(window);
    c.glfwTerminate();
}
