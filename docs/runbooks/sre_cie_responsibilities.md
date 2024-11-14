---
layout: default
description: Process all squads should follow for a pCIE or CIE
title: SRE CIE Responsibilities
service: Conductors
runbook-name: "SRE CIE Responsibilities"
link: /sre_cie_responsibilities.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# SRE CIE Responsibilities


## Overview

This runbook contains a full lifecycle of responsibilities for the role of the SRE Interrupt Pair, when a pCIE/CIE gets raised. The information is viable for everyone involved within the CIE process and should be referred to for and questions.

*Notes:* If our services are impacted by CIE of our dependencies (e.g. SL, BSS, IAM), we should raise our own CIE as a downstream CIE and refer to that CIE.  Select `IBM Service Dependency` as the Root Cause Code for the RCA. For more information about how to fill in the RCA, refer to [RCA playback/education video](https://ibm.box.com/s/24ia09ep7jcjzqlz5oxuo8729ex7ldpw) and [Root Cause Codes Usage Guidelines](https://watson.service-now.com/kb_view.do?sysparm_article=KB0011312) 

---

## Detailed information

## Understand Each Team's Responsibilities

- [CIE education and documentation from the AVM squad](https://pages.github.ibm.com/toc-avm/avm/)

Service Team Responsibilities during a CIE
```
- Take fully responsibilities to restore service as soon as possible.
- Timely communication during an incident can sometimes be more important than resolving an incident faster.  
- During an incident it’s critical that teams are communicating either via Slack or a conference bridge.  
- AVM is responsible for initial CIE Notifications(User Notification and Tier1 Notification) on any Sev1 incident within 30 minutes of being engaged. It is imperative that whoever is on duty be able to provide basic information about the incident (what is the impact, what region / environment is impacted, when the incident started, etc.) to the AVM in a timely manner.
- Any troubleshooting that is performed should be relayed in Slack or on the bridge. This includes changes performed regardless of whether they resolved the incident or not. It’s important that we can show progress, even if it’s just items that we’ve ruled out.  
- Troubleshooting steps do not need to be relayed in excruciating detail. AVM is not looking for exact command line syntax used, IP addresses or even server names, but if that information helps others in the channel feel free to include it. This information will be summarized for the executives. (e.g. Services on the controller node were restarted, node was rebooted, etc.)
```

## CIE Channels

Please be aware of the following CIE channels used by the SRE Squad 

- [#containers-cie](https://ibm-argonauts.slack.com/archives/C4SN1JNG5}) - **NB** _(Used For IBM Kubernetes, Registry, VA, and Satellite CIEs.)_


## pCIE/CIE Structure 

Below is the structure that **will** be followed by all squads whenever a CIE has been recognised.

When a pCIE/CIE has been triggered, make sure the **Primary oncall conductor [primary]** and **Secondary oncall conductor [secondary]** work through the following

## Raise a pCIE

1. An incident comes through triggering a potential CIE

1. Move any on-going discussions of the problem from any private channels, and into the relevant [CIE channel](#cie-channels)

1. Raise pCIE using [ciebot](./sre_raising_cie.html). Please refer to the templates [here](https://ibm.ent.box.com/notes/310391783160?s=zg6zvu9wqrlrbw0mmtxk1vcr54oh986d) to document the CIE  
**NB. DO NOT use terms such as `carrier, cruiser` as these are internal only, not known by external.**
   - Set Severity referencing [Raise-a-CIE-wiki](https://github.ibm.com/alchemy-conductors/team/wiki/Raise-a-CIE#step-3-decide-severity)

   - **primary** begins investigation by looking at [runbooks](./runbooks.html), [alerts & monitoring]({{ site.data.monitoring.dashboard.link }}) and attempts to resolve the situation.

   - **secondary** handles all paperwork and raises the pCIE using `@ciebot` - we always treat something as a potential CIE until we fully understand the blast radius and impact of the incident that is occurring.


   - **secondary** halts trains in the all regions: `traffic lights go red!`  
     _**[prod-trains](https://ibm-argonauts.slack.com/messages/C529CCTTQ) need to be manually stopped** and the SRE squad need to begin coordinating traffic!_

1. Either remain as pCIE only or upgrade to cCIE
   
   - **primary** and **secondary** need to quickly determine the impact of this issue.  After a short period of investigation and potential consultation with SRE members and/or developers, determine if the issue should be confirmed, or left as a potential CIE.
       - As **primary** , there is no hard and fast rule about time to investigate and fix a problem before confirming or paging out developers for assistance.  If after a few minutes it's clear you require help, inform the **secondary** to escalate the issue to development.
       - As **secondary**, if the SRE squad are unable to determine impact, and other squads are required to assist, use pager duty to page their on-call developer - Use [@interrupt bot](https://github.ibm.com/sre-bots/interrupt) to find who is on-call.  **DO NOT** rely on slack and developers responding to `@here` - keep paging out development squads where required. 
   
   - **secondary** If the incident is  confirmed as **NOT** critical impact, then the issue remains as a potential CIE and the CIE record remains in that state until either;
       - the situation is resolved, or 
       - the situation worsens, and the incident is upgraded to a cCIE.  The **secondary** is responsible for monitoring this.

   - **secondary** coordinate with the ERM - the details of the situation and the process loops around these steps.  When the problem is resolved, use [@ciebot](./sre_raising_cie.html) to close the CIE - the remainder of the runbook can be ignored.
   
   - **secondary** If confirmed as a critical impact event, use `@ciebot` to change the ServiceNow record to a confirmed CIE.  Move onto [Confirm and co-ordinate the cCIE](#confirm-and-co-ordinate-the-ccie)


## Confirm and co-ordinate the cCIE

1. When a CIE is confirmed, check trains in all regions were stopped when pCIE was raised. If not, stop the trains now. 
_**[prod-trains](https://ibm-argonauts.slack.com/messages/C529CCTTQ) need to be manually stopped** and the SRE squad need to begin coordinating traffic!_

   - **secondary** coordinates the confirmed CIE by alerting in the relevant [CIE channel ](#cie-channels)

   ```
   @here, @secondary coordinating cCIE <link>. @primary is investigating.
   NO-ONE else do anything unless requested and approved by @secondary"
   ```
    
   - **primary** continues to use runbooks to resolve the problem, having a maximum of 15 minutes to try and fix the issue
   - **secondary** should keep notes to aid with writing the RCA record and should work closely with the primary to track progress being made.
    

1. **Secondary** will help the **primary** in the CIE investigation by reviewing a list of all _non-ops_ change requests that have been approved in the last 24 hours. 

   The list of _non-ops_ change request can be found using the following query in the [cfs-prod-trains](https://ibm-argonauts.slack.com/archives/C529CCTTQ) slack channel:
   
   - Show non-ops trains which were Started, Approved or Completed in the past 24 hours: 
      ```
      recent changes
      ```
   - Show non-ops trains which were Started, Approved or Completed in the past 2 hours: 
      ```
      recent changes 2
      ```
   
   If the cfs-prod-trains slack channel is unavailable, the list of change requests can be found using the following ServiceNow queries.  
   _The queries include all regions, but the search filters can be modified to include only the regions impacted by the CIE if necessary._
   - [ServiceNow query for all regions in past 2 hours](https://watson.service-now.com/nav_to.do?uri=%2Fchange_request_list.do%3Fsysparm_query%3Dcmdb_ci%3D78f79f03db8543008799327e9d9619e0%5Eu_environment%3D81f84ee8db644f006001327e9d96191f%5EORu_environment%3Dc1f8cee8db644f006001327e9d96194b%5EORu_environment%3D45f84ee8db644f006001327e9d96191f%5EORu_environment%3D0df8cee8db644f006001327e9d96194b%5EORu_environment%3D4df8cee8db644f006001327e9d961944%5EORu_environment%3Db83059dddb0d23c080005878dc9619cc%5EORu_environment%3D1685bbf9db4044108623362f9d9619ae%5EORu_environment%3Da5e169411b042050a2b499ffbd4bcb54%5Eopened_atRELATIVEGT@hour@ago@2%5EdescriptionNOT%20LIKE%22ops%22:%20true%26sysparm_first_row%3D1%26sysparm_view%3D)
    - [ServiceNow query for all regions in past 24 hours](https://watson.service-now.com/nav_to.do?uri=%2Fchange_request_list.do%3Fsysparm_query%3Dcmdb_ci%3D78f79f03db8543008799327e9d9619e0%5Eu_environment%3D81f84ee8db644f006001327e9d96191f%5EORu_environment%3Dc1f8cee8db644f006001327e9d96194b%5EORu_environment%3D45f84ee8db644f006001327e9d96191f%5EORu_environment%3D0df8cee8db644f006001327e9d96194b%5EORu_environment%3D4df8cee8db644f006001327e9d961944%5EORu_environment%3Db83059dddb0d23c080005878dc9619cc%5EORu_environment%3D1685bbf9db4044108623362f9d9619ae%5EORu_environment%3Da5e169411b042050a2b499ffbd4bcb54%5Eopened_atRELATIVEGT@hour@ago@24%5EdescriptionNOT%20LIKE%22ops%22:%20true%26sysparm_first_row%3D1%26sysparm_view%3D)
    - [ServiceNow query for change to services that IKS depend on in the past 12 hours](https://watson.service-now.com/nav_to.do?uri=%2Fchange_request_list.do%3Fsysparm_tiny%3D0e79cf3247f5a9907e2f84be536d430c)


1. After 15 minutes of investigating, **primary** reports current status of cCIE to **secondary**.

1. With the details of the current status of the cCIE, **secondary** is responsible for bringing in required people to investigate.

   - **secondary** Consider paging out the development squad

   - **secondary** Add relevant updates to the relevant [CIE channel](#cie-channels) bringing in one/two people at a time to assist.
   
   ```
   @here, @secondary working with @user(s) to resolve CIE #incident_id.  
   More information will be available within the RCA.  
   Again, NO-ONE else do anything unless approved by @secondary.
   ```

   - If **secondary** brings in the required SRE/dev squad, allow the **primary** to pair with the dev-squad. Make sure **primary** and authorised users are working to resolve the issue and **KNOW** what is going on.

   - **secondary** continues to update the CIE channel **and** lead communications and **SHOULD NOT** be investigating the issue.  Other SRE enginners or developers should be called in to assist if necessary.

1. To find out DSET /AVM on call, use the `@interrupt avm` via slack DM.

1. Make a note of disruption metrics timeline and include it in HO following [guideline](https://ibm.ent.box.com/s/o0he1ph5tjnztjcianzkgrmx9e03gdp8)

1.  If a CIE is handed over to the next SRE Geo/Squad to continue working, then it's critical that a handover is completed correctly in the CIE channel.  Please follow these guidelines to provide a summary to the SREs taking over so they can immediately continue working the problem.
   - High level summary of the issue/outage
   - What actions have been taken so far (by anyone involved)
   - What is currently being actioned and by who
   - What actions are remaining and who is responsible for taking these
   - Who are the key dev contacts assisting with the CIE.
   
   - Example handover summary:
   
   ```
   Handover from EU to US on-call SREs
   Summary: The only region affected is `us-east`. Within that the actual issue was with the routers in WDC06. SL worked with the hw vendor and restored the connectivity https://control.softlayer.com/support/tickets/85618031..  Ideally WDC07 and WDC04 shouldn't have affected as they are in AZ.

   Actions taken:  SL restored router.  Joseph Goergen is looking into why so many masters are in CrashLoopbackOff state
   Outstanding actions: SRE engineers to continue with etcd recovery - see work item X for tracking.
   Dev called out: armada-deploy - Joseph Goergen
   ```
   
   Ensure that when you handover, you announce in the CIE channel it is the end of your shift, and provide the names of the primary and secondary interrupt pair of the new shift taking over.

        
**NB. _All questions regarding the CIE need to be asked in the relevant [CIE channel](#cie-channels), if anyone tries directly messaging SRE on-call, get them to repost in the CIE channel._**


## Downstream CIE from SL outage/incident.

If the current CIE is due to an issue with IaaS (Softlayer) and you have to open a ticket for them to engage, there are few things to keep in mind.

1.  If you open a ticket for a CIE with SL you must open that ticket as a SEV 1. This can only be done at the time it is opened. You must also mention in the text of the ticket that the issue is currently impacting IKS.

2.   Once the ticket has been opened, call the IaaS (Softlayer) support number 866-403-7638. Give them your name and the Production account number 531277. State that this is an emergency and you need for them to engage the appropriate support teams.

3.   Contact our AVM. Either are available via Slack #containers-cie. Be sure to explain who you are and give them the ticket you just opened. Have them make sure the ticket is escalated correctly and quickly. Tag them in the CIE channel to en sure they are aware it is affecting us as a CIE.

**NB. _If the outage is believed to be caused by IBM Cloud Infra, see this rb on how to [contact IBM Infra](./sre_cie_contact_ibm_infra.html)_**

## Post-CIE write-up and analysis

Once the cCIE is resolved, the **secondary** should co-ordinate with the AVM on-call to close the CIE record.

[Trains should be manually started](https://ibm-argonauts.slack.com/messages/C529CCTTQ) by either on-call SREs(interrupt)  
_(We consider automating this would potentially be more harmful incase the related PD is resolved too early. When the PD is resolved, the Service Now incident will also be resolved. Do not resolve the PD until the CIE is over)._

1. **secondary** updates the RCA in ServiceNow 
   
   - There will always be an SRE owner for the RCA (sometimes you will have additional co-owners - i.e: members of a dev-squad who's microservice was involved in the CIE)

   - Updates the ServiceNow Problem record created during the CIE.  A link should be emailed to the SRE after being created in ServiceNow.

   - Raise relevant GHE issues to improve/fix monitoring, alerting and logging. This helps to reduce MTTR( MeanTime To Recovery)

   - Retrospectively look at how we can stop this happening in the future
   
   -  SEV 1 PRB should be completed within 24 hours and SEV 2 PRB should be completed within 5 business days


See the [useful links](#useful-links) section which has links to education on completing RCAs, amoung other things.

---

## Further Questions

Any questions to the process or the runbook, please ask in the [{{ site.data.teams.containers-sre.comm.name }}]({{ site.data.teams.containers-sre.comm.link }}) slack channel.

## Useful links

- [AVM RCA Guideline](https://pages.github.ibm.com/toc-avm/avm/star/2019/03/10/How-to-Perform-RCA/)
- [RCA playback/education video](https://ibm.box.com/s/24ia09ep7jcjzqlz5oxuo8729ex7ldpw)
- [Root Cause Codes Usage Guidelines](https://watson.service-now.com/kb_view.do?sysparm_article=KB0011312)
- [ServiceNow](https://watson.service-now.com/navpage.do)

