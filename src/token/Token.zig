const lib = @import("../internal.zig").lib;
const Self = @This();

pub const Type = enum {
    unknown,
    text,
    number_int,
    number_float,
    char,
    string,
    comment,
    plus,
    minus,
    mul,
    div,
    l_paren,
    r_paren,
    l_brack,
    r_brack,
    l_brace,
    r_brace,
    l_angle,
    r_angle,
    dot,
    comma,
    question,
    colon,
    semicolon,

    pub fn fromCEnum(value: lib.LecTokenType) Type {
        return switch (value) {
            lib.LEC_TOKEN_TYPE_UNKNOWN => return .unknown,
            lib.LEC_TOKEN_TYPE_TEXT => return .text,
            lib.LEC_TOKEN_TYPE_NUMBER_INT => return .number_int,
            lib.LEC_TOKEN_TYPE_NUMBER_FLOAT => return .number_float,
            lib.LEC_TOKEN_TYPE_CHAR => return .char,
            lib.LEC_TOKEN_TYPE_STRING => return .string,
            lib.LEC_TOKEN_TYPE_COMMENT => return .comment,
            lib.LEC_TOKEN_TYPE_PLUS => return .plus,
            lib.LEC_TOKEN_TYPE_MINUS => return .minus,
            lib.LEC_TOKEN_TYPE_MUL => return .mul,
            lib.LEC_TOKEN_TYPE_DIV => return .div,
            lib.LEC_TOKEN_TYPE_L_PAREN => return .l_paren,
            lib.LEC_TOKEN_TYPE_R_PAREN => return .r_paren,
            lib.LEC_TOKEN_TYPE_L_BRACK => return .l_brack,
            lib.LEC_TOKEN_TYPE_R_BRACK => return .r_brack,
            lib.LEC_TOKEN_TYPE_L_BRACE => return .l_brace,
            lib.LEC_TOKEN_TYPE_R_BRACE => return .r_brace,
            lib.LEC_TOKEN_TYPE_L_ANGLE => return .l_angle,
            lib.LEC_TOKEN_TYPE_R_ANGLE => return .r_angle,
            lib.LEC_TOKEN_TYPE_DOT => return .dot,
            lib.LEC_TOKEN_TYPE_COMMA => return .comma,
            lib.LEC_TOKEN_TYPE_QUESTION => return .question,
            lib.LEC_TOKEN_TYPE_COLON => return .colon,
            lib.LEC_TOKEN_TYPE_SEMICOLON => return .semicolon,
            else => unreachable,
        };
    }
};

inner: lib.LecToken,

pub fn @"type"(self: Self) Type {
    return Type.fromCEnum(self.inner.type);
}
