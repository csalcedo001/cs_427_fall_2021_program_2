%%% General purpose rules
get_parent(Child, [[Child, Parent] | _], Parent).
get_parent(Child, [_ | RestParents], Parent) :- get_parent(Child, RestParents, Parent).


%%% Environment rules
action_space_add(vamp_wolf, L0, W, V, WDiff, VDiff, Action, L1) :-
    WNew is W - WDiff,
    VNew is V - VDiff,
    (
        WNew >= 0, VNew >= 0, VNew >= WNew,
        append(L0, [Action], L1)
    );
    (
        L1 = L0
    ).

action_space(vamp_wolf, State, Actions) :-
    [WW, VW, WE, VE, B] = State,
    A0 = [],
    ((B == west, W is WW, V is VW);
    (B == east, W is WE, V is VE)),
    action_space_add(vamp_wolf, A0, W, V, 1, 0, 0, A1),
    action_space_add(vamp_wolf, A1, W, V, 0, 1, 1, A2),
    action_space_add(vamp_wolf, A2, W, V, 2, 0, 2, A3),
    action_space_add(vamp_wolf, A3, W, V, 0, 2, 3, A4),
    action_space_add(vamp_wolf, A4, W, V, 1, 1, 4, Actions).

equivalent(vamp_wolf, StateA, StateB) :-
    StateA == StateB.

is_terminal(vamp_wolf, State) :-
    equivalent(vamp_wolf, State, [0, 0, 3, 3, east]);
    equivalent(vamp_wolf, State, [0, 0, 3, 3, west]).

get_start(vamp_wolf, Start) :-
    Start = [3, 3, 0, 0, west].

observe(vamp_wolf, State, Action, NextState) :-
    [WW, VW, WE, VE, B] = State,
    action_space(vamp_wolf, State, ActionSpace),
    member(Action, ActionSpace),
    ((B == west, Sign = 1, BNext = east);
    (B == east, Sign = -1, BNext = west)),
    (
        (Action == 0, [C0, C1] = [1, 0]);
        (Action == 1, [C0, C1] = [0, 1]);
        (Action == 2, [C0, C1] = [2, 0]);
        (Action == 3, [C0, C1] = [0, 2]);
        (Action == 4, [C0, C1] = [1, 1])
    ),
    WW2 is WW - C0 * Sign,
    VW2 is VW - C1 * Sign,
    WE2 is WE + C0 * Sign,
    VE2 is VE + C1 * Sign,
    NextState = [WW2, VW2, WE2, VE2, BNext].


%%% Search method rules
insert(Heuristic, PQ, State, PQNext) :-
    [_, HeurInsert | Params] = Heuristic,
    call(HeurInsert, Params, PQ, State, PQNext).

% Main search method
search(Puzzle, Heuristic, Path) :-
    get_start(Puzzle, State),
    PQ = [State],
    Visited = [State],
    Parents = [],
    search_recur(Puzzle, Heuristic, PQ, Visited, Path, Parents),
    write(Path), nl.

% Auxiliary recursive search method
search_recur(Puzzle, Heuristic, [], Visited, [], Parents).
search_recur(Puzzle, Heuristic, PQ, Visited, Path, Parents) :-
    length(PQ, N),
    N > 0,
    [State | PQ2] = PQ,
    % write(State), nl, nl,
    (
        (
            is_terminal(Puzzle, State),
            Path = [State]
        );
        (
            action_space(Puzzle, State, ActionSpace),
            search_for_loop(Puzzle, Heuristic, State, ActionSpace, PQ2, PQ3, Visited, Visited2, Parents, Parents2),
            search_recur(Puzzle, Heuristic, PQ3, Visited2, PrevPath, Parents2),
            % write(PQ3), write(" "),
            % nl,
            (
                (
                    ((length(PrevPath, M), M == 0) ; 
                    [LastState | _] = PrevPath,
                    get_parent(LastState, Parents2, State)),
                    append([State], PrevPath, Path)
                );(
                    Path = PrevPath
                )
            )
        )
    ).
    
search_for_loop(Puzzle, Heuristic, State, [], PQ, PQ, Visited, Visited, Parents, Parents).
search_for_loop(Puzzle, Heuristic, State, ActionSpace, PQ, NextPQ, Visited, NextVisited, Parents, NextParents) :-
    [Action | RestActionSpace] = ActionSpace,
    observe(Puzzle, State, Action, NextState),
    ((
        not(member(NextState, Visited)),
        append(Visited, [NextState], Visited2),
        append(Parents, [[NextState, State]], Parents2),
        insert(Heuristic, PQ, NextState, PQ1)
    );(
        Visited2 = Visited,
        PQ1 = PQ,
        Parents2 = Parents
    )),
    % write(State), write(" "),
    % write(Action), write(" "),
    % write(Visited), write(" "),
    % write(RestActionSpace), write(" "),
    % write(PQ), write(" "),
    % write(PQ1), write(" "),
    % write(Parents), write(" "),
    % nl,
    % nl,
    search_for_loop(Puzzle, Heuristic, State, RestActionSpace, PQ1, NextPQ, Visited2, NextVisited, Parents2, NextParents).
    % write(NextPQ), nl.

bfs_insert(_, PQ, State, NextPQ) :-
    append(PQ, [State], NextPQ).

dfs_insert(_, PQ, State, NextPQ) :-
    append([State], PQ, NextPQ).

best_fs_insert([Heur], PQ, State, NextPQ) :-
    % TODO: Implment insert
    NextPQ = PQ.

init_heuristic(bfs, [bfs, bfs_insert]).
init_heuristic(dfs, [dfs, dfs_insert]).
init_heuristic(best_fs, Heur, [best_fs, best_fs_insert, Heur]).
