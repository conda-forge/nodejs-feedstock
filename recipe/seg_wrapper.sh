#!/bin/bash
ulimit -c unlimited
ls -l /lib/*/libSeg*.so
LD_PRELOAD=/lib/powerpc64le-linux-gnu/libSegFault.so "$@"
if [[ $? -eq 139 ]]; then
  ls -l
  file $1
  gdb -q $1 *.core -x $(pwd)/backtrace
fi
