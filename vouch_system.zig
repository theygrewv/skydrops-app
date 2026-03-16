const std = @import("std");

pub const UserStatus = enum { unverified, verified };

pub const VouchManager = struct {
    // Maps DID to their current trust score
    trust_scores: std.StringHashMap(u32),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) VouchManager {
        return .{
            .trust_scores = std.StringHashMap(u32).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *VouchManager) void {
        self.trust_scores.deinit();
    }

    pub fn addVouch(self: *VouchManager, target_did: []const u8, is_domain_owner: bool) !void {
        const weight: u32 = if (is_domain_owner) 3 else 1;
        
        const current_score = self.trust_scores.get(target_did) orelse 0;
        try self.trust_scores.put(target_did, current_score + weight);
    }

    pub fn isVerified(self: VouchManager, target_did: []const u8) bool {
        const score = self.trust_scores.get(target_did) orelse 0;
        return score >= 5; // The "Golden Threshold"
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var manager = VouchManager.init(allocator);
    defer manager.deinit();

    const new_artist_did = "did:plc:new-artist-123";

    // Scenario: One domain owner and two verified humans vouch for the artist
    try manager.addVouch(new_artist_did, true);  // +3 points
    try manager.addVouch(new_artist_did, false); // +1 point
    try manager.addVouch(new_artist_did, false); // +1 point

    std.debug.print("\n--- Skydrops Refined Vouch System ---\n", .{});
    
    if (manager.isVerified(new_artist_did)) {
        std.debug.print("Result: ✅ {s} is now HUMAN VERIFIED (Score: 5)\n", .{new_artist_did});
    } else {
        std.debug.print("Result: ⏳ {s} still pending more vouches.\n", .{new_artist_did});
    }
}
