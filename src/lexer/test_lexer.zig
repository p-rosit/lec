const testing = @import("std").testing;
const lib = @import("../internal.zig").lib;

test "lexer init" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);
}

test "lexer next single char" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\n-.";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token1: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next1_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_MINUS), token1.type);
    try testing.expectEqual(0, token1.start);
    try testing.expectEqual(1, token1.length);
    try testing.expectEqualStrings("-", buffer[0..1]);

    var token2: lib.LecToken = undefined;
    const next2_err = lib.lec_lexer_next(&lexer, &token2);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_DOT), token2.type);
    try testing.expectEqual(1, token2.start);
    try testing.expectEqual(1, token2.length);
    try testing.expectEqualStrings(".", buffer[1..2]);
}

test "lexer next plus" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "+";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_PLUS), token.type);
    try testing.expectEqual(0, token.start);
    try testing.expectEqual(1, token.length);
}
