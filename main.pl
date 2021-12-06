:- 
    load_files(['functions']).

print_path([]).
print_path([State | RestPath]) :-
    write(State), nl,
    print_path(RestPath).

run(vamp_wolf, hfs) :-
    init_heuristic(hfs, H, heur_vamp_wolf),
    search(vamp_wolf, H, Path),
    print_path(Path).

run(sliding_tile, hfs) :-
    init_heuristic(hfs, H, heur_sliding_tile),
    search(sliding_tile, H, Path),
    print_path(Path).

run(Puzzle, Method) :-
    init_heuristic(Method, H),
    search(Puzzle, H, Path),
    print_path(Path).
