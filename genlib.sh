#!/usr/bin/env bash

cd /result/64
gendef libhackrf.dll
llvm-dlltool -m i386:x86-64 -d libhackrf.def -D libhackrf.dll -l libhackrf.lib

gendef libairspy.dll
llvm-dlltool -m i386:x86-64 -d libairspy.def -D libairspy.dll -l libairspy.lib

mkdir /out/64
cp /result/64/* /out/64

cd /result/32
gendef libhackrf.dll
llvm-dlltool -m i386 -d libhackrf.def -D libhackrf.dll -l libhackrf.lib

gendef libairspy.dll
llvm-dlltool -m i386 -d libairspy.def -D libairspy.dll -l libairspy.lib

mkdir /out/32
cp /result/32/* /out/32
