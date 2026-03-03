all:
	make -C data/download/code
	make -C data/clean/code
	make -C estimate/code
