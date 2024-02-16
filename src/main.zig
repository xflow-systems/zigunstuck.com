const std = @import("std");
const testing = std.testing;

const c = @cImport({
    @cInclude("tree_sitter/api.h");
    @cInclude("tree_sitter/highlight.h");
    @cInclude("tree-sitter-zig/src/tree_sitter/parser.h");
});

extern "c" fn tree_sitter_zig() *c.TSLanguage;

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

    const names: []const []const u8 = &.{ "function", "type", "constant", "keyword", "string" };
    const attribute_strings: []const []const u8 = &.{ "", "", "", "", "" };

    // todo replace 1 with 5 / names.len
    const highlighter = c.ts_highlighter_new(@constCast(@ptrCast(names)), @constCast(@ptrCast(attribute_strings)), 0);

    const scope = "source.zig";
    const injection_regex = "^zig";
    const language = tree_sitter_zig();
    const highlights_query = @embedFile("queries/highlights.scm");
    const injections_query = @embedFile("queries/injections.scm");
    const locals_query = "";

    _ = c.ts_highlighter_add_language(
        highlighter,
        scope,
        injection_regex,
        language,
        highlights_query,
        injections_query,
        locals_query,
        highlights_query.len,
        injections_query.len,
        locals_query.len,
    );
}
