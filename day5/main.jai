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
    filename := "input.txt";
    file_data, success := read_entire_file(filename);
    if !success {
        log_error("Error: Unable to load %\n", filename);
        return;
    }

    print("input.txt has % bytes.\n", file_data.count);

    print("------------------\n");
    time_solution_warmup("Solution A", solution_a, file_data, 20);
    time_solution_warmup("Solution A", solution_a, file_data, 200);
    time_solution_warmup("Solution A", solution_a, file_data, 2000);
    time_solution_warmup("Solution A", solution_a, file_data, 20000);
    time_solution_warmup("Solution A", solution_a, file_data, 200000);
    print("------------------\n");
    time_solution_warmup("Solution B", solution_b, file_data, 20);
    time_solution_warmup("Solution B", solution_b, file_data, 200);
    time_solution_warmup("Solution B", solution_b, file_data, 2000);
    time_solution_warmup("Solution B", solution_b, file_data, 20000);
    time_solution_warmup("Solution B", solution_b, file_data, 200000);

    free(file_data.data);
}

Range :: struct {
    min: int;
    max: int;
}

solution_a :: (input: string) -> int {
    sum: int;

    ranges: [..] Range;

    // Scan and store ranges
    line_number: int;
    while true {
        line, found := consume_next_line(*input);
        line_number += 1;
        if !found break;
        if !line break;

        found_val, lhs, rhs := split_from_left(line, #char "-");
        min_val := parse_int(*lhs);
        max_val := parse_int(*rhs);
        array_add(*ranges, .{min_val, max_val});
    }

    // Processing IDs
    while true {
        line, found := consume_next_line(*input);
        if !found break;

        val := parse_int(*line);
        // print("%", val);
        for ranges {
            if val >= it.min && val <= it.max {
                sum += 1;
                // print("is in range %-%", );
                break;
            }
        }
    }

    return sum;
}

solution_b :: (input: string) -> int {
    sum: int;

    ranges: [..] Range;

    // Scan and store ranges
    while outer := true {
        line, found := consume_next_line(*input);
        if !found break;
        if !line break;

        found_val, lhs, rhs := split_from_left(line, #char "-");
        min_val := parse_int(*lhs);
        max_val := parse_int(*rhs);

        array_add(*ranges, .{min_val, max_val});
    }

    // Combine with overlapping ranges
    while outer := true {
        for * it, it_index: ranges {
            for inner, inner_index: ranges {
                // print("%, %\n", it_index, inner_index);
                if inner_index == it_index continue;
                // print("comparing % to %\n", it.*, inner);
                // print("\tmin-max: %\n\tmax-min: %\n\tmin-min: %\n\tmax-max: %\n", it.min - inner.max, it.max - inner.min, it.min - inner.min, it.max - inner.max);
                if inner.min >= it.min && inner.max <= it.max {
                    // print("   % contains all of %\n", it.*, inner);
                    remove inner;
                    continue outer;
                }
                if inner.min >= it.min && inner.min <= it.max {
                    // print("   merging % and % into ", it.*, inner);
                    it.max = inner.max;
                    // print("%\n", it.*);
                    remove inner;
                    continue outer;
                }
                if inner.max >= it.min && inner.max <= it.max {
                    // print("   merging % and % into ", it.*, inner);
                    it.min = inner.min;
                    // print("%\n", it.*);
                    remove inner;
                    continue outer;
                }
            }
        }

        break;
    }

    // Double check for any overlapping ranges
    // for it, it_index: ranges {
    //     for inner, inner_index: ranges {
    //         if inner_index == it_index continue;
    //         min_max := sign(it.min - inner.max);
    //         max_min := sign(it.max - inner.min);
    //         min_min := sign(it.min - inner.min);
    //         max_max := sign(it.max - inner.max);
    //
    //         sum_of_signs :=
    //             sign(it.min - inner.max) +
    //             sign(it.max - inner.min) +
    //             sign(it.min - inner.min) +
    //             sign(it.max - inner.max);
    //         if abs(sum_of_signs) != 4 {
    //             print("Oh no! Overlaps found!\n\t% and %\n\t(%, %, %, %)\n", it, inner, min_max, max_min, min_min, max_max);
    //         }
    //     }
    // }

    // Calculate result
    for ranges {
        sum += it.max - it.min + 1;
    }

    return sum;
}


sign :: (val: $T) -> int
#modify {
    ti := cast(*Type_Info)T;
    if ti.type == .INTEGER || ti.type == .FLOAT {
        return true;
    }
    return false, "Unsupported argument type to random_range.";
}{
    if val < 0 {
        return -1;
    }
    return 1;
}
