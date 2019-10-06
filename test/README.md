From https://github.com/ton-blockchain/ton/issues/96:

Errors triggered by code inside a coroutine currently being called by the `times` loop keyword surface with an invalid line number, as if the error was triggered by the `times` keyword, instead of the actual keyword that originated the exception (basically, we're missing full stack traces here).

```
[daniil@daniil-arch test]$ cat test.fif 
{ abort"This is an error thrown inside a times loop" } : throw

{
  ."Printing stuff at line 4" cr
  ."Printing stuff at line 5" cr
  throw            // line 6
  ."Printing stuff at line 7" cr
} 3 times          // line 8

[daniil@daniil-arch test]$ fift -s test.fif
Printing stuff at line 4
Printing stuff at line 5
[ 1][t 0][1570377741.616638660][words.cpp:2804] test.fif:8: times: stack underflow
[ 1][t 0][1570377741.616738081][fift-main.cpp:198]      Error interpreting file `test.fif`: error interpreting included file `test.fif` : test.fif:8: times: stack underflow
```

Fift indicates that the error was thrown at line 8 by the `times` keyword (`test.fif:8: times:`): while it is true that the exception surfaced at that point in the code, the rest of the stack trace is missing, making it hard to debug exceptions thrown inside loops.
It would be nice to have a full stack trace, for example indicating that the error was first thrown in `test.fif:1: abort`, then surfaced in `test.fif:6: throw`, finally surfacing as `test.fif:8: times`.
