PREFIX:=${HOME}
PLISTDIR:=${PREFIX}/Library/LaunchAgents
BINDIR:=${PREFIX}/bin
BREW:=$(shell which brew)
FREQUENCY:=3600
ARGS:=-path $(BINDIR)/osx-ca-certs

PLIST=org.ra66i.openssl-osx-ca.plist
XMLARGS=$(ARGS:%=<string>%</string>)

.PHONY: install
.PHONY: uninstall
.PHONY: copy

osx-ca-certs: osx-ca-certs.m
	clang -framework CoreFoundation -framework Security $< -o $@

install: copy
	launchctl load $(PLISTDIR)/$(PLIST)

uninstall:
	launchctl unload $(PLISTDIR)/$(PLIST)
	rm $(BINDIR)/openssl-osx-ca
	rm $(BINDIR)/osx-ca-certs
	rm $(PLISTDIR)/org.ra66i.openssl-osx-ca.plist

copy: $(PLISTDIR)/$(PLIST) $(BINDIR)/osx-ca-certs $(BINDIR)/openssl-osx-ca

$(PLISTDIR):
	install -d $(PLISTDIR)

$(BINDIR):
	install -d $(BINDIR)

$(PLISTDIR)/$(PLIST): Library/LaunchAgents/$(PLIST) $(PLISTDIR) Makefile
	cat $< | \
		sed 's:{BINDIR}:$(BINDIR):g' | \
		sed 's:{FREQUENCY}:$(FREQUENCY):g' | \
		sed 's:{ARGS}:$(XMLARGS):g' | \
		sed 's:{BREW}:$(BREW):g' > $@

$(BINDIR)/openssl-osx-ca: bin/openssl-osx-ca $(BINDIR)
	install -m 0755 $< $@

$(BINDIR)/osx-ca-certs: osx-ca-certs $(BINDIR)
	install -m 0755 $< $@

clean:
	rm -f osx-ca-certs
