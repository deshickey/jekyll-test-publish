---
layout: default
title: Reviewing CIS health checks for Armada Machines
type: Informational
runbook-name: "Reviewing CIS health checks for Armada Machines"
description: "Reviewing CIS health checks for Armada Machines"
service: Conductors
link: /docs/runbooks/armada_bixfix_health_checks.html
parent: Armada Runbooks

---

Informational
{: .label }

# Reviewing CIS health checks for Armada Machines


## Overview

The runbook describes how to monitor CIS health checks of Alchemy owned machines.
These checks report a score out of 100 to show whether or not a machine is compliant.

BigFix captures a daily report for each machine and stores one year's worth of compliance scores. Currently, these scores go back as far as 8/8/17 (when the health checks went live).


## Detailed Information

### Bigfix Access

In order to access [BigFix Compliance Scores](https://w3iem-sca.sos.ibm.com/scm#), you need the correct SOS IDMgt permissions first.
Go to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome) and you need to request access to `[BU044-ALC-SOS-Reports]`. Once this hs been approved, you can access the compliance scores.

#### BigFix Compliance - accessing multiple c_codes

BigFix Compliance (previously called SCA) has an issue where members of multiple `c_codes` (like ALC + ALC_WAT) are only automatically granted access to one. The tool seems to pick just one of the `c_codes` from the Active Directory roles for the user. 

During testing, the tool only showed ALC_WAT systems and he was only searching for ALC systems. If you are having this issue, follow section `D` [here](https://w3-connections.ibm.com/wikis/home?lang=en#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/ServiceNow%20for%20SOS%20Customer%20usage) to request access. 


### Navigating through BigFix

The following shows a set of instructions for checking the compliance of given machine(s)

1. Navigate to https://w3iem-sca.sos.ibm.com/scm/computers

2. Click on configure view:

![image](https://media.github.ibm.com/user/43972/files/abfe02dc-4704-11e8-8f64-1b76e046b8bf)

3. Add a filter:

![image](https://media.github.ibm.com/user/43972/files/bdaaafee-4704-11e8-9561-e72fc84eef3d)

4. Choose your system (be aware of the property and whether you choose equals or contains):

![image](https://media.github.ibm.com/user/43972/files/f373cd68-4704-11e8-8c19-3382ae7d56c4)

5. Click the computer name:

![image](https://media.github.ibm.com/user/43972/files/142a270a-4705-11e8-927c-0f161af8e64b)

6. Click on number of checks:

![image](https://media.github.ibm.com/user/43972/files/37ffa3ee-4705-11e8-89e2-0c2c36321bb7)

7. Click on configure view:

![image](https://media.github.ibm.com/user/43972/files/4e1d23e0-4705-11e8-967c-b2d06a8e6231)

8. Choose your columns and Date range (set same start and end date to show status that date):

![image](https://media.github.ibm.com/user/43972/files/db96e940-4705-11e8-8abe-0cb01d7963ec)

9. Download the report, (recommend PDF for audit because it shows the date and isnt editable):

![image](https://media.github.ibm.com/user/43972/files/01032630-4706-11e8-99c7-2634356d93f3)


These instructions have been provided by the SOS Security team. If the instructions become out of date, it is paramount that this runbook gets re-formatted.


### Escalation Policy

If you are unable to access this data and you already have SOS IDMgt permissions set, escalate the issue to the conductors squad as per their [escalation policy](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada_pagerduty_escalation_policies.html)

Slack Channel: https://ibm-argonauts.slack.com/messages/C54H08JSK (#conductors)

GitHub Issues: https://github.ibm.com/alchemy-conductors/team/issues

