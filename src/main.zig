const std = @import("std");
const highlight = @import("./highlight.zig");

pub fn main() !void {
    const source_code = "\n//asdf\nconst asdf: u32 = 1;\nfn asdf() void { return 0; }";
    std.debug.print("{s}\n", .{try highlight.to_tagged_html(source_code)});
}
