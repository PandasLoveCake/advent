//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");

pub fn main() !void {
    const ally = std.heap.page_allocator;
    const parseInt = std.fmt.parseInt;
    const input = try readFile("input.txt");
    var valid_fields: u32 = 0;
    var number_list = std.ArrayList([]u8).init(ally);
    // Split the input into lines
    var lines = std.mem.tokenizeAny(u8, input.buf, "\n");

    // Loop through every Line
    while (lines.next()) |line| {
        //Split the Line into numbers
        var it_numbers = std.mem.tokenizeAny(u8, line, " ");
        //Find out the Size of a line.
        var line_numbers_len: usize = 0;
        while (it_numbers.next()) |_| {
            line_numbers_len += 1;
        }
        // Allocate Memory to hold the numbers of this line NOTE: The size is not buffer.len because that includes the whitespaces
        var line_numbers = try ally.alloc(u8, line_numbers_len);
        //Loop through the numbers and create Arrays of numbers instead of the strings we had before.
        var index: u32 = 0;
        it_numbers.reset();
        while (it_numbers.next()) |number| : (index += 1) {
            line_numbers[index] = try parseInt(u8, number, 10);
        }
        //Add the numbers to our list
        try number_list.append(line_numbers);
    }
    //std.debug.print("{any}\n", .{number_list});
    // Now we have a format we can work with. A list of Arrays.
    // All this really is inefficient but we have to loop through everything again.
    var failed_items = std.ArrayList([]u8).init(ally);
    for (number_list.items) |num| {
        if (!isAscendConsistent(num)) {
            try failed_items.append(num);
            continue;
        }
        if (!distanceSmallerThan3(num)) {
            try failed_items.append(num);
            continue;
        }
        valid_fields += 1;
    }
    var one_off: u32 = 0;
    for (failed_items.items) |num| {
        for (num, 0..) |_, i| {
            const nb = try removeSingleEntry(num, i);

            if (isAscendConsistent(nb) and distanceSmallerThan3(nb)) {
                one_off += 1;
                break;
            }
        }
    }
    std.debug.print("{d}\n", .{valid_fields + one_off}); // valid fields is part 1 and one_off is part 2
}
fn distanceSmallerThan3(input: []u8) bool {
    var prevNum: i16 = input[0];

    for (input[1..]) |n| {
        const nb: i16 = @intCast(n);
        // Cast both numbers to i16 for safe subtraction
        if (@abs(nb - prevNum) > 3) {
            return false;
        }
        if (@abs(nb - prevNum) < 1) {
            return false;
        }
        prevNum = nb;
    }
    return true;
}

fn isAscendConsistent(input: []u8) bool {
    var asc: u8 = 0; // 0 = not set, 1 = ascending, 2 = descending
    var prevNum: u8 = input[0];

    for (input) |n| {
        if (asc == 0) {
            if (n > prevNum) {
                asc = 1;
            } else if (n < prevNum) {
                asc = 2;
            } else {
                continue;
            }
        }

        if (asc == 1) {
            if (n < prevNum) {
                return false;
            }
        } else if (asc == 2) {
            if (n > prevNum) {
                return false;
            }
        }
        prevNum = n;
    }
    return true;
}

fn removeSingleEntry(input: []u8, index: usize) ![]u8 {
    const ally = std.heap.page_allocator;
    var list = std.ArrayList(u8).init(ally);
    for (0..input.len) |i| {
        if (i == index) continue;
        try list.append(input[i]);
    }
    const output: []u8 = list.items;
    return output;
}

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
const FileStruct = struct { buf: []u8, buf_size: usize };

//{ 40, 43, 41, 38, 37, 34, 34 }
//{ 45, 43, 41, 38, 37, 34, 34 }
//{ 45, 40, 41, 38, 37, 34, 34 }
//{ 45, 40, 43, 38, 37, 34, 34 }
//{ 45, 40, 43, 41, 37, 34, 34 }
//{ 45, 40, 43, 41, 38, 34, 34 }
//{ 45, 40, 43, 41, 38, 37, 34 }
//{ 45, 40, 43, 41, 38, 37, 34 }
