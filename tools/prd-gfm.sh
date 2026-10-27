#!/bin/sh
# SPDX-FileCopyrightText: 2026 Mohamed Hammad <Mohamed.Hammad@SpacecraftSoftware.org>
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Turn pandoc's DocBook-to-GFM output (stdin) into the Standard §17.5 shape.
# Usage: pandoc ... | sh tools/prd-gfm.sh PRD.texi > PRD.md
#
# DocBook drops the Texinfo Top node, so the title and MVP line are read from
# the @settitle and @set MVPLINE lines of the source. Chapters come out as
# level-1 headings and are shifted down one level; escaped task boxes are
# restored; blank lines between consecutive list items are removed.
set -eu

src=${1:?usage: prd-gfm.sh SOURCE.texi}
title=$(sed -n 's/^@settitle //p' "$src")
mvp=$(sed -n 's/^@set MVPLINE //p' "$src")
[ -n "$title" ] || { echo "prd-gfm.sh: error: no @settitle in $src" >&2; exit 1; }
[ -n "$mvp" ] || { echo "prd-gfm.sh: error: no @set MVPLINE in $src" >&2; exit 1; }

# REUSE-IgnoreStart
printf '%s\n' \
    '<!-- SPDX-FileCopyrightText: 2026 Mohamed Hammad <Mohamed.Hammad@SpacecraftSoftware.org> -->' \
    '<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->' \
    "<!-- Generated from $src by 'make PRD.md'. Edit the Texinfo source, not this file. -->" \
    '' "# $title" '' "$mvp" ''
# REUSE-IgnoreEnd

awk '
    /^#+ / { sub(/^#/, "##") }
    { gsub(/^- \\\[ \\\] /, "- [ ] "); gsub(/^- \\\[x\\\] /, "- [x] ") }
    # Hold blank lines; drop one if it sits between two list items.
    /^$/ { blank = 1; next }
    {
        if (blank && !(prev ~ /^- / && $0 ~ /^- /)) print ""
        blank = 0; print; prev = $0
    }
'
