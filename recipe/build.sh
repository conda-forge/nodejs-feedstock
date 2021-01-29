#!/usr/bin/env bash

# scrub -std=... flag which conflicts with builds
export CXXFLAGS=$(echo ${CXXFLAGS:-} | sed -E 's@\-std=[^ ]*@@g')

if [[ "$target_platform" == osx-* ]]; then
    # unset macosx-version-min hardcoded in clang CPPFLAGS
    export CPPFLAGS="$(echo ${CPPFLAGS:-} | sed -E 's@\-mmacosx\-version\-min=[^ ]*@@g')"
    export CPPFLAGS="${CPPFLAGS} -D_DARWIN_C_SOURCE"
    echo "CPPFLAGS=$CPPFLAGS"
else
    # need librt for clock_gettime with nodejs >= 12.12
    export LDFLAGS="$LDFLAGS -lrt"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
    # see https://github.com/nodejs/node/blob/0a993e1f24beea678769bc07099f05a1ed27334d/configure.py#L1058-L1068
    case $ARCH in
        64)
           DEST_ARCH=x64
           ;;
        32)
           DEST_ARCH=ia32
           ;;
        arm64|aarch64)
           DEST_ARCH=arm64
           ;;
        ppc64le)
           DEST_ARCH=ppc64
           ;;
        *)
           echo "unknown architecture for cross"
           exit 1
           ;;
    esac
    # see https://github.com/nodejs/node-gyp/blob/c3c510d89ede3a747eb679a49254052344ed8bc3/gyp/pylib/gyp/common.py#L433
    case $target_platform in
        linux-*)
           DEST_OS=linux
           ;;
        osx-*)
           DEST_OS=mac
           ;;
        win-*)
           DEST_OS=win
           ;;
        *)
           echo "unknown os for cross"
           exit 1
           ;;
    esac
    
    EXTRA_ARGS="--cross-compiling --dest-os=$DEST_OS --dest-arch=$DEST_ARCH"
fi

export CC_host=$CC_FOR_BUILD
export CXX_host=$CXX_FOR_BUILD

echo "sysroot: ${CONDA_BUILD_SYSROOT:-unset}"

# The without snapshot comes from the error in
# https://github.com/nodejs/node/issues/4212.
./configure \
    --ninja \
    --prefix=${PREFIX} \
    --without-snapshot \
    --without-node-snapshot \
    --shared \
    --shared-libuv \
    --shared-openssl \
    --shared-zlib \
    --with-intl=system-icu ${EXTRA_ARGS}

ninja -C out/Release -j${CPU_COUNT}

if [[ "$target_platform" != osx-* ]]; then
  cp out/Release/lib/libnode.* out/Release/
fi
python tools/install.py install ${PREFIX} ''
cp out/Release/node $PREFIX/bin

node -v
npm version

if [[ "$target_platform" != osx-* ]]; then
  # Get rid of OSX specific files that confuse conda-build
  rm -rf $PREFIX/lib/node_modules/npm/node_modules/term-size/vendor/macos/term-size
fi
