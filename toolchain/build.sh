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

cd ../..
