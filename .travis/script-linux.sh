#!/bin/bash

export PATH=$TRAVIS_HOME/depot_tools:$TRAVIS_HOME/go/bin:/usr/local/ssl/bin:$PATH
export GOROOT=$TRAVIS_HOME/go

### build crashpad
cd $TRAVIS_BUILD_DIR/crashpad/crashpad
mkdir -p out/Default
echo "crashpad_use_boringssl_for_http_transport_socket=true" > out/Default/args.gn
echo "extra_cflags=\"-I$TRAVIS_BUILD_DIR/boringssl -I/usr/local/ssl/include\"" >> out/Default/args.gn
echo "extra_ldflags=\"$TRAVIS_BUILD_DIR/boringssl/build/ssl/libssl.a $TRAVIS_BUILD_DIR/boringssl/build/crypto/libcrypto.a -L/usr/local/ssl/lib\"" >> out/Default/args.gn
echo "args.gn:"
cat out/Default/args.gn
gn gen out/Default  || exit 1
ninja -C out/Default || exit 2

# we just copy the entire crashpad tree into install-ext
mkdir $TRAVIS_BUILD_DIR/install-ext
cp -R $TRAVIS_BUILD_DIR/crashpad/crashpad $TRAVIS_BUILD_DIR/install-ext/.

# also copy the entire ssl tree for Xenial builds
cp -R /usr/local/ssl $TRAVIS_BUILD_DIR/install-ext/.

# build and install breakpad
cd $TRAVIS_BUILD_DIR/breakpad/src
./configure --prefix=$TRAVIS_BUILD_DIR/install-ext
make -j
make install

