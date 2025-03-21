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

test "lexer next plus" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\n+";
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
    try testing.expectEqualStrings("+", &buffer);
}
