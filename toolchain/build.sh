#!/bin/bash -e

cd "$(dirname "$0")"/..

git submodule update --init --recursive

cd lib

grep -q TONLIB_HOME $HOME/.bashrc || {
    echo "export TONLIB_HOME=$PWD" >> $HOME/.bashrc
    echo 'export FIFTPATH=$TONLIB_HOME/crypto/fift/lib:$TONLIB_HOME/crypto/smartcont' >> $HOME/.bashrc
    echo 'export PATH=$PATH:$TONLIB_HOME/../toolchain/bin' >> $HOME/.bashrc
}


git pull origin master

mkdir -p build
cd build
[ ! -f CMakeCache.txt ] && {
    cmake ..
}
cmake --build . --target lite-client
cmake --build . --target fift
cmake --build . --target func

rm -f ton-lite-client-test1.config.json
wget https://test.ton.org/ton-lite-client-test1.config.json

cd ../..

echo ""
echo "DONE! Restart your shell to apply changes and use the new fift, funcompile and lite-client commands."
echo ""
