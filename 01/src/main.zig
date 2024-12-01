//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const File = @import("std").fs.File;
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // Measure time for part1
    const start_part1 = std.time.nanoTimestamp();
    try part1();
    const end_part1 = std.time.nanoTimestamp();
    const duration_part1 = end_part1 - start_part1;

    // Measure time for part2
    const start_part2 = std.time.nanoTimestamp();
    try part2();
    const end_part2 = std.time.nanoTimestamp();
    const duration_part2 = end_part2 - start_part2;

    // Print durations
    try stdout.print("part1 took {d} ns\n", .{duration_part1});
    try stdout.print("part2 took {d} ns\n", .{duration_part2});
}

const FileStruct = struct { buf: []u8, buf_size: usize };

fn readFile(path: []const u8) !FileStruct {
    // Create Allocator
    const allocator = std.heap.page_allocator;

    //Open File
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    //Allocate memory for file
    const buf_size = try file.getEndPos();
    const buf = try allocator.alloc(u8, buf_size);

    //Read Contents
    const bytes_read = try file.readAll(buf);
    //defer allocator.free(buf); // TODO Free this buffer somehow

    return FileStruct{ .buf = buf, .buf_size = bytes_read };
}
fn part1() !void {
    const ally = std.heap.page_allocator;
    var numbersList = std.ArrayList(i32).init(ally);
    defer numbersList.deinit();
    const content = try readFile("input.txt");
    var it = std.mem.tokenizeAny(u8, content.buf, "\n ");
    while (it.next()) |item| {
        const n = try parseInt(i32, item, 10);
        try numbersList.append(n);
    }
    var numbers1: []i32 = try ally.alloc(i32, numbersList.items.len / 2);
    var numbers2: []i32 = try ally.alloc(i32, numbersList.items.len / 2);

    var even_index: usize = 0;
    var odd_index: usize = 0;
    for (numbersList.items, 0..) |number, i| {
        if (i % 2 == 0) {
            numbers1[even_index] = number;
            even_index += 1;
        } else {
            numbers2[odd_index] = number;
            odd_index += 1;
        }
    }

    std.mem.sort(i32, numbers1, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, numbers2, {}, comptime std.sort.asc(i32));

    //std.debug.print("\n{d}\n", .{numbers1});
    //std.debug.print("\n{d}\n", .{numbers2});
    var sum: i64 = 0;
    for (numbers1, numbers2) |a, b| {
        sum += @abs(a - b);
    }
    std.debug.print("\n{}\n", .{sum});

    //const diff = @abs(numbers1 - numbers2);
    //const addedDiff = @reduce(.Add, diff);
}
fn part2() !void {
    const ally = std.heap.page_allocator;
    var numbersList = std.ArrayList(i32).init(ally);
    defer numbersList.deinit();
    const content = try readFile("input.txt");
    var it = std.mem.tokenizeAny(u8, content.buf, "\n ");
    while (it.next()) |item| {
        const n = try parseInt(i32, item, 10);
        try numbersList.append(n);
    }
    var numbers1: []i32 = try ally.alloc(i32, numbersList.items.len / 2);
    var numbers2: []i32 = try ally.alloc(i32, numbersList.items.len / 2);

    var even_index: usize = 0;
    var odd_index: usize = 0;
    for (numbersList.items, 0..) |number, i| {
        if (i % 2 == 0) {
            numbers1[even_index] = number;
            even_index += 1;
        } else {
            numbers2[odd_index] = number;
            odd_index += 1;
        }
    }
    var similarity: i32 = 0;
    for (numbers1) |a| {
        var count: i32 = 0;
        for (numbers2) |b| {
            if (a == b) {
                count += 1;
            }
        }
        similarity += a * count;
    }
    std.debug.print("\n{}\n", .{similarity});
}
