#!/bin/bash

# Locate Typst packages with templates.
for pkg in $HOME/.cache/typst/packages/preview/*/; do
	pkg_name=$(basename "$pkg")
	latest_ver=$(ls "$pkg" | sort -V | tail -1)
	toml="$pkg/$latest_ver/typst.toml"
	if [ -f "$toml" ] && grep -q '^\[template\]' "$toml"; then
		echo "$pkg_name:$latest_ver"
	fi
done | tee /tmp/typst_templates.txt
