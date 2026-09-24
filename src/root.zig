const std = @import("std");
const Io = std.Io;

pub const c = @cImport({
    @cInclude("regex.h");
    @cInclude("regex_slim.h");
    @cInclude("stdio.h");
});

pub fn exec(allocator: std.mem.Allocator, pattern: [:0]const u8, input: [:0]const u8) !struct { bool, []c.regmatch_t } {
    const re = try Regex.init(pattern);
    defer re.deinit();

    var captures = try allocator.alloc(c.regmatch_t, re.re_nsub() + 1);
    const result = re.exec(input, captures.len, captures.ptr);

    return .{ result, captures };
}

pub fn returnstrings(allocator: std.mem.Allocator) !void {
    const string = "Hola, como estais?";
    const slice = &string;
    std.debug.print("{}\n", .{@TypeOf(string)});
    std.debug.print("{}\n", .{@TypeOf(slice)});
    const strings = try allocator.alloc(*const []u8, 3);
    defer allocator.free(strings);

    //const slice: []const u8 = string[6..10];
    // const hej = {strig[6..10] };
    std.debug.print("{any}\n", .{strings.len});
    std.debug.print("{any}\n", .{strings});
}

pub fn matches(pattern: [:0]const u8, input: [:0]const u8) !bool {
    const re = try Regex.init(pattern);
    defer re.deinit();

    return re.matches(input);
}

pub const Regex = struct {
    inner: *c.regex_t,

    pub fn init(pattern: [:0]const u8) !Regex {
        const inner = c.alloc_regex_t().?;
        if (0 != c.regcomp(inner, pattern, c.REG_NEWLINE | c.REG_EXTENDED)) {
            return error.compile;
        }

        return .{
            .inner = inner,
        };
    }

    pub fn deinit(self: Regex) void {
        c.free_regex_t(self.inner);
    }

    pub fn matches(self: Regex, input: [:0]const u8) bool {
        return 0 == c.regexec(self.inner, input, 0, null, 0);
    }

    pub fn exec(self: Regex, input: [:0]const u8, size: usize, caps: [*c]c.regmatch_t) bool {
        return 0 == c.regexec(self.inner, input, size, caps, 0);
    }

    pub fn re_nsub(self: Regex) usize {
        return c.re_nsub(self.inner);
    }
};

test "exec" {
    const allocator = std.testing.allocator;
    const result = try exec(allocator, "encoder has position ([0-9]*) and speed ([0-9]*)", "encoder has position 25 and speed 100");
    defer allocator.free(result[1]);
    try std.testing.expect(result[0]);
}

test "matches" {
    const result = try matches("encoder has position ([0-9]*) and speed ([0-9]*)", "encoder has position 25 and speed 100");
    try std.testing.expect(result);
}

test "strings" {
    const allocator = std.testing.allocator;
    try returnstrings(allocator);
}
