#!/usr/bin/env bash

# The without snapshot comes from the error in
# https://github.com/nodejs/node/issues/4212.
./configure --prefix=$PREFIX --without-snapshot
make -j${CPU_COUNT}
make install

node -v
npm version
# upgrade npm
npm install -g npm@5.0
# dedupe npm itself to get some slight protection from long paths on Windows
# Unclear why npm doesn't do this by default
# when it does for packages other than itself.
cd $PREFIX/lib/node_modules/npm
npm dedupe

npm version
