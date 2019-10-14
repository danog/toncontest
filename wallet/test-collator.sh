#!/bin/bash -ex
{

    address=$(cat tests/naddr.addr)

    cd ../lib/build
    rm -rf new
    mkdir -p new
    cd new
    mkdir -p db/static

    ../crypto/create-state ../../../toolchain/gen-zerostate.fif | tee log
    mv basestate0.boc db/static/$(sed '/Basestate0 file hash= /!d;s/Basestate0 file hash= //g;s/ .*//g' log)
    cp zerostate.boc db/static/$(sed '/Zerostate file hash= /!d;s/Zerostate file hash= //g;s/ .*//g' log)

    rm log

    fift -s ../../../toolchain/testgiver.fif $address 0 20

    ../test-ton-collator -z zerostate.boc -D db -v5 -m testgiver-query.boc
    ../test-ton-collator -z zerostate.boc -D db -v5 -w 0 -m ../../../wallet/tests/pony-create.boc -m ../../../wallet/tests/b.boc -m ../../../wallet/tests/code-update-merge.boc -m ../../../wallet/tests/c.boc
} 2>&1 | less -R
