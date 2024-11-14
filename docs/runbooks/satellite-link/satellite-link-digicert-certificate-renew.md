---
layout: default
description: How to resolve Cert Expiration Very Imminent
title: Cert Expiration Very Imminent - How to resolve 
service: satellite-link
runbook-name: "Cert Expiration Very Imminent"
tags:  satellite-link, tunnel, health consumption 
link: /satellite-link/Satellite link Cert Expiration Very Imminent
type: Alert
grand_parent: Armada Runbooks
parent: Satellite Link
---

Alert
{: .label .label-purple}

## Overview

| Alert_Situation | Info | Start |
|--
| `SatelliteLinkCertificateExpirationVeryImminent`| When Digicerts are about to expire, 2 types of PD are generated one when the certificate is expiring in < 25 days and the other one when is expiring in < 20 days. PD Alert < 20 days is termed as "very imminent"
 | [Steps to debug Satellite Link Certificate Expiration Very Imminent](#steps-to-debug-satellite-link-certificate-expiration-very-imminent) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~~
Labels:
 - alertname = SatelliteLinkCertificateExpirationVeryImminent
 - alert_situation = SatelliteLinkCertificateExpirationVeryImminent
 - service = satellite-link
 - severity = critical
 - cluster_id = xxxxxxxxxxx
 - namespace = satellite-link
Annotations:
 - summary = "Satellite Link Certificate Expiration Imminent"
 - description = "One or more certificates in use in satellite-link are nearing expiry"
~~~~

## Steps to debug Satellite Link Certificate Expiration Very Imminent

## Actions to take

1. Two types of PD alerts are generated when Digicerts are about to expire. one when the certificate is expiring in < 25 days and the other one when is expiring in < 20 days.
 
PD Alert < 25 days is termed as "imminent"
<img width="1045" alt="Screen Shot 2022-06-21 at 4 43 08 PM" src="https://media.github.ibm.com/user/348396/files/3d1c9000-f181-11ec-8e80-b7bcf5c2ac44">

PD Alert < 20 days is termed as "very imminent"

<img width="1042" alt="Screen Shot 2022-06-21 at 4 43 48 PM" src="https://media.github.ibm.com/user/348396/files/545b7d80-f181-11ec-8979-299cac2ff6f2">

2. Once the first PD Alert is generated, create an issue in satellite-link-support repo.
https://github.ibm.com/IBM-Cloud-Platform-Networking/Satellite-Link-Support/issues/86 and assign it satellite-link pipeline team 
[Clayton Leach, Sangeetha Kamatkar]

3. Satellite-Link pipeline team must open the following issues

   a) In Repo:alchemy-conductors/team [Add multiple names if multiple certs are expiring]
      Name: 
      `URGENT:Expiring cert needs renewal: Satellite-Link: region:[region name eg., eu-gb]`

      Issue Description: 
      ```
        Squad: Satellite Link
        Overview: Renew the expiring certificate (Digicert) for our production environment.
        Justification: Regional tunnel private certificate for [region name eg., eu-gb]
        Environment: Prod
        IBM Cloud Account: 2094928

      ```

      Example: https://github.ibm.com/alchemy-conductors/team/issues/14754

   b) In Repo:IBM-Cloud-Platform-Networking/hybrid-link
      Name:
      `URGENT:Expiring digicerts for [region names] needs renewal`

      Issue Description: link the above created issue here [example below]
      ```
        eu-gb: Issue created with conductors team to renew the certificate: alchemy-conductors/team#14754.
      ```
      Label: assign the label `Certificate-Rotation`

      Example: https://github.ibm.com/IBM-Cloud-Platform-Networking/hybrid-link/issues/1899

4. Send the csr of the certificate to the assigned conductors team as an encrypted email. [Check with Domenico Conia for csr and key of the expiring digicert]

5. Once the digicert renewed, conductor team will send the certificate pem file as an encrypted email.
   
6. Update the certificates in armada-secure. 
    
   A) Repo for the armada-secure: https://github.ibm.com/alchemy-containers/armada-secure
    
   B) Refer to the box note: https://ibm.ent.box.com/notes/774020089616 and follow the steps from the section "The general steps for adding a new Secret File"
    
   C) Once the PR is approved, merge the changes. This will automatically triggers the travis build.
    
   D) Deploy the build to the specific region (for which the certificates were created). refer: https://ibm.ent.box.com/notes/773998659400
    
7. Once the certificates are updated in armada-secure, Replace the certificate in certificate manager. Visit the certificate manager on IBMcloud-Resource list-Services. Click the 3 dots next to the entry and click on Reimport Certificate 

<img width="1422" alt="Screen Shot 2022-06-21 at 4 45 32 PM" src="https://media.github.ibm.com/user/348396/files/9258a180-f181-11ec-9db8-83df8029ead4">

Then add the fullchain.pem and privkey.pem files you just created.

<img width="1050" alt="Screen Shot 2022-06-21 at 4 46 15 PM" src="https://media.github.ibm.com/user/348396/files/ac927f80-f181-11ec-8e1f-854b879bc571">

Click Reimport and you should be almost done. You can verify this was done correctly by checking the expiration date of the new certificate. 
      
8. Finally, you need to restart both the Tunnel Server and API Server in the current region: 
    
    A) If the certificate issuer is "DigiCert Inc" then restart both API and Tunnel servers
    ```
     1) Login in with appropriate credentials
        `ibmcloud login -sso`
     2) Select the region  
        `3. Satellite Production (e3feec44d9b8445690b354c493aa3e89) <-> 2094928`
        `4. Satellite Stage (a8fd5d2f57b240f9b276a254c0fcb8a1) <-> 2146126`
     3) First list clusters in the appropriate account:
        `ibmcloud ks cluster ls`
     4) Find the appropriate cluster for tunnel server and use:
        `ibmcloud ks cluster config -c $CLUSTER_NAME`
     5) Restart the Server
        a) Tunnel Server
        `kubectl rollout restart deployment satellite-link-tunnel -n satellite-link`
        b) API Server
        `kubectl rollout restart deployment satellite-link-api -n satellite-link` 
     ``` 

9. Once service(s) are restarted do a final check by running 
    
    For public endpoint: `curl https://c-01-ws.[MZR].link.satellite.[test.]cloud.ibm.com -vk`

    For private endpoint: 
    ```
    1) exec into one of the pods in staging env:
         kubectl exec -it pod-name -n satellite-link -- /bin/bash

    2) then try the below command
         curl https://d-01-ws.private.[MZR].link.satellite.[test.]cloud.ibm.com -vk
    ```

the output should contain the expiration date of the new certificate under the `Server Certificate Section` : 

```
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN, server accepted to use http/1.1
* Server certificate:
*  subject: CN=*.us-east.link.satellite.test.cloud.ibm.com
*  start date: Sep 21 19:52:15 2020 GMT
*  expire date: Dec 20 19:52:15 2020 GMT
*  issuer: C=US; O=Let's Encrypt; CN=Let's Encrypt Authority X3
*  SSL certificate verify ok.

```

Make sure the expiration date matches the new certificate's expiration date. 

### Note: If you run into any problems during this process please contact the CICD Team on slack @Clay or @Sangeetha 

### Additional Information

More information on the satellite-link-tunnel can be found [here](https://github.ibm.com/IBM-Cloud-Platform-Networking/Satellite-Link-Support)

## Escalation Policy

If a CIE has been raised and you need assistance, please engage the development squad using the [{{ site.data.teams.satellite-link.escalate.name }}]({{ site.data.teams.satellite-link.escalate.link }}) pagerduty escalation policy.

If this is not a CIE, you can reach out using the [{{ site.data.teams.satellite-link.comm.name }}]({{ site.data.teams.satellite-link.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.satellite-link.name }}]({{ site.data.teams.satellite-link.issue }}) Github repository with all the debugging steps and information done to get to this point.