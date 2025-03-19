const std = @import("std");
const internal = @import("internal.zig");
const lib = internal.lib;
const gci = @import("gci");

pub const Arena = struct {
    inner: lib.LecArena,

    pub fn init(data: []u8) !Arena {
        var self: Arena = undefined;
        const err = lib.lec_arena_init(&self.inner, data.ptr, data.len);
        try internal.enumToError(err);
        return self;
    }
};

pub const Context = struct {
    inner: lib.LecContext,

    pub fn init(arena: Arena, reader: gci.InterfaceReader) !Context {
        var self: Context = undefined;
        const err = lib.lec_context_init(
            &self.inner,
            @as(*lib.GciInterfaceReader, @ptrCast(@constCast(&reader.reader))).*,
            arena.inner,
        );
        try internal.enumToError(err);
        return self;
    }
};

test "arena init" {
    var buffer: [5]u8 = undefined;
    _ = try Arena.init(&buffer);
}

test "context init" {
    var buffer: [5]u8 = undefined;
    const arena = try Arena.init(&buffer);

    const data = "";
    var reader = try gci.ReaderString.init(data);

    _ = try Context.init(arena, reader.interface());
}
