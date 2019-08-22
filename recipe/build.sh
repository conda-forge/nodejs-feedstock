#!/usr/bin/env bash

# scrub -std=... flag which conflicts with builds
export CXXFLAGS=$(echo ${CXXFLAGS:-} | sed -E 's@\-std=[^ ]*@@g')

if [ "$(uname)" = "Darwin" ]; then
    # unset macosx-version-min hardcoded in clang CPPFLAGS
    export CPPFLAGS="$(echo ${CPPFLAGS:-} | sed -E 's@\-mmacosx\-version\-min=[^ ]*@@g')"
    export CPPFLAGS="${CPPFLAGS} -D_DARWIN_C_SOURCE"
    echo "CPPFLAGS=$CPPFLAGS"
fi

# node config seems to ignore LDFLAGS?
# try cramming them into CFLAGS
export CFLAGS="$CFLAGS $LDFLAGS"
export CXXFLAGS="$CXXFLAGS $LDFLAGS"

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

