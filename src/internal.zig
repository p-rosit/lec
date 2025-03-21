pub const lib = @cImport({
    @cInclude("gci_reader.h");
    @cInclude("lec_arena.h");
    @cInclude("lec_common.h");
    @cInclude("lec_token.h");
    @cInclude("lec_lexer.h");
    @cInclude("lec_token.h");
});

pub fn enumToError(err: lib.LecError) !void {
    switch (err) {
        lib.LEC_ERROR_OK => return,
        lib.LEC_ERROR_NULL => return error.Null,
        lib.LEC_ERROR_BUFFER => return error.Buffer,
        lib.LEC_ERROR_READER => return error.Reader,
        else => return error.Unknown,
    }
}
