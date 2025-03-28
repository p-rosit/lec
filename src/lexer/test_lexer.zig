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

// Section: Empty --------------------------------------------------------------

test "lexer empty" {
    var buffer: [2]u8 = undefined;
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

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_EOF), next_err);
}

test "lexer whitespace" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\n\t   \n";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_EOF), next_err);
}

// Section: Single char tokens -------------------------------------------------

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
    try testing.expectEqual(0, token1.arena_start);
    try testing.expectEqual(1, token1.byte_start);
    try testing.expectEqual(1, token1.length);
    try testing.expectEqualStrings("-", buffer[0..1]);

    var token2: lib.LecToken = undefined;
    const next2_err = lib.lec_lexer_next(&lexer, &token2);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_DOT), token2.type);
    try testing.expectEqual(1, token2.arena_start);
    try testing.expectEqual(2, token2.byte_start);
    try testing.expectEqual(1, token2.length);
    try testing.expectEqualStrings(".", buffer[1..2]);
}

test "lexer next plus" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "+ ";
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
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next plus eof" {
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
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next plus fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "+ ";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_PLUS), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next minus" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "- ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_MINUS), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next minus eof" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "-";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_MINUS), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next minus fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "- ";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_MINUS), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next mul" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "*";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_MUL), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next div" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "/ ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_DIV), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next div eof" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "/";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_DIV), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next div fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "/ ";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_DIV), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next assign" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "= ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_ASSIGN), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next assign eof" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "=";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_ASSIGN), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next assign fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "= ";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_ASSIGN), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next l paren" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "(";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_L_PAREN), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next r paren" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = ")";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_R_PAREN), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next l brack" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "[";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_L_BRACK), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next r brack" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "]";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_R_BRACK), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next l brace" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "{";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_L_BRACE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next r brace" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "}";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_R_BRACE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next l angle" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "< ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_L_ANGLE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next l angle eof" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "<";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_L_ANGLE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next l angle fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "< ";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_L_ANGLE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next r angle" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "> ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_R_ANGLE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next r angle eof" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = ">";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_R_ANGLE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next r angle fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "> ";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_R_ANGLE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next dot" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = ".";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_DOT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next comma" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = ",";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_COMMA), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next question" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "?";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_QUESTION), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next colon" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = ":";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_COLON), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next semicolon" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = ";";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_SEMICOLON), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next not" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "!";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NOT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next preprocess" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "#";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_PREPROC), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

// Section: Multi char tokens --------------------------------------------------

test "lexer next equal" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "==";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_EQUAL), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lexer next equal fail" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "==";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_EQUAL), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lexer next not equal" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "!=";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NEQ), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lexer next not equal fail" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "!=";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NEQ), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lexer next leq" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "<=";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_LEQ), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lexer next leq fail" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "<=";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_LEQ), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lexer next geq" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = ">=";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_GEQ), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lexer next geq fail" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = ">=";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_GEQ), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lexer next increment" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "++";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_INC), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lext next increment fail" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "++";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_INC), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lexer next decrement" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "--";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_DEC), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

test "lexer next decrement fail" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "--";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_DEC), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
}

// Section: Comment ------------------------------------------------------------

test "lexer next comment" {
    var buffer: [8]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\t//\tcomment\n";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_COMMENT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(3, token.byte_start);
    try testing.expectEqual(8, token.length);
    try testing.expectEqualStrings("\tcomment", &buffer);
}

test "lexer next comment eof" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "//a";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_COMMENT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(2, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings("a", &buffer);
}

test "lexer next comment start fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "//-\n";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.reads_before_fail = 3;
    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_COMMENT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(2, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings("-", &buffer);
}

test "lexer next comment fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "//,\n";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 2);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_COMMENT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(2, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings(",", &buffer);
}

// Section: String and char ----------------------------------------------------

test "lexer next char" {
    var buffer: [4]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "' \\t:)'";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_CHAR), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(4, token.length);
    try testing.expectEqualStrings(" \t:)", &buffer);
}

test "lexer next char eof" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "'";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_UNTERMINATED), next_err);
}

test "lexer next char fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "' '";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.reads_before_fail = 2;
    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_CHAR), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings(" ", &buffer);
}

test "lexer next string" {
    var buffer: [4]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\" \\t:)\"";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_STRING), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(4, token.length);
    try testing.expectEqualStrings(" \t:)", &buffer);
}

test "lexer next string eof" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\"";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_UNTERMINATED), next_err);
}

test "lexer next string fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\" \"";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.reads_before_fail = 2;
    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_STRING), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings(" ", &buffer);
}
