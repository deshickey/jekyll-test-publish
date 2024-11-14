---
layout: default
title: Compliance SOS Reconcile
type: Informational
runbook-name: Compliance SOS Reconcile
description: compliance sos reconciliation tool guide
category: Armada
service: NA
tags: GITHUB, compliance, SOS
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
We keep security compliance records checked into some GitHub Enterprise repositories. These are the outputs of running various security compliance tools to collect the evidence we need for audits, especially the SOC2 Type 2 audit which requires evidence that we are taking daily actions to remain in a compliant state.

The SOS reconciliation tool provides the ability to compare a list of devices and VLANs from a set of Softlayer accounts (the source inventory) against the Shared Operational Services (SOS) inventory for a specified C_Code. There are two C_Code we Reconcile: ALC and ALC_WAT. Any discrepancies between the sets of data will be reported via human and machine readable (json) files, and if the discrepancies are significant, an alert raised to trigger further investigation.


## Detailed Information
The code repository in this Jenkins job is: https://github.ibm.com/alchemy-conductors/compliance-sos-reconcile

ALC reconciliation run by: 
https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-sos-reconcile-alc/

ALC_WAT reconciliation run by: 
https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-sos-reconcile-wat/

All result files will be generated in an "_output" folder within the current working directory, detail input and output information you can also find from above link.

## Investigation and Action
- Click on link to Jenkins build in the Details section of the incident. In the Jenkins build page click `Console Output` to display job output.
- Search the console output for the string `error` (case insensitive), then look at the goroutine parts, find out which part is causing the error.
	- if the error root is inside /compliance-sos-reconcile/sos or /compliance-sos-reconcile/inventory, consider how to resolve it by: 
		- check if the SOS service is down
		- check if the SOS_TOKEN in environment variable still valid.
		- ask in the #sos-api Slack channel for help, if necessary raise an SOS ticket as described below.

	- if the error root is inside /compliance-sos-reconcile/softlayer, consider how to resolve it by: 
		- check if APIKey for Softlayer still valid.
		- ask help from Softlayer Slack channel, if necessary raise an Softlayer ticket.

  - 'dial tcp 9.x.x.x:443: i/o timeout'
    - This indicates a network connectivity error between the Jenkins container and the SOS network. Ask the TaaS team in the #taas-jenkins-help Slack channel to check the VPN connectivity and network connectivity from Jenkins to w3.sos.ibm.com, if necessary raise a TaaS ticket as described below.

  - Any other errors are likely to be a code defect in the automation.

	- The error may be a temporary issue due to a blip in network connectivity or an SOS API outage. Consider re-running the failed Jenkins job to see if the problem goes away.	

- If you are unable to resolve the problem, open an issue in https://github.ibm.com/alchemy-conductors/security/issues and contact the Compliance Focal to discuss how to fix it.

## Raising an SOS Ticket (SOS API issues only)
- Follow the instructions on [this wiki page](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/IDMgt%20-%20Open%20ServiceNow%20Ticket), except that:
    - Specify Assignment Group `SOS API`
    - Specify Severity 2
    - Specify the C_Code from the error message in the Jenkins log ('ALC' or 'ALC_WAT')
    - Specify the description fields showing the error that came from the API and the time of the error


## Escalation Policy
1.  Check [Conductors Team GHE](https://github.ibm.com/alchemy-conductors/team/issues) for already opened issues.
2.  Raise an issue if one is not already open.
3.  Contact the Security Focal during office hours to discuss.
