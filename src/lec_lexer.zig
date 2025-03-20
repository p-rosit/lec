const std = @import("std");
const internal = @import("internal.zig");
const lib = internal.lib;
const gci = @import("gci");
const zlec = @import("lec.zig");

pub const Context = struct {
    inner: lib.LecContext,

    pub fn init(arena: zlec.Arena, reader: gci.InterfaceReader) !Context {
        var self: Context = undefined;
        const err = lib.lec_lexer_init(
            &self.inner,
            @as(*lib.GciInterfaceReader, @ptrCast(@constCast(&reader.reader))).*,
            arena.inner,
        );
        try internal.enumToError(err);
        return self;
    }

    pub fn next(self: *Context) !zlec.Token {
        var token: zlec.Token = undefined;
        const err = lib.lec_token_next(&self.inner, &token.inner);
        try internal.enumToError(err);
        return token;
    }
};

const testing = std.testing;

test "lexer init" {
    var buffer: [5]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "";
    var reader = try gci.ReaderString.init(data);

    _ = try Context.init(arena, reader.interface());
}
