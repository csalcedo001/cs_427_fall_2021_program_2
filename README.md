# Program 2 - Prolog

## How to run

```
swipl -l main.pl
```

After entering the interface, run the following lines to make the tests:

```
run(Puzzle, Method).
```

where Puzzle can be vamp\_wolf or sliding\_tile, and Method can be bfs, dfs, or hfs. The solution path will be printed if a path could be found during the execution of the program. Additionally, hfs prints the state and its cost as it is visiting them throughout the search.
