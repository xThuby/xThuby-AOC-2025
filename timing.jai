

Profiler :: struct {
    t0: Apollo_Time;
    t1: Apollo_Time;
    section_name: string;
}

SolutionProc :: #type (input: string) -> int;

time_solution_warmup :: (identifier: string, proc: SolutionProc, input: string, count: int = 20) {
    print("Running % % times.\n", identifier, count);
    profile_start(identifier);
    for 1..count {
        proc(input);
    }
    profile_end(count);
}

time_solution :: (identifier: string, proc: SolutionProc, input: string) {
    profile_start(identifier);
    print("%: %\n", identifier, proc(input));
    profile_end();
}

#scope_file

profiler: Profiler;

profile_start :: (name: string) {
    using profiler;
    section_name = name;
    t0 = current_time_consensus();
}

profile_end :: () {
    using profiler;
    t1 = current_time_consensus();
    diff := to_float64_seconds(t1 - t0);
    if diff < 1 {
        print("[%] Time taken: %ms\n", section_name, diff * 1_000);
    } else {
        print("[%] Time taken: %s\n", section_name, diff);
    }
}

profile_end :: (count: int) {
    using profiler;
    t1 = current_time_consensus();
    diff_total := to_float64_seconds(t1 - t0);
    diff_mod := diff_total / count;
    if diff_mod < 1 {
        print("[%] Time taken (avg): %ms\n", section_name, diff_mod * 1_000);
    } else {
        print("[%] Time taken (avg): %s\n", section_name, diff_mod);
    }
    if diff_total < 1 {
        print("[%] Time taken (total): %ms\n", section_name, diff_total * 1_000);
    } else {
        print("[%] Time taken (total): %s\n", section_name, diff_total);
    }
}
