#!/usr/bin/env bash

cd /result/64/bin
gendef libhackrf.dll
llvm-dlltool -m i386:x86-64 -d libhackrf.def -D libhackrf.dll -l hackrf.lib

gendef libairspy.dll
llvm-dlltool -m i386:x86-64 -d libairspy.def -D libairspy.dll -l airspy.lib

mkdir -p /out/64
cp *.dll *.lib /out/64
cd ..
cp *.dll /out/64
cp -r include /out/64/

cd /result/32/bin
gendef libhackrf.dll
llvm-dlltool -m i386 -d libhackrf.def -D libhackrf.dll -l hackrf.lib

gendef libairspy.dll
llvm-dlltool -m i386 -d libairspy.def -D libairspy.dll -l airspy.lib

mkdir -p /out/32
cp *.dll *.lib /out/32
cd ..
cp *.dll /out/32
cp -r include /out/32/
