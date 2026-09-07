#!/bin/sh
# Build one or all figures in this directory into PDFs.
#   ./build.sh            -> build every fig_*.tex
#   ./build.sh fig_x.tex  -> build one
set -e
cd "$(dirname "$0")"
for f in ${*:-fig_*.tex}; do
    [ -e "$f" ] || continue
    echo "--- $f"
    pdflatex -interaction=nonstopmode -halt-on-error "$f" >/dev/null 2>&1 \
        || { pdflatex -interaction=nonstopmode "$f" | grep -A3 "^!" | head -20; exit 1; }
    echo "    $(pdfinfo "${f%.tex}.pdf" | grep -i 'page size')"
done
rm -f *.aux *.log
