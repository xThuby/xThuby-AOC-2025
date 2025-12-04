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

    grid_width: int = find_index_from_left(input, "\n", 0);
    grid_height := grid_width;

    grid: Grid;
    init(*grid, grid_width, grid_height);
    defer deinit(*grid);

    // print("%, %\n", grid_width, grid_height);

    x: int;
    y: int;
    while true {
        line, found := consume_next_line(*input);
        if !found break;
        if !line break;

        for line {
            if it == #char "." {
                set(*grid, x, y, 0);
            } else {
                set(*grid, x, y, 1);
            }
            x += 1;
        }
        y += 1;
        x = 0;
    }

    for grid {
        if it == 0 continue;
        x := it_index.x;
        y := it_index.y;

        tl := get(grid, x-1, y-1);
        tc := get(grid, x  , y-1);
        tr := get(grid, x+1, y-1);
        ml := get(grid, x-1, y  );
        mr := get(grid, x+1, y  );
        bl := get(grid, x-1, y+1);
        bc := get(grid, x  , y+1);
        br := get(grid, x+1, y+1);
        total := tl+tc+tr+ml+mr+bl+bc+br;
        if total < 4 then sum += 1;
    }

    return sum;
}

solution_b :: (input: string) -> int {
    sum: int;

    grid_width: int = find_index_from_left(input, "\n", 0);
    grid_height := grid_width;

    grid: Grid;
    init(*grid, grid_width, grid_height);
    defer deinit(*grid);

    // print("%, %\n", grid_width, grid_height);

    x: int;
    y: int;
    while true {
        line, found := consume_next_line(*input);
        if !found break;
        if !line break;

        for line {
            if it == #char "." {
                set(*grid, x, y, 0);
            } else {
                set(*grid, x, y, 1);
            }
            x += 1;
        }
        y += 1;
        x = 0;
    }

    total: int = 99999;
    i := 0;
    while total > 0 {
        // for grid {
        //     if it_index.x == 0 && it_index.y != 0 then print("\n");
        //     print("%", it);
        // }
        // print("\n");

        total = 0;
        for *grid {
            if it.* == 0 continue;
            x := it_index.x;
            y := it_index.y;

            tl := clamp(get(grid, x-1, y-1), 0, 1);
            tc := clamp(get(grid, x  , y-1), 0, 1);
            tr := clamp(get(grid, x+1, y-1), 0, 1);
            ml := clamp(get(grid, x-1, y  ), 0, 1);
            mr := clamp(get(grid, x+1, y  ), 0, 1);
            bl := clamp(get(grid, x-1, y+1), 0, 1);
            bc := clamp(get(grid, x  , y+1), 0, 1);
            br := clamp(get(grid, x+1, y+1), 0, 1);
            neighbours := tl+tc+tr+ml+mr+bl+bc+br;
            if neighbours < 4 {
                it.* = 2;
                total += 1;
                sum += 1;
            }
        }
        // print("%\n", total);

        for *grid {
            if it.* == 2 it.* = 0;
        }

        i += 1;
        // if i >= 2 break;
    }

    return sum;
}

Point :: struct {
    x: int;
    y: int;

    #overlay (x) components: [2] int;
}

Grid :: struct {
    count_x: int;
    count_y: int;

    position: Vector2 = .{0, 0};
    values:   [] int;
}

init :: (using grid: *Grid, width: int, height: int) {
    count_x = width;
    count_y = height;

    values = NewArray(width*height, int);
}

deinit :: (using grid: *Grid) {
    array_free(values);
}

set :: (grid: *Grid, x: int, y: int, value: int) {
    // assert((x >= 0) && (x < grid.count_x), "Grid value bounds check failed, grid.count_x: %, tried to set %", grid.count_x, x);
    // assert((y >= 0) && (y < grid.count_y), "Grid value bounds check failed, grid.count_y: %, tried to set %", grid.count_y, y);

    index := y*grid.count_x + x;
    grid.values  [index] = value;
}

set :: (grid: *Grid, x: float, y: float, value: int) {
    set(grid, cast(int, x), cast(int, y), value);
}

set :: (grid: *Grid, pos: Vector2, value: int) {
    set(grid, cast(int, pos.x), cast(int, pos.y), value);
}

get :: (grid: Grid, x: int, y: int) -> (value: int) {
    if x < 0 || x >= grid.count_x || y < 0 || y >= grid.count_y {
        return 0;
    }

    index := y*grid.count_x + x;
    return grid.values[index];
}

get :: (grid: Grid, x: float, y: float) -> (value: int) {
    value := get(grid, cast(int, x), cast(int, y));
    return value;
}

get :: (grid: Grid, pos: Vector2) -> (value: int) {
    value := get(grid, cast(int, pos.x), cast(int, pos.y));
    return value;
}

for_expansion :: (grid: Grid, body: Code, flags: For_Flags) #expand {
    #assert !(flags & .REVERSE) "This iterator does not support reverse iteration!";
    DO_POINTER :: (flags & .POINTER).(bool);

    for y: 0..grid.count_y-1 {
        for x: 0..grid.count_x-1 {
            index := y*grid.count_x + x;

            #if DO_POINTER {
                `it := *grid.values[index];
            } else {
                `it := grid.values[index];
            }
            `it_index: Point;  // Let's make a new type to provide as it_index.
            it_index.x = x;
            it_index.y = y;

            #insert(break=break y) body;
        }
    }
}
