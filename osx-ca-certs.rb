#!/usr/bin/ruby
require "tempfile"

sec = "/usr/bin/security"
endc = "-----END CERTIFICATE-----\n"

chains = `security list-keychains`.lines.map do |kc|
  kc[/^\s*"(.+)"$/, 1]
end + ["/System/Library/Keychains/SystemRootCertificates.keychain"]

all_certs = IO.popen([sec, "find-certificate", "-a", "-p", *chains]) do |io|
  io.each_line.slice_after(endc).map(&:join)
end

verified_certs =
begin
  file = Tempfile.new "osx-ca-certs"

  all_certs.select do |cert|
    file.rewind
    file.write cert
    file.truncate cert.size
    file.flush

    system sec, "verify-cert", "-q", "-l", "-L", "-R", "offline", "-c", file.path, [:out] => "/dev/null"
  end
ensure
  file.close! if file
end

puts *verified_certs