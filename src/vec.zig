pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn add(self: Vec2, other: Vec2) Vec2 {
        return Vec2{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn sub(self: Vec2, other: Vec2) Vec2 {
        return Vec2{ .x = self.x - other.x, .y = self.y - other.y };
    }

    pub fn mul(self: Vec2, other: Vec2) Vec2 {
        return Vec2{ .x = self.x * other.x, .y = self.y * other.y };
    }

    pub fn div(self: Vec2, other: Vec2) Vec2 {
        return Vec2{ .x = self.x / other.x, .y = self.y / other.y };
    }

    pub fn mulScalar(self: Vec2, scalar: f32) Vec2 {
        return Vec2{ .x = self.x * scalar, .y = self.y * scalar };
    }

    pub fn divScalar(self: Vec2, scalar: f32) Vec2 {
        return Vec2{ .x = self.x / scalar, .y = self.y / scalar };
    }

    pub fn length(self: Vec2) f32 {
        return @sqrt(self.x * self.x + self.y * self.y);
    }
};
