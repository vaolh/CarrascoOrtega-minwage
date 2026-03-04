### REPLICATION FILE: recompile/Makefile
### VERSION: GNU Make 3.81+
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-03

all: ../output/task_flow.png

../output:
	mkdir -p $@

#################################################
############# Task Flow Diagram #################
#################################################

../output/graph.txt: code/symlink.sh | ../output
	cd code && bash symlink.sh

../output/task_flow.png: ../output/graph.txt | ../output
	dot -Grankdir=LR -Tpng ../output/graph.txt -o ../output/task_flow.png

#################################################
############## Run Order (tsort) ################
#################################################

runorder: ../output/graph.txt | ../output
	sed '1d; $$d' ../output/graph.txt | sed 's/->/ /' | tsort | sed 's/\(.*\)/make -C \1\/code/'
