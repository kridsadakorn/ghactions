#!/bin/sh

set -e

# For R libraries to persist between github actions (though not across runs) they must be installed somewhere inside $HOME. (see https://github.com/maxheld83/ghactions-inst-rdep/issues/10)
# hypothesis: $HOME does not exist at build time of this image, but only at run time, when the github actions runner maps this volume (or whatever).
# so doing anything in this directory must happen in the entrypoint, not the dockerfile.
R_LIB_PATH="$HOME"/lib/R/library # imitating idiomatic path from ~
# R user library directories must exist before they can be used 
mkdir -p "$R_LIB_PATH"
echo R_LIBS_USER="$R_LIB_PATH" >> "$HOME"/.Renviron

cat "$HOME"/.Renviron
echo "$HOME"

Rscript -e "remotes::install_deps(pkgdir = 'tests/testthat/descriptions/good', upgrade = 'always')"

ls -a "$R_LIB_PATH"

Rscript -e ".libPaths()"
Rscript -e "Sys.getenv(\"R_LIBS_USER\")"
echo "Completed dependency installation"
