
#!/bin/bash
# Define some helper functions
chr() { [ "$1" -lt 256 ] || return 1; printf "\\$(printf '%03o' "$1")"; }
ord() { LC_CTYPE=C printf '%d' "'$1"; }

mkdir -p tests
cd tests
# Create 10 public keys
for f in {a..j}; do fift -s ../gen-pub.fif $f;done

# Create wallet with those 10 public keys on workchain 0, requiring all 10 signatures to send a message
fift -s ../wallet-create.fif 0 pony 10 10 {a..j}
ls
fift -s ../create.fif 
for f in {0..9}; do fift -s ../create.fif $(chr $((97+f))) $f kQB_1uJkjQ06tWkLoX6WJjqmpgMctmSX8Z7jVbAWhaENe_qJ 10 $(chr $((97+f)));done
for f in {0..9}; do fift -s ../create.fif pony $(chr $((97+f))) $f kQB_1uJkjQ06tWkLoX6WJjqmpgMctmSX8Z7jVbAWhaENe_qJ 10 $(chr $((97+f)));done
for f in {0..9}; do fift -s ../create.fif pony $(chr $((97+f))) $f kQB_1uJkjQ06tWkLoX6WJjqmpgMctmSX8Z7jVbAWhaENe_qJ 0 10 $(chr $((97+f)));done
fift -s ../merge.fif 
fift -s ../merge.fif {a..j} merge
fift -s ../merge.fif {a..j} merge
fift -s ../inspect.fif merge
fift -s ../inspect.fif merge
fift -s ../merge.fif {a..j} merge
fift -s ../merge.fif {a..j} merge
fift -s ../merge.fif {a..j} merge
fift -s ../merge.fif {a..j} merge
fift -s ../merge.fif {a..j} merge
fift -s ../merge.fif {a..j} merge
fift -s ../merge.fif {a..j} merge
fift -s ../merge.fif {a..j} merge
for f in {1..9}; do fift -s ../sign.fif a $(chr $((97+f))) $(chr $((97+f))) $f;done
fift -s ../merge.fif {a..j} merge
fift -s ../inspect.fif j
fift -s ../inspect.fif merge