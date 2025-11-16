const std = @import("std");
const json = std.json;
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

const String = []const u8;

pub fn jsonView(allocator: std.mem.Allocator, filename: String) !void {
    const json_data = try std.fs.cwd().readFileAlloc(allocator, filename, 10 * 1024 * 1024);
    defer allocator.free(json_data);

    var parsed = json.parseFromSlice(json.Value, allocator, json_data, .{}) catch |err| {
        std.debug.print("json parse error: {}", .{err});
        return;
    };
    defer parsed.deinit();

    try printJsonObject(parsed.value, 0);
}

fn indent(depth: usize) !void {
    for (0..depth) |_| {
        try stdout.print("  ", .{});
    }
}

fn printJsonObject(value: json.Value, depth: usize) !void {
    try indent(depth);

    switch (value) {
        .null => |_| try stdout.print("null", .{}),
        .bool => |b| try stdout.print("{}", .{b}),
        .integer => |i| try stdout.print("{d}", .{i}),
        .float => |f| try stdout.print("{d}", .{f}),
        .string => |s| try stdout.print("\"{s}\"", .{s}),
        .array => |a| {
            try stdout.print("[\n", .{});
            for (0..a.items.len) |i| {
                try printJsonObject(a.items[i], depth + 1);
                if (i < a.items.len - 1) {
                    try stdout.print(",\n", .{});
                } else {
                    try stdout.print("\n", .{});
                }
            }
            try indent(depth);
            try stdout.print("]", .{});
        },
        .object => |obj| {
            try stdout.print("{{\n", .{});
            var o = obj.iterator();
            var i: usize = 0;
            while (o.next()) |p| : (i += 1) {
                try indent(depth + 1);
                try stdout.print("\"{s}\": ", .{p.key_ptr.*});
                try printJsonObject(p.value_ptr.*, depth + 1);
                if (i < o.len - 1) {
                    try stdout.print(",\n", .{});
                } else {
                    try stdout.print("\n", .{});
                }
            }
            try indent(depth);
            try stdout.print("}}", .{});
        },
        else => try stdout.print("unknown", .{}),
    }

    if (depth == 0) {
        try stdout.print("\n", .{});
    }
    try stdout.flush();
}
