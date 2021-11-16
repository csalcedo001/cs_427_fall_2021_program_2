factorial(0, 1).
factorial(N, F) :-  
   N > 0, 
   N1 is N-1, 
   factorial(N1, F1), 
   F is N * F1.

list_factorial(0, 1, [1]).
list_factorial(N, F, L) :-  
   N > 0, 
   N1 is N-1, 
   list_factorial(N1, F1, L1), 
   F is N * F1,
   append(L1, [F], L).
