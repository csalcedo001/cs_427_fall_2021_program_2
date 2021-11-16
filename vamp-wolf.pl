same([], []).
same(StateA, StateB) :-
    StateA == StateB.

is_terminal([[], [v, v, v, w, w, w], e]).
is_terminal([[], [v, v, v, w, w, w], w]).

arange(0, []).
arange(N, L) :-
    N > 0,
    N1 is N - 1,
    arange(N1, L1),
    append(L1, [N1], L).

% step(State, Action, NextState) :-
%     [East, West, BoatSide] = State,
%     (
%         (BoatSide == e, Set is East);
%         (BoatSide == w, Set is West)
%     ),
%     length(Set, N),
%     Action >= 0, Action < N,

action_space(State, Actions) :-
    [East, West, BoatSide] = State,
    (
        (BoatSide == e, length(East, N));
        (BoatSide == w, length(West, N))
    ),
    arange(N, Actions).

search(Puzzle, Strategy, Path) :-
    call(Puzzle, Start, action_space),
    call(Strategy, ),
    State is Start.

% Start is [[v, v, v, w, w, w], [], e].
