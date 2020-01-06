./bin/openssl-osx-ca -path ${PWD}/osx-ca-certs.rb `which brew`
impls=($(brew list | grep -E '^((libre|open)ssl(@[0-9\.]+)?)$'))
if [[ ${#impls} -lt 1 ]]; then
  echo found no ssl installs
  exit 1
fi

for impl in "${impls[@]}"; do
  dir=$("$(brew list $impl | grep bin/openssl | head -n1)" version -d | cut -d '"' -f 2)
  pem="$dir/cert.pem"

  if [[ $(grep "END CERT" "${pem}" | wc -l) -lt 150 ]]; then
    echo certs looks short
    exit 1
  fi

  security verify-cert -q -l -L -R offline -c "$pem" || exit $?
done
