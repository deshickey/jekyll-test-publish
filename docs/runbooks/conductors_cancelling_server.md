---
layout: default
title: How to remove a server
type: Informational
runbook-name: "How to remove a server"
description: "List of steps to take for removing a server"
service: Infrastructure
playbooks: [<NoPlayBooksSpecified>]
link: /conductors_cancelling_server.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook details list of necessary steps to take before removing/cancelling a server. This do NOT apply to tugboat workers.

Removing resources required approval. If GHE issue is not raised for server being removed, raise an issue in [team](https://github.ibm.com/alchemy-conductors/team/issues) repository and get approval from a lead.

**NOTE:** As we are removing servers, we need to follow every step with extreme care.

## Detailed Information

Before removing/cancelling any server make sure the server is ready to be stopped (shut down). Based on type of server following checks needs to be carried out.

- [Legacy carrier worker](#legacy-carrier-worker)
- [Infra server](#infra-server)

Once above checks are performed, rename the device and append `-cancel` to name.

1. Login to [Cloud UI](https://cloud.ibm.com/gen1/infrastructure/devices) and search server by name or IP.
1. Once server is located on the list, look for hamburger icon on the right side in the list.
1. Click the hamburger icon and press `Rename`.
1. Append `-cancel` to name and press `Rename` button.

We need to wait for some time for automation to reflect this change in our inventory. To be safe, wait at least a day before actually cancelling the device. To cancel device:

1. Login to [Cloud UI](https://cloud.ibm.com/gen1/infrastructure/devices) and search server by name or IP.
1. Click on the server name to go to details.
1. Click on `Actions` button and press `Cancel device`.

The device will go under `Reclaiming` state and will be removed from account after few hours.

### Legacy carrier worker

Make sure worker is cordoned, drained and removed from carrier.
```
$ kubectl delete node 10.73.111.179
node "10.73.111.179" deleted
$ kubectl get node 10.73.111.179
Error from server (NotFound): nodes "10.73.111.179" not found
```

### Infra server

If it is one of the infra server like sensu, qradar, haproxy or vpn, we need to make sure we remove alerts from [sensu-uptime](https://github.ibm.com/alchemy-conductors/sensu-uptime) to avoid false positive alerts.

## Escalation Policy

If you have any doubt on any step in this runbook consult other conductors in `#conductors-for-life` slack channel.
