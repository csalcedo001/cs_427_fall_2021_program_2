%%% General purpose rules
get_parent(Child, [[Child, Parent] | _], Parent).
get_parent(Child, [_ | RestParents], Parent) :- get_parent(Child, RestParents, Parent).

% Flatten
matrix_flatten(Matrix, List) :-
    matrix_flatten_recur(Matrix, [], List).

matrix_flatten_recur([], List, List).
matrix_flatten_recur(Matrix, CurrList, NextList) :-
    [Row | RestMatrix] = Matrix,
    append(CurrList, Row, MidList),
    matrix_flatten_recur(RestMatrix, MidList, NextList).

% Factorial
factorial(N, R) :- N < 1, R is 1.
factorial(N, R) :-
    N0 = N - 1,
    factorial(N0, R0),
    R is R0 * N.

% Matrix Swap
swap_x(Matrix, Y, Low, High, NextMatrix) :-
    swap_x_recur_j(Matrix, 0, 3, Y, Low, High, NextMatrix).

swap_x_recur_j(Matrix, I, J, Y, Low, High, NextMatrix) :-
    [Row | RestMatrix] = Matrix,
    J2 is J - 1,
    swap_x_recur_j(RestMatrix, I, J2, Y, Low, High, RestNextMatrix),
    NextMatrix = [Row | RestNextMatrix].

swap_x_recur_j(Matrix, I, Y, Y, Low, High, NextMatrix) :-
    [Row | RestMatrix] = Matrix,
    swap_x_recur_i(Row, I, Low, High, NextRow),
    NextMatrix = [NextRow | RestMatrix].

swap_x_recur_i(Row, I, Low, High, NextRow) :-
    [Val | RestRow] = Row,
    I2 is I + 1,
    swap_x_recur_i(RestRow, I2, Low, High, RestNextRow),
    NextRow = [Val | RestNextRow].

swap_x_recur_i(Row, Low, Low, _, NextRow) :-
    [V0, V1 | RestRow] = Row,
    NextRow = [V1, V0 | RestRow].

swap_y(Matrix, X, Low, High, NextMatrix) :-
    swap_y_recur_j(Matrix, 0, 3, X, Low, High, NextMatrix).

swap_y_recur_j(Matrix, I, J, X, Low, High, NextMatrix) :-
    [Row | RestMatrix] = Matrix,
    J2 is J - 1,
    swap_y_recur_j(RestMatrix, I, J2, X, Low, High, RestNextMatrix),
    NextMatrix = [Row | RestNextMatrix].

swap_y_recur_j(Matrix, I, High, X, _, High, NextMatrix) :-
    [Row1, Row2 | RestMatrix] = Matrix,
    swap_y_recur_i(Row1, Row2, I, X, NextRow1, NextRow2),
    NextMatrix = [NextRow1, NextRow2 | RestMatrix].

swap_y_recur_i(Row1, Row2, I, X, NextRow1, NextRow2) :-
    [V1 | RestRow1] = Row1,
    [V2 | RestRow2] = Row2,
    I2 is I + 1,
    swap_y_recur_i(RestRow1, RestRow2, I2, X, RestNextRow1, RestNextRow2),
    NextRow1 = [V1 | RestNextRow1],
    NextRow2 = [V2 | RestNextRow2].

swap_y_recur_i(Row1, Row2, X, X, NextRow1, NextRow2) :-
    [V1 | RestRow1] = Row1,
    [V2 | RestRow2] = Row2,
    NextRow1 = [V2 | RestRow1],
    NextRow2 = [V1 | RestRow2].


%%% Environment rules
%% vamp_wolf environment
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
    equivalent(vamp_wolf, State, [0, 0, 3, 3, east]).

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

%% sliding_tile environment
action_space(sliding_tile, State, Actions) :-
    [Matrix, [X, Y]] = State,
    [Row | _] = Matrix,
    length(Matrix, N),
    length(Row, M),
    X1 is X - 1,
    X2 is X + 1,
    Y1 is Y - 1,
    Y2 is Y + 1,
    A0 = [],
    (
        ((Y2 < N, append(A0, [0], A1)) ; A1 = A0),
        ((X2 < M, append(A1, [1], A2)) ; A2 = A1),
        ((Y1 >= 0, append(A2, [2], A3)) ; A3 = A2),
        ((X1 >= 0, append(A3, [3], Actions)) ; Actions = A3)
    ).

equivalent(sliding_tile, StateA, StateB) :-
    StateA == StateB.

% TODO: Consider terminal states different position of empty tile.
is_terminal(sliding_tile, State) :-
    [Matrix, _] = State,
    matrix_flatten(Matrix, List0),
    delete(List0, 16, List1),
    List1 == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15].
    % equivalent(sliding_tile, State, [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, _]]).

get_start(sliding_tile, Start) :-
    Matrix = [[12, 1, 2, 15], [11, 6, 5, 8], [7, 10, 9, 4], [16, 13, 14, 3]],
    Start = [Matrix, [0, 0]].
    % Matrix = [[1, 2, 3, 4], [5, 6, 7, 8], [16, 15, 14, 13], [12, 11, 10, 9]],
    % Start = [Matrix, [0, 1]].

observe(sliding_tile, State, Action, NextState) :-
    [Matrix, [X, Y]] = State,
    (
        (Action == 0, Axis = y, Low is Y, High is Y + 1, NextX is X, NextY is Y + 1);
        (Action == 1, Axis = x, Low is X, High is X + 1, NextX is X + 1, NextY is Y);
        (Action == 2, Axis = y, Low is Y - 1, High is Y, NextX is X, NextY is Y - 1);
        (Action == 3, Axis = x, Low is X - 1, High is X, NextX is X - 1, NextY is Y)
    ),
    (
        (Axis = x, swap_x(Matrix, Y, Low, High, NextMatrix));
        (Axis = y, swap_y(Matrix, X, Low, High, NextMatrix))
    ),
    NextState = [NextMatrix, [NextX, NextY]].
    


%%% Search method rules
insert(Heuristic, PQ, State, PQNext) :-
    [_, HeurInsert | Params] = Heuristic,
    call(HeurInsert, Params, PQ, State, PQNext).

% Main search method
search(Puzzle, Heuristic, Path) :-
    get_start(Puzzle, Start),
    search(Puzzle, Heuristic, Start, Path).

search(Puzzle, Heuristic, Start, Path) :-
    PQ = [Start],
    Visited = [Start],
    Parents = [],
    catch(
        (
            search_recur(Puzzle, Heuristic, PQ, Visited, Path, Parents),
            Error = none
        ),
        error(Error, _),
        (
            Error == resource_error(stack),
            Path = [],
            format('You runned out of memory, the stack is full!'),
            nl
        )
    ),
    (
        Error == none,
        write(Path), nl
    ).

% Auxiliary recursive search method
search_recur(_, _, [], _, [], _).
search_recur(Puzzle, Heuristic, PQ, Visited, Path, Parents) :-
    length(PQ, N),
    N > 0,
    [State | PQ2] = PQ,
    (
        (
            is_terminal(Puzzle, State),
            Path = [State]
        );
        (
            action_space(Puzzle, State, ActionSpace),
            search_for_loop(Puzzle, Heuristic, State, ActionSpace, PQ2, PQ3, Visited, Visited2, Parents, Parents2),
            search_recur(Puzzle, Heuristic, PQ3, Visited2, PrevPath, Parents2),
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
    
search_for_loop(_, _, _, [], PQ, PQ, Visited, Visited, Parents, Parents).
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
    search_for_loop(Puzzle, Heuristic, State, RestActionSpace, PQ1, NextPQ, Visited2, NextVisited, Parents2, NextParents).

bfs_insert(_, PQ, State, NextPQ) :-
    append(PQ, [State], NextPQ).

dfs_insert(_, PQ, State, NextPQ) :-
    append([State], PQ, NextPQ).

hfs_insert([Heur], PQ, State, NextPQ) :-
    sort_insert_recur(Heur, PQ, State, NextPQ).

sort_insert_recur(Heur, [], CurrState, [CurrState]) :-
    call(Heur, CurrState, CurrCost),
    write("State: "), write(CurrState), nl,
    write("Cost: "), write(CurrCost), nl, nl.

sort_insert_recur(Heur, PQ, CurrState, NextPQ) :-
    [FrontState | RestPQ] = PQ,
    call(Heur, CurrState, CurrCost),
    call(Heur, FrontState, FrontCost),
    (
        (
            CurrCost > FrontCost,
            sort_insert_recur(Heur, RestPQ, CurrState, RestNextPQ),
            NextPQ = [FrontState | RestNextPQ]
        );
        (
            NextPQ = [CurrState, FrontState | RestPQ],
            write("State: "), write(CurrState), nl,
            write("Cost: "), write(CurrCost), nl, nl
        )
    ).

init_heuristic(bfs, [bfs, bfs_insert]).
init_heuristic(dfs, [dfs, dfs_insert]).
init_heuristic(hfs, [hfs, hfs_insert, Heur], Heur).


%%% Heuristics
% vamp_wolf Heuristic
heur_vamp_wolf(State, Cost) :-
    [WW, VW, WE, VE, B] = State,
    Cost is WW.

% sliding_tile Heuristic
heur_sliding_tile(State, Cost) :-
    [Matrix, BlankPos] = State,
    matrix_cost(Matrix, 0, Cost).

matrix_cost([], _, 0).
matrix_cost(Matrix, CurrY, Cost) :-
    [Row | RestMatrix] = Matrix,
    row_cost(Row, 0, CurrY, RowCost),
    NextY is CurrY + 1,
    matrix_cost(RestMatrix, NextY, RestCost),
    Cost is RowCost + RestCost.

row_cost([], _, _, 0).
row_cost(Row, CurrX, Y, Cost) :-
    [Tile | RestRow] = Row,
    tile_cost(Tile, CurrX, Y, TileCost),
    NextX is CurrX + 1,
    row_cost(RestRow, NextX, Y, RestCost),
    Cost is TileCost + RestCost.

tile_cost(Tile, Xi, Yi, Cost) :-
    Pos1 is Tile - 1,
    Pos2 is Tile,
    matrix_pos_dist(Pos1, Xi, Yi, Dist1),
    matrix_pos_dist(Pos2, Xi, Yi, Dist2),
    Cost is min(Dist1, Dist2).

matrix_pos_dist(MatrixPos, Xi, Yi, Dist) :-
    Xf is mod(MatrixPos, 4),
    Yf is (MatrixPos - Xf) / 4,
    Dist is abs(Xf - Xi) + abs(Yf - Yi).
