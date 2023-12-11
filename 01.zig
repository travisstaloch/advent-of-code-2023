//! https://adventofcode.com/2023/day/1

const std = @import("std");

const digits = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var parts = [2]usize{ 0, 0 };
    for (&parts, 1..) |*partsum, partnum| {
        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        while (lines.next()) |line| {
            // std.debug.print("line='{s}'\n", .{line});
            const first_digit = blk: for (0..line.len) |i| {
                const c = line[i];
                if (std.ascii.isDigit(c)) break c - '0';
                if (partnum == 1) continue;
                for (digits, 1..) |dig, digi| {
                    if (std.mem.startsWith(u8, line[i..], dig))
                        break :blk @as(u8, @truncate(digi));
                }
            } else return error.NoDigtFound;
            // std.debug.print("first_digit={}\n", .{first_digit});

            var iter = std.mem.reverseIterator(line);
            const last_digit = blk: while (iter.next()) |c| {
                if (std.ascii.isDigit(c)) break :blk c - '0';
                if (partnum == 1) continue;
                for (digits, 1..) |dig, digi| {
                    if (std.mem.startsWith(u8, line[iter.index..], dig))
                        break :blk @as(u8, @truncate(digi));
                }
            } else return error.NoDigtFound;

            partsum.* += first_digit * 10 + last_digit;
        }
    }

    std.debug.print("parts={any}\n", .{parts});
}
