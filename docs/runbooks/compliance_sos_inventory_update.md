---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to diagnose sos-inventory-update Jenkins job failures
service: Conductors
title: sos-inventory-update Jenkins job failures
runbook-name: "sos-inventory-update Jenkins job failures"
link: /compliance_sos_inventory_update.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview
- Several times a day we run the sos-inventory-update Jenkins job to update the SOS Inventory metadata about the security compliance status of our machines. This involves processing all of the machine data in the Netint devices.csv files and calling the SOS API to update the SOS machine metadata.
- We update the Application and Environment fields for machines to reflect which squad or service owns them for reporting purposes.
- We update the Status field to reflect the machine's lifecycle status:
    - Build: the machine is < 48 hours old and is to be excluded from security compliance checking
    - Live: the machine is actively in use
    - Available: the machine is marked for cancellation, it's awaiting deprovisioning and is to be excluded from security compliance checking
- The code for this job is in https://github.ibm.com/alchemy-conductors/security/tree/master/inventory-manager

## Example alert(s)
Error during updating the SOS Inventory metadata used to track security compliance. See the output of the build here https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/sos-inventory-update/288/

## Automation
This is automation, but there is no automation for error recovery.

## Actions to take
- Open the console output of the failed Jenkins build.
- Search the console output for the string `error` (case insensitive).
- Consider how to resolve the error:
    - `dial tcp: lookup w3.sos.ibm.com on 9.x.x.x:53: read udp 172.17.x.x:x->9.x.x.x:53: i/o timeout`
        - The references to `lookup` and `:53` indicate a failure to look up the SOS API server `w3.sos.ibm.com` via DNS. This indicates a problem with DNS infrastructure on the specified 9.x.x.x server. Ask in the #sos-api Slack channel for help, if necessary raise an SOS ticket as described below.

    - `dial tcp 9.x.x.x:443: i/o timeout`
        - This indicates a network connectivity error between the Jenkins container and the SOS network. Ask the TaaS team in the #taas-jenkins-help Slack channel to check the VPN connectivity and network connectivity from Jenkins to w3.sos.ibm.com, if necessary raise a TaaS ticket as described below.

    - `Failed to query SOS inventory`
    - `SOS inventory returned an error when querying`
    - `Failed to update SOS inventory`
    - `SOS inventory returned an error when updating`
        - These errors all relate to unexpected results from the SOS API. Ask in the #sos-api Slack channel for help, if necessary raise an SOS ticket as described below.

    - `SOS inventory returned an unexpected number of servers when querying`
        - This error may indicate that two machines have the same hostname. Check for duplicate hostnames of the specified machine in the SoftLayer portal. If two have the same name then one of them must be renamed. Take care that renaming a machine would typically require the machine to be reloaded and re-bootstrapped to ensure its configuration is correct.
        - Consider raising an issue in https://github.ibm.com/alchemy-conductors/security/issues to make the inventory update code more robust.

    - Any other errors are likely to be a code defect in the automation.

- The error may be a temporary issue due to a blip in network connectivity or an SOS API outage. Consider re-running the failed Jenkins job to see if the problem goes away.

- If you are unable to resolve the problem, open an issue in https://github.ibm.com/alchemy-conductors/security/issues and contact the Compliance Focal to discuss how to fix it.

## Raising an SOS Ticket (SOS API issues only)
- Follow the instructions on [this wiki page](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/IDMgt%20-%20Open%20ServiceNow%20Ticket), except that:
    - Specify Assignment Group `SOS API`
    - Specify Severity 2
    - Specify the C_Code from the error message in the Jenkins log (or specify `ALC` if unclear)
    - Specify the description fields showing the error that came from the API and the time of the error

## Raising a TaaS Ticket (Jenkins issues only)
- Go to https://taas-home.w3ibm.mybluemix.net/jenkins
- Follow the link to open a ticket.
- Fill out the form to specify the details of the connectivity issue showing the error, the time of the error and the IP addresses involved.
- Click the Save button (top right) to create the ticket.

## Escalation Policy
- Raise an issue in https://github.ibm.com/alchemy-conductors/security/issues/
- Contact the Security Focal during office hours to discuss.