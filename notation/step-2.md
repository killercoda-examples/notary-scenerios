## Prerequisite

Maker sure you have completed all the previous steps before proceeding.

## Create an OCI-compatible registry

```
docker run -d -p 5001:5000 -e REGISTRY_STORAGE_DELETE_ENABLED=true --name registry registry
```{{exec}}

## Add an image to the OCI-compatible registry

```
docker build -t localhost:5001/net-monitor:v1 https://github.com/wabbit-networks/net-monitor.git#main
docker push localhost:5001/net-monitor:v1
```{{exec}}

## Getting the Digest

Get the digest value it's outputted and paste that value at the end `IMAGE=localhost:5001/net-monitor@sha256:<value>`

or run `docker inspect localhost:5001/net-monitor:v1 -f '{{ .RepoDigests }}'`{{exec}} to get that value again


### Check image for any existing signatures

Confirm that there are no signatures shown in the output.

```
notation ls $IMAGE
```{{exec}}


## Generate a test key and self-signed certificate

Use `notation cert generate-test` to generate a test RSA key for signing artifacts, and a self-signed X.509 test certificate for verifying artifacts. Please note the self-signed certificate should be used for testing or development purposes only.

The following command generates a test key and a self-signed X.509 certificate. With the `--default` flag, the test key is set as a default signing key. The self-signed X.509 certificate is added to a named trust store `wabbit-networks.io` of type `ca`.

```
notation cert generate-test --default "wabbit-networks.io"
```{{exec}}

Use `notation key` ls to confirm the signing key is correctly configured. Key name with a * prefix is the default key.

```
notation key ls
```{{exec}}

Use `notation cert ls` to confirm the certificate is stored in the trust store.

```
notation cert ls
```{{exec}}

#### Sign the container image 

Use `notation` sign to sign the container image.

```
notation sign $IMAGE
```{{exec}}

By default, the signature format is `JWS`. Use `--signature-format` to use [COSE](https://datatracker.ietf.org/doc/html/rfc8152) signature format.

```
notation sign --signature-format cose $IMAGE
```{{exec}}

The generated signature is pushed to the registry and the digest of the container image returned.

Use `notation ls` to show the signature associated with the container image.

```
notation ls $IMAGE
```{{exec}}

#### Create a trust 

To verify the container image, configure the trust policy to specify trusted identities that sign the artifacts, and level of signature verification to use. For more details, see trust [policy spec](https://github.com/notaryproject/notaryproject/blob/main/specs/trust-store-trust-policy.md#trust-policy  ).

Create a JSON file with the following trust policy, for example:

```
cat <<EOF > ./trustpolicy.json
{
    "version": "1.0",
    "trustPolicies": [
        {
            "name": "wabbit-networks-images",
            "registryScopes": [ "*" ],
            "signatureVerification": {
                "level" : "strict" 
            },
            "trustStores": [ "ca:wabbit-networks.io" ],
            "trustedIdentities": [
                "*"
            ]
        }
    ]
}
EOF
```{{exec}}

Use notation policy import to import the trust policy configuration from a JSON file. For example:

```
notation policy import ./trustpolicy.json
```{{exec}}

Use notation policy show to view the applied policy configuration. For example:

```
notation policy show
```{{exec}}

#### Verify the container image

```
notation verify $IMAGE
```{{exec}}

> Congratulations you have successfully signed Docker image `notation cli` you can now go the next step
