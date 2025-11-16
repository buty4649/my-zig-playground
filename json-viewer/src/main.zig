const std = @import("std");
const json_viewer = @import("json_viewer");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = std.process.args();
    _ = args.skip();

    while (args.next()) |arg| {
        try json_viewer.jsonView(allocator, arg);
    }
}
