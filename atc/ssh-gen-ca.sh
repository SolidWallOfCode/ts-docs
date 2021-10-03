# SPDX-License-Identifier: Apache-2.0
# Generate root certificate.
# Note - after running this, no existing signed certificate will work with the new root CA.

# the openssl.cnf file requires two environment variables
# PREFIX - the certificate prexifx. This is used to decorate the distinguished name.
# DN - this must be "CA" for root certs and "Signed" for signed certs.

# Set serial number for signed certs.
echo 1 > ca-serial-no.txt

# Generate the root cert key.
rm -f vgl-ca.key
openssl genrsa -passout pass:claudio -des3 -out vgl-ca.key 2048

# Create the root cert.
rm -f vgl-ca.pem
PREFIX=vgl DN=CA openssl req -passin pass:claudio -config ./openssl.cnf -x509 -new -nodes \
-key vgl-ca.key -sha256 -days 36500 -batch -out vgl-ca.pem

