all:
	make -C data/raw/code
	make -C data/clean/code
	make -C estimate/code
