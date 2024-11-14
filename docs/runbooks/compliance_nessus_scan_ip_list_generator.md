---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to diagnose nessus_scan_ip_list_generator Jenkins job failures
service: Conductors
title: nessus_scan_ip_list_generator Jenkins job failures
runbook-name: "nessus_scan_ip_list_generator Jenkins job failures"
link: /compliance_nessus_scan_ip_list_generator.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview

- Every day the [nessus_scan_ip_list_generator] Jenkins job is executed.

- Its purpose is to update the many `Asset lists` we have defined in [SecurityCenter] with the IP addresses/subnets to be scanned by Nessus in the many vulnerability scans we have defined.

## Useful links

- [nessus_scan_ip_list_generator] jenkins job
- The code is located in [compliance-nessus-scan-asset-list-generator GHE repository](https://github.ibm.com/alchemy-conductors/compliance-nessus-scan-asset-list-generator)

## Example alert(s)
Nessus asset list build did not complete within the last day, see [nessus_scan_ip_list_generator] build output

## Automation
There is no automation for error recovery, manual review and intervention is required.

## Actions to take
1. Navigate to Jenkins using the link provided in the alert
1. Open the console output of the failed Jenkins build.
1. Search the console output for the string `error` (case insensitive).
1. Consider how to resolve the error:
    - `dial tcp: lookup w3.sos.ibm.com on 9.x.x.x:53: read udp 172.17.x.x:x->9.x.x.x:53: i/o timeout`
        - The references to `lookup` and `:53` indicate a failure to look up the SOS API server `w3.sos.ibm.com` via DNS. This indicates a problem with DNS infrastructure on the specified 9.x.x.x server. Ask in the #sos-api Slack channel for help, if necessary raise an SOS ticket as described below.

    - `dial tcp 9.x.x.x:443: i/o timeout`
        - This indicates a network connectivity error between the Jenkins container and the SOS network. Ask the TaaS team in the #taas-jenkins-help Slack channel to check the VPN connectivity and network connectivity from Jenkins to w3.sos.ibm.com, if necessary raise a TaaS ticket as described below.

    - `Error posting to login: Failed to decode data: {"type":"regular","response":[],"error_code":163,"error_msg":"Account locked.\n","warnings":[],"timestamp":1531051843}`
        - This indicates that the login credentials used are invalid. The most likely reason is that the SOS IDMgt password of the conauto@uk.ibm.com user has expired. Reset the password of the conauto SOS IDMgt user.

    - `Failed to find our automated server list:`
        - This indicates that someone has deleted an asset list in SecurityCenter. Log into [SecurityCenter] with your SOS IDMgt and recreate the named asset list:
            - Navigate to the Assets section
            - Click the Add button at the top-right
            - Select Static IP List
            - Enter the name cited as missing in the error message
            - Enter at least one IP address (it doesn't matter what, the Jenkins job will replace it later)
            - Click Submit to create the asset list

    - Any other errors are likely to be a code defect in the automation.

1. The error may be a temporary issue due to a blip in network connectivity or an SOS API outage. Consider re-running the failed Jenkins job to see if the problem goes away.

- If you are unable to resolve the problem, open an issue in [the security repo](https://github.ibm.com/alchemy-conductors/security/issues/new) and contact the Security Squad to discuss how to fix it.

## Raising an SOS Ticket (SOS API issues only)
- Follow the instructions on [this wiki page](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/IDMgt%20-%20Open%20ServiceNow%20Ticket), except that:
    - **Assignment Group** `SOS API`
    - **Severity 2**
    - **C_Code** from the error message in the Jenkins log (or specify `ALC` if unclear)
    - description fields showing the error that came from the API and the time of the error

## Raising a TaaS Ticket (Jenkins issues only)
1. Go to [TaaS Support site](https://taas.cloud.ibm.com/support/technical-support.md#formal-ticket-procedure.md)
1. Follow the link to open a ticket.
1. Fill out the form to specify the details of the connectivity issue showing:
   - error
   - the time of the error
   - IP addresses involved
   - severity of the issue
1. Click the Save button (top right) to create the ticket.

## Escalation Policy
- Raise an issue in the [Security squads GHE repository](https://github.ibm.com/alchemy-conductors/security/issues/)
- Contact the SRE Security and Compliance Focal during office hours to discuss.


[SecurityCenter]: https://w3sccv.sos.ibm.com
[nessus_scan_ip_list_generator]: https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/nessus_scan_ip_list_generator