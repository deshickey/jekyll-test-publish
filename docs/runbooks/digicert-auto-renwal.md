---
layout: default
title: Automation for Certificate renewal process for digicert issued certs
type: Informational
runbook-name: Digicert-Auto-Renwal
description: Automation for Certificate renewal process for digicert issued certs
category: Armada
service: NA
tags: GITHUB, certificates
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
There are multiple endpoints where the certificate issued by digicerts are used currently. For example all the tugboats and carriers have public and private endpoints using digicert certificates.

The Automation of Certificate renewal uses the [ibmcloud-ciso/certorder](https://github.ibm.com/ibmcloud-ciso/certorder) tool for ordering certificates.


## Detailed Information
The code repository for the automation for Certificate renewal process for digicert issued certs is: https://github.ibm.com/alchemy-conductors/certificate-expiry-management

The sync job that runs everyday once per Argonauts Production (532177) and IKS BNPP(2051458) accounts: 
https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/test-cert-expiry-check/

The job is responsible for three things mainly:
 - monitoring every endpoint whether it is using the correct certificate or not
 - checking the certificates in Secrets manager to get all the certificates expiring in next 60 days or before and creating the CSR and keys and encrypt them and create a PR for armada-secure, then create cert renewal order(pull request) in [ibmcloud-ciso/certorder](https://github.ibm.com/ibmcloud-ciso/certorder) repo.
 - Once the renewed certificate is issued, download and reimport to secret manager of corresponding account and then encrypt it and update the PR in armada-secure with the encrypted key.

Types of alerts:

Below is the mapping of alertname to its invetigating section. Please click on the link.

| AlertName | Info | Action |
|--
| `ExpiryDatesMismatch` | This indicates that the expiry date of the cert used by endpoint and the corresponding cert in Secret manager do not match. | [Expiry Dates Mismatch of certificates](#expiry-dates-mismatch-of-certificates) |
| `DelayedMergeCertOrderPR` | This indicates that the cert renewal request (pull request) created is not merged by the ibmcloud-ciso after 7 days. | [Certorder PR not merged](#certorder-pr-not-merged) |
{:.table .table-bordered .table-striped}

_Note: Link to the manual process for Digicert renwal is [here](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/using_certificate_manager.html)_


### Expiry Dates Mismatch of certificates

The automation job iterates through all the public / private endpoints of all the tugboats / carriers and gets the expiry date of the certificate they're using it then compares it with the corresponding certificate found in the Secret Manager of that ibmcloud account. If the expiry dates of the certificates doesn't match, then it triggers the PagerDuty alert you received. The idea is that, all the certificates (renewed / new) are stored in the secrets manager and the certificates deployed to the endpoints are supposed to match with the ones stored in secerts manager. Following are the reasons for the mismatch and what actions you can take to fix them.

- The certificate has been renewed and new Certificate is reimported to Secrets Manager but the PR for armada-secure with the corresponding encrypted certificate and key is not merged. In this case, it needs to be chased in the #armada-secure channel by asking @razee-prod-approvers to review the PR if it has not been approved yet. Once approved, it needs to be merged. The PR will be generated from the branch similar to the certificate name. For example a certificate `*.eu-de.containers.cloud.ibm.com` that has an expiry date of 2022-01-31, will be having a PR from branch called `AUTO_RENEW_DIGICERT-WILDCARD_EU-DE_CONTAINERS_CLOUD_IBM_COM-2022-01-31` with the encrypted certificate and key
- The certificate has been renewed and new Certificate is reimported to Secrets Manager and the PR for armada-secure with the corresponding encrypted certificate and key is also merged but its not been promoted yet in Razee.  In this case, please raise the necessary train and take action for promoting the cert and key to production.
- The certificate has been renewed and new Certificate is reimported to Secrets Manager and the PR for armada-secure with the corresponding encrypted certificate and key is also merged and promoted to prod in Razee. In this case, there is a possibility that a wrong cert is deployed OR the deployment did not complete successfully. Please login to the corresponding tugboat/carrier and check the deployment.
- It is possible that sometimes the endpoints are configured with wrong certificates. This may result in the pagerduty alert of type `ExpiryDatesMismatch`. This needs to be checked with #netint team.


### Certorder PR not merged

The automation job checks all the open Pull Requests that it created for ordering certificates on a daily basis. If it finds out that a request (which is a pull request on certorder repo) is older than 7 days and still open, it will trigger a PD. In this case please take the domain mentioned in the PD and check the corresponding pull request from the branch in certorder repo. For example, a domain like `*.eu-de.containers.cloud.ibm.com` that has an expiry date of 2022-01-31 will be having a PR from branch called `IKS-DIGICERT-RENEWAL-WILDCARD_EU-DE_CONTAINERS_CLOUD_IBM_COM-2022-01-31` in certorder repo. Expiry date can be obtained from the secrets manager OR from the jenkins job (mentioned in PD) console log (by searching for the text `CERTMAP is :` and identifying the key which is equal to the domain mentioned in the PD. The value of the key will be the expiry date)
