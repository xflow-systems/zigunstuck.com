const std = @import("std");
const highlight = @import("./highlight.zig");

const BIG_SIZE = 1024 * 4;

fn readFile(allocator: std.mem.Allocator, file: std.fs.File) ![]u8 {
    var buffer: [BIG_SIZE]u8 = undefined;
    const bytes_read = try file.read(buffer[0..buffer.len]);
    return try allocator.dupe(u8, buffer[0..bytes_read]);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    try std.fs.cwd().makePath("dist/gen");

    const posts_dir = try std.fs.cwd().openDir("./posts", .{ .iterate = true });
    const layout = try std.fs.cwd().openFile("./layout.html", .{});
    const layout_contents = try readFile(allocator, layout);
    std.debug.print("{s}\n", .{layout_contents});

    var walker = try posts_dir.walk(allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        var file = try std.fs.cwd().openFile(try std.fs.path.join(allocator, &.{ "./posts/", entry.path }), .{});
        defer file.close();
        const basename = entry.basename;
        const post_contents = try readFile(allocator, file);
        var post_name = try std.mem.replaceOwned(u8, allocator, basename, ".html", "");
        post_name = try std.mem.replaceOwned(u8, allocator, post_name, "_", " ");

        const final_post_contents = try std.mem.replaceOwned(u8, allocator, layout_contents, "%INNER_CONTENT%", post_contents);
        std.debug.print("{s}\n", .{final_post_contents});

        const rel_path = try std.fs.path.join(allocator, &.{ "dist", "gen", entry.path });
        const new_post_file = try std.fs.cwd().createFile(rel_path, .{ .truncate = true });
        defer new_post_file.close();
        try new_post_file.writeAll(final_post_contents);
        std.debug.print("{s}\n", .{rel_path});
    }

    // const source_code = "\n//asdf\nconst asdf: u32 = 1;\nfn asdf() void { return 0; }";
    // std.debug.print("{s}\n", .{try highlight.to_tagged_html(source_code)});
}
