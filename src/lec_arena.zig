const internal = @import("internal.zig");
const lib = internal.lib;

pub const Arena = struct {
    inner: lib.LecArena,

    pub fn init(data: []u8) !Arena {
        var self: Arena = undefined;
        const err = lib.lec_arena_init(&self.inner, data.ptr, data.len);
        try internal.enumToError(err);
        return self;
    }
};

const testing = @import("std").testing;

test "arena init" {
    var buffer: [5]u8 = undefined;
    _ = try Arena.init(&buffer);
}
