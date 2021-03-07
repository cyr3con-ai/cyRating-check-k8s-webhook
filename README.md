## Setting up

### Clone the configuration

`git clone https://github.com/cyr3con-ai/cyRating-check-k8s-webhook.git`

### Go to the configuration dir 

`cd cyRating-check-k8s-webhook`

### Add the deployment.yaml and webhook.yaml files according to the templates provided

NOTE: Before running setup.sh, Please contact CYR3CON Team to get you access token and secret token pair as it will be required while running this script.

Access token and secret token will be asked after 3rd step.

### Run Script setup.sh with following format

COMMAND : `./setup.sh`

It will do the following for you:
1. Generate Certification
2. Create Secret
3. Create webhook service
4. Setup access token and secret token for you to use service.
5. Create webhook deployment
6. Deployment Check if succeeded or not
7. Create webhook configuration

### Check if deployment succeeded

At the end of step 6, you should see: 

`deployment "cy-rating-check" successfully rolled out`

### Test invalid pod deployment rejection 
Command

`kubectl apply -f examples/invalid_pod.yaml` 

should return something similar:

`Error from server: error when creating "examples/invalid_pod.yaml": admission webhook "cy-rating-check.cyr3con.ai" denied the request: image 'openjdk:11.0.9.1-jre' has vulnerabilities (5) with cyRatings above the accepted threshold: {38.4615=[CVE-2019-18276, CVE-2020-15719, CVE-2020-15999, CVE-2010-4052, CVE-2010-4051]}`

### Test valid pod deployment approval 

Command

`kubectl apply -f examples/valid_pod.yaml`

should return

`pod/valid-app created`

## Get logs from webhook deployment pod

`kubectl logs $(kubectl get pods | grep cy-rating-check | awk '{print $1}')`

## Configuration update

To update configuration, ex. the accepted threshold value:
1. delete webhook configuration: `kubectl delete -f webhook_config/webhook.yaml`
2. delete deployment configuration: `kubectl delete -f webhook_config/deployment.yaml`
3. change configuration files as needed
4. apply deployment configuration: `kubectl apply -f webhook_config/deployment.yaml`
5. apply webhook configuration: `kubectl apply -f webhook_config/webhook.yaml`

## Troubleshooting

If you see certification issue stating `x509: certificate has expired or is not yet valid`:
Perform the following steps to resolve the issue by refreshing cert

1. `kubectl delete secret cy-rating-check`
2. `./certs/generate.sh`
3. `kubectl create secret generic cy-rating-check -n default --from-file=key.pem=certs/webhook-key.pem --from-file=cert.pem=certs/webhook-crt.pem`
4. `kubectl delete -f webhook_config/webhook.yaml`
5. `kubectl delete -f webhook_config/deployment.yaml`
6. `kubectl apply -f webhook_config/deployment.yaml`
7. `kubectl apply -f webhook_config/webhook.yaml`
