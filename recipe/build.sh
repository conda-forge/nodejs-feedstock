#!/usr/bin/env bash

# scrub -std=... flag which conflicts with builds
export CXXFLAGS=$(echo ${CXXFLAGS:-} | sed -E 's@\-std=[^ ]*@@g')

# Override default number of CPUs
echo "Using $(nproc) CPUs"
CPU_COUNT=$(nproc)

# The without snapshot comes from the error in
# https://github.com/nodejs/node/issues/4212.
./configure --prefix=$PREFIX --without-snapshot
make -j${CPU_COUNT}
make install > /dev/null

node -v
npm version

