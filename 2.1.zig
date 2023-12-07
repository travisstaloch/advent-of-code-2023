const std = @import("std");
const Color = enum { red, green, blue };

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    const rgb_limits = [3]u8{ 12, 13, 14 };
    var parts = @Vector(2, usize){ 0, 0 };

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var powers = @Vector(3, usize){ 0, 0, 0 };
        var lineit = std.mem.splitSequence(u8, line, ": ");
        var gameid = try std.fmt.parseInt(u8, lineit.next().?[5..], 10);
        var it = std.mem.tokenizeAny(u8, lineit.next().?, "; ,");
        while (true) {
            const n = try std.fmt.parseInt(usize, it.next() orelse break, 10);
            const color = std.meta.stringToEnum(Color, it.next().?) orelse
                return error.ParseFailure;
            const color_int = @intFromEnum(color);
            gameid *= @intFromBool(n <= rgb_limits[color_int]);
            powers[color_int] = @max(powers[color_int], n);
        }
        parts += .{ gameid, @reduce(.Mul, powers) };
    }
    std.debug.print("part1={} part2={}\n", .{ parts[0], parts[1] });
}
