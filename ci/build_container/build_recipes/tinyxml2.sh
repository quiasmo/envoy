#!/bin/bash

set -e

VERSION=5.0.0

wget -O tinyxml2-$VERSION.tar.gz https://github.com/leethomason/tinyxml2/archive/$VERSION.tar.gz
tar xf tinyxml2-$VERSION.tar.gz
cd tinyxml2-$VERSION
$CC $CFLAGS $CPPFLAGS -c tinyxml2.cpp -o tinyxml2.o
ar rcs libtinyxml2.a tinyxml2.o
cp libtinyxml2.a $THIRDPARTY_BUILD/lib
cp tinyxml2.h $THIRDPARTY_BUILD/include
