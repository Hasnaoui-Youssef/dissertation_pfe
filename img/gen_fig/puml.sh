#!/bin/sh
# Render PlantUML sources in this directory to cropped PDFs.
set -e
cd "$(dirname "$0")"
JAR=../../plantuml/plantuml.jar
for f in ${*:-fig_*.puml}; do
    [ -e "$f" ] || continue
    base="${f%.puml}"
    java -jar "$JAR" -tpdf "$f" >/dev/null 2>&1
    [ -s "$base.pdf" ] || { echo "FAILED: $f"; java -jar "$JAR" -tpdf "$f"; exit 1; }
    mv "$base.pdf" "$base.raw.pdf"
    pdfcrop --margins 2 "$base.raw.pdf" "$base.pdf" >/dev/null
    rm -f "$base.raw.pdf"
    echo "--- $f  $(pdfinfo "$base.pdf" | grep -i 'page size')"
done
