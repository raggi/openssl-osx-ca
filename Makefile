install: uninstall
	(crontab -l; echo "0 * * * * $(PWD)/bin/openssl-osx-ca") | crontab -

uninstall:
	(crontab -l | grep -v openssl-osx-ca) | crontab -
