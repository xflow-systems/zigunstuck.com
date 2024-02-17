const std = @import("std");
const testing = std.testing;

const c = @cImport({
    @cInclude("tree_sitter/api.h");
    @cInclude("tree_sitter/highlight.h");
    @cInclude("tree-sitter-zig/src/tree_sitter/parser.h");
});

extern "c" fn tree_sitter_zig() *c.TSLanguage;

const names: []const [*c]const u8 = &.{
    "attribute",
    "boolean",
    "character",
    "comment",
    "conditional",
    "constant",
    "constant.builtin",
    "error",
    "exception",
    "exception",
    "field",
    "float",
    "function",
    "function.builtin",
    "include",
    "include",
    "keyword",
    "keyword.coroutine",
    "keyword.function",
    "keyword.operator",
    "keyword.return",
    "label",
    "number",
    "operator",
    "parameter",
    "punctuation.bracket",
    "punctuation.delimiter",
    "punctuation.special",
    "repeat",
    "spell",
    "storageclass",
    "string",
    "string.escape",
    "string.special",
    "type",
    "type.builtin",
    "type.qualifier",
    "variable",
    "variable.builtin",
};

pub fn to_tagged_html(source_code: []const u8) ![]const u8 {
    // const parser: ?*c.TSParser = c.ts_parser_new();
    // defer c.ts_parser_delete(parser);
    // const set_lang_success = c.ts_parser_set_language(parser, tree_sitter_zig());
    // try testing.expect(set_lang_success);

    // const tree = c.ts_parser_parse_string(parser, null, source_code, source_code.len);
    // defer c.ts_tree_delete(tree);
    // const root_node = c.ts_tree_root_node(tree);
    // std.debug.print("syntax tree: {s}\n", .{c.ts_node_string(root_node)});

    // const attribute_strings: []const [*c]const u8 = &.{ "comment", "a", "", "", "", "" };
    // var attribute_strings: [names.len][*c]const u8 = undefined;

    // for (0..names.len) |name_index| {
    //     attribute_strings[name_index] = names[name_index];
    // }

    // todo replace 1 with 5 / names.len
    const highlighter = c.ts_highlighter_new(@constCast(@ptrCast(names)), @constCast(@ptrCast(names)), @truncate(names.len));
    defer c.ts_highlighter_delete(highlighter);

    // TODO use relative file paths
    const highlights_query_path = "queries/highlights.scm";
    const highlights_query = @embedFile(highlights_query_path);
    const highlights_query_ptr: [*c]const u8 = highlights_query;

    const injections_query_path = "queries/injections.scm";
    const injections_query = @embedFile(injections_query_path);
    const injections_query_ptr: [*c]const u8 = injections_query;

    const empty: [:0]const u8 = "";
    const lang_name: [:0]const u8 = "zig";
    const scope_name: [:0]const u8 = "source.zig";
    const injection_regex: [:0]const u8 = "^zig";

    std.debug.print("queries {}\n\n", .{highlights_query.len});

    _ = c.ts_highlighter_add_language(
        highlighter,
        lang_name,
        scope_name,
        injection_regex,
        tree_sitter_zig(),
        highlights_query_ptr,
        injections_query_ptr,
        empty,
        highlights_query.len,
        injections_query.len,
        0,
    );

    const buffer = c.ts_highlight_buffer_new();
    defer c.ts_highlight_buffer_delete(buffer);
    const source_code_ptr: [*c]const u8 = @ptrCast(source_code);

    _ = c.ts_highlighter_highlight(highlighter, scope_name, source_code_ptr, @truncate(source_code.len), buffer, 0);

    const html_output: [*c]const u8 = c.ts_highlight_buffer_content(buffer);
    return std.mem.span(html_output);
    // std.debug.print("html: \n\n{s}\n\n", .{spanned_output});
}
