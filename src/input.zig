const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

pub const InputHandler = struct {
    pub fn setupCallbacks(window: ?*c.GLFWwindow) void {
        _ = c.glfwSetKeyCallback(window, handleKey);
        _ = c.glfwSetCursorPosCallback(window, handleMouseMove);
        _ = c.glfwSetMouseButtonCallback(window, handleMouseClick);
    }

    fn handleKey(window: ?*c.GLFWwindow, key: i32, _: i32, action: i32, _: i32) callconv(.C) void {
        if (action == c.GLFW_PRESS or action == c.GLFW_REPEAT) {
            switch (key) {
                c.GLFW_KEY_W => std.debug.print("w pressed\n", .{}),
                c.GLFW_KEY_ESCAPE => c.glfwSetWindowShouldClose(window, c.GLFW_TRUE),
                else => {},
            }
        }
    }

    fn handleMouseMove(_: ?*c.GLFWwindow, xpos: f64, ypos: f64) callconv(.C) void {
        std.debug.print("Mouse moved: ({d}, {d})\n", .{ xpos, ypos });
    }

    fn handleMouseClick(_: ?*c.GLFWwindow, button: i32, action: i32, _: i32) callconv(.C) void {
        if (action == c.GLFW_PRESS) {
            switch (button) {
                c.GLFW_MOUSE_BUTTON_LEFT => std.debug.print("Left mouse button pressed\n", .{}),
                c.GLFW_MOUSE_BUTTON_RIGHT => std.debug.print("Right mouse button pressed\n", .{}),
                else => {},
            }
        }
    }
};
