# Scripts to check Typst version required by templates in Typst Universe

Upstream issue at https://github.com/typst/packages/issues/3126

```bash
# Clone the packages repo
git clone https://github.com/typst/packages
# Create a symlink to preview
PKGS_REPO=$(realpath packages)
mkdir -p "$HOME/.cache/typst/packages"
ln -s "$PKGS_REPO/packages/preview" "$HOME/.cache/typst/packages/preview"

# Download all Typst versions.
./dl_typst_versions.sh

# Find packages with templates.
./find_package_templates.sh

# Build template packages to check for errors.
./init_templates.sh
```
