### REPLICATION FILE: Makefile
### VERSION: GNU Make 3.81+
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-03

all:
	@if [ -z "$$(find data/download/output -name '*.dta' 2>/dev/null)" ]; then \
		echo "Downloading data..."; \
		make -C data/download/code; \
	else \
		echo "data/download/output already populated, skipping download."; \
	fi
	make -C data/clean/code
	make -C estimate/code
