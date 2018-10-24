#!/usr/bin/env bash

# remove `-std=c++17` from CXXFLAGS
export CXXFLAGS=$(echo $CXXFLAGS | sed -E 's@\-std=[^ ]+@@')
# The without snapshot comes from the error in
# https://github.com/nodejs/node/issues/4212.
./configure --prefix=$PREFIX --without-snapshot
make -j${CPU_COUNT}
make install

node -v
npm version

