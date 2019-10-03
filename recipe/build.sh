#!/usr/bin/env bash

# scrub -std=... flag which conflicts with builds
export CXXFLAGS=$(echo ${CXXFLAGS:-} | sed -E 's@\-std=[^ ]*@@g')

if [ "$(uname)" = "Darwin" ]; then
    # unset macosx-version-min hardcoded in clang CPPFLAGS
    export CPPFLAGS="$(echo ${CPPFLAGS:-} | sed -E 's@\-mmacosx\-version\-min=[^ ]*@@g')"
    export CPPFLAGS="${CPPFLAGS} -D_DARWIN_C_SOURCE"
    echo "CPPFLAGS=$CPPFLAGS"
fi

# dyld path required to find libuv during testing
if [ "$(uname)" = "Darwin" ]; then
    # required for some tests
    export DYLD_LIBRARY_PATH=$PREFIX/lib:$DYLD_LIBRARY_PATH
    # add DYLD path for tests
    # (node incorrectly adds to LD_LIBRARY_PATH on mac)
    export DYLD_LIBRARY_PATH=$SRC_DIR/out/Release/lib.host:$SRC_DIR/out/Release/lib.target:$DYLD_LIBRARY_PATH
else
    # required for some tests
    export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
fi

# The without snapshot comes from the error in
# https://github.com/nodejs/node/issues/4212.
./configure \
    --prefix=$PREFIX \
    --without-snapshot \
    --shared-libuv \
    --shared-openssl \
    --shared-zlib \
    --with-intl=system-icu

make -j${CPU_COUNT}
make install

node -v
npm version

