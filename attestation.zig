const std = @import("std");

pub const Attestation = struct {
    voter_did: []const u8,
    target_did: []const u8,
    is_human_vote: bool,
};

pub const ProofOfHumanity = struct {
    handle: []const u8,
    vouch_count: u32,
    has_sovereign_domain: bool,

    pub fn isVerified(self: ProofOfHumanity) bool {
        // Rule 1: Custom domains are auto-vouched
        if (self.has_sovereign_domain) return true;
        
        // Rule 2: If no domain, you need at least 3 vouches from other humans
        if (self.vouch_count >= 3) return true;
        
        return false;
    }
};

pub fn main() !void {
    // Artist A: No domain, but 4 friends vouched for them
    const artist_a = ProofOfHumanity{
        .handle = "indie-painter.bsky.social",
        .vouch_count = 4,
        .has_sovereign_domain = false,
    };

    // Artist B: Just joined, no vouches, no domain
    const artist_b = ProofOfHumanity{
        .handle = "random-user.bsky.social",
        .vouch_count = 0,
        .has_sovereign_domain = false,
    };

    std.debug.print("\n--- Skydrops Human Attestation Check ---\n", .{});

    const list = [_]ProofOfHumanity{ artist_a, artist_b };

    for (list) |artist| {
        const verified = artist.isVerified();
        std.debug.print("Artist: {s: <25} Verified: {s}\n", .{ 
            artist.handle, 
            if (verified) "✅ YES" else "❌ PENDING" 
        });
    }
}
