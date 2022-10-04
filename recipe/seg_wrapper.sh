#!/bin/bash
ulimit -c unlimited
echo "Search #1 -----"
find / -name libSegFault.so 2>/dev/null
LD_PRELOAD=/opt/conda/envs/sysroot_linux-ppc64le/powerpc64le-conda-linux-gnu/sysroot/lib64/libSegFault.so "$@"
if [[ $? -eq 139 ]]; then
  ls -l
  file $1
  gdb -q $1 *.core -x $(pwd)/backtrace
fi
