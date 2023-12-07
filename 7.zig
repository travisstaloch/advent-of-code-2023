//! https://adventofcode.com/2023/day/7

const std = @import("std");

const Cards = @Vector(5, u8);
const Class = enum { hicard, pair, twopair, threekind, fullhouse, fourkind, fivekind };
const ranks = "23456789TJQKA".*;
const ranks_p2 = "J23456789TQKA".*;
const Part = enum { part1, part2 };

fn scoreCards(class: Class, cards: Cards, part: Part) usize {
    var card_ranks: [5]u8 = cards;
    const ranks_table = if (part == .part1) ranks else ranks_p2;
    for (0..5) |i| card_ranks[i] =
        @intCast(std.mem.indexOfScalar(u8, &ranks_table, card_ranks[i]).? + 1);
    const lorank = std.mem.readInt(u40, &card_ranks, .big);
    const hirank = (std.math.pow(usize, 10, @intFromEnum(class) + 1) << 32);
    return hirank + lorank;
}

const Hand = struct {
    rank: usize,
    bid: u32,
    fn lessThan(_: void, lhs: Hand, rhs: Hand) bool {
        return lhs.rank < rhs.rank;
    }
};

fn countOf(cards: Cards, rank: u8) u8 {
    const mask = cards == @as(Cards, @splat(rank));
    const i: u5 = @bitCast(mask);
    return @popCount(i);
}

fn handRank(line: []const u8, part: Part) usize {
    const cards: Cards = line[0..5].*;
    const jc = if (part == .part1) 0 else countOf(cards, 'J');
    var max: usize = 0;
    for (ranks) |rank| {
        const jcount = if (rank == 'J') 0 else jc;
        const count = countOf(cards, rank);
        const r: usize = switch (count + jcount) {
            5 => scoreCards(.fivekind, cards, part),
            4 => scoreCards(.fourkind, cards, part),
            3 => for (ranks) |rank2| {
                if (part == .part2 and rank2 == 'J' or rank == rank2) continue;
                if (countOf(cards, rank2) == 2) break scoreCards(.fullhouse, cards, part);
            } else scoreCards(.threekind, cards, part),
            2 => for (ranks) |rank2| {
                if (part == .part2 and rank2 == 'J' or rank == rank2) continue;
                if (countOf(cards, rank2) == 2) break scoreCards(.twopair, cards, part);
            } else scoreCards(.pair, cards, part),
            1 => scoreCards(.hicard, cards, part),
            0 => 0,
            else => unreachable,
        };
        max = @max(max, r);
    }
    return max;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var hands = std.ArrayList(Hand).init(alloc);
    var parts: [2]usize = undefined;
    for ([_]Part{ .part1, .part2 }) |part| {
        hands.clearRetainingCapacity();
        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        while (lines.next()) |line| {
            try hands.append(.{
                .rank = handRank(line, part),
                .bid = try std.fmt.parseInt(u32, line[6..], 10),
            });
        }

        std.mem.sort(Hand, hands.items, {}, Hand.lessThan);
        var sum: usize = 0;
        for (hands.items, 1..) |s, i|
            sum += i * s.bid;
        parts[@intFromEnum(part)] = sum;
    }
    std.debug.print("part1 {} part2 {}\n", .{ parts[0], parts[1] });
    std.debug.assert(parts[0] == 249638405);
    std.debug.assert(parts[1] == 249776650);
}
