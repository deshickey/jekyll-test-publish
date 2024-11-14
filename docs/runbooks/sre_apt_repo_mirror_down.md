---
layout: default
description: How to deal with infra-apt-repo-mirror machines going down
service: "Infrastructure"
title: How to deal with infra-apt-repo-mirror machines going down
runbook-name: How to deal with infra-apt-repo-mirror machines going down
link: /sre_apt_repo_mirror_down.html
type: Troubleshooting
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Doc Contribution
nav_order: 2
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook helps SRE team members deal with an apt-repo-mirror machine reporting unreachable/down.

The infra-apt-repo-mirror holds the apt repos we use when we `patch`, `bootstrap` and `deploy` our servers.

This server being down affects a lot of actions so needs to be recovered asap.

## Example alert(s)

- `apt-repo-mirror-down prestage-mon01` 

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

## Escalation Policy

The SRE squad own these servers.  The UK SREs originally set them up. If you're unable to recover an apt-repo-mirror server, then consult the UK SREs.