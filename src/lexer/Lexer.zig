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

// Section: Empty --------------------------------------------------------------

test "lexer empty" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Eof, err);
}

test "lexer whitespace" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "\n\t   \n";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Eof, err);
}

// Section: Single char tokens -------------------------------------------------

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

test "lexer next plus eof" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "+";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.plus, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next plus fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "+ ";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

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

test "lexer next minus eof" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "-";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.minus, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next minus fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "- ";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

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

test "lexer next div eof" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "/";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.div, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next div fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "/ ";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

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

test "lext next assign eof" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "=";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.assign, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next assign fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "= ";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.assign, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
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

test "lexer next l angle eof" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "<";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.l_angle, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next l angle fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "< ";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

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

test "lexer next r angle eof" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = ">";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.r_angle, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next r angle fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "> ";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

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

test "lexer next not" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "!";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.not, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

test "lexer next preprocess" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "#";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.preproc, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
}

// Section: Multi char tokens --------------------------------------------------

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

test "lexer next equal fail" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "==";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.equal, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer next not equal" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "!=";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.neq, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer next not equal fail" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "!=";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.neq, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer next leq" {
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

test "lexer next leq fail" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "<=";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.leq, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer next geq" {
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

test "lexer next geq fail" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = ">=";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.geq, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer next increment" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "++";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.inc, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer next increment fail" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "++";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.inc, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer next decrement" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "--";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.dec, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

test "lexer next decrement fail" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "--";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.dec, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
}

// Section: Comment ------------------------------------------------------------

test "lexer next comment" {
    var buffer: [9]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "//\tcomment\n";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.comment, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(2, token.inner.byte_start);
    try testing.expectEqual(8, token.inner.length);
    try testing.expectEqualStrings("\tcomment", buffer[0..8]);

    const newline = try lexer.next();
    try testing.expectEqual(TokenType.newline, newline.type());
    try testing.expectEqualStrings("\n", buffer[8..9]);
}

test "lexer next comment eof" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "//a";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.comment, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(2, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings("a", &buffer);
}

test "lext next comment start fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "//-\n";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.reads_before_fail = 3;
    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.comment, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(2, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings("-", &buffer);
}

test "lexer next comment fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "//,\n";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 2);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.comment, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(2, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings(",", &buffer);
}

// Section: String and char ----------------------------------------------------

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

test "lexer next char eof" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "'";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const err = lexer.next();
    try testing.expectError(error.Unterminated, err);
}

test "lexer next char fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "' '";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.reads_before_fail = 2;
    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.char, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(1, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings(" ", &buffer);
}

test "lexer next char escape fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "'\\t'";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 2);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.char, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(1, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings("\t", &buffer);
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

test "lexer next string eof" {
    var buffer: [4]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "\"";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const err = lexer.next();
    try testing.expectError(error.Unterminated, err);
}

test "lexer next string fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "\" \"";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.reads_before_fail = 2;
    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.string, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(1, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings(" ", &buffer);
}

test "lexer next string escape fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "\"\\t\"";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 2);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.string, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(1, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings("\t", &buffer);
}

// Section: Number -------------------------------------------------------------

test "lexer next int" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "12 ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_int, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
    try testing.expectEqualStrings("12", &buffer);
}

test "lexer next int eof" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "32";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_int, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
    try testing.expectEqualStrings("32", &buffer);
}

test "lexer next int fail" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "60";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err1 = lexer.next();
    try testing.expectError(error.Reader, err1);

    reader.inner.amount_of_reads = 0;

    const err2 = lexer.next();
    try testing.expectError(error.Reader, err2);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_int, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
    try testing.expectEqualStrings("60", &buffer);
}

test "lexer next number type fail" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0x3";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 1);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.reads_before_fail = 3;
    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_hex, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings("3", &buffer);
}

test "lexer next hex" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0x2f ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_hex, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
    try testing.expectEqualStrings("2f", &buffer);
}

test "lexer next hex eof" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0x2f";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_hex, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
    try testing.expectEqualStrings("2f", &buffer);
}

test "lexer next hex fail" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0xa3";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 2);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.reads_before_fail = 3;
    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_hex, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
    try testing.expectEqualStrings("a3", &buffer);
}

test "lexer next bin" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0b10 ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_bin, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
    try testing.expectEqualStrings("10", &buffer);
}

test "lexer next bin eof" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0b10";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_bin, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
    try testing.expectEqualStrings("10", &buffer);
}

test "lexer next bin fail" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0b11";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 2);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.reads_before_fail = 3;
    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_bin, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(2, token.inner.length);
    try testing.expectEqualStrings("11", &buffer);
}

test "lexer next zero" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0 ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_int, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings("0", &buffer);
}

test "lexer next zero eof" {
    var buffer: [1]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_int, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(1, token.inner.length);
    try testing.expectEqualStrings("0", &buffer);
}

test "lexer next float" {
    var buffer: [9]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "12.93e+34 ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_float, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(9, token.inner.length);
    try testing.expectEqualStrings("12.93e+34", &buffer);
}

test "lexer next float eof" {
    var buffer: [9]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "12.93e-34";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_float, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(9, token.inner.length);
    try testing.expectEqualStrings("12.93e-34", &buffer);
}

test "lexer next float point" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0. ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const err = lexer.next();
    try testing.expectError(error.Number, err);
}

test "lexer next float point eof" {
    var buffer: [2]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0.";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const err = lexer.next();
    try testing.expectError(error.Number, err);
}

test "lexer next float point fail" {
    var buffer: [3]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "0.";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 2);

    var lexer = try Self.init(reader.interface(), arena);
    const err1 = lexer.next();
    try testing.expectError(error.Reader, err1);

    reader.inner.amount_of_reads = 0;

    const err2 = lexer.next();
    try testing.expectError(error.Number, err2);
}

test "lexer next float fraction" {
    var buffer: [3]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "4.3 ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_float, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(3, token.inner.length);
    try testing.expectEqualStrings("4.3", &buffer);
}

test "lexer next float fraction eof" {
    var buffer: [3]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "4.3";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_float, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(3, token.inner.length);
    try testing.expectEqualStrings("4.3", &buffer);
}

test "lexer next float fraction fail" {
    var buffer: [3]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "4.3";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 2);

    var lexer = try Self.init(reader.interface(), arena);
    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_float, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(3, token.inner.length);
    try testing.expectEqualStrings("4.3", &buffer);
}

test "lexer next float e" {
    var buffer: [4]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "5.0e ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const err = lexer.next();
    try testing.expectError(error.Number, err);
}

test "lexer next float e eof" {
    var buffer: [4]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "5.0e";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const err = lexer.next();
    try testing.expectError(error.Number, err);
}

test "lexer next float e fail" {
    var buffer: [4]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "5.0e";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 4);

    var lexer = try Self.init(reader.interface(), arena);
    const err1 = lexer.next();
    try testing.expectError(error.Reader, err1);

    reader.inner.amount_of_reads = 0;

    const err2 = lexer.next();
    try testing.expectError(error.Number, err2);
}

test "lexer next float exponent sign" {
    var buffer: [5]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "7.2e+ ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const err = lexer.next();
    try testing.expectError(error.Number, err);
}

test "lexer next float exponent sign eof" {
    var buffer: [5]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "7.2e+";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const err = lexer.next();
    try testing.expectError(error.Number, err);
}

test "lexer next float exponent sign fail" {
    var buffer: [5]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "7.2e+";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 5);

    var lexer = try Self.init(reader.interface(), arena);
    const err1 = lexer.next();
    try testing.expectError(error.Reader, err1);

    reader.inner.amount_of_reads = 0;

    const err2 = lexer.next();
    try testing.expectError(error.Number, err2);
}

test "lexer next float exponent" {
    var buffer: [5]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "1.2e3 ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_float, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(5, token.inner.length);
    try testing.expectEqualStrings("1.2e3", &buffer);
}

test "lexer next float exponent eof" {
    var buffer: [5]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "1.2e3";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_float, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(5, token.inner.length);
    try testing.expectEqualStrings("1.2e3", &buffer);
}

test "lexer next float exponent fail" {
    var buffer: [6]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "1.2e34";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 5);

    var lexer = try Self.init(reader.interface(), arena);
    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.number_float, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(6, token.inner.length);
    try testing.expectEqualStrings("1.2e34", &buffer);
}

// Section: Text ---------------------------------------------------------------

test "lexer next text" {
    var buffer: [3]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "int ";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.text, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(3, token.inner.length);
}

test "lexer next text eof" {
    var buffer: [3]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "int";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);
    const token = try lexer.next();
    try testing.expectEqual(TokenType.text, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(3, token.inner.length);
    try testing.expectEqualStrings("int", &buffer);
}

test "lexer next text fail" {
    var buffer: [3]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "int";
    var r = try gci.ReaderString.init(data);
    var reader = try gci.ReaderFail.init(r.interface(), 2);

    var lexer = try Self.init(reader.interface(), arena);

    const err = lexer.next();
    try testing.expectError(error.Reader, err);

    reader.inner.amount_of_reads = 0;

    const token = try lexer.next();
    try testing.expectEqual(TokenType.text, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(3, token.inner.length);
    try testing.expectEqualStrings("int", &buffer);
}

test "lexer next text characters" {
    var buffer: [4]u8 = undefined;
    const arena = try zlec.Arena.init(&buffer);

    const data = "i_23/";
    var reader = try gci.ReaderString.init(data);

    var lexer = try Self.init(reader.interface(), arena);

    const token = try lexer.next();
    try testing.expectEqual(TokenType.text, token.type());
    try testing.expectEqual(0, token.inner.arena_start);
    try testing.expectEqual(0, token.inner.byte_start);
    try testing.expectEqual(4, token.inner.length);
    try testing.expectEqualStrings("i_23", &buffer);
}
