const std = @import("std");

pub fn main() !void {
    // 1. Logic: Who gets in?
    const Gatekeeper = struct {
        pub fn isHuman(handle: []const u8) bool {
            // Skydrops Law: Custom domains are auto-trusted.
            return !std.mem.endsWith(u8, handle, ".bsky.social");
        }
    };

    std.debug.print("\n--- 🛰️  Skydrops Live Firehose (Safe-Mode) ---\n", .{});

    // 2. Simulated traffic from the AT Protocol
    const traffic = [_][]const u8{
        "artist.skydrops.app",
        "bot-99.bsky.social",
        "indie-creator.com",
        "spam-gen.bsky.social",
    };

    for (traffic) |handle| {
        if (Gatekeeper.isHuman(handle)) {
            std.debug.print("Processing: {s: <25} ✅ ALLOWED: Verified Human\n", .{handle});
        } else {
            std.debug.print("Processing: {s: <25} 🚫 BLOCKED: Bot/Unverified\n", .{handle});
        }
        
        // FIX: In 0.15.2, sleep is now located in std.Thread
        std.Thread.sleep(500 * std.time.ns_per_ms);
    }
    
    std.debug.print("\nStatus: Stable. Ready to connect to bsky.network.\n", .{});
}
