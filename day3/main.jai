// #import "Basic"()(MEMORY_DEBUGGER = true);
#import "Basic";
#import "File";
#import "Text_File_Handler";
#import "String";
#import "Sort";
#import "Math";
#import "Hash_Table";

#load "../timing.jai";

main :: () {
    file_data, success := read_entire_file("input.txt");
    if !success {
        print("Error: Unable to load input.txt\n");
        return;
    }

    print("input.txt has % bytes.\n", file_data.count);

    print("------------------\n");
    time_solution("Solution A", solution_a, file_data);
    print("------------------\n");
    time_solution("Solution B", solution_b, file_data);

    free(file_data.data);
}

solution_a :: (input: string) -> int {

    sum: int;

    while true {
        line, found := consume_next_line(*input);
        if !found break;
        if !line break;

        // print("%\n", line);

        highest_joltage: int;
        c: string = ---;
        d: string = ---;
        for i: 0..line.count-2 {
            c.data    = line.data + i;
            c.count   = 1;
            val := parse_int(*c);
            for j: (i+1)..line.count-1 {
                d.data    = line.data + j;
                d.count   = 1;
                val2 := parse_int(*d);
                joltage := val * 10 + val2;
                highest_joltage = max(joltage, highest_joltage);
            }
        }
        sum += highest_joltage;
        // print("\t%\n", highest_joltage);
    }

    return sum;
}

solution_b :: (input: string) -> int {

    sum: int;

    while true {
        line, found := consume_next_line(*input);
        if !found break;
        if !line break;

        // print("%\n", line);
        highest_joltage: int = find_joltage(line, 12, 0);
        sum += highest_joltage;
        // print("\n\t%\n", highest_joltage);
    }

    return sum;
}

find_joltage :: (line: string, d: int, i: int) -> int {
    if d == 0 return 0;
    c: string = ---;
    highest: int;
    highest_index: int;
    for j: i..line.count-d {
        c.data    = line.data + j;
        c.count   = 1;
        val := parse_int(*c);
        if val > highest {
            highest = val;
            highest_index = j;
        }
    }
    // print("% + ", highest);
    return highest * ipow(10, d-1) + find_joltage(line, d-1, highest_index+1);
}

split_int :: (num: int) -> (ok: bool, left: int, right: int) {
    num_digits := get_num_digits(num);
    if num_digits % 2 != 0 return false, 0, 0;

    mult := ipow(10, num_digits/2);
    left  := num / mult;
    right := num % mult;

    return true, left, right;
}

split_int_completely :: (num: int, result: *[] int) -> ok: bool {
    num_digits := get_num_digits(num);

    result.count = num_digits;

    idx: int;
    for < 0..num_digits-1 {
        // print("num: %1, it: %2, 10^%2: %3\n", num, it, ipow(10, it));
        result.*[idx] = (num / ipow(10, it)) % 10;
        idx += 1;
    }

    return true;
}

get_num_digits :: (n: int) -> int {
    if (n < 0) n = ifx (n == S64_MIN) then S64_MAX else -n;
    if (n < 10) return 1;
    if (n < 100) return 2;
    if (n < 1000) return 3;
    if (n < 10000) return 4;
    if (n < 100000) return 5;
    if (n < 1000000) return 6;
    if (n < 10000000) return 7;
    if (n < 100000000) return 8;
    if (n < 1000000000) return 9;
    return 10;
}

ipow :: (_base: int, _exp: int) -> int {
    base := _base;
    exp := _exp;
    result: int = 1;
    while true {
        if (exp & 1)
        result *= base;
        exp >>= 1;
        if !exp
        break;
        base *= base;
    }

    return result;
}
