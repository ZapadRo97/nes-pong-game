#!/bin/bash

if [ ! -d "out" ]; then
  mkdir out
fi

if [ ! -d "dbg" ]; then
  mkdir dbg
fi

ca65 src/main.s -o out/main.o -l dbg/main.lst -g
ca65 src/header.s -o out/header.o
ca65 src/init.s -o out/init.o
ca65 src/bg.s -o out/bg.o
ld65 -C main.x out/header.o out/init.o out/main.o out/bg.o -o pong.nes -m dbg/map.txt --dbgfile dbg/debug.dbg
python3 dbg2nl.py dbg/debug.dbg pong.nes.0.nl
