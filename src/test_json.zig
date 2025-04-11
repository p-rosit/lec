const std = @import("std");
const testing = std.testing;
const con = @import("con");
const gci = @import("gci");
const lec = @import("lec.zig");

const ZigFileReader = gci.Reader(std.fs.File.Reader);

const LexerTest = struct {
    name: []const u8,
    total_arena: usize,
    data: []const u8,
    tokens: []LexerToken,
};

const LexerToken = struct {
    type: lec.Token.Type,
    data: []const u8,
    byte_start: usize,
    arena_start: usize,
};

test {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer _ = arena.deinit();

    var paths = try findTests(allocator);
    defer {
        for (paths.items) |path| {
            allocator.free(path);
        }
        paths.deinit(allocator);
    }

    for (paths.items) |path| {
        const file = try std.fs.cwd().openFile(path, .{});
        var file_reader = ZigFileReader.init(&file.reader());
        var comment_reader = try con.ReaderComment.init(file_reader.interface());

        var depth: [4]con.Container = undefined;
        var parse_context = try con.Deserialize.init(comment_reader.interface(), &depth);

        const tests = parseTests(arena.allocator(), &parse_context) catch |err| {
            std.debug.print("====================================\n", .{});
            std.debug.print("Error parsing {s}\n", .{path});
            return err;
        };
        defer _ = arena.reset(.retain_capacity);

        for (tests.items) |t| {
            try runTest(arena.allocator(), path, t);
        }
    }
}

fn runTest(allocator: std.mem.Allocator, path: []const u8, t: LexerTest) !void {
    var reader = try gci.ReaderString.init(t.data);

    var buffer: [128]u8 = undefined;
    const arena = try lec.Arena.init(&buffer);
    var lexer = try lec.Lexer.init(reader.interface(), arena);

    var tokens = std.ArrayListUnmanaged(lec.Token){};

    while (true) {
        const tok = lexer.next() catch |err| {
            if (error.Eof == err) {
                break;
            }
            return err;
        };
        try tokens.append(allocator, tok);
    }

    if (t.tokens.len != tokens.items.len) {
        std.debug.print("====================================\n", .{});
        std.debug.print(
            \\Test case {s}:{s} failed, expected to parse {} tokens, got {} tokens.
            \\
            \\Data: "{s}"
            \\
            \\Expected tokens:
            \\
        ,
            .{ path, t.name, t.tokens.len, tokens.items.len, t.data },
        );
        for (t.tokens) |token| {
            std.debug.print("  type={}, data=\"{s}\", byte_start={}, arena_start={}\n", .{ token.type, token.data, token.byte_start, token.arena_start });
        }
        std.debug.print("\nGot tokens:\n", .{});
        for (tokens.items) |result| {
            std.debug.print("  type={}, data=\"{s}\", byte_start={}, arena_start={}\n", .{ result.type(), buffer[result.inner.arena_start .. result.inner.arena_start + result.inner.length], result.inner.byte_start, result.inner.arena_start });
        }
        return error.TokenAmount;
    }

    for (0.., t.tokens, tokens.items) |i, token, result| {
        const data = buffer[result.inner.arena_start .. result.inner.arena_start + result.inner.length];
        const wrong_type = token.type != result.type();
        const wrong_arena = token.arena_start != result.inner.arena_start;
        const wrong_byte = token.byte_start != result.inner.byte_start;
        const wrong_length = token.data.len != result.inner.length;
        const wrong_data = !std.mem.eql(u8, token.data, data);

        if (wrong_type or wrong_arena or wrong_byte or wrong_length or wrong_data) {
            std.debug.print("====================================\n", .{});
            std.debug.print("Test {s}:{s} token {} incorrect:\n", .{ path, t.name, i });
            std.debug.print("Expected: type={}, data=\"{s}\", byte_start={}, arena_start={}\n", .{ token.type, token.data, token.byte_start, token.arena_start });
            std.debug.print("Got:      type={}, data=\"{s}\", byte_start={}, arena_start={}\n", .{ result.type(), data, result.inner.byte_start, result.inner.arena_start });
        }

        try testing.expectEqual(token.type, result.type());
        try testing.expectEqual(token.arena_start, result.inner.arena_start);
        try testing.expectEqual(token.byte_start, result.inner.byte_start);
        try testing.expectEqual(token.data.len, result.inner.length);
        try testing.expectEqualStrings(token.data, data);
    }

    const err = lexer.next();
    try testing.expectError(error.Eof, err);
}

fn findTests(allocator: std.mem.Allocator) !std.ArrayListUnmanaged([]u8) {
    var paths: std.ArrayListUnmanaged([]u8) = .{};
    const dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
    var walker = try dir.walk(allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        if (entry.kind != .file) {
            continue;
        }
        if (entry.basename[0] == '.') {
            continue;
        }
        if (!std.mem.eql(u8, ".json", std.fs.path.extension(entry.basename))) {
            continue;
        }

        const path = try allocator.dupe(u8, entry.path);
        try paths.append(allocator, path);
    }

    return paths;
}

fn parseTests(allocator: std.mem.Allocator, parse_context: *con.Deserialize) !std.ArrayListUnmanaged(LexerTest) {
    var ts = std.ArrayListUnmanaged(LexerTest){};

    try parse_context.arrayOpen();

    var next: con.DeserializeType = .string;
    while (true) : (next = try parse_context.next()) {
        if (next == .array_close) {
            break;
        }
        const t = try parseTest(allocator, parse_context);
        try ts.append(allocator, t);
    }

    try parse_context.arrayClose();
    return ts;
}

fn parseTest(allocator: std.mem.Allocator, parse_context: *con.Deserialize) !LexerTest {
    var t: LexerTest = undefined;
    var steps: std.ArrayListUnmanaged(LexerToken) = .{};

    try parse_context.dictOpen();
    {
        const buffer = try allocator.alloc(u8, 1024);
        var sw = try gci.WriterString.init(buffer);

        const name_key_start = sw.start();
        try parse_context.dictKey(sw.interface());
        try testing.expectEqualStrings("name", try sw.end(name_key_start));

        const name_start = sw.start();
        try parse_context.string(sw.interface());
        t.name = try sw.end(name_start);

        const data_key_start = sw.start();
        try parse_context.dictKey(sw.interface());
        try testing.expectEqualStrings("data", try sw.end(data_key_start));

        const data_start = sw.start();
        try parse_context.string(sw.interface());
        t.data = try sw.end(data_start);

        const result_start = sw.start();
        try parse_context.dictKey(sw.interface());
        try testing.expectEqualStrings("result", try sw.end(result_start));

        try parse_context.arrayOpen();

        var next: con.DeserializeType = .string;
        while (true) : (next = try parse_context.next()) {
            if (next == .array_close) {
                break;
            }

            const step = try parseTestStep(parse_context, &sw);
            try steps.append(allocator, step);
        }

        try parse_context.arrayClose();
        t.tokens = try steps.toOwnedSlice(allocator);
    }
    try parse_context.dictClose();

    var arena_position: usize = 0;
    for (t.tokens) |*step| {
        step.arena_start = arena_position;
        arena_position += step.data.len;
    }

    return t;
}

fn parseTestStep(parse_context: *con.Deserialize, writer: *gci.WriterString) !LexerToken {
    var tok: LexerToken = undefined;

    try parse_context.dictOpen();
    {
        const type_key_start = writer.start();
        try parse_context.dictKey(writer.interface());
        try testing.expectEqualStrings("type", try writer.end(type_key_start));

        const type_start = writer.start();
        try parse_context.string(writer.interface());
        tok.type = try parseTokenType(try writer.end(type_start));

        const data_key_start = writer.start();
        try parse_context.dictKey(writer.interface());
        try testing.expectEqualStrings("data", try writer.end(data_key_start));

        const data_start = writer.start();
        try parse_context.string(writer.interface());
        tok.data = try writer.end(data_start);

        const byte_key_start = writer.start();
        try parse_context.dictKey(writer.interface());
        try testing.expectEqualStrings("byte_start", try writer.end(byte_key_start));

        const byte_start = writer.start();
        try parse_context.number(writer.interface());
        tok.byte_start = try std.fmt.parseInt(usize, try writer.end(byte_start), 0);
    }
    try parse_context.dictClose();

    return tok;
}

fn parseTokenType(token_type: []const u8) !lec.Token.Type {
    if (std.mem.eql(u8, "text", token_type)) {
        return .text;
    } else if (std.mem.eql(u8, "whitespace", token_type)) {
        return .whitespace;
    } else if (std.mem.eql(u8, "newline", token_type)) {
        return .newline;
    } else if (std.mem.eql(u8, "escaped_newline", token_type)) {
        return .escaped_newline;
    } else if (std.mem.eql(u8, "number_int", token_type)) {
        return .number_int;
    } else if (std.mem.eql(u8, "number_bin", token_type)) {
        return .number_bin;
    } else if (std.mem.eql(u8, "number_hex", token_type)) {
        return .number_hex;
    } else if (std.mem.eql(u8, "number_float", token_type)) {
        return .number_float;
    } else if (std.mem.eql(u8, "char", token_type)) {
        return .char;
    } else if (std.mem.eql(u8, "string", token_type)) {
        return .string;
    } else if (std.mem.eql(u8, "comment", token_type)) {
        return .comment;
    } else if (std.mem.eql(u8, "plus", token_type)) {
        return .plus;
    } else if (std.mem.eql(u8, "minus", token_type)) {
        return .minus;
    } else if (std.mem.eql(u8, "mul", token_type)) {
        return .mul;
    } else if (std.mem.eql(u8, "div", token_type)) {
        return .div;
    } else if (std.mem.eql(u8, "assign", token_type)) {
        return .assign;
    } else if (std.mem.eql(u8, "equal", token_type)) {
        return .equal;
    } else if (std.mem.eql(u8, "neq", token_type)) {
        return .neq;
    } else if (std.mem.eql(u8, "leq", token_type)) {
        return .leq;
    } else if (std.mem.eql(u8, "geq", token_type)) {
        return .geq;
    } else if (std.mem.eql(u8, "inc", token_type)) {
        return .inc;
    } else if (std.mem.eql(u8, "dec", token_type)) {
        return .dec;
    } else if (std.mem.eql(u8, "not", token_type)) {
        return .not;
    } else if (std.mem.eql(u8, "l_paren", token_type)) {
        return .l_paren;
    } else if (std.mem.eql(u8, "r_paren", token_type)) {
        return .r_paren;
    } else if (std.mem.eql(u8, "l_brack", token_type)) {
        return .l_brack;
    } else if (std.mem.eql(u8, "r_brack", token_type)) {
        return .r_brack;
    } else if (std.mem.eql(u8, "l_brace", token_type)) {
        return .l_brace;
    } else if (std.mem.eql(u8, "r_brace", token_type)) {
        return .r_brace;
    } else if (std.mem.eql(u8, "l_angle", token_type)) {
        return .l_angle;
    } else if (std.mem.eql(u8, "r_angle", token_type)) {
        return .r_angle;
    } else if (std.mem.eql(u8, "dot", token_type)) {
        return .dot;
    } else if (std.mem.eql(u8, "comma", token_type)) {
        return .comma;
    } else if (std.mem.eql(u8, "question", token_type)) {
        return .question;
    } else if (std.mem.eql(u8, "colon", token_type)) {
        return .colon;
    } else if (std.mem.eql(u8, "semicolon", token_type)) {
        return .semicolon;
    } else if (std.mem.eql(u8, "preproc", token_type)) {
        return .preproc;
    }

    return error.UnknownTokenType;
}
