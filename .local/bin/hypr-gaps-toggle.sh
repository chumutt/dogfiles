#!/bin/sh
# dwm-style gaps toggle: default gaps <-> no gaps (dwm togglegaps/defaultgaps).
cur=$(hyprctl getoption general:gaps_in | sed -n "s/^css gap data: //p")
if [ "$cur" = "0 0 0 0" ]; then
  hyprctl eval "hl.config({ general = { gaps_in = {top=2,right=4,bottom=2,left=4}, gaps_out = {top=4,right=4,bottom=4,left=4} } })"
else
  hyprctl eval "hl.config({ general = { gaps_in = {top=0,right=0,bottom=0,left=0}, gaps_out = {top=0,right=0,bottom=0,left=0} } })"
fi
