#!/bin/bash
#

set -ex

prefix=$1

tmpdir=$(mktemp -d)
pushd $tmpdir

curl -L https://sourceforge.net/projects/astyle/files/astyle/astyle%203.1/astyle_3.1_linux.tar.gz/download | \
    tar xzf -

pushd astyle/build/gcc
make -j
make prefix=$prefix install
popd
popd
rm -rf "$tmpdir"

