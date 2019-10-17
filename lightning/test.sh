
#!/bin/bash -e
# Define some helper functions
chr() { [ "$1" -lt 256 ] || return 1; printf "\\$(printf '%03o' "$1")"; }
ord() { LC_CTYPE=C printf '%d' "'$1"; }

{
    mkdir -p tests
    cd tests
    # Create 2 wallets, with 2 public/private keypairs
    fift -s ../../lib/crypto/smartcont/new-wallet-v2.fif 0 wallA | tee logwallA
    fift -s ../../lib/crypto/smartcont/new-wallet-v2.fif 0 wallB | tee logwallB

    sed '/Non-bounceable address [(]for init[)]: /!d;s/.* //g' logwallA > initaddrwallA.addr
    sed '/Non-bounceable address [(]for init[)]: /!d;s/.* //g' logwallB > initaddrwallB.addr

    addrwallA=$(sed '/Bounceable address [(]for later access[)]: /!d;s/.* //g' logwallA)
    addrwallB=$(sed '/Bounceable address [(]for later access[)]: /!d;s/.* //g' logwallB)

    # Generate public key files
    fift -s ../gen-pub.fif wallA
    fift -s ../gen-pub.fif wallB

    # Create wallet with those 2 public keys and and addresses
    fift -s ../wallet-create.fif 0 pony wallA wallB $addrwallA $addrwallB | tee log

    # Get wallet address
    sed '/Non-bounceable address [(]for init[)]: /!d;s/.* //g' log > naddr.addr

    address=$(sed '/Bounceable address [(]for later access[)]: /!d;s/.* //g' log)
    rm log
    rm logwallA
    rm logwallB
    echo

    # Sign zerostate with key B
    fift -s ../sign.fif pony wallB 0

    # Create a new wallet query (seqno 1) signed with key B (not creator A), transferring 5 grams to the other user (A)
    fift -s ../create.fif pony wallB 0 1 5 0 # Not final

    # Sign new state with key A
    fift -s ../sign.fif pony wallA 1

    # Create a new wallet query (seqno 2) signed with creator key A), transferring 3 grams to the other user (B)
    fift -s ../create.fif pony wallA 1 2 3   # Not final

    # Sign new state with key B
    fift -s ../sign.fif pony wallB 2

    # Create a new wallet query (seqno 1) signed with key B (not creator A), transferring 0 grams to the other user (A)
    fift -s ../create.fif pony wallB 0 3 0 0 # Not final

    # Sign new state with key A
    fift -s ../sign.fif pony wallA 3

    # Inspect final state 3
    fift -s ../inspect.fif pony-state3c

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
        pony-state0c-ext -1 \
        pony-state1c-ext -1 \
        pony-state1-ext -1 \
        pony-state2-ext -1 \
        pony-state2c-ext -1 \
        pony-state3-ext -1 \
        pony-state3c-ext -1
} 2>&1 | less -R
