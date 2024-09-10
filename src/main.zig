const std = @import("std");
const c = @cImport({
    @cInclude("GLFW/glfw3.h");
});

export fn errorCallback(_: c_int, description: [*c]const u8) void {
    std.debug.panic("Error: {s}\n", .{description});
}

pub fn main() anyerror!void {
    if (c.glfwInit() == 0) {
        std.debug.print("Failed to initialize GLFW\n", .{});
        return;
    }

    _ = c.glfwSetErrorCallback(errorCallback);

    const window = c.glfwCreateWindow(640, 480, "Hello, Zig!", null, null) orelse {
        std.debug.print("Failed to create GLFW window\n", .{});
        c.glfwTerminate();
        return;
    };

    c.glfwMakeContextCurrent(window);

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    c.glfwDestroyWindow(window);
    c.glfwTerminate();
}
