# Daniil Gentili entry

This is my entry for the TON contest.

## Building

Simply run the build.sh script to automatically build tonlib and set up some simplified wrapper scripts.

```
toolchain/build.sh
```

This will automatically build the lite client, fift and func, and will also edit .bashrc to add some wrapper scripts to the PATH.

* `lite-client` runs the lite client, already preconfigured to connect to the testnet, with db path set to $TONLIB_HOME/../ton-db-dir (aka this repo/ton-db-dir).
* `funcompile` is a wrapper for the `func` compiler, automatically including the stdlib while compiling.
* `fift` is a simple wrapper for the fift compiler.

## Contents

* `toolchain` - Some automatic builder scripts and wrappers around the funC compiler and fift
* `wallet` - Advanced upgradable multisignature wallet
* `test` - A small bugreport about issues with fift exception traces
* [GitHub issues and bugreports](https://github.com/ton-blockchain/ton/issues?utf8=%E2%9C%93&q=author%3Adanog+):
  * [#59, bug in funC compiler](https://github.com/ton-blockchain/ton/issues/59)
  * [#96, issues with fift exception traces](https://github.com/ton-blockchain/ton/issues/96)
  * [#87, pull request with more funC dictionary manipulation primitives](https://github.com/ton-blockchain/ton/pull/87)
  * [#98, pull request with minor fift script shebang fixes](https://github.com/ton-blockchain/ton/pull/98)
* Another improvement for the funC language would be the implementation of more tuple manipulation primitives, such as quiet tuple fetching primitives:
```
// <type> <type>_atq(tuple t, int index) asm "INDEXVARQ";
AsmOp compile_tuple_atq(std::vector<VarDescr>& res, std::vector<VarDescr>& args) {
  assert(args.size() == 2 && res.size() == 1);
  auto& y = args[1];
  if (y.is_int_const() && y.int_const >= 0 && y.int_const < 16) {
    y.unused();
    return exec_arg_op("INDEXQ", y.int_const, 1, 1);
  }
  return exec_op("INDEXVARQ", 2, 1);
}

// ...

  define_builtin_func("int_atq", TypeExpr::new_map(TupleInt, Int), compile_tuple_atq);
  define_builtin_func("cell_atq", TypeExpr::new_map(TupleInt, Cell), compile_tuple_atq);
  define_builtin_func("slice_atq", TypeExpr::new_map(TupleInt, Cell), compile_tuple_atq);
  define_builtin_func("tuple_atq", TypeExpr::new_map(TupleInt, Tuple), compile_tuple_atq);
  define_builtin_func("atq", TypeExpr::new_forall({X}, TypeExpr::new_map(TupleInt, X)), compile_tuple_atq);
```

And 
