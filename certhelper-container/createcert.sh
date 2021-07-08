# This script will pull metadata from a running ECS Fargate task (running platform version 1.4.0)
# to get the task's IP, and use it to create a cfr file which is used to then generate self signed
# TLS certificates vault will use. It will also modify the permissions to allow the vault user access.

#######################################################
# Variables for the certificates. Edit these as needed.
#######################################################
VAULTDNS=yourvault.fqdn.com
COUNTRYCODE=US
STATE=Pennsylvania
LOCALITY=Pittsburgh
ORGANIZATION=examplecompany
#######################################################

# Pull the fargate task's IP.
CURRENTIP=$(curl ${ECS_CONTAINER_METADATA_URI_V4} | jq -r '.Networks[0].IPv4Addresses[0]')

# Build a file that defines the desired certificate properties.
cat > /ssl/selfsigned.cfr <<-DATA
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = ${COUNTRYCODE}
ST = ${STATE}
L =  ${LOCALITY}
O = ${ORGANIZATION}
CN = ${VAULTDNS}

[v3_req]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:TRUE
subjectAltName = @alt_names

[alt_names]
IP.1 = ${CURRENTIP}
DATA

# Make the required TLS certs.
openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout /ssl/server.key -out /ssl/server.crt -config /ssl/selfsigned.cfr -days 365

# Add vault group permissions
chmod 770 /ssl && chmod 440 /ssl/*

# List files at /ssl for troubleshooting
ls -al /ssl
