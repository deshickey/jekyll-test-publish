---
layout: default
description: Rotating registry pull image secrets
service: Conductors
title: Rotating registry pull image secrets
runbook-name: "Rotating registry pull image secrets"
link: /rotate_registry_pull_image_secrets.html
type: Informational
grand_parent: Armada Runbooks
parent: Registry
---

Informational
{: .label }

## Overview

The runbook shows how a new secret can be created and added to armada-secure.

## Detailed Information

The purpose of this runbook is to show how the registery secrets can be rotated. The secrets are JSON files for each region with number of FQDNs which represent the registry server in that region. While the contents of this file is in plain text, the buil tool will encode the contents into base64 format so they can be added to Secrets in the target resource.

## Steps to rotate the API Key and generate the secret

The steps below show how the API Keys can be verified. However, to generate the secrets, you can jump to the section [Generating new secrets for Armada-secure ](#generating-image-pull-secrets-for-armada-secure).

### Find the Service ID and API Keys

Generate a new API Key from the Service ID as below: 

```bash
#  Alchemy-Production "1185207" account
❯ ic iam service-api-keys iks-armada-master-registry-access-read-only --output JSON | jq -r '.[] | .name' | grep 625
iks-armada-master-registry-access-read-only-prod-ap-north-20210625
iks-armada-master-registry-access-read-only-prod-ap-south-20210625
iks-armada-master-registry-access-read-only-prod-eu-central-20210625
iks-armada-master-registry-access-read-only-prod-eu-fr2-20210625
iks-armada-master-registry-access-read-only-prod-uk-south-20210625
iks-armada-master-registry-access-read-only-prod-us-east-20210625
```

### Verify `armada-master` images in the container registry:

```bash
ibmcloud cr images --restrict armada-master
Listing images...
Repository                                                     Tag                                        Digest         Namespace       Created         Size      Security status
icr.io/armada-master/alpine                                    latest                                     b6459ba7992a   armada-master   2 years ago     2.1 MB    1 Issue
icr.io/armada-master/armada-event-exporter                     140eca0ed9d0af08272e61923ca7b4086383b139   1ad6407d3d0f   armada-master   2 years ago     34 MB     44 Issues
icr.io/armada-master/armada-event-exporter                     155b439e3bb0835cdc6f30da1954de993f71833d   6f2103beac0c   armada-master   2 years ago     34 MB     44 Issues
icr.io/armada-master/armada-event-exporter                     2ca6ba710334b5ed5c24eaab775fcf1779292c57   26dc7c587e79   armada-master   2 years ago     34 MB     44 Issues
icr.io/armada-master/armada-event-exporter                     6c04d26f28fefb26c1e0a44fc824122a258c663f   e98e4e943987   armada-master   2 years ago     29 MB     40 Issues
icr.io/armada-master/armada-event-exporter                     786a4561bf6ec43f1e37663e24b1837081cf239a   cb10b4d0a7b3   armada-master   2 years ago     34 MB     42 Issues
```

### Verify the API Key by pulling images using that API

#### Using docker client to verify the API Key

`Please note that in order to login using the API Key, the username must be set to iamapikey. Otherwise, the login will fail`

```bash
❯ docker login registry.ng.bluemix.net
Username: iamapikey
Password:
Login Succeeded

❯ docker pull registry.ng.bluemix.net/armada-master/alpine
Using default tag: latest
latest: Pulling from armada-master/alpine
Digest: sha256:9905ea3f204f70253964596d9841ff1c84130d8f28140c51051c731b606b5d10
Status: Downloaded newer image for registry.ng.bluemix.net/armada-master/alpine:latest
registry.ng.bluemix.net/armada-master/alpine:latest

❯ docker login registry.au-syd.bluemix.net
Username: iamapikey
Password:
Login Succeeded

❯ docker pull registry.au-syd.bluemix.net/armada-master/alpine
Using default tag: latest
latest: Pulling from armada-master/alpine
Digest: sha256:9905ea3f204f70253964596d9841ff1c84130d8f28140c51051c731b606b5d10
Status: Downloaded newer image for registry.au-syd.bluemix.net/armada-master/alpine:latest
registry.au-syd.bluemix.net/armada-master/alpine:latest

```

#### Using docker registry secret:

```bash
##############################################
# Creating a secret for registry verification
$ kubectl -n kube-system create secret docker-registry internal-registry-iamapikey \
> --docker-server="us.icr.io" \
> --docker-username="iamapikey" \
> --docker-password="HIDDEN" \ 
> --docker-email="ibmcont3@us.ibm.com" \
> --dry-run -o yaml | kubectl apply -f -

secret/internal-registry-iamapikey created


##############################################
# Listing new secrets
$ kubectl get secret -A | grep iamapikey
kube-system                        internal-registry-iamapikey                      kubernetes.io/dockerconfigjson         1      90m
kube-system                        regausyd-internal-registry-iamapikey             kubernetes.io/dockerconfigjson         1      38m
kube-system                        regng-internal-registry-iamapikey                kubernetes.io/dockerconfigjson         1      38m


##############################################
# us.icr.io
$ kubectl describe pod access-armada-us-reg
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  14s   default-scheduler  Successfully assigned default/access-armada-us-reg to 10.130.231.188
  Normal  Pulling    10s   kubelet            Pulling image "us.icr.io/armada-master/nginx:latest"
  Normal  Pulled     3s    kubelet            Successfully pulled image "us.icr.io/armada-master/nginx:latest" in 7.074850865s
  Normal  Created    1s    kubelet            Created container armada-container
  Normal  Started    1s    kubelet            Started container armada-container


##############################################
# registry.ng.bluemix.net
$ kubectl describe po regng-access-armada-us-reg
Name:         regng-access-armada-us-reg
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal   Pulling    7s                  kubelet            Pulling image "registry.ng.bluemix.net/armada-master/armada-log-collector:21459247c5e9ebf7fc7498bf6ac76c7299497e88"
  Normal   Pulled     2s                  kubelet            Successfully pulled image "registry.ng.bluemix.net/armada-master/armada-log-collector:21459247c5e9ebf7fc7498bf6ac76c7299497e88" in 5.336169005s
  Normal   Started    1s (x2 over 3m33s)  kubelet            Started container regng-armada-container
  Normal   Created    1s (x2 over 3m33s)  kubelet            Created container regng-armada-container
  Warning  BackOff    0s                  kubelet            Back-off restarting failed container


##############################################
# registry.au-syd.bluemix.net
$ kubectl describe po regausyd-access-armada-us-reg
Name:         regausyd-access-armada-us-reg
...
Events:
  Type     Reason     Age   From               Message
  ----     ------     ----  ----               -------
  Normal   Scheduled  12s   default-scheduler  Successfully assigned default/regausyd-access-armada-us-reg to 10.130.231.188
  Normal   Pulling    8s    kubelet            Pulling image "registry.au-syd.bluemix.net/armada-master/addon-resizer:1.8.12"
  Normal   Pulled     2s    kubelet            Successfully pulled image "registry.au-syd.bluemix.net/armada-master/addon-resizer:1.8.12" in 5.749303138s
  Normal   Created    2s    kubelet            Created container regausyd-armada-container


################################################
# cat yaml files used for the test
$ cat us-icr-io-armada-reg.yaml
apiVersion: v1
kind: Pod
metadata:
    name: access-armada-us-reg
spec:
    containers:
    - name: armada-container
      image: "us.icr.io/armada-master/nginx:latest"
    imagePullSecrets:
    - name: internal-registry-iamapikey

$ cat reg-ng-armada-reg.yaml
apiVersion: v1
kind: Pod
metadata:
    name: regng-access-armada-us-reg
spec:
    containers:
    - name: regng-armada-container
      image: "registry.ng.bluemix.net/armada-master/armada-log-collector:21459247c5e9ebf7fc7498bf6ac76c7299497e88"
    imagePullSecrets:
    - name: regng-internal-registry-iamapikey
$ cat reg-ausyd-armada-reg.yaml
apiVersion: v1
kind: Pod
metadata:
    name: regausyd-access-armada-us-reg
spec:
    containers:
    - name: regausyd-armada-container
      image: "registry.au-syd.bluemix.net/armada-master/addon-resizer:1.8.12"
    imagePullSecrets:
    - name: regausyd-internal-registry-iamapikey

```


### Generating image pull secrets for armada-secure

To generate an image pull registry secret in Armada secure, you need to create a JSON file for a pre-defined list of FQDNS. each FQDN represents an image registry server.  Currently, the list below shows the registries used for each region:
```bash
US:
  - us.icr.io
  - private.us.icr.io
  - registry.ng.bluemix.net

AU:
  - au.icr.io
  - private.au.icr.io
  - registry.au-syd.bluemix.net

JP:
  - jp.icr.io
  - private.jp.icr.io
  - au.icr.io
  - private.au.icr.io
  - registry.au-syd.bluemix.net

FR2:
  - fr2.icr.io
  - private.fr2.icr.io 
  - de.icr.io
  - private.de.icr.io
  - registry.eu-de.bluemix.net

DE:
  - de.icr.io
  - private.de.icr.io
  - registry.eu-de.bluemix.net

UK:
  - uk.icr.io
  - private.uk.icr.io
  - registry.eu-gb.bluemix.net
```

The above-mentioned list can be used to populate the secret in JSON format as below:

```json
  {
    "auths": {
        "<REGION-FQDN1>": {
            "username": "iamapikey",
            "password": "<SECRET>",
            "email": "ibmcont3@us.ibm.com",
            "auth": "<Base64 of username:password>"
        },
        "<REGION-FQDN2>": {
            "username": "iamapikey",
            "password": "<SECRET>",
            "email": "ibmcont3@us.ibm.com",
            "auth": "<Base64 of username:password>"
        },
        "<REGION-FQDN3>": {
            "username": "iamapikey",
            "password": "<SECRET>",
            "email": "ibmcont3@us.ibm.com",
            "auth": "<Base64 of username:password>"
        }
     }
  }
```

As an example and by using the above-mentioned list of FQDNs, for JP region, replace each <REGION-FQDN> with each FQDN listed. In this case:
* jp.icr.io
* private.jp.icr.io
* au.icr.io
* private.au.icr.io
* registry.au-syd.bluemix.net

So, you will end up with the below tempalte:

```json
  {
    "auths": {
        "jp.icr.io": {
            "username": "iamapikey",
            "password": "<SECRET>",
            "email": "ibmcont3@us.ibm.com",
            "auth": "<Base64 of username:password>"
        },
        "private.jp.icr.io": {
            "username": "iamapikey",
            "password": "<SECRET>",
            "email": "ibmcont3@us.ibm.com",
            "auth": "<Base64 of username:password>"
        },
        "au.icr.io": {
            "username": "iamapikey",
            "password": "<SECRET>",
            "email": "ibmcont3@us.ibm.com",
            "auth": "<Base64 of username:password>"
        },
        "private.au.icr.io": {
            "username": "iamapikey",
            "password": "<SECRET>",
            "email": "ibmcont3@us.ibm.com",
            "auth": "<Base64 of username:password>"
        },
        "registry.au-syd.bluemix.net": {
            "username": "iamapikey",
            "password": "<SECRET>",
            "email": "ibmcont3@us.ibm.com",
            "auth": "<Base64 of username:password>"
        }
     }
  }
```

The `auth` attribute uses a base64-encoding format for the username and password concatenated with a `:` as below:

```bash
❯ echo -n "${username}:${password}" | base64
dTE6cDE=
```

Please note that the line feed should not be included in the `auth` attribute so you should use `-n` to the trailing line won't be printed and added to the base64 message. Once the JSON file is ready, encrypt it with `gpg` as per the instructions in the armada-secure and make sure to replace the corresponding environment variables (they should end with `_64` to endicate that these variables should be encoded into base64 format and update the metadata files with the new information).

## References

* [https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

* [https://github.ibm.com/alchemy-conductors/team/issues/11560](https://github.ibm.com/alchemy-conductors/team/issues/11560)

* [https://github.ibm.com/alchemy-containers/armada-secure/pull/4004](https://github.ibm.com/alchemy-containers/armada-secure/pull/4004)
