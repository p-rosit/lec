const std = @import("std");
const gci = @import("gci");

pub fn testFunc() u8 {
    return 2;
}

test "test" {
    try std.testing.expect(testFunc() == 2);
    _ = @import("gci");
    _ = gci.Reader;
}

test "fail init" {
    var c = try gci.ReaderString.init("1");

    var context = try gci.ReaderFail.init(c.interface(), 0);
    _ = context.interface();
}
