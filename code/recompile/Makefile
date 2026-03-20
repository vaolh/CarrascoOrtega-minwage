### REPLICATION FILE: code/recompile/Makefile
### VERSION: GNU Make 3.81+
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-03

PAPERDIR := ../../paper

all: $(PAPERDIR)/images/task_flow.png

$(PAPERDIR)/images:
	mkdir -p $@

#################################################
############# Task Flow Diagram #################
#################################################

$(PAPERDIR)/images/graph.txt: symlink.sh | $(PAPERDIR)/images
	bash symlink.sh

$(PAPERDIR)/images/task_flow.png: $(PAPERDIR)/images/graph.txt | $(PAPERDIR)/images
	dot -Grankdir=LR -Tpng $< -o $@

#################################################
############## Run Order (tsort) ################
#################################################

runorder: $(PAPERDIR)/images/graph.txt | $(PAPERDIR)/images
	sed '1d; $$d' $< | sed 's/->/ /' | tsort | sed 's/\(.*\)/make -C \1/'
