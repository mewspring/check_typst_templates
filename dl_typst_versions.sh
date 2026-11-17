#!/bin/bash

VERS="0.5.0 0.6.0 0.7.0 0.8.0 0.9.0 0.10.0 0.11.1 0.12.0 0.13.1 0.14.2 0.15.1"

mkdir -p typst_versions
cd typst_versions
for VER in $VERS; do
	echo $VER
	wget "https://github.com/typst/typst/releases/download/v$VER/typst-x86_64-unknown-linux-musl.tar.xz"
	tar -xJvf typst-x86_64-unknown-linux-musl.tar.xz typst-x86_64-unknown-linux-musl/typst -O > typst_$VER
	chmod +x typst_$VER
	rm -f typst-x86_64-unknown-linux-musl.tar.xz
done
