#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# CREATE THE PRIVATE KEY FOR OUR CUSTOM CA
openssl genrsa -out certs/ca.key 2048

# GENERATE A CA CERT WITH THE PRIVATE KEY
openssl req -new -x509 -key certs/ca.key -out certs/ca.crt -config certs/ca_config.txt

# CREATE THE PRIVATE KEY FOR OUR WEBHOOK SERVER
openssl genrsa -out certs/webhook-key.pem 2048

# CREATE A CSR FROM THE CONFIGURATION FILE AND OUR PRIVATE KEY
openssl req -new -key certs/webhook-key.pem -subj "/CN=cy-rating-check.default.svc" -out certs/webhook.csr -config certs/webhook_config.txt

# CREATE THE CERT SIGNING THE CSR WITH THE CA CREATED BEFORE
openssl x509 -req -in certs/webhook.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/webhook-crt.pem -extfile certs/webhook_config.txt -extensions v3_req

# INJECT CA IN THE WEBHOOK CONFIGURATION
export CA_BUNDLE=$(cat certs/ca.crt | base64 | tr -d '\n')
cat webhook_config/webhook.yaml.template | envsubst > "webhook_config/webhook.yaml"
