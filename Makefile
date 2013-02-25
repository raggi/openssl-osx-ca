PREFIX:=/opt/openssl-osx-ca
BREW:=$(shell which brew)

install: uninstall
	echo $(BREW)
	mkdir -p $(PREFIX)
	cp -r $(PWD)/* $(PREFIX)/
	(crontab -l; echo "0 * * * * $(PREFIX)/bin/openssl-osx-ca $(BREW)") | crontab -
	$(PREFIX)/bin/openssl-osx-ca $(BREW)

uninstall:
	(crontab -l | grep -v openssl-osx-ca) | crontab -
