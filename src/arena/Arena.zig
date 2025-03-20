const internal = @import("../internal.zig");
const lib = internal.lib;
const Self = @This();

inner: lib.LecArena,

pub fn init(data: []u8) !Self {
    var self: Self = undefined;
    const err = lib.lec_arena_init(&self.inner, data.ptr, data.len);
    try internal.enumToError(err);
    return self;
}

const testing = @import("std").testing;

test "arena init" {
    var buffer: [5]u8 = undefined;
    _ = try Self.init(&buffer);
}
