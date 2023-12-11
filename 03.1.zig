//! https://adventofcode.com/2023/day/3
//! this one follows SpexGuy's solution https://zigbin.io/d3b52f because i
//! wanted to understand it better.

const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var part1: usize = 0;
    var part2: usize = 0;

    const linelen = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    var gears = std.AutoArrayHashMap(usize, [2]usize).init(alloc);

    var digstart: ?usize = null;
    for (0..input.len) |i| {
        const isdig = std.ascii.isDigit(input[i]);
        if (isdig and digstart == null) {
            digstart = i;
        } else if (!isdig and digstart != null) { // digit end
            const dig = input[digstart.?..i];
            digstart = null;
            const abovei = if (i > linelen) i - linelen else i;
            const belowi = if (i + linelen < input.len) i + linelen else i;
            const nbor_symi = sym: for ([_]usize{ abovei, i, belowi }) |endi| {
                for ((endi - dig.len) -| 1..endi + 1) |ii| {
                    const c = input[ii];
                    if (c != '.' and
                        !std.ascii.isWhitespace(c) and
                        !std.ascii.isDigit(c))
                        break :sym ii;
                }
            } else null;

            if (nbor_symi) |symi| {
                const n = try std.fmt.parseInt(usize, dig, 10);
                part1 += n;
                if (input[symi] == '*') {
                    const gop = try gears.getOrPut(symi);
                    if (!gop.found_existing) gop.value_ptr.* = .{ 0, 1 };
                    gop.value_ptr[0] += 1;
                    gop.value_ptr[1] *= n;
                }
            }
        }
    }

    var it = gears.iterator();
    while (it.next()) |e| {
        if (e.value_ptr[0] == 2) part2 += e.value_ptr[1];
    }
    std.debug.print("part1 {}\npart2 {}\n", .{ part1, part2 });
    // std.debug.assert(part1 == 535078);
    // std.debug.assert(part2 == 75312571);
}
