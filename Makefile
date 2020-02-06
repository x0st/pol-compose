NAME=pol
BIN_DIR=/usr/local/bin

.PHONY: install uninstall link tmp-dir

install: uninstall link tmp-dir

tmp-dir:
	@test -d .tmp || mkdir .tmp 2> /dev/null

link:
	@sudo ln -s $(shell pwd)/pol.sh ${BIN_DIR}/${NAME}

uninstall:
	@sudo rm -f ${BIN_DIR}/${NAME}
