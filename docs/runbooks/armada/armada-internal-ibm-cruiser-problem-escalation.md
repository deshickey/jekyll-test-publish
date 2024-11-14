---
layout: default
title: How IBM teams escalate problems to the Container Service team
type: Informational
runbook-name: "How IBM teams escalate problems with kubernetes clusters to the Container Service (Armada) team"
description: "Help for IBM teams to investigate and escalate problems with kubernetes clusters to the Container Service team"
category: armada
service: armada
link: /armada/armada-internal-ibmcruiser-problem-escalation.html 
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview/Purpose of Runbook

This runbook describes how internal IBM teams can get support from the Container
Service team for problems with their cluster. 

## Detailed Information

Before seeking support there are some places to look for information that may
help either by knowing that there are known ongoing issues or answering specific
common problems:

- [Troubleshooting guide] in the documentation.

- [Cloud status] shows known existing problems across IBM Cloud. 

  Select _Notifications_ and filter by Component _IBM Containers_.
  
- Informal help can be found on slack channel [armada-users]. 

  The armada developers will help with general questions
  and some specific cluster problems. 
  However this is not a monitored channel and therefore a response cannot be 
  guaranteed.
  
If the above channels do not help, then please get help from the Container 
Service team in either of the following ways depending on the severity.

- For problems with your cluster see [Sev 1-4 Problems](#getting-support-for-problems)

- If there a potential or confirmed Critical Impact Event (CIE) with your
  production service please see [Escalating during a CIE](#escalating-during-a-cie)

### Getting support for problems

The following steps will raise a Support ticket which will initially handled by the IBM Cloud DSET team.

1. Create a support ticket at [Support unified console] making sure you have
selected the IBM Cloud account in which your cluster is provisioned. 
  Select:

   - Ticket Type: Technical

   - Related to: Services

   - Technical area of support: Compute

   - Severity: Level 1 to Level 4

   - Subject: Brief summary of the problem

   - In the Brief Description field include the following:
      - region: us-south, us-east, uk-south, eu-central, ap-south, ap-north 
      - data center in which the cluster is located: e.g. dal10, dal12, ams03 
      - cluster id : taken from `ibmcloud ks cluster ls` 
      - IBM Cloud account number : 
      - userid that is having the problem (if there is a specific userid) :
      - description of problem:  
    
   - Select Submit Ticket

1. The support ticket will be handled via ServiceNow
 
  
### Escalating during a CIE

Use this process to escalate Critical Impact Events (CIEs) with your production
environment where the immediate attention of the Armada team 
(IBM Cloud Containers service) is needed. 
This should be used at any time of day or week.

1. Gather must collect information before escalating to Armada team:
  - region: us-south, us-east, uk-south, eu-central, ap-south, ap-north 
  - data center in which the cluster is located: e.g. dal10, dal12, ams03
  - cluster id : taken from `ibmcloud ks cluster ls`
  - IBM Cloud account number : 
  - userid that is having the problem (if there is a specific userid) :
  - description of problem:  
2. Manually open a PagerDuty incident against Armada impacted service:
  - Send an email to `alchemy-customer-problem@ibm.pagerduty.com`
     - Subject: Please include your service name in the subject
     - Body: any relevant information including where to contact you.

3. Primary SRE will acknowledge and contact you and investigate the incident.

4. Communicate on the CIE resolution in following slack channels and the PagerDuty:
  - [conductors] : On-call SRE for armada . Good place to start.
  - [containers-cie] : used if there is a current Container Service CIE in
    progress 
    
6. Contact person: in slack channel [conductors] run '@interrupt' to find out 
   the on-call SRE.

## Further Information

- [Troubleshooting guide] in the documentation.

- [Cloud status] shows known existing problems across IBM Cloud. 

  Select _Notifications_ and filter by Component _IBM Containers_.
  
- Informal help can be found on slack channel [armada-users]. 



[Support unified console]: https://control.bluemix.net/support/unifiedConsole/tickets/add 
[Troubleshooting guide]: https://console.bluemix.net/docs/containers/cs_troubleshoot.html#cs_troubleshoot
[Cloud status]: http://ibm.biz/ibmcloudstatus
[Alchemy - Internal IBM Customer problem]: https://ibm.pagerduty.com/services/PP94KKK
[armada-users]: https://ibm-cloudplatform.slack.com/messages/C4S4NUCB1
[conductors]: https://ibm-cloudplatform.slack.com/messages/C54H08JSK
[containers-cie]: https://ibm-cloudplatform.slack.com/messages/C4SN1JNG5
