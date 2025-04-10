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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_EOF), next_err);
}

// Section: Single char tokens -------------------------------------------------

test "lexer whitespace" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\n";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NEWLINE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_PREPROC), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
}

// Section: Multi char tokens --------------------------------------------------

test "lexer next whitespace" {
    var buffer: [3]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = " \t _";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_WHITESPACE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(3, token.length);
}

test "lexer next whitespace eof" {
    var buffer: [3]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = " \t ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_WHITESPACE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(3, token.length);
}

test "lexer next whitespace fail" {
    var buffer: [3]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = " \t ";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 2);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;

    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_WHITESPACE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(3, token.length);
}

test "lexer next escaped newline" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\\\n ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_ESCAPED_NEWLINE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next escaped newline eof" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\\\n";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_ESCAPED_NEWLINE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(1, token.length);
}

test "lexer next escaped newline fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\\\n";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;

    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_ESCAPED_NEWLINE), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(1, token.length);
}

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    var buffer: [9]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "//\tcomment\n";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_COMMENT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(2, token.byte_start);
    try testing.expectEqual(8, token.length);
    try testing.expectEqualStrings("\tcomment", buffer[0..8]);

    const newline_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), newline_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NEWLINE), token.type);
    try testing.expectEqualStrings("\n", buffer[8..9]);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.reads_before_fail = 3;
    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.reads_before_fail = 2;
    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_CHAR), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings(" ", &buffer);
}

test "lexer next char escape fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "'\\t'";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 2);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_CHAR), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings("\t", &buffer);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

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
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.reads_before_fail = 2;
    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_STRING), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings(" ", &buffer);
}

test "lexer next string escape fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "\"\\t\"";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data.ptr, data.len);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 2);
    try testing.expectEqual(@as(c_uint, lib.GCI_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_STRING), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(1, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings("\t", &buffer);
}

// Section: Number -------------------------------------------------------------

test "lexer next int" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "12 ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_INT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
    try testing.expectEqualStrings("12", &buffer);
}

test "lexer next int eof" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "32";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_INT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
    try testing.expectEqualStrings("32", &buffer);
}

test "lexer next int fail" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "60";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next2_err);

    reader.amount_of_reads = 0;

    const next3_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next3_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_INT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
    try testing.expectEqualStrings("60", &buffer);
}

test "lexer next number type fail" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0x3";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 1);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.reads_before_fail = 3;
    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_HEX), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings("3", &buffer);
}

test "lexer next hex" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0x2f ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_HEX), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
    try testing.expectEqualStrings("2f", &buffer);
}

test "lexer next hex eof" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0x2f";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_HEX), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
    try testing.expectEqualStrings("2f", &buffer);
}

test "lexer next hex fail" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0xa3";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 2);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.reads_before_fail = 3;
    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_HEX), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
    try testing.expectEqualStrings("a3", &buffer);
}

test "lexer next bin" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0b10 ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_BIN), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
    try testing.expectEqualStrings("10", &buffer);
}

test "lexer next bin eof" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0b10";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_BIN), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
    try testing.expectEqualStrings("10", &buffer);
}

test "lexer next bin fail" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0b11";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 2);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.reads_before_fail = 3;
    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_BIN), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(2, token.length);
    try testing.expectEqualStrings("11", &buffer);
}

test "lexer next zero" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0 ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_INT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings("0", &buffer);
}

test "lexer next zero eof" {
    var buffer: [1]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_INT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(1, token.length);
    try testing.expectEqualStrings("0", &buffer);
}

test "lexer next float" {
    var buffer: [9]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "12.93e+34 ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_FLOAT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(9, token.length);
    try testing.expectEqualStrings("12.93e+34", &buffer);
}

test "lexer next float eof" {
    var buffer: [9]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "12.93e-34";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_FLOAT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(9, token.length);
    try testing.expectEqualStrings("12.93e-34", &buffer);
}

test "lexer next float point" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0. ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_NUMBER), next_err);
}

test "lexer next float point eof" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0.";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_NUMBER), next_err);
}

test "lexer next float point fail" {
    var buffer: [2]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "0.";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 2);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_NUMBER), next2_err);
}

test "lexer next float fraction" {
    var buffer: [3]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "4.3 ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_FLOAT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(3, token.length);
    try testing.expectEqualStrings("4.3", &buffer);
}

test "lexer next float fraction eof" {
    var buffer: [3]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "4.3";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_FLOAT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(3, token.length);
    try testing.expectEqualStrings("4.3", &buffer);
}

test "lexer next float fraction fail" {
    var buffer: [3]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "4.3";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 2);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_FLOAT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(3, token.length);
    try testing.expectEqualStrings("4.3", &buffer);
}

test "lexer next float e" {
    var buffer: [4]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "5.0e ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_NUMBER), next_err);
}

test "lexer next float e eof" {
    var buffer: [4]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "5.0e";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_NUMBER), next_err);
}

test "lexer next float e fail" {
    var buffer: [4]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "5.0e";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 4);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_NUMBER), next2_err);
}

test "lexer next float exponent sign" {
    var buffer: [5]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "7.2e+ ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_NUMBER), next_err);
}

test "lexer next float exponent sign eof" {
    var buffer: [5]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "7.2e+";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_NUMBER), next_err);
}

test "lexer next float exponent sign fail" {
    var buffer: [5]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "7.2e+";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 5);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_NUMBER), next2_err);
}

test "lexer next float exponent" {
    var buffer: [5]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "1.2e3 ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_FLOAT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(5, token.length);
    try testing.expectEqualStrings("1.2e3", &buffer);
}

test "lexer next float exponent eof" {
    var buffer: [5]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "1.2e3";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_FLOAT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(5, token.length);
    try testing.expectEqualStrings("1.2e3", &buffer);
}

test "lexer next float exponent fail" {
    var buffer: [6]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "1.2e34";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 5);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_NUMBER_FLOAT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(6, token.length);
    try testing.expectEqualStrings("1.2e34", &buffer);
}

// Section: Text ---------------------------------------------------------------

test "lexer next text" {
    var buffer: [3]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "int ";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_TEXT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(3, token.length);
    try testing.expectEqualStrings("int", &buffer);
}

test "lexer next text eof" {
    var buffer: [3]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "int";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_TEXT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(3, token.length);
    try testing.expectEqualStrings("int", &buffer);
}

test "lexer next text fail" {
    var buffer: [3]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "int";
    var r: lib.GciReaderString = undefined;
    const r_init = lib.gci_reader_string_init(&r, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), r_init);
    var reader: lib.GciReaderFail = undefined;
    const reader_init = lib.gci_reader_fail_init(&reader, lib.gci_reader_string_interface(&r), 2);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_fail_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next1_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_READER), next1_err);

    reader.amount_of_reads = 0;

    const next2_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next2_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_TEXT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(3, token.length);
    try testing.expectEqualStrings("int", &buffer);
}

test "lexer next text characters" {
    var buffer: [4]u8 = undefined;
    var arena: lib.LecArena = undefined;
    const arena_init = lib.lec_arena_init(&arena, &buffer, buffer.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), arena_init);

    const data = "i_23/";
    var reader: lib.GciReaderString = undefined;
    const reader_init = lib.gci_reader_string_init(&reader, data, data.len);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), reader_init);

    var lexer: lib.LecLexer = undefined;
    const init_err = lib.lec_lexer_init(&lexer, lib.gci_reader_string_interface(&reader), arena);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), init_err);

    var token: lib.LecToken = undefined;
    const next_err = lib.lec_lexer_next(&lexer, &token);
    try testing.expectEqual(@as(c_uint, lib.LEC_ERROR_OK), next_err);
    try testing.expectEqual(@as(c_uint, lib.LEC_TOKEN_TYPE_TEXT), token.type);
    try testing.expectEqual(0, token.arena_start);
    try testing.expectEqual(0, token.byte_start);
    try testing.expectEqual(4, token.length);
    try testing.expectEqualStrings("i_23", &buffer);
}
