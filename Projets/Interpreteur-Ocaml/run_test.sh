#!/usr/bin/env bash
set -e

EXE=./_build/default/main.exe

for f in tests/*.test; do
  echo "=== $f ==="
  $EXE "$f" > out.s
  spim -file out.s
done
