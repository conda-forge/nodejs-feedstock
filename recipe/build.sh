#!/usr/bin/env bash

# scrub -std=... flag which conflicts with builds
export CXXFLAGS=$(echo ${CXXFLAGS:-} | sed -E 's@\-std=[^ ]*@@g')

# Increase CPUs for multiarch builds
if [ "$(uname -m)" = "armv8" ] || [ "$(uname -m)" = "ppc64le" ]; then
    echo "Using $(grep -c ^processor /proc/cpuinfo) CPUs"
    CPU_COUNT=$(grep -c ^processor /proc/cpuinfo)
fi

if [ "$(uname)" = "Darwin" ]; then
    # unset macosx-version-min hardcoded in clang CPPFLAGS
    export CPPFLAGS="$(echo ${CPPFLAGS:-} | sed -E 's@\-mmacosx\-version\-min=[^ ]*@@g')"
    export CPPFLAGS="${CPPFLAGS} -D_DARWIN_C_SOURCE"
    echo "CPPFLAGS=$CPPFLAGS"
else
    # need librt for clock_gettime with nodejs >= 12.12
    export LDFLAGS="$LDFLAGS -lrt"
fi

echo "sysroot: ${CONDA_BUILD_SYSROOT:-unset}"

# The without snapshot comes from the error in
# https://github.com/nodejs/node/issues/4212.
./configure \
    --prefix=$PREFIX \
    --without-snapshot \
    --without-node-snapshot \
    --shared-libuv \
    --shared-openssl \
    --shared-zlib \
    --with-intl=system-icu

# Decrease parallelism a bit as we will otherwise get out-of-memory problems
# This is only necessary on Travis
if [ "$(uname -m)" = "ppc64le" ]; then
    # Decrease parallelism a bit as we will otherwise get out-of-memory problems
    echo "Using $(grep -c ^processor /proc/cpuinfo) CPUs"
    CPU_COUNT=$(grep -c ^processor /proc/cpuinfo)
    CPU_COUNT=$((CPU_COUNT / 4))
fi
make -j${CPU_COUNT}
make install > /dev/null

node -v
npm version

