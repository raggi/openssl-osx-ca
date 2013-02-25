PREFIX:=/opt/openssl-osx-ca

install: uninstall
	mkdir -p $(PREFIX)
	cp -r $(PWD)/* $(PREFIX)/
	(crontab -l; echo "0 * * * * $(PREFIX)/bin/openssl-osx-ca") | crontab -

uninstall:
	(crontab -l | grep -v openssl-osx-ca) | crontab -
