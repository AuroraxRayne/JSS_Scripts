#!/bin/sh

#clear spotlight cache
mdutil -Ea

sleep 1

#turn off indexing
mdutil -aEi off /
rm -rf /.Spotlight*
rm -rf /.metadata_never_index

sleep 3

#turn indexing back on
mdutil -ai on /
mdutil -E