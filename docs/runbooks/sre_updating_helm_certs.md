---
layout: default
description: How to update the helm certs for the Support Account Clusters
service: "Infrastructure"
title: How to update the helm certs for the Support Account Clusters
runbook-name: How to update the helm certs for the Support Account Clusters
link: /sre_updating_helm_certs.html
tags: helm, support, AAA
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview 

This document details how to replace the helm certs that are stored in [1337 helm-certs repo]


## Useful links and information


**NB:** This process has not been tested on a mac and has previously failed when running it on a mac.  Please run this steps on a Linux VM.


The following GHE links show previous times that these certs were updated
- [default namespace helm cert renewal](https://github.ibm.com/alchemy-conductors/team/issues/6540)
- [sre-bots-use namespace helm cert renewal](https://github.ibm.com/alchemy-conductors/team/issues/7990)


The helm certs are used by the following clusters in the Support account.  Knowing this is crucial to complete the re-deploy of the updated certs

- `default` - infra-accessallareas
- `sre-bots` - infra-accessallareas
- `sre-bots-us` - bots

## Detailed Information 

To renew the certs follow these steps.

1. Clone [1337 helm-certs repo] to a linux server
2. Generate the new certs for the namespace you are updating the certs for.  Execute the `tiller-certs.sh` script from within desired directory (there is a directory per namespace)
```
cullepl@cullepl-VirtualBox:~/git/sre-helm-certs/sre-bots-us$ ./tiller-certs.sh 
Generating RSA private key, 4096 bit long modulus (2 primes)
....................................................................................................................................................................................................................++++
....................................................................................................++++
e is 65537 (0x010001)
Can't load /home/cullepl/.rnd into RNG
139976623788480:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/home/cullepl/.rnd
Generating RSA private key, 4096 bit long modulus (2 primes)
.....................++++
...................................++++
e is 65537 (0x010001)
Generating RSA private key, 4096 bit long modulus (2 primes)
............................................................................++++
........................................................++++
e is 65537 (0x010001)
Can't load /home/cullepl/.rnd into RNG
140486444904896:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/home/cullepl/.rnd
Can't load /home/cullepl/.rnd into RNG
140326261510592:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/home/cullepl/.rnd
Signature ok
subject=C = UK, ST = Hampshire, L = Hursley, O = IBM, CN = tiller
Getting CA Private Key
Signature ok
subject=C = UK, ST = Hampshire, L = Hursley, O = IBM, CN = tiller
Getting CA Private Key
```
3. Create a PR and checkin the new certs.  Get an SRE to review the PR.  Until the PR is reviewed and committed, do not proceed any further.

4. Once the certs have been review and merged, we need to re-deploy them into the cluster which uses them.
Login to cloud.ibm.com account 278445, for example  
   `ibmcloud login -sso`

5. Connect to the correct cluster (depending where the certs are used)  
   `ibmcloud ks cluster config -c infra-accessallareas --export` or  `ibmcloud ks cluster config -c bots --export`

6. Clean-up the current tiller components that use the certs (that have expired or are about to expire).  Remember to reference the correct namespace. 
      -  `kubectl delete deploy tiller-deploy -n <namespace>`
      -  `kubectl delete secret tiller-secret -n <namespace>`
      -  `kubectl delete service tiller-deploy -n <namespace>`

7. Executed `helm init` command to re-deploy the helm / tiller parts with the updated certs, filling in the correct namespace details.

**NB:** The below command assumes you are in the directory where the `.pem` files are located

```
helm init \
--tiller-tls \
--tiller-tls-verify \
--tiller-tls-cert=tiller-cert.pem \
--tiller-tls-key=tiller-key.pem \
--tls-ca-cert=tiller-ca.cert.pem \
--service-account=tiller \
--tiller-namespace=<namespace>

```

## Escalation/Help

Speak to the SRE squad in the conductors-for-life channel for any help needed.



[1337 helm-certs repo]: https://github.ibm.com/alchemy-1337/sre-helm-certs