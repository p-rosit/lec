const std = @import("std");
const internal = @import("../internal.zig");
const lib = internal.lib;
const gci = @import("gci");
const zlec = @import("../lec.zig");
const Self = @This();

inner: lib.LecLexer,

pub fn init(reader: gci.InterfaceReader, arena: zlec.Arena) !Self {
    var self: Self = undefined;
    const err = lib.lec_lexer_init(
        &self.inner,
        @as(*lib.GciInterfaceReader, @ptrCast(@constCast(&reader.reader))).*,
        arena.inner,
    );
    try internal.enumToError(err);
    return self;
}

pub fn next(self: *Self) !zlec.Token {
    var token: zlec.Token = undefined;
    const err = lib.lec_lexer_next(&self.inner, &token.inner);
    try internal.enumToError(err);
    return token;
}

const testing = std.testing;

test "c tests" {
    _ = @import("test_lexer.zig");
}

test "lexer init" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "";
    var reader = try gci.ReaderString.init(data);

    _ = try Self.init(reader.interface(), arena);
}

test "lexer next plus" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "\n+";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(0, token.inner.start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings("+", &buffer);
}
