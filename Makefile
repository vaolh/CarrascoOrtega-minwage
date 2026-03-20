### REPLICATION FILE: Makefile
### VERSION: GNU Make 3.81+
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-03

all: build estimate

build:
	make -C code/build

estimate:
	make -C code/estimate

recompile:
	make -C code/recompile

.PHONY: all build estimate recompile
