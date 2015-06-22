.PHONY:	default pdf all
default: pdf

pdf:
	cd doc-src && $(MAKE) pdf

all:
	cd doc-src && $(MAKE)
