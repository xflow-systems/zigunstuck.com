const std = @import("std");
const testing = std.testing;

const c = @cImport({
    @cInclude("tree_sitter/api.h");
    @cInclude("tree-sitter-zig/src/tree_sitter/parser.h");
});

extern "c" fn tree_sitter_zig() *c.TSLanguage;

pub fn main() !void {
    const parser: ?*c.TSParser = c.ts_parser_new();
    defer c.ts_parser_delete(parser);
    const set_lang_success = c.ts_parser_set_language(parser, tree_sitter_zig());
    try testing.expect(set_lang_success);

    const source_code = "const asdf = 1;";
    const tree = c.ts_parser_parse_string(parser, null, source_code, source_code.len);
    defer c.ts_tree_delete(tree);
    const root_node = c.ts_tree_root_node(tree);
    std.debug.print("syntax tree: {s}\n", .{c.ts_node_string(root_node)});
}
