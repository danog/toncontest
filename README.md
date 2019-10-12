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