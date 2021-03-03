#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# INJECT TOKENS IN THE DEPLOYMENT CONFIGURATION
export ACCESS_TOKEN="$1"
export SECRET_TOKEN="$2"
cat webhook_config/deployment.yaml.template | envsubst > "webhook_config/deployment.yaml"
echo "generated successfully"
