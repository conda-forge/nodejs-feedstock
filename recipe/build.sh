#!/usr/bin/env bash

set -exuo pipefail

# Make the abseil target empty
cp $RECIPE_DIR/abseil.gyp tools/v8_gypfiles/abseil.gyp

# scrub -std=... flag which conflicts with builds
export CXXFLAGS=$(echo ${CXXFLAGS:-} | sed -E 's@\-std=[^ ]*@@g')

if [[ "$target_platform" == osx-* ]]; then
    # unset macosx-version-min hardcoded in clang CPPFLAGS
    export CPPFLAGS="$(echo ${CPPFLAGS:-} | sed -E 's@\-mmacosx\-version\-min=[^ ]*@@g')"
    export CPPFLAGS="${CPPFLAGS} -D_DARWIN_C_SOURCE"
    echo "CPPFLAGS=$CPPFLAGS"
    sed -i '/@loader_path/d' node.gyp
else
    # need librt for clock_gettime with nodejs >= 12.12
    export LDFLAGS="$LDFLAGS -lrt"

    # https://github.com/nodejs/node/issues/52223
    sed -i 's/define HAVE_SYS_RANDOM_H 1/undef HAVE_SYS_RANDOM_H/g' deps/cares/config/linux/ares_config.h
    sed -i 's/define HAVE_GETRANDOM 1/undef HAVE_GETRANDOM/g' deps/cares/config/linux/ares_config.h
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
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
    --verbose \
    --prefix=${PREFIX} \
    --without-node-snapshot \
    --shared \
    --shared-brotli \
    --shared-cares \
    --shared-libuv \
    --shared-nghttp2 \
    --shared-openssl \
    --shared-sqlite \
    --shared-zlib \
    --shared-zstd \
    --with-intl=system-icu \
    ${EXTRA_ARGS:-}

if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  for ninja_build in `find out/Release/obj.host/ -name '*.ninja'`; do
    sed -ie 's/-mminimal-toc//g' ${ninja_build}
  done
fi

if [[ "${target_platform}" != "${build_platform}" ]]; then
  # Don't optimize code for the build host so much
  for ninja_build in `find out/Release/obj.host/ -name '*.ninja'`; do
    # O0 leads to compilation issues with GCC
    if [[ "${target_platform}" == linux-* ]]; then
      sed -ie 's/-O3/-O1/g' ${ninja_build}
    else
      sed -ie 's/-O3/-O0/g' ${ninja_build}
    fi
  done
fi

ninja -C out/Release -j${CPU_COUNT}

if [[ "$target_platform" != osx-* ]]; then
  cp out/Release/lib/libnode.* out/Release/
fi
python tools/install.py install --dest-dir ${PREFIX} --prefix ''
cp out/Release/node $PREFIX/bin

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  node -v
  npm version
fi

if [[ "${target_platform}" != osx-* ]]; then
  # Get rid of OSX specific files that confuse conda-build
  rm -rf $PREFIX/lib/node_modules/npm/node_modules/term-size/vendor/macos/term-size
fi
