FROM ubuntu:20.04

LABEL maintainer="Johannes.Pohl90@gmail.com"

ENV TZ=Europe/Berlin

ADD mingw-w64-i686.cmake mingw-w64-x86_64.cmake /root/

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \  
 && apt-get -qq update \
 && apt-get -qq install git mingw-w64 mingw-w64-tools cmake wget p7zip-full file llvm \
 && mkdir -p /result/64 && mkdir -p /result/32 \
 && cp /usr/i686-w64-mingw32/lib/libwinpthread-1.dll /result/32 \
 && cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll /result/64 \
 && mkdir -p /libusb && cd libusb \
 && wget https://github.com/libusb/libusb/releases/download/v1.0.25/libusb-1.0.25.7z \
 && 7z x libusb-1.0.25.7z \
 && cp include/libusb-1.0/libusb.h /usr/i686-w64-mingw32/include/ \
 && cp include/libusb-1.0/libusb.h /usr/x86_64-w64-mingw32/include/ \
 && cp MinGW32/dll/libusb-1.0.dll* /usr/i686-w64-mingw32/lib/ \
 && cp MinGW32/dll/libusb-1.0.dll /result/32 \
 && cp MinGW64/dll/libusb-1.0.dll* /usr/x86_64-w64-mingw32/lib/ \
 && cp MinGW64/dll/libusb-1.0.dll /result/64

RUN git clone --depth 1 https://github.com/airspy/airspyone_host /airspy && cd /airspy \
 && mkdir build && cd build \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-x86_64.cmake .. \
 && make -j$(nproc) \
 && cp airspy-tools/src/libairspy.dll /result/64 \
 && cd .. && mkdir build32 && cd build32 \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-i686.cmake .. \
 && make -j$(nproc) \
 && cp airspy-tools/src/libairspy.dll /result/32

RUN wget http://www.fftw.org/fftw-3.3.10.tar.gz \
 && tar xf fftw-3.3.10.tar.gz \
 && rm fftw-3.3.10.tar.gz \
 && cd fftw-3.3.10 \
 && mkdir build && cd build \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-x86_64.cmake -DENABLE_FLOAT=OFF -DENABLE_LONG_DOUBLE=OFF -DENABLE_QUAD_PRECISION=OFF .. \
 && make -j$(nproc) \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-x86_64.cmake -DENABLE_FLOAT=ON -DENABLE_LONG_DOUBLE=OFF -DENABLE_QUAD_PRECISION=OFF .. \
 && make -j$(nproc) \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-x86_64.cmake -DENABLE_FLOAT=OFF -DENABLE_LONG_DOUBLE=ON -DENABLE_QUAD_PRECISION=OFF .. \
 && make -j$(nproc) \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-x86_64.cmake -DENABLE_FLOAT=OFF -DENABLE_LONG_DOUBLE=OFF -DENABLE_QUAD_PRECISION=ON .. \
 && cp ../api/fftw3.h /usr/x86_64-w64-mingw32/include/ \
 && cp libfftw3* /usr/x86_64-w64-mingw32/lib/ \
 && cp libfftw3*.dll /result/64 \
 && cd .. \
 && mkdir build32 && cd build32 \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-i686.cmake -DENABLE_FLOAT=OFF -DENABLE_LONG_DOUBLE=OFF -DENABLE_QUAD_PRECISION=OFF .. \
 && make -j$(nproc) \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-i686.cmake -DENABLE_FLOAT=ON -DENABLE_LONG_DOUBLE=OFF -DENABLE_QUAD_PRECISION=OFF .. \
 && make -j$(nproc) \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-i686.cmake -DENABLE_FLOAT=OFF -DENABLE_LONG_DOUBLE=ON -DENABLE_QUAD_PRECISION=OFF .. \
 && make -j$(nproc) \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-i686.cmake -DENABLE_FLOAT=OFF -DENABLE_LONG_DOUBLE=OFF -DENABLE_QUAD_PRECISION=ON .. \
 && cp ../api/fftw3.h /usr/i686-w64-mingw32/include/ \
 && cp libfftw3* /usr/i686-w64-mingw32/lib/ \
 && cp libfftw3*.dll /result/32

RUN git clone --depth 1 https://github.com/greatscottgadgets/hackrf /hackrf && cd /hackrf/host \
 && mkdir build && cd build \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-x86_64.cmake -DFFTW_LIBRARIES=/usr/x86_64-w64-mingw32/lib/ .. \
 && make -j$(nproc) \
 && cp libhackrf/src/libhackrf.dll /result/64 \
 && cd .. && mkdir build32 && cd build32 \
 && cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-i686.cmake -DFFTW_LIBRARIES=/usr/i686-w64-mingw32/lib/ .. \
 && make -j$(nproc) \
 && cp libhackrf/src/libhackrf.dll /result/32


ADD genlib.sh /

# generate libs
# gendef libhackrf.dll
# llvm-dlltool -m i386:x86-64 -d libhackrf.def -D libhackrf.dll -l libhackrf.lib
# https://stackoverflow.com/questions/9946322/how-to-generate-an-import-library-lib-file-from-a-dll/9946390