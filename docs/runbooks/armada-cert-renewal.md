---
layout: default
title: Containers and Satellite Certificate Renewal
type: Operations
runbook-name: armada-cert-renewal
description: Procedure for renewing TLS certificates for containers and satellite services
category: Armada
service: armada-cert-management
tags: certificate, cert-renewal, expiration
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview
This runbook details the procedure for renewing TLS certificates for Containers and Satellite services.

## Example alerts

```
alert_key: armada-cert-management/certs_expiring_60_days
alert_situation: certs_expiring_60_days
alertname: CertsExpiringWithin60Days
description: Certificate monitoring detected certificates in secrets manager that will expire in less than 60 days.
expiring_certs:
  - '*.private.eu-gb.link.satellite.cloud.ibm.com'
  - '*.private.us-east.link.satellite.cloud.ibm.com'
service: armada-cert-management
severity: critical
summary: Detected certificates in secrets manager that will expire in less than 60 days.
```

## Detailed Information
SRE maintain the TLS certificates used for securing communication to the containers and satellite microservices. Each certificate is valid for 365 days, and a renewed certificate must be deployed before the current certificate expires. Failure to do so will prevent customers and other services from communicating with our services and will cause a CIE.

Certificate monitoring will trigger pagerduty alerts for expiring certificates, beginning at 60 days prior to expiration. The procedure below describes how to renew the certificates to resolve the alerts.

## Detailed Procedure
Search the [team `cert-renewal` issues](https://github.ibm.com/alchemy-conductors/team/labels/cert-renewal) for the common name of the expiring certificate, e.g. `*.private.eu-gb.link.satellite.cloud.ibm.com` to find the issue to action.

NOTE: If there are several certificates for the service that are expiring around the same time, they may be included in the issue that requires action for the alert. Do not be alarmed. The Cert-Management automation will process all of the certificates listed in the issue.

The renewal issue includes a checklist, with links to the related automation.

  > [ ] Order certificate(s) [[batch-renew-digicert-certificates](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/batch-renew-digicert-certificates/)]  
  > [ ] Submit Funding Request for DigiCert Public TLS/SSL Certificates form (Link and form instructions below)  
  > [ ] Raise and merge armada-secure PR with the updated certificate and key [[update-digicert-certs-in-armada-secure](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/update-digicert-certs-in-armada-secure/)]  
  > [ ] Promote armada-secure PR to all targets [[razeeflags](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-secure)]  
  > [ ] Run verification checks on the renewed certificate(s) after promotion to each respective region [[verify-deployed-certificate](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/verify-deployed-certificate/)]  
  > [ ] (`containers` wildcard certs only) Verify that `TRIGGER_REGION_NAMED_CERT_REFRESH` operation `COMPLETED` for each region where certs were updated.  
  > [ ] Rotate the certificate in secrets manager [[rotate-renewed-cert-in-secrets-manager](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/rotate-renewed-cert-in-secrets-manager/)]  
  > [ ] Verify that all temporary secrets related to this renewal (i.e. `-OIP` and `-pending` secrets), are deleted from secrets manager  

<img src="https://assets.github.ibm.com/images/icons/emoji/unicode/1f4a1.png" alt="bulb" height="16"> **PRO TIP:** For this process, use the links from the Requirements checklist and Job Summary sections _in the GHE issue_.  Wherever possible, those links will pre-fill the build parameters for each of the Jenkins jobs

### Order certificates
To order (renew) the certificates in the renewal issue, click the [batch-renew-digicert-certificates](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/batch-renew-digicert-certificates/) link from the Requirements checklist in the renewal issue.
  1. Run the job once with `DRY_RUN` and `UPDATE_ISSUE` selected (default) to see what will be updated.
  1. Review the job summary that is added to the issue and verify that the common names listed match what's in the issue description and that there are no outrageous costs (e.g. wildcard certificates should be less than $350 per wildcard). If there are any anomalies, post in `#conductors-for-life`, requesting additional review/assistance.
  1. If the `DRY_RUN` summary looks good, run the job again, this time with `DRY_RUN` de-selected.

When the job completes, a summary will be added to the GHE issue, along with instructions for the next step.

### Submit Funding Request Form
The DigiCert order(s) will be pending approval until a funding request form is submitted and approved.
  1. Expand the "Funding Request for DigiCert Public TLS/SSL Certificates form info" section of the renewal issue to display the form questions and answers.
  1. Open a new tab or window to the [Funding Request for DigiCert Public TLS/SSL Certificates form](https://certhub.digitalcerts.identity-services.intranet.ibm.com/digicert/funds) and fill out the form, using the answers from the renewal issue. Click `Submit`, then click `Request Funds`.

     Note: If the form link redirects you to IBM CertHub after authentication, click "Request Public TLS/SSL", then select "Funding Form" to return to the form page.
  1. Once the funding form is approved, you should receive an email from DigiCert, for each certificate, letting you know that the order has been approved. Click the [batch-check-digicert-order-status](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/batch-check-digicert-order-status/) link at the end of the last Job Summary update in the renewal issue to confirm the status. When the job completes, a summary will be added to the GHE issue, along with instructions for the next step.

### Raise and merge armada-secure PR with the updated certificate(s) and key(s)
Once all certificates have been issued, click the [update-digicert-certs-in-armada-secure](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/update-digicert-certs-in-armada-secure) link - from either the Requirements checklist or the end of the last Job Summary update in the renewal issue.
  1. Run the job with the pre-filled parameter values.
  1. Click the link at the end of the console log output to review the armada-secure PR.
  1. If the PR looks correct, follow the usual process to get approvals and merge the PR.

### Promote armada-secure PR and verify renewed certificates
Follow the [process for armada-secure promotion and verification](https://github.ibm.com/alchemy-containers/armada-secure/wiki/Approved-Testing-Sources) to deploy the armada-secure build to each region via [Razeeflags](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-secure).

For each deploy target, if the build contains a renewed certificate for that target, perform the verification steps below.

  1. Wait for deployments to rollout.

     For the [istio-enabled tugboat](#istio-enabled-tugboats) in the deploy target, check [Razeedash](https://razeedash.containers.cloud.ibm.com/v2/alchemy-containers/clusters) and verify that the `cse-health-check` deployment has fully rolled out, as most of the verification checks query those pods for the certificate.
  1. Run verification checks on the renewed certificate(s)

     Click the [verify-deployed-certificate](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/verify-deployed-certificate/) link from the Requirements checklist of the renewal issue to run the verification job for **each** renewed certificate in that target.

     For example, if both `*.private.eu-gb.link.satellite.cloud.ibm.com` and `*.eu-gb.link.satellite.cloud.ibm.com` were renewed, then after deploying to the `link` target for `uk-south`
     - Run the job with `*.private.eu-gb.link.satellite.cloud.ibm.com` for `COMMON_NAME`, then
     - Run the job with `*.eu-gb.link.satellite.cloud.ibm.com` for `COMMON_NAME`.  

     The job will add the verification results to the renewal issue, and if the certificate is a wildcard `containers` certificate, it will also add a placeholder for `TRIGGER_REGION_NAMED_CERT_REFRESH` verification.
  1. Verify that TRIGGER_REGION_NAMED_CERT_REFRESH operation STARTED

     When a wildcard `containers` certificate is renewed, ROKS clusters require a master refresh for them to pick up the updated "named cert". The `armada-deploy` microservice should automatically detect that the certificate has been updated and trigger refreshes for all of the clusters that require it.
     1. Search slack for `STARTED TRIGGER_REGION_NAMED_CERT_REFRESH` and find the post for the region that armada-secure was just deployed to.
     1. Copy the slack post and paste it into the placeholder that was added to the renewal issue.  

     If you are unable to find the `TRIGGER_REGION_NAMED_CERT_REFRESH` post, request assistance from the armada-deploy squad in [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }})

     NOTE: `stage` has 3 microservices tugboats (for `stage`, `stage4`, and `stage5`), so there should be triggers from each of those tugboats when stage `containers` wildcard certs are renewed, and the verification job will add placeholders for all 3. If the performance (`stage4` and `stage5`) tugboats are locked, they will not receive the updated certificate(s) and trigger refreshes until they are unlocked.

### Rotate the certificate in secrets manager
The certificate renewal automation stores the renewed certificate in secrets manager as a temporary secret with the same name as the original secret, but with `-pending` appended. Once the new certificate is deployed to all targets, the certificate in the original secret can be rotated and the temporary secrets can be deleted.

For each renewed certificate, run the [rotate-renewed-cert-in-secrets-manager](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/rotate-renewed-cert-in-secrets-manager/) Jenkins job.

If the rotation is successful, the job will delete the associated `-OIP` and `-pending` secrets and will update the renewal issue with the results.

Example:
  > Jenkins job: [https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/rotate-renewed-cert-in-secrets-manager/122/](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/rotate-renewed-cert-in-secrets-manager/122/)  
  > Rotated secret, star_jp-tok_containers_cloud_ibm_com, in secrets manager.  
  > Cert secret matches pending cert. Temporary secrets can be deleted.  
  > Deleted star_jp-tok_containers_cloud_ibm_com-pending  
  > Deleted star_jp-tok_containers_cloud_ibm_com-OIP

### Verify that all temporary secrets related to the renewed certificates are deleted from secrets manager
The `rotate-renewed-cert-in-secrets-manager` job should delete the two temporary secrets (i.e. `-OIP` and `-pending`) for each certificate, once rotation is complete. However, if rotation was successful, but the temporary secrets were not deleted, use the [cleanup-temp-secrets](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/job/cleanup-temp-secrets/) job to delete them.

### Review Issue and Complete Requirements Checklist
Review the Requirements checklist in the renewal issue, and verify that each task is complete and documented within the issue.

If the renewal issue included any wildcard `containers` certificates, find the `COMPLETED` `TRIGGER_REGION_NAMED_CERT_REFRESH` slack message(s), using the same steps as for `STARTED` messages before, and update the verification post(s) in the renewal issue accordingly. See completed `containers` issue in the [Examples](#examples) section for reference.

Once all tasks are complete, close the renewal issue.

## Automation
All certificate management jobs are under <https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Cert-Management/>

## Reference

### Istio-enabled tugboats
  - `SatelliteConfig` tugboats for `satellite-config` targets
  - `LinkApiSatellite` tugboats for `link` targets
  - `MicroservicesAndEtcd` tugboats for the remaining regional targets

Use `armada-envs` to lookup the respective cluster ID by running the command in the example below. Replace values for `PIPELINE_ENV`, `REGION`, and `TUGBOAT_PURPOSE`, as appropriate.

Example:
```bash
$ PIPELINE_ENV="prod" \
  REGION="us-south" \
  TUGBOAT_PURPOSE="MicroservicesAndEtcd" \
  yq eval-all '
    select(
      .pipeline_env == env(PIPELINE_ENV) and
      .tugboat_purpose == env(TUGBOAT_PURPOSE) and
      .cluster_region == env(REGION)
    ) |
    pick(["carrier_name","cluster_id"])
  ' ./*-*/carrier*.yml
```

```yaml
# ******************************************************************************
# * Licensed Materials - Property of IBM
# * IBM Cloud Kubernetes Service, 5737-D43
# * (C) Copyright IBM Corp. 2019-2022 All Rights Reserved.
# * US Government Users Restricted Rights - Use, duplication or
# * disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
# ******************************************************************************
carrier_name: prod-dal10-carrier105
cluster_id: bn08l8td0bfjd8d8kqkg
```

### Examples
Examples of completed `cert-renewal` issues:
- `containers` <https://github.ibm.com/alchemy-conductors/team/issues/23669>
- `satellite-config` <https://github.ibm.com/alchemy-conductors/team/issues/23595>
