# SPDX-License-Identifier: Apache-2.0
# Bash script to generate signed certificate for a specific host.

host="$1"
if [ -z "$host" ] ; then
	echo "Usage: $(basename $0) host"
	exit 1
fi

# the openssl.cnf file requires two environment variables
# PREFIX - the certificate prefix. This is used to decorate the distinguished name.
# DN - this must be "CA" for root certs and "Signed" for signed certs.

let N=$(cat ca-serial-no.txt) # signed certificate serial number.

# Generate key for the signed cert.
name="vgl-signed-${host}"
key_file="${name}.key"
cert_file="${name}.pem"

rm -f ${key_file}
PREFIX=vgl DN=Signed openssl genrsa -passout pass:claudio -out ${key_file} 2048

# Generate the CSR for the signed cert.
rm -f tmp.csr
PREFIX=vgl DN=Signed openssl req -passin pass:claudio -config ./openssl.cnf -new -key ${key_file} -addext "subjectAltName=DNS:${host}" -batch -out tmp.csr

# Generate the signed certificate. This is ugly but OpenSSL is broken - extensions (such as SANS) are flat out
# not carried over from the CSR to the certificate. It's listed as a bug, but no indication it will ever get fixed.
# Of course, there's no nice --addext option for certificate generation, so it's necessary to create a file
# for the extension data.
rm -f ${cert_file}
cat > sans.tmp <<SANS 
[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${host}
DNS.2 = ${host}.solidwallofcode.com
SANS

# Finally the certificate can be generated.
PREFIX=vgl DN=Signed openssl x509 -passin pass:claudio -req -in tmp.csr -CA vgl-ca.pem -CAkey vgl-ca.key \
-set_serial 0$N -out ${cert_file} -days 36500 -sha256 -extfile sans.tmp -extensions req_ext

# cleanup.
rm -f tmp.csr sans.tmp
let N=N+1
echo ${N} > ca-serial-no.txt

