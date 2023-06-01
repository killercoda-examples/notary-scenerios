## Prerequsites

- Kubernetes v1.20 or higher

## Step 1: Setup Gatekeeper with [external data](https://open-policy-agent.github.io/gatekeeper/website/docs/externaldata/)

```
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts

helm install gatekeeper/gatekeeper  \
    --name-template=gatekeeper \
    --namespace gatekeeper-system --create-namespace \
    --set enableExternalData=true \
    --set validatingWebhookTimeoutSeconds=5 \
    --set mutatingWebhookTimeoutSeconds=2
```{{exec}}

## Step 2: Deploy ratify on gatekeeper in the default namespace.

> Note: if the `crt/key/cabundle` are NOT set under `provider.tls` in `values.yaml`, helm would generate a CA certificate and server key/certificate for you.

```
curl -sSLO https://raw.githubusercontent.com/deislabs/ratify/main/test/testdata/notary.crt
helm install ratify \
    ./charts/ratify --atomic \
    --namespace gatekeeper-system \
    --set-file notaryCert=./notary.crt
```{{exec}}

## Step 3: See Ratify in action

### Deploy a `demo` constraint.

```
kubectl apply -f https://deislabs.github.io/ratify/library/default/template.yaml
kubectl apply -f https://deislabs.github.io/ratify/library/default/samples/constraint.yaml
```{{exec}}

> Once the installation is completed, you can test the deployment of an image that is signed using Notary V2 solution.

### Deploying Signed Image


> This will successfully create the pod `demo` 

```
kubectl run demo --image=wabbitnetworks.azurecr.io/test/notary-image:signed
kubectl get pods demo
```{{exec}}

> Optionally you can see the output of the pod logs via: `kubectl logs demo`

### Deploying Unsigned Image

```
kubectl run demo1 --image=wabbitnetworks.azurecr.io/test/notary-image:unsigned
```{{exec}}

You will see a deny message from Gatekeeper denying the request to create it as the image doesn't have any signatures.

```
Error from server (Forbidden): admission webhook "validation.gatekeeper.sh" denied the request: [ratify-constraint] Subject failed verification: wabbitnetworks.azurecr.io/test/net-monitor:unsigned
```

> Congrats 🎉, you just validated the container images in your k8s cluster!

### Clean up

> Notes: Helm does NOT support upgrading CRDs, so uninstalling Ratify will require you to delete the CRDs manually. Otherwise, you might fail to install CRDs of newer versions when installing Ratify.

```
kubectl delete -f https://deislabs.github.io/ratify/library/default/template.yaml
kubectl delete -f https://deislabs.github.io/ratify/library/default/samples/constraint.yaml
helm delete ratify --namespace gatekeeper-system
kubectl delete crd stores.config.ratify.deislabs.io verifiers.config.ratify.deislabs.io certificatestores.config.ratify.deislabs.io
```
