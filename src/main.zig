const std = @import("std");
const testing = std.testing;

const c = @cImport({
    @cInclude("tree_sitter/api.h");
    @cInclude("tree_sitter/highlight.h");
    @cInclude("tree-sitter-zig/src/tree_sitter/parser.h");
});

extern "c" fn tree_sitter_zig() *c.TSLanguage;

const CStrResult = struct {
    bytes: [*c]const u8,
    len: u32,
};

fn cStr(comptime string: []const u8) CStrResult {
    const null_byte = "\x00";
    return CStrResult{ .bytes = string ++ null_byte, .len = string.len + 1 };
}

fn csb(comptime string: []const u8) [*c]const u8 {
    return cStr(string).bytes;
}

pub fn main() !void {
    // const parser: ?*c.TSParser = c.ts_parser_new();
    // defer c.ts_parser_delete(parser);
    // const set_lang_success = c.ts_parser_set_language(parser, tree_sitter_zig());
    // try testing.expect(set_lang_success);

    // const source_code = "const asdf = 1;";
    // const tree = c.ts_parser_parse_string(parser, null, source_code, source_code.len);
    // defer c.ts_tree_delete(tree);
    // const root_node = c.ts_tree_root_node(tree);
    // std.debug.print("syntax tree: {s}\n", .{c.ts_node_string(root_node)});

    // const names: []const []const u8 = &.{ "function", "type", "constant", "keyword", "string" };
    // const attribute_strings: []const []const u8 = &.{ "", "", "", "", "" };

    const names: []const [*c]const u8 = &.{ csb("function"), csb("type"), csb("constant"), csb("keyword"), csb("string") };
    const attribute_strings: []const [*c]const u8 = &.{ csb(""), csb(""), csb(""), csb(""), csb("") };

    // todo replace 1 with 5 / names.len
    const highlighter = c.ts_highlighter_new(@constCast(@ptrCast(names)), @constCast(@ptrCast(attribute_strings)), @truncate(names.len));
    _ = highlighter;

    // const scope = cStr("source.zig");
    // const injection_regex = cStr("^zig");
    // const language = tree_sitter_zig();
    // const highlights_query = cStr(@embedFile("queries/highlights.scm"));
    // const injections_query = cStr(@embedFile("queries/injections.scm"));
    // const locals_query = cStr("");

    // _ = c.ts_highlighter_add_language(
    //     highlighter,
    //     scope.bytes,
    //     injection_regex.bytes,
    //     language,
    //     highlights_query.bytes,
    //     injections_query.bytes,
    //     locals_query.bytes,
    //     highlights_query.len,
    //     injections_query.len,
    //     locals_query.len,
    // );
}
