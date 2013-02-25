# openssl-osx-ca

A simple script intended to be run from `cron(1)` to sync a homebrew installed
openssl CA pem with the certificates found in the OSX Keychain.

The installed CA pem file will be made available through the default X.509 store
path.

## Installation

 * To install via homebrew:
   ``` bash
      brew tap raggi/ale
      brew install openssl-osx-ca
   ```

 * To install standalone:
   ``` bash
      make install PREFIX=/opt/openssl-osx-ca
   ```

## Intended use cases

 * Ruby 2.0.0+
 * Other brew installed programs that rely on modern OpenSSL versions

## Known limitations

 * `openssl s_client` does not respect the default cafile. Adding any `-CApath`
   argument (even e.g. '\?'), will cause verification to work.
 * Syncs are only performed once per hour.
 * Syncs may not be sufficiently atomic. There is a small possiblity of race
   conditions that could cause `openssl` programs to fail. The sync time is very
   very short, so in practice this is unlikely.

