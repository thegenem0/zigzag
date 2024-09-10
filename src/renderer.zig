const std = @import("std");
const Shader = @import("shader.zig");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

const VERTEX_SHADER_PATH: []const u8 = "/home/thegenem0/dev/personal/zigzoom/src/shaders/vertex.glsl";
const FRAGMENT_SHADER_PATH: []const u8 = "/home/thegenem0/dev/personal/zigzoom/src/shaders/fragment.glsl";

pub const Renderer = struct {
    shaderProgram: Shader.ShaderProgram,
    vao: u32 = 0,
    vbo: u32 = 0,

    pub fn init(self: *Renderer, _: std.mem.Allocator) !void {
        self.shaderProgram = try Shader.ShaderProgram.init(VERTEX_SHADER_PATH, FRAGMENT_SHADER_PATH);

        const vertices = [_]f32{
            -0.5, -0.5, 0.0, // Left
            0.5, -0.5, 0.0, // Right
            0.0, 0.5, 0.0, // Top
        };

        c.glGenVertexArrays(1, &self.vao);
        c.glGenBuffers(1, &self.vbo);

        c.glBindVertexArray(self.vao);

        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.vbo);
        c.glBufferData(c.GL_ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, c.GL_STATIC_DRAW);

        c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), null);
        c.glEnableVertexAttribArray(0);

        // unbind VAO
        c.glBindVertexArray(0);
    }

    pub fn render(self: *Renderer, window: *c.GLFWwindow) !void {
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        try self.shaderProgram.reloadIfModified();

        c.glUseProgram(self.shaderProgram.program);
        c.glBindVertexArray(self.vao);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);

        // unbind VAO
        c.glBindVertexArray(0);

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    pub fn deinit(self: *Renderer) void {
        c.glDeleteVertexArrays(1, &self.vao);
        c.glDeleteBuffers(1, &self.vbo);
        self.shaderProgram.deinit();
    }
};
