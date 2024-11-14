---
layout: default
description: How to deal with Infrastructure machines not responding
service: "Infrastructure"
title: How to deal with Infrastructure machines not responding
runbook-name: How to deal with Infrastructure machines not responding
link: /infra-keep_alive_check.html
type: Troubleshooting
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

This runbook helps SRE team members deal with an Infrastructure machine reporting unreachable/down.

## Example alert

- [Infra System(s) down in Dev](https://ibm.pagerduty.com/incidents/Q0GI4NX8J5XL3T)
  
### How to get the Infrastructure machine name from Pager Duty Alert
- Get `instance` value from `Segment` section in the alert <br> 
  - Example: <br> 
        `instance = 10.141.38.9`  <br> 
        Use `netmax` bot to get the name of Infrastructure machine for given IP address `10.141.38.9`. In this example it is `dev-mon01-infra-vpn-12`. <br>
        OR <br>
        Search in [NetInt-source-file](https://github.ibm.com/alchemy-netint/network-source/tree/master/softlayer-data). <br>
    <img src="../runbooks/images/infra-system-down-alert.png" alt="Sysdig-Alert-Segment-Details" style="width: 100%;"/>
  
## Investigation and Action

### Investigate machine state

Go through these series of checks to determine what actions to take next.

- Can you ping the server?

- Can you ssh to the server?

- Check the machine in the IBM Cloud Classic Infrastructure portal
  - Is it powered on and connected?
  - Does it have a transaction running against it - (a clock icon indicating an IaaS transaction is in progress)

- If the machine is unreachable via SSH/ping, then try a hard reboot
  - If a hard reboot doesn't work, then try a power-off / power-on

If reboot cycles/power off/on doesn't work then raise a support case against the server.  Raise it as severity 1 as these servers are key infrastructure servers as they host the `apt` repositories we uses when bootstrapping, patching and deploying servers.

### If a machine is dead

If you and/or IaaS support are unable to get the server back online, then follow the guidance in this runbook to [osreload the infra-apt-repo-mirror server](./reloading_apt_repo_mirror_server.html)

### Read only filesystem?

If the server is reporting a read only filesystem after it is recovered, then use this [runbook to correct](./recover_read_only_fs.html)

## False Positive alert
If PagerDuty Alert is still open after verifying that Infrastructure machine is up and running, refer to [Sysdig Monitoring On Support Act runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sysdig-suptacct-debug.html) for further debugging steps.

  ## Escalation Policy

The SRE squad own these servers.  The UK SREs originally set them up. If you're unable to recover an apt-repo-mirror server, then consult the UK SREs.
