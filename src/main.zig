const std = @import("std");
const Window = @import("window.zig");

const c = @cImport({
    @cInclude("glad/glad.h");
});

pub fn main() anyerror!void {
    const window = try Window.createWindow(640, 480, "Hello, Zig!");
    defer Window.destroyWindow(window);

    try Window.runWindowLoop(window);
}
