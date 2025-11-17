const std = @import("std");
const json = std.json;
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

const String = @import("string").String;

pub fn jsonView(allocator: std.mem.Allocator, filename: [:0]const u8) !void {
    const json_data = try std.fs.cwd().readFileAlloc(allocator, filename, 10 * 1024 * 1024);
    defer allocator.free(json_data);

    var parsed = json.parseFromSlice(json.Value, allocator, json_data, .{}) catch |err| {
        std.debug.print("json parse error: {}", .{err});
        return;
    };
    defer parsed.deinit();

    try printJsonObject(allocator, parsed.value);
}

fn printJsonObject(allocator: std.mem.Allocator, value: json.Value) !void {
    var s = String.init(allocator);
    defer s.deinit();

    try formatJsonObject(value, &s, 0, true);

    try stdout.writeAll(s.str());
    try stdout.flush();
}

fn indent(str: *String, depth: usize) !void {
    for (0..depth) |_| {
        str.concat("  ") catch |err| return err;
    }
}

fn quote(str: *String, s: []const u8) !void {
    try str.concat("\"");
    try str.concat(s);
    try str.concat("\"");
}

fn formatJsonObject(value: json.Value, str: *String, depth: usize, root: bool) !void {
    if (root and depth > 0) try indent(str, depth);

    var buf: [1024]u8 = undefined;
    switch (value) {
        .null => |_| try str.concat("\x1b[2mnull\x1b[m"),
        .bool => |b| try str.concat(if (b) "\x1b[33mtrue\x1b[m" else "\x1b[33mfalse\x1b[m"),
        .integer => |n| {
            const formatted = std.fmt.bufPrint(&buf, "{d}", .{n}) catch unreachable;
            try str.concat(formatted);
        },
        .float => |n| {
            const formatted = std.fmt.bufPrint(&buf, "{d}", .{n}) catch unreachable;
            try str.concat(formatted);
        },
        .string, .number_string => |s| {
            try str.concat("\x1b[32m");
            try quote(str, s);
            try str.concat("\x1b[m");
        },
        .array => |a| {
            try str.concat("[\n");

            for (0..a.items.len) |i| {
                try indent(str, depth + 1);
                try formatJsonObject(a.items[i], str, depth + 1, false);
                if (i < a.items.len - 1) try str.concat(",");
                try str.concat("\n");
            }

            try indent(str, depth);
            try str.concat("]");
        },
        .object => |obj| {
            try str.concat("{\n");

            var o = obj.iterator();
            var i: usize = 0;
            while (o.next()) |p| : (i += 1) {
                try indent(str, depth + 1);

                switch (depth % 4) {
                    0 => |_| {
                        try str.concat("\x1b[34m");
                    },
                    1 => |_| {
                        try str.concat("\x1b[36m");
                    },
                    2 => |_| {
                        try str.concat("\x1b[35m");
                    },
                    3 => |_| {
                        try str.concat("\x1b[31m");
                    },
                    else => unreachable,
                }

                try quote(str, p.key_ptr.*);
                try str.concat("\x1b[m: ");
                try formatJsonObject(p.value_ptr.*, str, depth + 1, false);

                if (i < o.len - 1) {
                    try str.concat(",");
                }
                try str.concat("\n");
            }

            try indent(str, depth);
            try str.concat("}");
        },
    }

    if (root) try str.concat("\n");
}
