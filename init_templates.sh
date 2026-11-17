#!/bin/bash
set -o pipefail

REPO_DIR=$(pwd)
TYPST_VERSIONS_DIR="$REPO_DIR/typst_versions"

# Versions sorted from newest to oldest
VERSIONS=(0.14.2 0.13.1 0.12.0 0.11.1 0.10.0 0.9.0 0.8.0 0.7.0 0.6.0 0.5.0 0.4.0 0.3.0 0.2.0 0.1.0)
LATEST="${VERSIONS[0]}"
PREVIOUS="${VERSIONS[1]}"

mkdir -p $REPO_DIR/testdata
mkdir -p $REPO_DIR/_build_error_
mkdir -p $REPO_DIR/_outdated_
mkdir -p $REPO_DIR/_unsupported_

cd $REPO_DIR/testdata

while IFS=: read -r pkg_name pkg_ver; do
	# Init the template using the latest version
	if ! "$TYPST_VERSIONS_DIR/typst_$LATEST" init "@preview/$pkg_name:$pkg_ver" "$pkg_name" 2>/tmp/init_err.txt; then
		echo "INIT_FAIL $pkg_name:$pkg_ver: $(cat /tmp/init_err.txt | tr '\n' ' ')"
		continue
	fi

	# Find the entrypoint from typst.toml
	toml="$HOME/.cache/typst/packages/preview/$pkg_name/$pkg_ver/typst.toml"
	entrypoint=$(grep -A5 '^\[template\]' "$toml" | grep 'entrypoint' | head -1 | sed 's/.*= *"\(.*\)"/\1/')

	if [ -z "$entrypoint" ]; then
		echo "NO_ENTRY $pkg_name:$pkg_ver"
		continue
	fi

	# Try compiling with versions from newest to oldest
	tmpout="/tmp/typst_out.pdf"
	compiled_with=""

	for ver in "${VERSIONS[@]}"; do
		if "$TYPST_VERSIONS_DIR/typst_$ver" compile "$pkg_name/$entrypoint" "$tmpout" 2>/dev/null; then
			compiled_with="$ver"
			break
		fi
	done
	rm -f "$tmpout"

	if [ -z "$compiled_with" ]; then
		echo "❌ $pkg_name:$pkg_ver build error with all Typst versions"
		mv "$pkg_name" "$REPO_DIR/_build_error_/$pkg_name"
	elif [ "$compiled_with" = "$LATEST" ]; then
		echo "✅ $pkg_name:$pkg_ver compatible with Typst $LATEST"
	elif [ "$compiled_with" = "$PREVIOUS" ]; then
		short_ver=$(echo "$compiled_with" | sed 's/\.[0-9]*$//')
		echo "⚠️ $pkg_name:$pkg_ver requires Typst $short_ver (outdated)"
		mv "$pkg_name" "$REPO_DIR/_outdated_/$pkg_name"
	else
		short_ver=$(echo "$compiled_with" | sed 's/\.[0-9]*$//')
		echo "⛔ $pkg_name:$pkg_ver requires Typst $short_ver (unsupported)"
		mv "$pkg_name" "$REPO_DIR/_unsupported_/$pkg_name"
	fi
done < /tmp/typst_templates.txt

echo "=== DONE ==="
