% TSP (Traveling Salesperson Problem) — Романчук Анна Сергіївна
:- use_module(library(lists)).
:- use_module(library(clpfd)).

sample_matrix([
  [0,  10, 15, 20, 10, 25],
  [10, 0,  35, 25, 17, 30],
  [15, 35, 0,  30, 28, 14],
  [20, 25, 30, 0,  16, 18],
  [10, 17, 28, 16, 0,  12],
  [25, 30, 14, 18, 12, 0 ]
]).

matrix_n(M, N) :- length(M, N).

dist(M, I, J, D) :-
    nth1(I, M, Row),
    nth1(J, Row, D).

tour_cost(M, _Start, Tour, Cost) :-
    tour_cost_pairs(M, Tour, 0, Cost).

tour_cost_pairs(_M, [_Last], Acc, Acc).
tour_cost_pairs(M, [A,B|T], Acc, Cost) :-
    dist(M, A, B, D),
    Acc1 is Acc + D,
    tour_cost_pairs(M, [B|T], Acc1, Cost).

% CLP(FD): flatten matrix for stable element/3 addressing
matrix_flat(M, Flat, N) :-
    matrix_n(M, N),
    append(M, Flat).

% D = M[I][J] via Flat index
dist_fd_flat(Flat, N, I, J, D) :-
    Index #= (I - 1) * N + J,
    element(Index, Flat, D).

% CLP cost for closed Tour
tour_cost_fd_flat(_Flat, _N, [_Last], Acc, Acc).
tour_cost_fd_flat(Flat, N, [A,B|T], Acc, Cost) :-
    dist_fd_flat(Flat, N, A, B, D),
    Acc1 #= Acc + D,
    tour_cost_fd_flat(Flat, N, [B|T], Acc1, Cost).

% 1) CLP(FD) exact (ONE optimal solution)
tsp_clp(M, Start, Tour, Cost) :-
    matrix_n(M, N),
    matrix_flat(M, Flat, N),

    % Order = permutation of all cities except Start
    N1 is N - 1,
    length(Order, N1),
    Order ins 1..N,
    all_different(Order),
    maplist(#\=(Start), Order),

    append([Start|Order], [Start], Tour),

    % Cost constraints (avoid "ins" instability in some sandboxes)
    Cost #>= 0,
    Cost #=< 1000000,
    tour_cost_fd_flat(Flat, N, Tour, 0, Cost),

    labeling([ffc, min(Cost)], [Cost|Order]),
    !.

% 2) Brute force exact (baseline)
tsp_bruteforce(M, Start, Tour, Cost) :-
    matrix_n(M, N),
    numlist(1, N, Cities),
    select(Start, Cities, Others),
    permutation(Others, Perm),
    append([Start|Perm], [Start], Tour),
    tour_cost(M, Start, Tour, Cost),
    \+ ( permutation(Others, Perm2),
         append([Start|Perm2], [Start], Tour2),
         tour_cost(M, Start, Tour2, Cost2),
         Cost2 < Cost
       ).

% 3) Greedy heuristic
tsp_greedy(M, Start, Tour, Cost) :-
    matrix_n(M, N),
    numlist(1, N, Cities),
    select(Start, Cities, Remaining),
    greedy_build(M, Start, Remaining, [Start], PathRev),
    reverse(PathRev, Path),
    append(Path, [Start], Tour),
    tour_cost(M, Start, Tour, Cost).

greedy_build(_M, _Curr, [], PathRev, PathRev).
greedy_build(M, Curr, Remaining, PathRev, Final) :-
    best_next(M, Curr, Remaining, Next),
    select(Next, Remaining, Remaining1),
    greedy_build(M, Next, Remaining1, [Next|PathRev], Final).

best_next(M, Curr, [H|T], Best) :-
    dist(M, Curr, H, D0),
    best_next_(M, Curr, T, H, D0, Best).
best_next_(_M, _Curr, [], Best, _D, Best).
best_next_(M, Curr, [X|Xs], Best0, D0, Best) :-
    dist(M, Curr, X, Dx),
    ( Dx < D0 -> Best1 = X, D1 = Dx ; Best1 = Best0, D1 = D0 ),
    best_next_(M, Curr, Xs, Best1, D1, Best).

/** <examples>
?- once((sample_matrix(M), tsp_clp(M,1,TC,CC), tsp_bruteforce(M,1,TB,CB), writeln(clp=CC-TC), writeln(bf =CB-TB), CC=:=CB)).
% clp=90-[1, 2, 5, 4, 6, 3, 1]
% bf=90-[1, 2, 5, 4, 6, 3, 1]
% CB = CC, CC = 90,
% M = [[0, 10, 15, 20, 10, 25], [10, 0, 35, 25, 17, 30], [15, 35, 0, 30, 28, 14], [20, 25, 30, 0, 16, 18], [10, 17, 28, 16, 0, 12], [25, 30, 14, 18, 12, 0]],
% TB = TC, TC = [1, 2, 5, 4, 6, 3, 1]
%
?- once((sample_matrix(M), tsp_greedy(M,1,TG,CG), writeln(greedy=CG-TG))).
% greedy=103-[1, 2, 5, 6, 3, 4, 1]
% CG = 103,
% M = [[0, 10, 15, 20, 10, 25], [10, 0, 35, 25, 17, 30], [15, 35, 0, 30, 28, 14], [20, 25, 30, 0, 16, 18], [10, 17, 28, 16, 0, 12], [25, 30, 14, 18, 12, 0]],
% TG = [1, 2, 5, 6, 3, 4, 1]
*/