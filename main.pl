:- 
    load_files(['functions']).

print_path([]).
print_path([State | RestPath]) :-
    write(State), nl,
    print_path(RestPath).

run(Puzzle, best_fs, Heuristic) :-
    init_heuristic(best_fs, H, Heuristic),
    search(Puzzle, H, Path),
    print_path(Path).

run(Puzzle, Method) :-
    init_heuristic(Method, H),
    search(Puzzle, H, Path),
    print_path(Path).
