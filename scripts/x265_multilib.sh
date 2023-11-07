#!/bin/sh
PREFIX_DIR=${1:-/usr/local/lib}

mkdir -p 8bit 10bit 12bit

pushd 12bit
cmake ../../../source -DCMAKE_INSTALL_PREFIX=${PREFIX_DIR} -DHIGH_BIT_DEPTH=ON \
    -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DMAIN12=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
make ${MAKEFLAGS} -j
popd

pushd 10bit
cmake ../../../source -DCMAKE_INSTALL_PREFIX=${PREFIX_DIR} -DHIGH_BIT_DEPTH=ON \
    -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
make ${MAKEFLAGS} -j
popd

pushd 8bit
ln -sf ../10bit/libx265.a libx265_main10.a
ln -sf ../12bit/libx265.a libx265_main12.a
cmake ../../../source -DCMAKE_INSTALL_PREFIX=${PREFIX_DIR} -DEXTRA_LIB="x265_main10.a;x265_main12.a" -DEXTRA_LINK_FLAGS=-L. -DLINKED_10BIT=ON \
    -DLINKED_12BIT=ON -DENABLE_SHARED=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DENABLE_CLI=OFF
make ${MAKEFLAGS} -j

# rename the 8bit library, then combine all three into libx265.a
mv libx265.a libx265_main.a

uname=`uname`
if [ "$uname" = "Linux" ]
then

# On Linux, we use GNU ar to combine the static libraries together
ar -M <<EOF
CREATE libx265.a
ADDLIB libx265_main.a
ADDLIB libx265_main10.a
ADDLIB libx265_main12.a
SAVE
END
EOF

else

# Mac/BSD libtool
libtool -static -o libx265.a libx265_main.a libx265_main10.a libx265_main12.a 2>/dev/null

fi
make install
popd


