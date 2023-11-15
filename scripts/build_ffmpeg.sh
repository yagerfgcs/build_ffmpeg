#!/bin/bash
ROOT_DIR=`pwd`/../
FFMPEG_SRC=${ROOT_DIR}/FFmpeg
INSTALL_DIR=${ROOT_DIR}/install
SCRIPTS_DIR=${ROOT_DIR}/scripts
THIRD_PARTY_DIR=${ROOT_DIR}/3rd

if [ -d $INSTALL_DIR ]; then
    echo "Use exists install dir."
else
    mkdir $INSTALL_DIR
fi

install_nasm()
{
    echo "Install nasm..."
    if command -v nasm >/dev/null 2>&1; then
        echo "Use exists nasm."
    else
        os_type=$(uname)
        if [[ "$os_type" == "Darwin" ]]; then
            brew install nasm
            #/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        elif [[ "$os_type" == "Linux" ]]; then
            sudo yum install -y http://yum.tbsite.net/taobao/7/x86_64/test/nasm/nasm-2.15.03-3.el8.x86_64.rpm
        else
            echo "Unknown operating system"
        fi
        echo "Install nasm done."
    fi
}

build_lame()
{
    echo "Build lame"
    if [ -f "${INSTALL_DIR}/lib/libmp3lame.a" ]; then
        echo "Use built static libmp3lame.a"
    else
        if [ -f "${THIRD_PARTY_DIR}/lame-3.100.tar.gz" ]; then
            echo "exist lame source in 3rd dir, use it"
            tar -zxvf ${THIRD_PARTY_DIR}/lame-3.100.tar.gz -C $INSTALL_DIR
        else
            echo "do not have lame source, need download"
            wget https://jaist.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz -P ${THIRD_PARTY_DIR}
        fi
        pushd $INSTALL_DIR/lame*
        os_type=$(uname)
        if [[ "$os_type" == "Darwin" ]]; then
            XCRUN_SDK=`echo macosx | tr '[:upper:]' '[:lower:]'`
            CC="xcrun -sdk $XCRUN_SDK clang -arch x86_64"
            CFLAGS="-arch x86_64 $SIMULATOR"
            if ! xcodebuild -version | grep "Xcode [1-6]\."
            then
                CFLAGS="$CFLAGS -fembed-bitcode"
            fi
            CXXFLAGS="$CFLAGS"
            LDFLAGS="$CFLAGS"
            CC=$CC ./configure --disable-shared --disable-frontend --host=x86_64-apple-darwin \
                               --prefix=$INSTALL_DIR CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
        elif [[ "$os_type" == "Linux" ]]; then
            LDFLAGS="-fPIC" ./configure --prefix=$INSTALL_DIR --build=BUILD --enable-static --enable-nasm --with-pic
        else
            echo "Unknown operating system"
        fi
        make -j
        make install
        popd
    fi
}

build_x264()
{
    pushd $INSTALL_DIR
    echo "Build x264"
    if [ -d x264 ]; then 
        echo "Use exists x264."
    else
        git clone -b master git@github.com:mirror/x264.git
    fi
    pushd x264
    if [ -f "${INSTALL_DIR}/lib/libx264.a" ]; then
        echo "Use built static libx264.a"
    else
        ./configure --prefix=$INSTALL_DIR \
         --enable-static \
         --enable-pic
    fi
    make -j
    make install
    popd
    popd
}

build_x265()
{
    pushd $INSTALL_DIR
    echo "Build x265"
    if [ -d x265 ]; then 
        echo "Use exists x265."
    else
        if [ -f "${THIRD_PARTY_DIR}/x265_v3.3.tar.gz" ]; then
            echo "exist x265 in 3rd dir, use it"
            tar -zxvf $THIRD_PARTY_DIR/x265_v3.3.tar.gz -C $INSTALL_DIR
        else
            echo "download x265 source code from https://www.x265.org/downloads/ and save it to 3rd dir, for example: 3rd/x265_v3.3.tar.gz"
        fi 
    fi
    pushd x265_3.3
    ln -sf $INSTALL_DIR/../scripts/x265_multilib.sh build/linux/x265_multilib.sh
    if [ -f "${INSTALL_DIR}/lib/libx265.a" ]; then
        echo "Use built static libx265.a"
    else
        pushd build/linux
            sh x265_multilib.sh $INSTALL_DIR
        popd
    fi
    popd
    popd
}

# backup
#     ./configure --pkg-config=$(which pkg-config) \
#     --pkg-config-flags="--static" \
#     --enable-pic \
#     --enable-static \
#     --enable-shared \
#     --prefix=${INSTALL_DIR} \
#     --enable-libx264 \
#     --enable-libx265 \
#     --enable-decoder=hevc \
#     --enable-demuxer=flv --enable-demuxer=h264 --enable-demuxer=hevc --enable-demuxer=hls \
#     --enable-openssl \
#     --enable-libmp3lame \
#     --enable-gpl \
#     --enable-nonfree \
#     --disable-doc \
#     --extra-cflags="-I${INSTALL_DIR}/include "\
#     --extra-ldflags="-L${INSTALL_DIR}/lib -ldl -lpthread"

# for debug, add --enable-debug --disable-stripping
build_ffmpeg()
{
    if [ -f "${INSTALL_DIR}/lib/libavcodec.so" ]; then
        echo "Use built libavcodec.so"
    else
        pushd $ROOT_DIR
        echo "check ffmpeg source"
        if [ -d FFmpeg ]; then 
            echo "Use exists ffmpeg."
        else
            git clone -b feature/support_hevc_base_rc4.4 git@github.com:yagerfgcs/FFmpeg.git
        fi
        pushd FFmpeg
        # configure
        export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:$INSTALL_DIR/lib/pkgconfig

        # for v4.4
        ./configure --pkg-config=$(which pkg-config) \
                  --pkg-config-flags="--static" \
                  --enable-debug --disable-stripping \
                  --enable-pic \
                  --enable-static \
                  --prefix=${INSTALL_DIR} \
                  --enable-libx264 --enable-libx265 \
                  --enable-encoder=libx264 --enable-encoder=libx265 \
                  --enable-decoder=h264 --enable-decoder=hevc \
                  --enable-demuxer=h264 --enable-demuxer=hevc --enable-demuxer=hls \
                  --enable-muxer=h264 --enable-muxer=hevc \
                  --enable-openssl \
                  --enable-libmp3lame \
                  --enable-gpl \
                  --enable-avresample \
                  --enable-nonfree \
                  --disable-doc \
                  --extra-cflags="-I${INSTALL_DIR}/include "\
                  --extra-ldflags="-L${INSTALL_DIR}/lib -ldl -lpthread"

        # for v6.1
        # ./configure --pkg-config=$(which pkg-config) \
        #           --pkg-config-flags="--static" \
        #           --enable-debug --disable-stripping \
        #           --enable-pic \
        #           --enable-static \
        #           --prefix=${INSTALL_DIR} \
        #           --enable-libx264 --enable-libx265 \
        #           --enable-encoder=libx264 --enable-encoder=libx265 \
        #           --enable-decoder=h264 --enable-decoder=hevc \
        #           --enable-demuxer=h264 --enable-demuxer=hevc --enable-demuxer=hls \
        #           --enable-muxer=h264 --enable-muxer=hevc \
        #           --enable-openssl \
        #           --enable-libmp3lame \
        #           --enable-gpl \
        #           --enable-nonfree \
        #           --disable-doc \
        #           --extra-cflags="-I${INSTALL_DIR}/include "\
        #           --extra-ldflags="-L${INSTALL_DIR}/lib -ldl -lpthread"

        make -j16
        make examples
        make install
        popd
        popd
    fi
}

package_ffmpeg() 
{
    pushd $INSTALL_DIR
    if [ -d ffmpeg ]; then
        rm -rf ffmpeg
    fi
    mkdir -p ffmpeg
    cp -rf lib include bin ffmpeg/
    tar -czvf ffmpeg.tar.gz ffmpeg
    popd
}

###################### script started ######################
install_nasm
build_lame
build_x264
build_x265
build_ffmpeg
package_ffmpeg


