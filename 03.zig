//! https://adventofcode.com/2023/day/3

const std = @import("std");
const isDigit = std.ascii.isDigit;

fn findDigitsEnd(line: []const u8, x: usize) usize {
    var end = x;
    while (end < line.len and isDigit(line[end]))
        end += 1;
    return end;
}

fn findDigitsStart(line: []const u8, x: usize) usize {
    var start = x;
    if (isDigit(line[x])) {
        while (start != 0) {
            const next = start - 1;
            if (!isDigit(line[next])) break;
            start = next;
        }
    }
    return start;
}

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

    var lines = std.ArrayList([]const u8).init(alloc);
    var nbors = std.StringArrayHashMap(void).init(alloc);

    var lineiter = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineiter.next()) |line| try lines.append(line);

    for (lines.items, 0..) |line, y| {
        // part 1 - sum all numbers adjacent to symbol
        var x: usize = 0;
        while (x < line.len) {
            const c = line[x];
            x = blk: {
                if (isDigit(c)) {
                    // start of number. find its end.
                    const digend = findDigitsEnd(line, x);
                    // check for neighboring symbol
                    for (y -| 1..@min(lines.items.len, y + 2)) |ny| {
                        for (x -| 1..@min(lines.items[0].len, digend + 1)) |nx| {
                            const nc = lines.items[ny][nx];
                            if (nc != '.' and !isDigit(nc)) {
                                // found part digit
                                part1 += try std.fmt.parseInt(usize, line[x..digend], 10);
                                break :blk digend + 1;
                            }
                        }
                    }
                    // found non-part digit
                    break :blk digend + 1;
                }
                break :blk x + 1;
            };
        }

        // part 2 - sum neighbor products for '*' tiles with exactly 2 neighbors
        x = 0;
        while (x < line.len) : (x += 1) {
            if (line[x] == '*') {
                // found '*' tile. search for neighboring digits
                nbors.clearRetainingCapacity();
                for (y -| 1..@min(lines.items.len, y + 2)) |ny| {
                    const nbline = lines.items[ny];
                    for (x -| 1..@min(lines.items[0].len, x + 2)) |nx| {
                        // find start and end of neighboring digits
                        const digstart = findDigitsStart(nbline, nx);
                        const digend = findDigitsEnd(nbline, nx);

                        // save digits if any
                        if (digstart < digend)
                            try nbors.put(nbline[digstart..digend], {});
                    }
                }
                const keys = nbors.keys();
                if (keys.len == 2) {
                    part2 +=
                        try std.fmt.parseInt(usize, keys[0], 10) *
                        try std.fmt.parseInt(usize, keys[1], 10);
                }
            }
        }
    }
    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    // std.debug.assert(part1 == 535078);
    // std.debug.assert(part2 == 75312571);
}
