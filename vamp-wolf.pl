%%% General purpose rules
arange(0, []).
arange(N, L) :-
    N > 0,
    N1 is N - 1,
    arange(N1, L1),
    append(L1, [N1], L).

contains([Value | _], Value).
contains([_ | List], Value) :- contains(List, Value).


%%% Environment rules
action_space_add(vamp_wolf, L0, W, V, WDiff, VDiff, Action, L1) :-
    WNew is W - WDiff,
    VNew is V - VDiff,
    (
        WNew >= 0, VNew >= 0,
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
    contains(ActionSpace, Action),
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

% step(vamp_wolf, State, Action, NextState) :-
%     [East, West, BoatSide] = State,
%     (
%         (BoatSide == e, Set is East);
%         (BoatSide == w, Set is West)
%     ),
%     length(Set, N),
%     Action >= 0, Action < N,


%%% Search method rules
insert(Heuristic, PQ, State, PQNext) :-
    % TODO: insert element to queue according to heuristic
    append(PQ, [State], PQNext).

% Main search method
% search(Puzzle, BFS, Path).
search(Puzzle, Heuristic, Path) :-
    get_start(Puzzle, State),
    PQ = [State],
    search_recur(Puzzle, Heuristic, PQ, Path).

% Auxiliary recursive search method
search_recur(Puzzle, Heuristic, [], []).
search_recur(Puzzle, Heuristic, PQ, Path) :-
    length(PQ, N),
    N > 0,
    [State | NextPQ] = PQ,
    (
        (
            is_terminal(Puzzle, State),
            Path is [State]
        );
        (
            action_space(Puzzle, ActionSpace),
            search_for_loop(Puzzle, Heuristic, State, ActionSpace, PQ, NextPQ),
            search_recur(Puzzle, Heuristic, NextPQ, PrevPath),
            append(PrevPath, [State], Path)
        )
    ).
    
search_for_loop(Puzzle, Heuristic, State, [], PQ, []).
search_for_loop(Puzzle, Heuristic, State, [Action | RestActionSpace], PQ, NewPQ) :-
    observe(Puzzle, State, Action, NextState),
    % TODO: Replace append by Heuristic
    insert(Heuristic, PQ, NextState, PQ1),
    search_for_loop(Puzzle, Heuristic, State, RestActionSpace, PQ1, NewPQ).
