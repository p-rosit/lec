const lib = @import("internal.zig").lib;

pub const Token = struct {
    inner: lib.LecToken,
};
