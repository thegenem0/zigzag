const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
});

pub const ShaderProgram = struct {
    program: u32,
    vertexShaderPath: []const u8,
    fragmentShaderPath: []const u8,
    lastVertexModified: i128,
    lastFragmentModified: i128,

    pub fn init(vertexPath: []const u8, fragmentPath: []const u8) !ShaderProgram {
        const program = try createProgram(vertexPath, fragmentPath);
        const vertexModTime = try getFileLastModifiedTime(vertexPath);
        const fragmentModTime = try getFileLastModifiedTime(fragmentPath);

        return ShaderProgram{
            .program = program,
            .vertexShaderPath = vertexPath,
            .fragmentShaderPath = fragmentPath,
            .lastVertexModified = vertexModTime,
            .lastFragmentModified = fragmentModTime,
        };
    }

    pub fn reloadIfModified(self: *ShaderProgram) !void {
        const vertexModTime = getFileLastModifiedTime(self.vertexShaderPath) catch |err| {
            switch (err) {
                error.FileNotFound => {
                    std.debug.print("Vertex shader not saved yet\n", .{});
                    return;
                },
                else => return err,
            }
        };

        const fragmentModTime = getFileLastModifiedTime(self.fragmentShaderPath) catch |err| {
            switch (err) {
                error.FileNotFound => {
                    std.debug.print("Fragment shader not saved yet\n", .{});
                    return;
                },
                else => return err,
            }
        };

        if (vertexModTime > self.lastVertexModified or fragmentModTime > self.lastFragmentModified) {
            std.debug.print("Reloading shader\n", .{});

            const newProgram = try ShaderProgram.createProgram(self.vertexShaderPath, self.fragmentShaderPath);
            self.program = newProgram;
            self.lastVertexModified = vertexModTime;
            self.lastFragmentModified = fragmentModTime;
        }
    }

    pub fn deinit(self: *ShaderProgram) void {
        c.glDeleteProgram(self.program);
    }

    fn createProgram(vertexPath: []const u8, fragmentPath: []const u8) !u32 {
        const vertexShader = try compileShader(vertexPath, c.GL_VERTEX_SHADER);
        defer c.glDeleteShader(vertexShader);

        const fragmentShader = try compileShader(fragmentPath, c.GL_FRAGMENT_SHADER);
        defer c.glDeleteShader(fragmentShader);

        const program = c.glCreateProgram();
        c.glAttachShader(program, vertexShader);
        c.glAttachShader(program, fragmentShader);
        c.glLinkProgram(program);

        var success: c.GLint = 0;
        c.glGetProgramiv(program, c.GL_LINK_STATUS, &success);
        if (success == 0) {
            var infoLog: [512]u8 = undefined;
            c.glGetProgramInfoLog(program, 512, null, &infoLog[0]);
            std.debug.print("Error linking program: {s}\n", .{&infoLog});
            return error.ShaderLinkError;
        }

        return program;
    }

    fn loadShaderSource(path: []const u8) ![]u8 {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        const file_size = try file.getEndPos();
        var buffer = try std.heap.page_allocator.alloc(u8, file_size);

        const bytes_read = try file.read(buffer);

        return buffer[0..bytes_read];
    }

    fn compileShader(shaderPath: []const u8, shaderType: u32) !u32 {
        const source = try loadShaderSource(shaderPath);
        defer std.heap.page_allocator.free(source);

        const shader = c.glCreateShader(shaderType);

        c.glShaderSource(shader, 1, &source.ptr, null);
        c.glCompileShader(shader);

        var success: c.GLint = 0;
        c.glGetShaderiv(shader, c.GL_COMPILE_STATUS, &success);
        if (success == 0) {
            var infoLog: [512]u8 = undefined;
            c.glGetShaderInfoLog(shader, 512, null, &infoLog[0]);
            std.debug.print("Error compiling {s}: {s}\n", .{ shaderPath, &infoLog });
            return error.ShaderCompileError;
        }

        return shader;
    }

    fn getFileLastModifiedTime(path: []const u8) !i128 {
        const file_info = try std.fs.cwd().statFile(path);
        return file_info.mtime;
    }
};
