#!/bin/bash

### REPLICATION FILE: symlink.sh
### VERSION: bash/zsh
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-03

#################################################
############# Generate Task Graph ###############
#################################################

OUTFILE="../../paper/images/graph.txt"
mkdir -p ../../paper/images

ESTIMATE_DIR="../estimate"

# ── Collect file lists ──
DO_FILES=()
while IFS= read -r f; do DO_FILES+=("$f"); done \
    < <(ls "$ESTIMATE_DIR"/*.do 2>/dev/null | xargs -n1 basename | grep -v 'read-enighyear' | sort -u)

R_FILES=()
while IFS= read -r f; do R_FILES+=("$f"); done \
    < <(ls "$ESTIMATE_DIR"/*.R 2>/dev/null | xargs -n1 basename | grep -v '^_' | sort -u)

PY_FILES=()
while IFS= read -r f; do PY_FILES+=("$f"); done \
    < <(ls "$ESTIMATE_DIR"/*.py 2>/dev/null | xargs -n1 basename | sort -u)

# ── Grid parameters ──
ALL_EST=("${DO_FILES[@]}" "${R_FILES[@]}" "${PY_FILES[@]}")
COLS=4
NFILES=${#ALL_EST[@]}
NROWS=$(( (NFILES + COLS - 1) / COLS ))

# Helper: node id from filename
nid() { echo "$1" | sed 's/[.-]/_/g'; }

# ── Write DOT ──
cat > "$OUTFILE" << 'DOT'
digraph G {
    rankdir=TB;
    newrank=true;
    splines=true;
    nodesep=0.3;
    ranksep=0.45;
    node [fontname="Helvetica" fontsize=9 style=filled margin="0.04,0.02"];
    edge [arrowsize=0.5 color="#555555"];
DOT

# ── Use an invisible "anchor" chain to force row separation ──
# anchor0 (top) → anchor1 → anchor2 → ... → anchorN+1 (bottom)
# Each anchor sits on its row's rank=same and is invisible
TOTALROWS=$(( NROWS + 2 ))  # +2 for top row and recompile row
echo '    // Invisible anchor chain' >> "$OUTFILE"
for (( r=0; r<TOTALROWS; r++ )); do
    echo "    anchor${r} [label=\"\" shape=point width=0 height=0 style=invis];" >> "$OUTFILE"
done
for (( r=0; r<TOTALROWS-1; r++ )); do
    echo "    anchor${r} -> anchor$((r+1)) [style=invis];" >> "$OUTFILE"
done

# ── Declare nodes ──
cat >> "$OUTFILE" << 'DOT'

    // Data pipeline
    node [shape=folder fillcolor="#D6EAF8"];
    build     [label="build"];

    // Shared preamble
    node [shape=ellipse fillcolor="#F9E79F"];
    readdo    [label="read-enighyear.do"];
DOT

echo '    node [shape=ellipse fillcolor="#D5F5E3"];' >> "$OUTFILE"
for f in "${DO_FILES[@]}"; do
    echo "    $(nid "$f") [label=\"${f}\"];" >> "$OUTFILE"
done

echo '    node [shape=ellipse fillcolor="#FADBD8"];' >> "$OUTFILE"
for f in "${R_FILES[@]}"; do
    echo "    $(nid "$f") [label=\"${f}\"];" >> "$OUTFILE"
done

echo '    node [shape=ellipse fillcolor="#E8DAEF"];' >> "$OUTFILE"
for f in "${PY_FILES[@]}"; do
    echo "    $(nid "$f") [label=\"${f}\"];" >> "$OUTFILE"
done

echo '    node [shape=folder fillcolor="#D6EAF8"];' >> "$OUTFILE"
echo '    recompile [label="recompile"];' >> "$OUTFILE"

# ── Row 0: download, clean, readdo ──
echo "    { rank=same; anchor0; build; readdo; }" >> "$OUTFILE"

# ── Estimate rows (1 .. NROWS) ──
for (( row=0; row<NROWS; row++ )); do
    start=$(( row * COLS ))
    end=$(( start + COLS ))
    (( end > NFILES )) && end=$NFILES
    anchor_idx=$(( row + 1 ))
    echo -n "    { rank=same; anchor${anchor_idx}; " >> "$OUTFILE"
    for (( i=start; i<end; i++ )); do
        echo -n "$(nid "${ALL_EST[$i]}"); " >> "$OUTFILE"
    done
    echo "}" >> "$OUTFILE"
done

# ── Last row: recompile ──
echo "    { rank=same; anchor$((NROWS+1)); recompile; }" >> "$OUTFILE"

# ── Invisible horizontal ordering within each row ──
for (( row=0; row<NROWS; row++ )); do
    start=$(( row * COLS ))
    end=$(( start + COLS ))
    (( end > NFILES )) && end=$NFILES
    for (( i=start; i<end-1; i++ )); do
        echo "    $(nid "${ALL_EST[$i]}") -> $(nid "${ALL_EST[$((i+1))]}") [style=invis];" >> "$OUTFILE"
    done
done

# ── Visible edges ──
echo '    build -> readdo;' >> "$OUTFILE"

for f in "${DO_FILES[@]}"; do
    echo "    readdo -> $(nid "$f");" >> "$OUTFILE"
done

for f in "${R_FILES[@]}" "${PY_FILES[@]}"; do
    echo "    build -> $(nid "$f");" >> "$OUTFILE"
done

for f in "${ALL_EST[@]}"; do
    echo "    $(nid "$f") -> recompile;" >> "$OUTFILE"
done

echo '}' >> "$OUTFILE"

echo "Graph written to $OUTFILE"