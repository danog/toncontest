
#!/bin/bash -e
# Define some helper functions
chr() { [ "$1" -lt 256 ] || return 1; printf "\\$(printf '%03o' "$1")"; }
ord() { LC_CTYPE=C printf '%d' "'$1"; }

mkdir -p tests
cd tests
# Create 10 public keys
for f in {a..j}; do fift -s ../gen-pub.fif $f;done

# Create wallet with those 10 public keys on workchain 0, requiring all 10 signatures to send a message
fift -s ../wallet-create.fif 0 pony 10 10 {a..j} | tee log

# Get wallet address
sed '/Non-bounceable address [(]for init[)]: /!d;s/.* //g' log > naddr.addr

address=$(sed '/Bounceable address [(]for later access[)]: /!d;s/.* //g' log)
rm log

# Create a new wallet query signed with key a (ID 0), transferring 10 grams to the wallet itself
fift -s ../create.fif pony a 0 $address 0 10 a

# Here, note the `a 0`: to save space, I have chosen to not use the entire ecdh key as key in the signature dictionary.
# Instead, a **key ID** is used to distinguish signatures made by certain keys: this is a simple 4-bit value (instead of 256 bits!), equal to the position of the key in the `wallet-create` argument list.
# In this case, the `a` key was the first key (`{a..j}` in Bash is shorthand for `a b c .. j`), so the ID is `0`.
# What follows is the address, the seqno, the amount of grams and the savefile (`a`) for the query.



# Sign the query using all keys separately, creating eight more boc files, each signed by two keys only (0 and 1..9)
for f in {1..9}; do fift -s ../sign.fif a $(chr $((97+f))) $(chr $((97+f))) $f;done

# Merge all queries
fift -s ../merge.fif {a..j} merge

# Inspect queries
fift -s ../inspect.fif merge

# Finally run the generated files in the VM
#
# First init VM with constructor message
# Then load first file with only one signature by key a (0)
# Run seqno get-method
# Run getPartialsByKeyId get-method
# Load file with all signatures (and send message)
# Run getPartialsByKeyId get-method
#
fift -s ../test.fif \
    pony-create \
    a -1 \
    0 85143 \
    0 113609 \
    merge -1 \
    0 113609