# SPDX-License-Identifier: Apache-2.0
# Bash script to generate signed certificates.

# the openssl.cnf file requires two environment variables
# PREFIX - the certificate prefix. This is used to decorate the distinguished name.
# DN - this must be "CA" for root certs and "Signed" for signed certs.

let N=$(cat ca-serial-no.txt) # signed certificate serial number.

# Generate key for the signed cert.
name="vgl-signed-${N}"
key_file="${name}.key"
cert_file="${name}.pem"

rm -f ${key_file}
PREFIX=vgl DN=Signed openssl genrsa -passout pass:claudio -out ${key_file} 2048

# Generate the CSR for the signed cert.
rm -f tmp.csr
PREFIX=vgl DN=Signed openssl req -passin pass:claudio -config ./openssl.cnf -new -key ${key_file} -batch -out tmp.csr

# Generate the signed certificate.
rm -f ${cert_file}
PREFIX=vgl DN=Signed openssl x509 -passin pass:claudio -req -in tmp.csr -CA vgl-ca.pem -CAkey vgl-ca.key \
-set_serial 0$N -out ${cert_file} -days 36500 -sha256

# cleanup.
rm -f tmp.csr
let N=N+1
echo ${N} > ca-serial-no.txt

