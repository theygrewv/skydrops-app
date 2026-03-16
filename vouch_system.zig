const std = @import("std");

pub const VouchManager = struct {
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

    // Positive Trust
    pub fn addVouch(self: *VouchManager, target_did: []const u8, is_domain_owner: bool) !void {
        const weight: u32 = if (is_domain_owner) 3 else 1;
        const current_score = self.trust_scores.get(target_did) orelse 0;
        try self.trust_scores.put(target_did, current_score + weight);
    }

    // Negative Trust (Reporting)
    pub fn flagAccount(self: *VouchManager, target_did: []const u8, is_domain_owner: bool) !void {
        const penalty: u32 = if (is_domain_owner) 5 else 2;
        const current_score = self.trust_scores.get(target_did) orelse 0;
        
        // Prevent underflow (score cannot be negative)
        const new_score = if (current_score > penalty) current_score - penalty else 0;
        try self.trust_scores.put(target_did, new_score);
    }

    pub fn isVerified(self: VouchManager, target_did: []const u8) bool {
        const score = self.trust_scores.get(target_did) orelse 0;
        return score >= 5; 
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var manager = VouchManager.init(allocator);
    defer manager.deinit();

    const target = "did:plc:shady-account-456";

    std.debug.print("\n--- Skydrops Reputation & Flagging System ---\n", .{});

    // 1. Shady account gets some vouches from other bots/low-trust humans
    try manager.addVouch(target, false); // +1
    try manager.addVouch(target, false); // +1
    try manager.addVouch(target, true);  // +3 (Total: 5 - VERIFIED)
    
    std.debug.print("Initial Status: {s}\n", .{if (manager.isVerified(target)) "✅ VERIFIED" else "❌ PENDING"});

    // 2. A Domain Owner notices it's a bot and FLAGS it
    std.debug.print("⚠️  Domain Owner flagged the account!\n", .{});
    try manager.flagAccount(target, true); // -5

    std.debug.print("Final Status:   {s} (Score dropped back to 0)\n", .{if (manager.isVerified(target)) "✅ VERIFIED" else "❌ BLOCKED"});
}
