const std = @import("std");

// 1. User Data Structure
pub const UserStanding = struct {
    handle: []const u8,
    score: i32,
    is_sovereign: bool,

    pub fn render(self: UserStanding) void {
        std.debug.print("\n--- 🛡️  TRUST DASHBOARD: {s} ---\n", .{self.handle});
        std.debug.print("Status: {s} (Score: {d})\n", .{
            if (self.is_sovereign) "🌟 SOVEREIGN" else "✅ HUMAN",
            self.score
        });
        std.debug.print("------------------------------------------\n\n", .{});
    }
};

// 2. Gesture Logic
pub fn main() !void {
    var last_tap: i64 = 0;
    const threshold: i64 = 300; // ms

    // The user we are checking
    const target = UserStanding{
        .handle = "@artist.com",
        .score = 8,
        .is_sovereign = true,
    };

    std.debug.print("🚀 Skydrops UI: Tap the handle to view standing...\n", .{});

    // SIMULATION 1: Two taps 200ms apart (SUCCESS)
    std.debug.print("(Tap...)\n", .{});
    last_tap = std.time.milliTimestamp();
    
    std.Thread.sleep(200 * std.time.ns_per_ms); // Wait 200ms
    
    const now = std.time.milliTimestamp();
    if (now - last_tap < threshold) {
        std.debug.print("(Tap!) -> DOUBLE-TAP DETECTED\n", .{});
        target.render();
    } else {
        std.debug.print("(Tap) -> Single Tap (ignored)\n", .{});
    }

    // SIMULATION 2: Two taps 500ms apart (FAILURE)
    std.debug.print("Testing a slow second tap...\n", .{});
    last_tap = std.time.milliTimestamp();
    
    std.Thread.sleep(500 * std.time.ns_per_ms); // Wait too long
    
    const now_slow = std.time.milliTimestamp();
    if (now_slow - last_tap < threshold) {
        target.render();
    } else {
        std.debug.print("(Tap) -> Too slow! No dashboard triggered.\n", .{});
    }
}
