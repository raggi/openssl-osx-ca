PREFIX:=/opt/openssl-osx-ca
BREW:=$(shell which brew)
FREQUENCY="@hourly"

install: uninstall
	echo $(BREW)
	mkdir -p $(PREFIX)
	cp -r ./* $(PREFIX)/
	(crontab -l; echo "$(FREQUENCY) $(PREFIX)/bin/openssl-osx-ca --skip-login-keychain --skip-system-keychain $(BREW)") | crontab -
	$(PREFIX)/bin/openssl-osx-ca $(BREW)

uninstall:
	(crontab -l | grep -v openssl-osx-ca) | crontab -
