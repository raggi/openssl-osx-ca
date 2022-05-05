# osx-ca-certs (previously openssl-osx-ca (and libressl-osx-ca))

A simple tool and script intended to be run periodically by `launchd(8)` to sync
an openssl style CA pem with the certificates found in the OSX Keychain(s).

The original name is now a misnomer, as the software will manage certificate
bundles for both openssl and libressl installed under Homebrew.

The Makefile contains a target called `osx-ca-certs` that acts a lot like
`security export -t certs -p`, except that it does not dump certificates that
are marked as untrusted as the latter does.

The keychains exported to the CA bundle by default are:
 * System.keychain
 * SystemRootCertificates.keychain
 * login.keychain (if run as a user)

The installed CA pem file will be made available through the default X.509 store
path. This is commonly found in either: `/usr/local/etc/openssl/cert.pem` (for
Intel based Macs) or `/opt/homebrew/etc/openssl/cert.pem` (for M1/ARM based Macs).

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
 * LibreSSL users
 * OpenSSL users
 * Other brew / manually installed things that link a non-Apple TLS
   implementations

## Known limitations & Notes

 * Only supports El Capitan and above.
 * Syncs are by default perfomed once per hour.
 * Syncs may not be sufficiently atomic. There is a small possiblity of race
   conditions that could cause `openssl` programs to fail. The sync time is very
   very short, so in practice this is unlikely.
 * OSX CA bundles are not always particularly up to date, for example in August
   2016, they contained 17 expired certificates and several that Mozilla have
   chosen to remove, either for technical or audit reasons.
 * Installation as root is generally not required, and may require some extra
   changes to the Makefile.
