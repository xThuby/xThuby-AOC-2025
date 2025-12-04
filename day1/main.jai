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

    // Dial starts at 50.
    dial: int = 50;
    sum: int;

    i: int = 0;
    while true {
        // print("%", dial);
        line, found := consume_next_line(*input);
        if !found break;
        if !line break;

        turn_dir: int = 0;
        if line[0] == #char "L" turn_dir = -1;
        if line[0] == #char "R" turn_dir = 1;

        line.data += 1;
        line.count -= 1;
        turn_amount, ok := parse_int(*line);

        // print(" + % = %", turn_amount * turn_dir, dial);

        for 1..turn_amount {
            dial += turn_dir;

            if dial > 99 dial -= 100;
            if dial < 0  dial += 100;
        }

        if dial == 0 sum += 1;

        // print(" (%)\n", dial);

        i += 1;
    }

    return sum;
}

solution_b :: (input: string) -> int {

    // Dial starts at 50.
    dial: int = 50;
    sum: int;

    i: int = 0;
    while true {
        // print("%", dial);
        line, found := consume_next_line(*input);
        if !found break;
        if !line break;

        turn_dir: int = 0;
        if line[0] == #char "L" turn_dir = -1;
        if line[0] == #char "R" turn_dir = 1;

        line.data += 1;
        line.count -= 1;
        turn_amount, ok := parse_int(*line);

        // print(" + % = %", turn_amount * turn_dir, dial);

        for 1..turn_amount {
            dial += turn_dir;

            if dial > 99 dial -= 100;
            if dial < 0  dial += 100;

            if dial == 0 sum += 1;
        }

        // print(" (%)\n", dial);

        i += 1;
    }

    return sum;
}

