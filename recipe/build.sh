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
    
    EXTRA_ARGS="--cross-compiling --dest-os=$DEST_OS --dest-cpu=$DEST_ARCH"
fi

export CC_host=$CC_FOR_BUILD
export CXX_host=$CXX_FOR_BUILD
export AR_host=$($CC_FOR_BUILD -print-prog-name=ar)
export LDFLAGS_host="$(echo $LDFLAGS | sed s@${PREFIX}@${BUILD_PREFIX}@g)"

echo "sysroot: ${CONDA_BUILD_SYSROOT:-unset}"

./configure \
    --ninja \
    --prefix=${PREFIX} \
    --without-node-snapshot \
    --shared \
    --shared-libuv \
    --shared-openssl \
    --shared-zlib \
    --with-intl=system-icu \
    ${EXTRA_ARGS}

if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  for ninja_build in `find out/Release/obj.host/ -name '*.ninja'`; do
    sed -ie 's/-mminimal-toc//g' ${ninja_build}
  done
fi

if [ "$(uname -m)" = "ppc64le" ]; then
    # Decrease parallelism a bit as we will otherwise get out-of-memory problems
    ninja -C out/Release -j3
else
    ninja -C out/Release -j${CPU_COUNT}
fi

if [[ "$target_platform" != osx-* ]]; then
  cp out/Release/lib/libnode.* out/Release/
fi
python tools/install.py install ${PREFIX} ''
cp out/Release/node $PREFIX/bin

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  node -v
  npm version
fi

if [[ "$target_platform" != osx-* ]]; then
  # Get rid of OSX specific files that confuse conda-build
  rm -rf $PREFIX/lib/node_modules/npm/node_modules/term-size/vendor/macos/term-size
fi
