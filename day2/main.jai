// #import "Basic"()(MEMORY_DEBUGGER = true);
#import "Basic";
#import "File";
#import "Text_File_Handler";
#import "String";
#import "Sort";
#import "Math";
#import "Hash_Table";

main :: () {
    file_data, success := read_entire_file("input.txt");
    if !success {
        print("Error: Unable to load input.txt\n");
        return;
    }

    print("input.txt has % bytes.\n", file_data.count);

    print("------------------\n");
    print("Solution A: %\n", solution_a(file_data));
    print("------------------\n");
    print("Solution B: %\n", solution_b(file_data));

    free(file_data.data);
}

solution_a :: (input: string) -> int {

    sum: int;

    lines := split(input, "\n");
    id_ranges := split(lines[0], ",");

    for id_ranges {
        found, lhs, rhs := split_from_left(it, "-");
        if !found continue;

        start := parse_int(*lhs);
        end   := parse_int(*rhs);

        // print("% to %\n\t", start, end);
        for start..end {
            ok, left, right := split_int(it);
            if !ok continue;
            if left != right continue;
            sum += it;
            // print("%(% %) ", it, left, right);
        }
        // print("\n");
    }

    return sum;
}

solution_b :: (input: string) -> int {

    sum: int;

    lines := split(input, "\n");
    id_ranges := split(lines[0], ",");

    digits: [] int = NewArray(64, int);

    for id_ranges {
        found, lhs, rhs := split_from_left(it, "-");
        if !found continue;

        start := parse_int(*lhs);
        end   := parse_int(*rhs);

        print("% to %\n\t", start, end);
        for start..end {
            ok := split_int_completely(it, *digits);
            if !ok exit(1); 
            // print("%( ", it);
            // print(")\n\t");
        }
        print("\n");
    }

    return sum;
}

LEFT_MASK  :s64:   0xffff_ffff_0000_0000;
RIGHT_MASK :s64:   0x0000_0000_ffff_ffff;

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
