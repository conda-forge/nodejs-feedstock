#!/bin/bash
ulimit -c unlimited
gdb -x $(pwd)/backtrace --args "$@"
#if [[ $? -eq 139 ]]; then
#  ls -l
#  file $1
#  gdb -q $1 *.core -x $(pwd)/backtrace
#fi
