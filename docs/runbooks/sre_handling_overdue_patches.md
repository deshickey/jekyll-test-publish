---
layout: default
title: How to address SOS reporting machines overdue on patching
type: Informational
runbook-name: "How to address SOS reporting machines overdue on patching"
description: "How to address SOS reporting machines overdue on patching"
service: Conductors
link: /sre_handling_overdue_patches.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document details how to address machines reporting as overdue on patching.

You'll be reading this if you have either of, a team GHE raised by:
- the **IKS Security Squad**, eg. [team 6947](https://github.ibm.com/alchemy-conductors/team/issues/6947)
- an **automated check**, eg. [team 7453](https://github.ibm.com/alchemy-conductors/team/issues/7453)

## Useful links

- [patch process runbook]  
should be consulted for end to end process of patching or speak to a member of the UK or India SRE Squad.
- [compliance-bigfix-overdue-patches](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Security-Compliance/job/compliance-bigfix-overdue-patches/)  
is one source of an alert, i.e. jenkins job which runs daily to check SOS data for overdue patches.
- The [SOS Compliance Portal]

## Detailed information

This runbook will guide you through getting the machines patched and then reporting correctly.

Reporting of our patch state can be viewed in the [SOS Compliance Portal]  
_The data there is gathered from every machine we own and relies on the Bigfix (IEM) agent running on each machine and sending data back up to SOS._

### Reviewing the contents of the GHE and performing initial investigation

Patching usually starts being reported overdue for one, or more, of the following reasons:

- A set of machines has been missed by the regular patching process as described by in the [patch process runbook]  
**If you suspect this, please raise the issue with the UK SREs so we can review.**

- A new set of machines has been ordered but the person performing the order has not rebooted them to apply the new patches/kernels  
**You can usually see this from recent team ticket activity or by querying the machine(s) in IaaS to see their creation date.**

- A machine has been osreloaded, but failed to complete the reload successfully and patching/reboots have no occurred.  
**Search for the machine in `#bot-igorina-logging`**

- In some rare cases, we were experiencing reporting issues in bigfix, for example [GHE 5451](https://github.ibm.com/alchemy-conductors/team/issues/5451), however this appears to have been addressed  
_such issues have not be seen since March 2020_

#### Regardless of the reason, we need to get this addressed immediately.

Follow these steps to get an idea of what servers are currently reporting overdue so we can ensure that the current list in GHE matches what SOS is reporting.

1. Log into the [SOS Compliance Portal]  
_the link should automatically target the **C_CODE** `ALC`_

2. Sort by `Next patch due`  
_NB: Pay attention to Bigfix last report date/time - if this is not within the last 24 hours then the issue could be else where - i.e a problem with the bigfix agent running on the server.  If thats the case, reboot the server!_

3. Review the nodes reporting overdue and compare to the GHE raised.
   - Ignore any `compose` and `vyatta` servers  
   _we are not responsible for them_
   - All other servers regardless of whether they are dev, prod, etc. servers, should never go overdue.
  
4. Address the overdue machines as per the steps below.
 
### Addressing the overdue patching

To address the over due patches, do the following.

1. Re-submit a `prod` patch request against all of the servers reporting as overdue  
_follow the guidance in the [sre patching runbook](./sre_patching.html)_

2. Once patching is complete, issue reboots for these servers via **`igorina`**, for example:  
`reboot <machine1> <machine2> <machine3> <machine...> checkrequired outage:0`

   - Update the GHE with results of each step - i.e. `smith-status` output and igorina `reboot` output.
   - Add `compliance` and `overdue` labels to the GHE  
   _Adding these labels will help with reviews of why these have gone overdue._
   - Close out the GHE when all machines have been processed.  
   There is several hours of lag between actual machine status and what is reported via the [SOS Compliance Portal]  
   _... so don't expect results to change quickly!_

## Escalation Policy

There is no formal escalation policy.

This is an SRE owned process so should be raised and discussed in either

- `#conductors` if you are not a member of the SRE Squad.
- `#sre-cfs`, `#conductors-for-life` or `#sre-cfs-patching` if you are a member of the SRE squad (these are internal private channels)

If you have any concerns, please raise them with Paul Cullen.

[patch process runbook]: https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/patch_process_runbook.html
[SOS Compliance Portal]: https://w3.sos.ibm.com/inventory.nsf/compliance_portal.xsp?c_code=alc
