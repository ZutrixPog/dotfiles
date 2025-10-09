#!/usr/bin/env bash

BG_RAW="/tmp/wlogout-bg.png"
BG_BLUR="/tmp/wlogout-bg-blur.png"

while true; do
    grim "$BG_RAW"
    convert "$BG_RAW" -scale 25% -blur 0x8 -scale 400% "$BG_BLUR"

    sleep 120
done
