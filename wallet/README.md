# Multisignature wallet

Upgradable multisignature wallet.
Included signature verification scripts to avoid problems with eventual preloaded orders with invalid signatures.

Code can be upgraded via a special multisignature message.

```
  633  fift -s ../wallet-create.fif 0 pony 10 10 {a..k}
  634  chr() {   [ "$1" -lt 256 ] || return 1;   printf "\\$(printf '%03o' "$1")"; }
  635  ord() {   LC_CTYPE=C printf '%d' "'$1"; }
  636  ord a
  637  for f in {0..9}; do fift -s ../gen-pub.fif ;done
  638  for f in {a..k}; do fift -s ../gen-pub.fif ;done
  639  for f in {a..k}; do fift -s ../gen-pub.fif $f;done
  640  fift -s ../wallet-create.fif 0 pony 10 10 {a..k}
  641  ls
  642  fift -s ../create.fif 
  643  for f in {0..9}; do fift -s ../create.fif $(chr $((97+f))) $f kQB_1uJkjQ06tWkLoX6WJjqmpgMctmSX8Z7jVbAWhaENe_qJ 10 $(chr $((97+f)));done
  644  for f in {0..9}; do fift -s ../create.fif pony $(chr $((97+f))) $f kQB_1uJkjQ06tWkLoX6WJjqmpgMctmSX8Z7jVbAWhaENe_qJ 10 $(chr $((97+f)));done
  645  for f in {0..9}; do fift -s ../create.fif pony $(chr $((97+f))) $f kQB_1uJkjQ06tWkLoX6WJjqmpgMctmSX8Z7jVbAWhaENe_qJ 0 10 $(chr $((97+f)));done
  646  fift -s ../merge.fif 
  647  fift -s ../merge.fif {a..k} merge
  648  fift -s ../merge.fif {a..j} merge
  649  fift -s ../inspect.fif merge
  650  fift -s ../inspect.fif merge
  651  fift -s ../merge.fif {a..j} merge
  652  fift -s ../merge.fif {a..j} merge
  653  fift -s ../merge.fif {a..j} merge
  654  fift -s ../merge.fif {a..j} merge
  655  fift -s ../merge.fif {a..j} merge
  656  fift -s ../merge.fif {a..j} merge
  657  fift -s ../merge.fif {a..j} merge
  658  fift -s ../merge.fif {a..j} merge
  659  for f in {1..9}; do fift -s ../sign.fif a $(chr $((97+f))) $(chr $((97+f))) $f;done
  660  fift -s ../merge.fif {a..j} merge
  661  fift -s ../inspect.fif j
  662  fift -s ../inspect.fif merge
```