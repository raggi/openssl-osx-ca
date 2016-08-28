# openssl-osx-ca

A simple script intended to be run from `cron(1)` to sync an openssl style CA
pem with the certificates found in the OSX Keychain(s).

The keychains exported to the CA bundle by default are:
 * System.keychain
 * SystemRootCertificates.keychain
 * login.keychain (if run as a user)

Note: You can disable login.keychain exports by supplying
`--skip-login-keychain`. If you install as root, remember that user logins
keychains will not be included.

The installed CA pem file will be made available through the default X.509 store
path, commonly `/usr/local/etc/openssl/cert.pem`.

## Installation

 * To install via homebrew:
   ``` bash
      brew tap raggi/ale
      brew install openssl-osx-ca
      brew services start openssl-osx-ca
   ```

 * To install standalone:
   ``` bash
      make install
   ```

 * To set the frequency, set the value of FREQUENCY when installing, defaults to
   `3600`, one hour. The value of FREQUENCY must be a value in seconds.
   ``` bash
      make install FREQUENCY=3600
   ```

 * Other variables from the Makefile can be overridden, take a look at the head
   of the Makefile for more information.

## Intended use cases

 * Ruby 2.0.0+
 * Other brew installed programs that rely on modern OpenSSL versions
 * Programs that require a ca-certificates style bundle

## Known limitations & Notes

 * Syncs are by default perfomed once per hour.
 * Syncs may not be sufficiently atomic. There is a small possiblity of race
   conditions that could cause `openssl` programs to fail. The sync time is very
   very short, so in practice this is unlikely.
 * OSX CA bundles are not always particularly up to date, for example in August
   2016, they contained 17 expired certificates and several that Mozilla have
   chosen to remove, either for technical or audit reasons.
 * Installation as root is generally not required, and may require some extra
   changes to the Makefile.
