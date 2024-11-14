---
layout: default
description: "[Informational] Addon - Image Key Synchronizer"
title: "[Informational] Addon - Image Key Synchronizer"
runbook-name: "[Informational] Addon - Image Key Synchronizer"
service: armada
tags: armada, addon, roks, encrypted, container, image, images, layer, layers, private, key, synchronizer, redhat, openshift
link: /armada/armada-addon-image-key-synchronizer.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

Red Hat OpenShift on IBM Cloud introduces support for encryped container images. Users who want to deploy containers from encrypted images need to enable the [Image Key Synchronizer managed addon](https://cloud.ibm.com/docs/openshift?topic=openshift-images#encrypted-images), which will synchronize private keys - provided in the form of Kubernetes Secrets - to the worker nodes, then the container runtime (cri-o) will use these keys to decrypt encrypted container images.

## Detailed Information

The IBM Cloud Image Key Synchronizer is available as a managed addon named `image-key-synchronizer`.

The addon is supported on Red Hat OpenShift on IBM Cloud version 4.6 or later.

When users enable the Image Key Synchronizer addon in their cluster, the `image-key-synchronizer` namespace is created and the synchronizer DaemonSet (`image-key-synchronizer/addon-image-key-synchronizer`) is deployed. Each node will have a single pod which will be responsible for synchronizing the keys to the container runtime on the corresponding node.

Users can then create Kubernetes secrets that contain the image decryption keys in the `image-key-synchronizer` namespace. The addon adds the keys to a specific directory (`/etc/crio/keys/synced`) on the worker nodes which is accessible by the container runtime.

The image decryption keys can be provided in two formats: plain format or Key Protect wrapped format.

### Plain Format

The image decryption private key is provided directly in a `key` typed Kubernetes Secret, like:

```yaml
apiVersion: v1
kind: Secret
type: key
metadata:
  name: image-decryption-key
  namespace: image-key-synchronizer
stringData:
  my-key.pem: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpAIBAAKCAQEAnUHsna5D1f3YRT1g52pI8DgnzStT9+79R1NoPyPLTx3Y01/o
    NvhUZgZCWxCapn9LAMtWRO+U9o3SIAwh5IlAmQoY0r0wztJrJ6vZPL7D/bk5SxW/
    s+8hbd/SQ556PcV4TA7QMUh4fIgOGnRJQXnI+RgmeocgYuWbzsCOhejotkwzeHcp
    aXJ9eoDg2e5foiovdJaZlvq6RKJv4dPtMP9SsOcYcG+wGy81SMJ29dBMhknk5/zB
    5uRle1lgDkLBvwBe7uw36CbVffEwXnFRJY1aBMD057WVupWinjp5wJLJpFRDV+jN
    vqbsi8z27tsrKFRI8RSMeuuw2GRZS/g7oz1LGwIDAQABAoIBAEuz2bFKm9NfIQar
    9oNQsg4aKmblTcXUIc99QnjqxUuv5ZpT2BjmUNLQfo9SHjC6pKOcP0puPzq1qQrO
    bF51CEjkCHEirGVT/Eububc5amYxDXis3p1DJ8eZ8MGmf9hOwIt0shqXdZEVehyY
    EE/ZzbrEOnnPpPKW7/uGzNV/+s8OfKLIjafnks0zFTWt2yJqy5D17Mh05xZIYwsw
    7TDLSNgNHMFlriFvoW3VNyy8ZqXp8g3nlhTWrqiObGBGfPaiGbglv8Q5hIA+alYN
    zCZLPKotlnl738aFcTOx0XGXy9ZyEUrtojfuDg1OvSdpo2HFour1BXPKi5uhpS+E
    zyb9l8kCgYEAyyzLl9RpjqmJxlQYgIp94VAe37kQaPCmkt14e4HB1vwLJ3pBiGmT
    v0fuRyrXKp/0dNwsgvt2dhnnw+TSbtryva3n/EkNHT6U9Xv5012VNBkp6cxdwHFW
    oxu3DQaNx8dqvlfmBk3ADr0zGaF+TiCsxQ/BnZoyD/mR6YcXal6aVZ0CgYEAxiTj
    3uRgETkW9Q+LMk2TzM0vhLb19yr6Zm3WBk84FP3+hrdW0ehluo7GuZM7H5e7tAeM
    WExEpSotG+7cx0Y2T/yTgexamleN5j9/MLGm1Z3/mYmhc+DL12AE4U953ef/Rrjr
    6V7m5iddoLgZyrAoNA3rxZwV80tuQheMH1aH4hcCgYBbvWZQsEDZggQL4X0OzXn5
    esv2CQI34DHWrtnwKq7z++qtcK6WgdWM0VXuHJH7VS50ddZDbngW66uS8Id0NrjU
    nOnbKMEbK17nWYt8vQzZ8WLThsvuUT7ld2Y4I3Vxd8HkIJ1ky0alYRjpwdnePTLF
    6E9scmuYewA/ihgwl3booQKBgQCH+69LO+5WQ5jmzCkad7U0e6jd6va5D4zTmROm
    Nt3lQj9Y0yBJZLXUJ8Jof4u27dpK/lcqDgWaWGym2/I27I+/qzbM1CAA+Jg2KWOv
    1mwJ9KoDBDqCnUcn42TWAEZBrcM7FRQKkC/kyiVudIp22RhuSRODBdDmrODZiPGI
    XElbNwKBgQCwBHGCBSPA/+Xt2kEcSTIobD/ESAzDSj9H/dyVCKmw1d1xlIFQTQI3
    38CGmx/RgBsk3ME5xwUe2eoR8i1zacz4xOYQWsmfECLKXRhwUpxEBgCmKXTNhDAY
    H/ToB6kXNj+DCZk7UeSR9td1v8CWnP4MA4TrBg5N7wlC18lfTR2QIw==
    -----END RSA PRIVATE KEY-----
```
### Key Protect Wrapped Format

The image decryption key is wrapped using [IBM Cloud Key Protect Service](https://cloud.ibm.com/docs/key-protect?topic=key-protect-about) and the wrapped key is provided in a `kp-key` typed Kubernetes Secret, like:

```yaml
apiVersion: v1
kind: Secret
type: kp-key
metadata:
  name: image-decryption-key-wrapped
  namespace: image-key-synchronizer
stringData:
  rootkeyid: "0991a26e-a4b7-45eb-83a7-75abfcd984e8"
  ciphertext: "eyJjaXBoZXJ0ZXh0IjoiQ0tpY3I3Q0tvSTE0TG9pOWhXa0pUeFRFV0poMm9lUXVCR094TTYwdG1qemVxaE4weDF6R1FqMUVSRXZiZ1AwNmNUNjJxeXNEQ2hRY2swSzgyQmVqa2RtMGU4bEI3UVhqNWlLUUJ4aWhiV2NuU3UxSU9qeU41dms4aVN4SGZkRlA0V3QxTXR3SkRxTVZDa3c1OU42enEzVUFLMTdWNFVUVnBlYzhzT29lazMzU1MvOEE5NUFyRXYyQm10WEt4OHVuYmhDYWtOQTJXbHRieGp3S1pkVzk5WHFRMnZwYmJKanAydWlxUzFGSENzQ244QzByMU1OZ0xQUmFvMVBjV3VkeHF4STc0U3JYTVd3OTd6ZmlPcjFOZ054cG1oeTVhdEZwVFBTM1FsTS9uNzZJUkdQU1JyWmVuMWJrc2Zabmcxa0Urakdqbm5qWHFXWEl5MGZHNVYxUkFVejVFRkp5bnVJMlVKVEFBeUEyWk9pZ0Vya0NsVjJzV0syVjBmYVlacjE3MXU3ckZESkIybkxOc1Z3Zzg1SHVocWZTOXJYTXVLMCs5UnY2T3VBTFhGR1hyM1lBSW95QURQSDdyM3R1RTYvRjlyclFrd2orRVJuUUdISHVSbFlFcmxFTnRLVVpnMEVxREMxaUlPaE16OGtHU2dadEM1ckhaS01LVGhZb003ZlN6enFkZWdVY2U3dzFXTTV2aDR5MnpNWVNFQmhLUW5vK2luODluRjVvVTZ2cHZvbkM4bkJyZ3JlSHF3QzBVNTlTc1M0alZjYnJpZ2JhV29JMmZyNHlJMEdmakhoN2hDckZVS0lzY0k3STViSEdNOUlqMGJ0OW9mSGZLRmFWNWl0MVltOGtMM1JIOGZYL2x4SXFzN1hjMVl1S1VNbXc5a2V2M3J2NDVnVEIyZmVrdmdKeHJ3QTF4SFBQYW5TVHNNa3FUbkUwR2ZEYk1La1YwdW1XT3hPTVRQTjtSb3U3cUVQWXR5MDh6M3ZJUGRLN3FINmFrU2tuOEVabXdHSG1YMFRwM0hzNHN6NzRRODV1Rk44QTROQ0sxRnNHUmJxMTJHRkFFZUhMV1k0UlphSUlnWUt5M0NJY1VkQVVteFYvWERCZmtIYlpFVVVJYzdMNWpZT3YyaFBUMXp2WmlNcU4vN3FxbVhyUFdpRkRXUDhZbzFOWXZqb2s3dkVWc3ZqSXMwTzR3YmdZUVlBZjZsNexampledy93K01uS3ZHeFVhbFVKeDljd3hvT0tJU0ZQVGZLQlhSZU04UUtBZCtWVGQvdFgyS1FLdGtTQk54c2RsNVhQcDM4UmpKcjVlaE9MZHZtL05tekxRVFVjK3B6Y2hNOFBUays4SWY4TEFZQU85L0RZd2pqdHJPc3c2QWdzZENqMEhkOFZwbzFJemYyZ1pzcHdPUS9LcGNKbi9GK3ByS01rN2Z4eTUvZkdadzNZaHVFcDdtb1NvT3dtQUszN2huV2MydG93cDlPWUgwNDIzcHlmNHZrUnp2eTBEaFpUeHZHQjNpYXZRQVBvTDkranpDcUk2THREYmVWSVBKQ2dBZWtXc29reU9FR2oxbHlsbnlvN2REdUlYSkY1NzFkNUZwend1bmlhSmhOVUlESjRHcW1GODJMc2o5eVQ5ckJQWkhUbEttcXlzclM5alUzQ0gvZmRMaTVSb2hhU0g1Wk5ueGpDMjRhcENiM0tBWDlEUDZnb0o4UTZzWmdWZ002eXFma1J3bGorTEVocUZiUVVLb25aK0dqWjZwcjdLZzNoTVRTYVFYaU1sMHZrbUQ3SHB6ZGtDRnZMZzFHNmM5RWQ5SkU2NUlOZFpQNlhNMFJvbkZxODNIV3BXT3JlUVpsdXdxanJhQ1luQXdEUXExcG5EVTZNZStWSDdkYmFCKzJ5SmtlT2tyR29DVmN2K3JvOFRxVzltdEJoaEpQR0ovenlTbUluRFhwNnBtYUdzczVFT3JOZnNxMHRkRWwwOHlsVnlJRXFOcnM2UFNQNkVoVXliUHpQSFpYSG9GM1RsaGxzRTY1Z2pOaGpkTXVDYkR4RFVmT21FUjFGRDBWMDVoVUxnQkVidWluQlM2a1pFY2xHZHdTdG0rSFJRZEtEeGUwNmJFLzlmYUhOSFd2WFVLL0pRdElvY0ZoeVZzOWQ3L2tsN0g2V2lMdW05S0hzancrSTZLUHdOSUs5MmVYd1N6dUZVSUt3Z3VGSzBLcFFuVlp1dWhSd2R3R3pWU253WGdxajVHM2R4VnNwTlZSVDJrdzZnZWorbTU3NjZWOHl6amRKWkVoM1FXdzhCa0U5NUxSRDBNMnFsd0dNdTBrZHFqVEl4SGlrdFFLbHBhK1VzMmR4OSt1cW1ucnZvdUpYQkdlYVprU2JhTytaV0xuRmU3Y0xUbnlwbTIvNFg0SzhvaDNTWDgyeUxZSThMNFNVbxQ3TFFySVJTa0I5YzFtdkNFNndKYXhQRzRFYnExYzlxOXJwVU1CNGRsUWQ3ZjFlUmxzU29jb2doM1JBK3FvUXdackNRaHpWd1doQnJUQTlVZWxHQVFCbDROM3JIMlpPS1FiNUgzYzFuMVJGeXJzMUdHZWFzRWFZMThXd0d6eUhPM3M3STdKZXNLcFl1QWZ3WlcxMUs5eUR0c0NUUWFnZjdZOWNYNkEvNE1tZU9IeDVnOS9zM3FYaVJHR1Z6Y1U4M0R3OFAwTzcyZnhwVmc4WTBVQzgxa0JkWWdHajI2N2RIeGRTUVNZdlZzb2dMUm1wcGZwWk1qVUlSVkpyelBNS1BzZjZSaG9lYlZRTDJ3WWR6T3JrZWt0VUZRM1BxU05UUmZrZFo4TGY2S3BkZzY5QXYwK1ZpU1JNSGRCSFZZTVRjYnl4VVdxS2FvR3hUNlJ4ODdIays2RFl0VmVBYlBJNFo5ZlJYYlpNVjVWekw1THZIOEsxNHk4RXZ5ZU5SZ0M5WTljR2ZwSFMybDl4czcyMENLN0pHRXRwcUhQY0VtcFFMV2tDZGVNaWtic0FqQkx6ckhZUUVhYU09IiwiaXYiOiJNRitNVmlDMjA5NmsyeHZBIiwidmVyc2lvbiI6IjQuMC4wIiwiaGFuZGxlIjoiMDk5MWEyNmUtYTRhNy00NWViLTgzYTctNzVhYmZiZDk4NGU3In1="
```

The `rootkeyid` field contains the root key ID used to wrap the private key. The `ciphertext` field contains the wrapped private key.

The Image Key Synchronizer will take care of unwrapping the wrapped secret before writing the private key file to the nodes. In order to know how to unwrap these keys, the addon needs extra configuration, that can be provided in a Kubernetes Secret, named `keyprotect-config` in the `image-key-synchronizer` namespace, like:

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: keyprotect-config
  namespace: image-key-synchronizer
stringData:
  config.json: |
      {
          "keyprotect-url":"https://us-south.kms.cloud.ibm.com",
          "instance-id": "308da298-74a5-4044-9661-d9130fd29cb0",
          "apikey": "0mHUl7TEexampleru9wUybnzBzB_qnUxe9m1CkbaXUFD"
      }
```

The `keyprotect-url` JSON field contains the base URL of Key Protect to call. Possible options can be found [here](https://cloud.ibm.com/docs/key-protect?topic=key-protect-regions#service-endpoints).

The `instance-id` JSON field contains the Key Protect instance ID which was used to wrap the keys.

The `apikey` JSON field contains an API key that has (at least) `Reader` access to the specified Key Protect instance. (Preferably, create an IAM Service ID, assign `Reader` access to the Key Protect Instance, generate an API key for the Service ID and use that API key here.)

## Deploying the addon

### 1. Checking the OpenShift version

OpenShift version has to be >= 4.6
```
oc get version
```

###  2. Enable the Image Key Synchronizer addon

To check whether the Image Key Synchronizer addon is enabled for this cluster, run:

```
ibmcloud oc cluster addons --cluster <CLUSTERID>
```

To enable or disable addon for this cluster, run:

```
ibmcloud oc cluster addon enable image-key-synchronizer --cluster <CLUSTER_ID>
```

### 3. Verify that the addon was succesfully deployed

```
oc get ds addon-image-key-syncrhonizer -n image-key-synchronizer
```

## Troubleshooting

After installing the addon, the following components shall exist in the cluster:

  - a Namespace (Project) called `image-key-synchronizer` (all resoures below are created under this),
  - a ServiceAccount called `addon-image-key-synchronizer`,
  - a Role called `addon-image-key-synchronizer`,
  - a RoleBinding called `addon-image-key-synchronizer`,
  - a DaemonSet called `addon-image-key-synchronizer`.

If you are experiencing that the `addon-image-key-synchronizer-XXXX` pods are not in Running states, please check the following:

  - the cluster nodes are in a good condition, up and running and are joined to the cluster,
  - the CPU, memory and disk usage of the node where the pod could not start,
  - in case of ImagePullBackoff state, registry credentials are configured properly,
  - number of Pods should equal to the number of Nodes,
  - all the resources mentioned above are existing on the cluster.

  Run the [get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) job and look for the `ALB IMAGE-KEY-SYNCHRONIZER ADDON` section for a summary on related resources.


## Possible Issues

### Problems with the addon DaemonSet or Pods

Use the `kubectl describe` command to interrogate the detailed description of the DaemonSet and/or the problematic Pod(s) and look for the detailed problem description under Conditions.


### Missing addon resources

If any of the addon related resources listed here is missing, try to disable and then re-enable the addon with the `ibmcloud ks cluster addon <disable|enable>` commands. It is safe to execute the addon disable/enable procedure, because the resources (Secrets) provided by the user are not deleted. (The addon related resources can be found above.)

### Misconfiguration

If you did not found any issues with the resources mentioned above, it is possible that the addon is misconfigured. Checking the logs generated by the pods with `kubectl logs` might help determining a configuration problem.

When finding misconfiguration issues, advise the customer to visit [the official documentation](https://cloud.ibm.com/docs/openshift?topic=openshift-images#encrypted-images) and check their configuration.

## Escalation Policy

Once the initial investigation is performed if there are still errors:

1. Create a GHE Issue against [armada-frontdoor](https://github.ibm.com/alchemy-containers/armada-frontdoor/issues/) and provide results from the investigation.
1. Also, inform the armada-ingress squad about the problem via slack in [#armada-ingress](https://ibm-containers.slack.com/archives/armada-ingress) with the GHE issue link.
