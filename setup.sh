#!/usr/bin/env bash
echo "Step 1: Generating certificate"
./certs/generate.sh
echo "Step 2: Creating secret"
kubectl create secret generic cy-rating-check -n default --from-file=key.pem=certs/webhook-key.pem --from-file=cert.pem=certs/webhook-crt.pem
echo "Step 3: Creating webhook service"
kubectl apply -f webhook_config/service.yaml
echo "Step 4: Adding auth tokens to webhook deployment configuration"
echo "Input ACCESS TOKEN"
read ACCESS_TOKEN
echo "Input SECRET TOKEN"
read SECRET_TOKEN
./auth/generate.sh $ACCESS_TOKEN $SECRET_TOKEN
echo "Step 5: Creating webhook deployment"
kubectl apply -f webhook_config/deployment.yaml
echo "Step 6: Checking if deployment succeeded"
kubectl rollout status deployment cy-rating-check --timeout=30s
echo "Step 7: Creating webhook configuration"
kubectl apply -f webhook_config/webhook.yaml
echo "Done. Setup Completed Successfully"
