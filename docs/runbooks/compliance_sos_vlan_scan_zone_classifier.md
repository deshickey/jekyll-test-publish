---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to diagnose sos-vlan-scan-zone-classifier Jenkins job failures
service: Conductors
title: sos-vlan-scan-zone-classifier Jenkins job failures
runbook-name: "sos-vlan-scan-zone-classifier Jenkins job failures"
link: /compliance_sos_vlan_scan_zone_classifier.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview
- Every day the [sos-vlan-scan-zone-classifer Jenkins job] is executed to update the SOS Inventory metadata

- The job tries to assign every VLAN to a specific Nessus scanzone so it can be scanned for security vulnerabilities.

- A Scan Zone is made up of one or more Nessus scanner servers in our IaaS Accounts (these are named `infra-nessus-XX`).

- Each VLAN must have an associated "Scan Zone" or devices on the VLAN risk not getting scanned.

- The Scan Zone VALN  details are stored in the SOS Inventory.  These get automatically published (twice daily) into the SecurityCenter.
    - [Armada control plane ALC scan zones](https://w3.sos.ibm.com/inventory.nsf/security_center.xsp?c_code=alc)
    - [Armada control plane ALC_FR2 scan zones](https://w3.sos.ibm.com/inventory.nsf/security_center.xsp?c_code=alc_fr2)

- The code for the VLAN classifications job is in the [security GHE repository](https://github.ibm.com/alchemy-conductors/security/tree/master/scan-zone)

## Example alert(s)

An alert will arrive stating `Scan zone classification tool failed` see output of builds in [sos-vlan-scan-zone-classifier jenkins job]

## Automation
There is currently no automation for error recovery.

## Actions to take

- Open the console output of the failed Jenkins build.
- Search the console output for the string `error` (case insensitive).

- The error may be a temporary issue due to a blip in network connectivity or an SOS API outage. Consider re-running the failed Jenkins job to see if the problem goes away.  If the problem does not clear on a re-run, then further investigation will be required.

- Consider how to resolve the error:
    - `dial tcp: lookup w3.sos.ibm.com on 9.x.x.x:53: read udp 172.17.x.x:x->9.x.x.x:53: i/o timeout`
        - The references to `lookup` and `:53` indicate a failure to look up the SOS API server `w3.sos.ibm.com` via DNS. This indicates a problem with DNS infrastructure on the specified 9.x.x.x server. Ask in the `#sos-api` Slack channel for help, if necessary raise an SOS ticket as described below.

    - `dial tcp 9.x.x.x:443: i/o timeout`
        - This indicates a network connectivity error between the Jenkins container and the SOS network. Ask the TaaS team in the [#taas-jenkins-help Slack channel](https://ibm-argonauts.slack.com/archives/C56Q2JUKS) to check the VPN connectivity and network connectivity from Jenkins to w3.sos.ibm.com, if necessary raise a TaaS ticket as described below.

    - `Failed to get list of vlans`
    - `Retrieved zero vlans from SOS`
    - `Error posting to SOS api`
    - `Non-200 error code updating SOS`
        - These errors relate to unexpected results from the SOS API. Ask in the [#sos-api Slack channel](https://ibm-argonauts.slack.com/archives/CARQFH3BP) for help, if necessary raise an SOS ticket as described below.

    - `SOS inventory returned an unexpected number of servers when querying`
        - This error may indicate that two machines have the same hostname. Check for duplicate hostnames of the specified machine in the SoftLayer portal. If two have the same name then one of them must be renamed. Take care that renaming a machine would typically require the machine to be reloaded and re-bootstrapped to ensure its configuration is correct.
        - Consider raising an issue in https://github.ibm.com/alchemy-conductors/security/issues to make the inventory update code more robust.

    - Any other errors are likely to be a code defect in the automation.

- If you are unable to resolve the problem, open an issue in [security GHE repository](https://github.ibm.com/alchemy-conductors/security/issues) and contact the Compliance Focal to discuss how to fix it.

## Raising an SOS Ticket (SOS API issues only)
- Follow the instructions on [the SOS wiki page](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/IDMgt%20-%20Open%20ServiceNow%20Ticket), except that:
    - Specify Assignment Group `SOS API`
    - Specify Severity 2
    - Specify the C_Code from the error message in the Jenkins log (or specify `ALC` if unclear)
    - Specify the description fields showing the error that came from the API and the time of the error

## Raising a TaaS Ticket (Jenkins issues only)
- Go to [TaaS ticket interface](https://taas-home.w3ibm.mybluemix.net/jenkins)
- Follow the link to open a ticket.
- Fill out the form to specify the details of the connectivity issue showing the error, the time of the error and the IP addresses involved.
- Click the Save button (top right) to create the ticket.

## Escalation Policy
- Raise an issue in the [Security GHE repository](https://github.ibm.com/alchemy-conductors/security/issues/)
- Contact the Security Focal during office hours to discuss.


[sos-vlan-scan-zone-classifier jenkins job]: https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/sos-vlan-scan-zone-classifier/
