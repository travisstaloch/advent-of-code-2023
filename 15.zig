//! https://adventofcode.com/2023/day/16

const std = @import("std");
const Box = std.StringArrayHashMapUnmanaged(u8);

fn hash(s: []const u8) u16 {
    var v: u16 = 0;
    for (s) |c| v = ((v + c) * 17) & 0xff;
    return v;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var it = std.mem.tokenizeAny(u8, input, ",\n");
    var part1: usize = 0;
    var boxes = [1]Box{.{}} ** 256;
    while (it.next()) |s| {
        part1 += hash(s);
        const i = std.mem.indexOfAny(u8, s, "-=").?;
        const label = s[0..i];
        const boxid = hash(label);
        if (s[i] == '-') {
            _ = boxes[boxid].orderedRemove(label);
        } else if (s[i] == '=') {
            const foclen = try std.fmt.parseInt(u8, s[i + 1 ..], 10);
            try boxes[boxid].put(alloc, label, foclen);
        }
    }

    var part2: usize = 0;
    for (boxes, 1..) |box, boxid| {
        for (box.values(), 1..) |foclen, slot|
            part2 += boxid * slot * foclen;
    }

    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    std.debug.assert(part1 == 515974);
    std.debug.assert(part2 == 265894);
}
