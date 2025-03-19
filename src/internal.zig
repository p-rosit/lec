pub const lib = @cImport({
    @cInclude("lec_token.h");
    @cInclude("lec.h");
});

pub fn enumToError(err: lib.LecError) !void {
    switch (err) {
        lib.LEC_ERROR_OK => return,
        lib.LEC_ERROR_NULL => return error.Null,
        lib.LEC_ERROR_BUFFER => return error.Buffer,
        else => return error.Unknown,
    }
}
