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
const TokenType = zlec.Token.Type;

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

test "lexer next single char" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "\n-.";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);

    const token1 = try lexer.next();
    try testing.expectEqual(TokenType.minus, token1.type());
    try testing.expectEqual(0, token1.inner.arena_start);
    try testing.expectEqual(1, token1.inner.byte_start);
    try testing.expectEqual(1, token1.inner.length);
    try testing.expectEqualStrings("-", buffer[0..1]);

    const token2 = try lexer.next();
    try testing.expectEqual(TokenType.dot, token2.type());
    try testing.expectEqual(1, token2.inner.arena_start);
    try testing.expectEqual(2, token2.inner.byte_start);
    try testing.expectEqual(1, token2.inner.length);
    try testing.expectEqualStrings(".", buffer[1..2]);
}

test "lexer next plus" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "+ ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.plus, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next minus" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "- ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.minus, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next mul" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "*";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.mul, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next div" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "/ ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.div, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next assign" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "= ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.assign, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next equal" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "==";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.equal, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer leq" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "<=";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.leq, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer geq" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = ">=";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.geq, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer next l paren" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "(";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.l_paren, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next r paren" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = ")";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.r_paren, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next l brack" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "[";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.l_brack, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next r brack" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "]";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.r_brack, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next l brace" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "{";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.l_brace, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next r brace" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "}";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.r_brace, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next l angle" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "< ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.l_angle, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next r angle" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "> ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.r_angle, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next dot" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = ".";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.dot, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next question" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "?";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.question, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next colon" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = ":";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.colon, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next semicolon" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = ";";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.semicolon, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next comment" {
    var buffer: [10]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "\t//\tcomment\n";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.comment, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(1, token.inner.byte_start);
    try testing.expectEqual(10, token.inner.length);
}

test "lexer next char" {
    var buffer: [4]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "' \\t:)'";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.char, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(1, token.inner.byte_start);
    try testing.expectEqual(4, token.inner.length);
    try testing.expectEqualStrings(" \t:)", &buffer);
}

test "lexer next string" {
    var buffer: [4]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "\" \\t:)\"";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.string, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(1, token.inner.byte_start);
    try testing.expectEqual(4, token.inner.length);
    try testing.expectEqualStrings(" \t:)", &buffer);
}
