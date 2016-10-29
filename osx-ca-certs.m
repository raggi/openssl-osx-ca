/*
 * A large portion of the code in this file is copied from the Go programming
 * language sources. It specifically comes from:
 * src/crypto/x509/root_cgo_darwin.go at
 * 4a15508c663429652d32f5363c0964152b28dd74 in the Go repo. It is copied here
 * with great regard and thanks to the Go authors, who are consistently awesome.
 */

// Copyright 2011 The Go Authors. All rights reserved.  Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file in
// the Go language project sources at version
// 4a15508c663429652d32f5363c0964152b28dd74, with modiciations under the
// openssl-osx-ca MIT license and copyright James Tucker.

#include <stdio.h>
#include <errno.h>
#include <sys/sysctl.h>
#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>

int main() {
	// Get certificates from all domains, not just System, this lets
	// the user add CAs to their "login" keychain, and Admins to add
	// to the "System" keychain
	SecTrustSettingsDomain domains[] = { kSecTrustSettingsDomainSystem,
					     kSecTrustSettingsDomainAdmin,
					     kSecTrustSettingsDomainUser };

	int numDomains = sizeof(domains)/sizeof(SecTrustSettingsDomain);

	CFMutableDataRef combinedData = CFDataCreateMutable(kCFAllocatorDefault, 0);

	for (int i = 0; i < numDomains; i++) {
		CFArrayRef certs = NULL;
		// Only get certificates from domain that are trusted
		OSStatus err = SecTrustSettingsCopyCertificates(domains[i], &certs);
		if (err != noErr) {
			continue;
		}
		int numCerts = CFArrayGetCount(certs);
		for (int j = 0; j < numCerts; j++) {
			CFDataRef data = NULL;
			CFErrorRef errRef = NULL;
			SecCertificateRef cert = (SecCertificateRef)CFArrayGetValueAtIndex(certs, j);
			if (cert == NULL) {
				continue;
			}
			// We only want to add Root CAs, so make sure Subject and Issuer Name match
			CFDataRef subjectName = SecCertificateCopyNormalizedSubjectContent(cert, &errRef);
			if (errRef != NULL) {
				CFRelease(errRef);
				continue;
			}
			CFDataRef issuerName = SecCertificateCopyNormalizedIssuerContent(cert, &errRef);
			if (errRef != NULL) {
				CFRelease(subjectName);
				CFRelease(errRef);
				continue;
			}
			Boolean equal = CFEqual(subjectName, issuerName);
			CFRelease(subjectName);
			CFRelease(issuerName);
			if (!equal) {
				continue;
			}
			// Note: SecKeychainItemExport is deprecated as of 10.7 in favor of SecItemExport.
			// Once we support weak imports via cgo we should prefer that, and fall back to this
			// for older systems.
			err = SecItemExport(cert, kSecFormatX509Cert, kSecItemPemArmour, NULL, &data);
			if (err != noErr) {
				continue;
			}
			if (data != NULL) {
				CFDataAppendBytes(combinedData, CFDataGetBytePtr(data), CFDataGetLength(data));
				CFRelease(data);
			}
		}

		fwrite(CFDataGetBytePtr(combinedData), 1, CFDataGetLength(combinedData), stdout);

		CFRelease(certs);
	}
	return 0;
}
