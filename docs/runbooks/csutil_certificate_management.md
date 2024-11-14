---
layout: default
description: How csutil certificates are managed
service: SOS csutil certificates
title: How csutil certificates are stored and managed
runbook-name: "SOS onboarding"
tags: conductors support onboarding
playbooks: ["Runbook needs to be Updated with playbooks info (if applicable)"]
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
link: /csutil_certificate_management.html
type: Informational
parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This document details how SOS certificates, used in csutil deployments, are stored and managed now that the 1337 repos are no longer in use.

## Contents

The below sections cover the following;

- [Detailed overview](#detailed-information) - overview of the process including the secrets manager instance details
- [Locating and reserving certificates](#locating-and-reserving-certificates)
- [Labelling certificates - reserving them for exclusive use, and freeing after use](#managing-the-certificates)
- [Downloading the certificate](#downloading-a-certificate)

## Detailed information

Secrets manager is now being used to securely store the SOS VPN certificates used during csutil deployments, replacing the GHE repositories `csutil-certs-containers-kubernetes-dev` and `cruiser-onboard-containers-kubernetes` in the `alchemy-1337` organization.

A single secrets manager instance has been setup with two access groups in IAM.
The instance is located in the `1186049 Dev Containers` cloud account _NB: SRE are working on enabling access for developers - see [GHE 23035](https://github.ibm.com/alchemy-conductors/team/issues/23035)_

To connect to secrets manager, first, target the secrets manager instance
* `ibmcloud secrets-manager config set service-url https://f5ff0271-df89-4371-888b-fb989fef2510.eu-gb.secrets-manager.appdomain.cloud`

Two groups have been setup within Secrets manager (full details in the sections below).  
All developers will get access to `development_sos_certificates` access group.  
Members of the SRE team will also get access to `sre_sos_certificates` access group where certificates used on the production control plane are stored.  Reducing who can see these minimises any duplicate usage of certificates, which causes runtime problems.

Access is controlled via this [accesshub configuration](https://github.ibm.com/argonauts-access/role-config/blob/master/iks/iam/com_ibm_cloud/dev-containers.json) - if any issues are discovered, they should be discussed with SRE.

This document provides detailed information about how these SOS certificates are managed.  If you are a developer and just want step by step instructions on how to reserve a certificate and deploy csutils to your cluster, the network team has a wiki that provides that here: https://github.ibm.com/alchemy-containers/armada-network/wiki/How-to-Deploy-csutils-on-Long-Running-Clusters/

### SOS certificates for Development use

Details of where certificates specifically for use by Development teams are as follows.  These are typically the `containerskubernetesdev` certificates.

- Secrets Manager name: `sos_csutil_certificates`
- Secrets Manager Group Name: `development_sos_certificates`
- Secrets Manager Group ID: `7281002a-dd4d-c82b-b582-b1aa896fad31`
- service-url: `https://f5ff0271-df89-4371-888b-fb989fef2510.eu-gb.secrets-manager.appdomain.cloud`

### SOS certificates for SRE use

The following group was setup to store certificates used by SRE for csutil installs on tugboats and SRE infrastructure clusters.
Only SREs have access to see the secrets added to this group as if these are accidentally used by two clusters, it could cause issues with reporting compliance on our control plane.

- Secrets Manager name: `sos_csutil_certificates`
- Secrets Manager Group Name: `sre_sos_certificates`
- Secrets Manager Group ID: `bda26e01-b057-0b2a-96a9-8998a61db8d6`
- service-url: `https://f5ff0271-df89-4371-888b-fb989fef2510.eu-gb.secrets-manager.appdomain.cloud`


## Locating and reserving certificates

The following commands can be used to find a certificate and then mark them as in use.

## Example queries

### Get a secret using the certificates name

If you know the name of the exact certificate you wish to get, you can query and grab the cert contents very easily.

To validate this is indeed the correct certificate, you can run the following command, which will report the labels and other metadata.

`ibmcloud sm secret-by-name --secret-group-name "development_sos_certificates" --secret-type "imported_cert" --name "containerskubernetesdev001"`
```
created_by              IBMid-2700013MWS
created_at              2024-05-22T15:44:52.000Z
custom_metadata         <Nested Object>
description             OVPN SOS certificate for use by development
downloaded              true
id                      f81fbcae-bc6b-a8dc-a232-40544eb3222b
labels                  [bluqapud0depnt4ggt8g, fvt-orchestrator]
locks_total             0
name                    containerskubernetesdev001
secret_group_id         7281002a-dd4d-c82b-b582-b1aa896fad31
secret_type             imported_cert
state                   1
state_description       active
updated_at              2024-05-23T11:54:46.000Z
versions_total          1
expiration_date         2027-10-16T14:16:12.000Z
signing_algorithm       SHA256-RSA
common_name             ChangeMe
intermediate_included   false
issuer                  ChangeMe
key_algorithm           RSA2048
private_key_included    false
serial_number           d3:c7:2c:e9:e2:ee:c3:bf
validity                <Nested Object>
```

To then download the certificate, please see [this section](#downloading-a-certificate)

### To query/search for secrets

If you are in need of reserving a certificate for a cluster you intend to keep long term (i.e. over 6 days) you can run searches for discover free certificates.  

The best way to do this is to search and they parse the output.  I find using the `--output json` the most effective way.
Any certificates without any labels, or with labels such as `available` or `free` can be deemed available for use by anyone.

- `ibmcloud sm secrets --limit 1000 --output json | jq '.secrets[] | select(.labels[0] == "available" or (has("labels") | not))' | grep '"name"' | sort`

   Note that by default only 200 secrets are returned, so `--limit 1000` ensures that all of our certs are queried

- `ibmcloud sm secrets --search containerskubernetesdev05`  
   
   This will pattern match and return multiple hits if the string is included in multiple certs
```
Name                         ID                                     Secret_Type     secret_group_id                        State    Locks   Expiration
containerskubernetesdev055   11f2115c-b924-4f08-818e-76e02fc2c120   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
containerskubernetesdev051   2e2e1a1a-b093-f2dc-8a38-48f8d02ed019   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
containerskubernetesdev058   34f438e9-c65a-9a5c-363a-0e69f46b0d23   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
containerskubernetesdev053   53ad2153-ced2-456a-0e22-4d1210472a33   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
containerskubernetesdev054   56937ac4-2131-61a1-1e50-06ecd3780160   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
containerskubernetesdev057   5bd9fd13-a0c6-0d2a-8b6e-5808b1e82100   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
containerskubernetesdev052   a003cdf0-c907-2b9b-7a90-23a9dec4edf5   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
containerskubernetesdev050   c710732e-ac89-c750-5319-895986ba0a5c   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
containerskubernetesdev059   f57ac427-9087-3f81-0ab4-ba7a5372e7c6   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
containerskubernetesdev056   fd755453-049e-bce4-d0a8-80181f6b9684   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
```

An example command showing that no labels are set on this certificate, therefore meaning it is free to be reserved.
- `ibmcloud sm secrets --search containerskubernetesdev296 --output json`
```
{
  "first": {
    "href": "https://f5ff0271-df89-4371-888b-fb989fef2510.eu-gb.secrets-manager.appdomain.cloud/api/v2/secrets?limit=200\u0026search=containerskubernetesdev296"
  },
  "last": {
    "href": "https://f5ff0271-df89-4371-888b-fb989fef2510.eu-gb.secrets-manager.appdomain.cloud/api/v2/secrets?limit=200\u0026search=containerskubernetesdev296"
  },
  "limit": 200,
  "offset": 0,
  "secrets": [
    {
      "common_name": "ChangeMe",
      "created_at": "2024-05-22T15:46:26.000Z",
      "created_by": "IBMid-2700013MWS",
      "crn": "crn:v1:bluemix:public:secrets-manager:eu-gb:a/47998ac029ed4ca69cf807338b7dbd2e:f5ff0271-df89-4371-888b-fb989fef2510:secret:318f6738-9a03-0728-56df-6e6b25581422",
      "description": "OVPN SOS certificate for use by development",
      "downloaded": true,
      "expiration_date": "2027-10-16T14:16:12.000Z",
      "id": "318f6738-9a03-0728-56df-6e6b25581422",
      "intermediate_included": false,
      "issuer": "ChangeMe",
      "key_algorithm": "RSA2048",
      "locks_total": 0,
      "name": "containerskubernetesdev296",
      "private_key_included": false,
      "secret_group_id": "7281002a-dd4d-c82b-b582-b1aa896fad31",
      "secret_type": "imported_cert",
      "serial_number": "d3:c7:2c:e9:e2:ee:c3:bf",
      "signing_algorithm": "SHA256-RSA",
      "state": 1,
      "state_description": "active",
      "updated_at": "2024-05-22T15:46:26.000Z",
      "validity": {
        "not_after": "2027-10-16T14:16:12.000Z",
        "not_before": "2017-10-18T14:16:12.000Z"
      },
      "versions_total": 1
    }
  ],
  "total_count": 1
}
```

### Label searching

If you're re-deploying csutil and want the already reserved certificate for a cluster, you can search in these ways to find it.

You can search based on labels.  i.e. A clustername or a clusterid.  __NB:__ This requires an exact match - regex seems not to work.
* `ibmcloud sm secrets --match-all-labels "bts-stage-baremetal-oc4-1"`
```
Name                         ID                                     Secret_Type     secret_group_id                        State    Locks   Expiration
containerskubernetesdev040   05850e12-f5e4-c4e7-c0ed-f8b63d7ed675   imported_cert   7281002a-dd4d-c82b-b582-b1aa896fad31   active   0       2027-10-16T14:16:12.000Z
```

* `ibmcloud sm secrets --match-all-labels "prestage-us-south-carrier101"`
```
Name                      ID                                     Secret_Type     secret_group_id                        State    Locks   Expiration
containerskubernetes090   20e5332c-c9e8-c3fe-581f-95d2bb1ed1e2   imported_cert   bda26e01-b057-0b2a-96a9-8998a61db8d6   active   0       2027-10-16T14:16:12.000Z
```

## Managing the certificates

__PLEASE NOTE:__ It is the responsibility of the person interacting with secrets manager to correct label the certificates.
There is no tracking file - labels are the sole way certificates are being managed so be extremely careful running commands.

### Reserving a certificate: Adding a label

Once you've found a free certificate, label it to reserve it.  Provide labels such as `squad-name`,`clusterid` and `clustername` so, if required, you can be contacted in the future. 
You will need to use the `id` of the secret to update its metadata

-  `ibmcloud secrets-manager secret-metadata-update --id <the secret id> --labels clusterid,clustername,squad-name`

### Freeing up a certificate after use

If a cluster is removed, then the labels need to be removed and either made blank, or change the labels to be `available` to anyone looking, can see the certificate is un-reserved.

Use the `ibmcloud secrets-manager secret-metadata-update` command to change the labels.

For example:
`ibmcloud secrets-manager secret-metadata-update --id <the secret id> --labels=available`

## Downloading a certificate

Finally, once you've identified the certificate you wish to use, you can grab the contents using the `secret-by-name` option.

To grab the certificate, you can run the `secret-by-name` command and pipe the  output to jq, and re-direct the `.certificate` section into a file.
This can then be used in the csutil installation process.

__PLEASE NOTE:__ The file name needs to have a `.ovpn` extension, or the csutil installation will fail.

- `ibmcloud sm secret-by-name --secret-group-name "development_sos_certificates" --secret-type "imported_cert" --name "containerskubernetesdev001" --output json | jq -r .certificate > containerskubernetesdev001.ovpn`

## Escalation and assistance

There is no formal escalation policy for this. If in doubt with any of these steps, please speak to the SRE Squad  
