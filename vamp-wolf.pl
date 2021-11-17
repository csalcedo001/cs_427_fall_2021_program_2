%%% General purpose rules
arange(0, []).
arange(N, L) :-
    N > 0,
    N1 is N - 1,
    arange(N1, L1),
    append(L1, [N1], L).


%%% Environment rules
action_space(vamp_wolf, State, Actions) :-
    [East, West, BoatSide] = State,
    (
        (BoatSide == e, length(East, N));
        (BoatSide == w, length(West, N))
    ),
    arange(N, Actions).

same(vamp_wolf, StateA, StateB) :-
    StateA == StateB.

% TODO: Consider different order of elements in list
is_terminal(vamp_wolf, [[], [v, v, v, w, w, w], BoatSide]) :-
    BoatSide == e;
    BoatSide == w.

get_start(vamp_wolf, Start) :-
    Start = [[v, v, v, w, w, w], [], e].

observe(vamp_wolf, State, Action, NextState, Done) :-
    true.

% step(vamp_wolf, State, Action, NextState) :-
%     [East, West, BoatSide] = State,
%     (
%         (BoatSide == e, Set is East);
%         (BoatSide == w, Set is West)
%     ),
%     length(Set, N),
%     Action >= 0, Action < N,


%%% Search method rules
empty(BFS, L) :-
    true.

visit_next(Heuristic, L, LNext, State) :-
    % TODO: Extract element from BFS' queue
    true.

% Main search method
search(Puzzle, BFS, Path).
search(Puzzle, Heuristic, Path) :-
    get_start(Puzzle, State),
    PriorityQueue = [State],
    search_recur(Puzzle, Heuristic, PQ, Path).

% Auxiliary recursive search method
search_recur(Puzzle, Heuristic, [], []).
search_recur(Puzzle, Heuristic, PQ, Path) :-
    length(PQ, N),
    N > 0,
    [State|NextPQ] = PQ,
    (
        (
            is_terminal(Puzzle, State),
            Path is [State]
        );
        (
            action_space(Puzzle, ActionSpace),
            search_for_loop(Puzzle, Heuristic, State, ActionSpace, PQ, NextPQ),
            search_recur(Puzzle, Heuristic, NextPQ, PrevPath),
            append(PrevPath, State, Path)
        )
    ).
    
search_for_loop(Puzzle, Heuristic, State, [], PQ, []).
search_for_loop(Puzzle, Heuristic, State, [Action, RestActionSpace], PQ, NewPQ) :-
    observe(Puzzle, State, Action, NextState, _),
    % TODO: Replace append by Heuristic
    append(PQ, NextState, PQ1),
    search_for_loop(Puzzle, Heuristic, State, RestActionSpace, PQ1, NewPQ).
