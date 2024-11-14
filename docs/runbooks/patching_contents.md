---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: About the patching process
service: Conductors
title: Patching process contents page
runbook-name: "Conductors: Patching process documentation contents"
link: /patching_contents.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Index of patching process related runbooks

## Detailed Information

The patching process has many components and runbooks covering different aspects of it.  
This document provides an index to the important documents to assist SRE members performing patching of Argonauts machines.

## Detailed Procedure

[Patching process runbook](./patch_process_runbook.html) - This documents high level details of the patching process.

### Patching procedure steps

The process is covered by the above patching process runbook, linked above.

These are the steps to follow, with details instructions how to perform patching safely across all IKS environments.

1. **Main patching process**  
Follow the [patching procedure](./patching_rollout_procedure.html) runbook to roll out new patches safely across the servers in the IKS accounts.
2. **HAPROXYs**  
_NB note that HAPPROXYs are specifically mentioned in the **procedure** runbook now!_

### Common SRE operations

1. [How to patch a machine to the latest production ready level of packages](./sre_patching.html) - this assists SREs re-applying `prod` level patches to a single or set of machines.

### Other requests /  Operations

- [Reloading an infra-apt-repo-mirror](./reloading_apt_repo_mirror_server.html) - If an `infra-apt-repo-mirror` machine breaks, and needs osreloading, this is how to do it.

- [Machines reporting overdue in SOS](./sre_handling_overdue_patches.html) - dealing with team GHE issues reporting patches overdue.

