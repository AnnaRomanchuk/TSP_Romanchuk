# TSP: Prolog (CLP(FD)) + Haskell

## Files
- `tsp.pl` — Prolog solution: CLP(FD) (exact), brute force (exact), greedy (heuristic)
- `TSP.hs` — Haskell solution: brute force (exact), greedy (heuristic)

## Run Prolog (SWI)
```prolog
?- once((sample_matrix(M), tsp_clp(M,1,TC,CC), tsp_bruteforce(M,1,TB,CB), writeln(clp=CC-TC), writeln(bf =CB-TB), CC=:=CB)).
?- once((sample_matrix(M), tsp_greedy(M,1,TG,CG), writeln(greedy=CG-TG))).
```
## Run Haskell
```
:l TSP_zadacha_Romanchuk.hs
demo
```
