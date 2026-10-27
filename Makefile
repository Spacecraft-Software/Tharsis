# SPDX-FileCopyrightText: 2026 Mohamed Hammad <Mohamed.Hammad@SpacecraftSoftware.org>
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Documentation targets. PRD.texi is canonical; PRD.md is generated and
# committed so GitHub and the Standard §17.5 progress figures can read it.

MAKEINFO = makeinfo
PANDOC   = pandoc

.PHONY: all prd-check clean

all: PRD.md

PRD.md: PRD.texi tools/prd-gfm.sh
	$(MAKEINFO) --docbook -o PRD.xml PRD.texi
	$(PANDOC) -f docbook -t gfm --wrap=none PRD.xml | sh tools/prd-gfm.sh PRD.texi > PRD.md.tmp
	rm -f PRD.xml
	mv PRD.md.tmp PRD.md

# Fails if PRD.texi has Texinfo errors or PRD.md is stale.
prd-check:
	$(MAKEINFO) --no-headers -o /dev/null PRD.texi
	$(MAKEINFO) --docbook -o PRD.xml PRD.texi
	$(PANDOC) -f docbook -t gfm --wrap=none PRD.xml | sh tools/prd-gfm.sh PRD.texi | cmp -s - PRD.md
	rm -f PRD.xml

clean:
	rm -f PRD.xml PRD.md.tmp tharsis-prd.info
