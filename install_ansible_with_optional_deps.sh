#!/bin/bash

pacman -Sy --noconfirm python

pacman -Sy --noconfirm --needed --overwrite='*' ansible

optional_deps="$(pacman -Q --info ansible | sed -E -e '1,/^(^Depends On)/d' -e '/^Required By/,$ d'  -e 's/^([^ ][^:]+: |[ ]+)//' -e 's/:.*//')"
pacman -Sy --noconfirm --needed --overwrite='*' $optional_deps

yes | pacman -Scc
