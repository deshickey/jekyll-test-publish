---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Monitor packets per second on worker node interfaces
service: conductors
title: Monitor High PPS on Worker Nodes
runbook-name: "conductors_monitor_packets"
link: /conductors_monitor_packets.html
type: Troubleshooting
failure: ["VSIInterfaceOverloaded", "BareMetalInterfaceOverloaded"]
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

The runbook describes how to proceed to an alert out of monitoring the packets per second (PPS) on each worker node per network interface. VSI has a limitation of 60,000 PPS on virtual interfaces and beyond this the following issues should occur

- Packet loss
- Increase of TCP retries 
- Performance degradation due to large amount of packets on interfaces

## Detailed Information

For VSI, the following monitoring to check if PPS becomes higher than the limitation (60000) and for baremetal, the limitation would go up to 500000.

## Example Alerts

- VSI
```
      rate(node_network_transmit_packets_total{(device=~"eth.*"}[1m]) > 60000 or
      rate(node_network_receive_packets_total{device=~eth.*""}[1m]) > 60000
```

- Baremetal

```
		  rate(node_network_transmit_packets_total{device=~"bond.*"}[1m]) > 500000 or
      rate(node_network_receive_packets_total{device=~"bond.*"}[1m]) > 500000

```
## Investigation and Action

### Troubleshooting 

- Check if any heavy network pods (eg, VIP) are scheduled in the same node
  - Validate if node taint / label has been configured correctly
  - Check if network pods can be rescheduled to lower the PPS
- Check if a carrier / tugboat reaches the maximum capacity. If so, plan for scale up 
- Check if there are any noisy neighbour VSIs 
  - Check metrics of bandwidth / disk IO / CPU / memory consumption 
- Check traffic to public / private endpoints
- If high PPS is observed from edge nodes, open a GHE issue to discuss about converting VSIs to baremetals


### Further investigation

In case general troubleshooting does not provide sufficient information, you can use a few other methods to collect data to investigate further. 

- Identify a worker node(s) which shows high PPS. Then you need to access the node using the following runbook - [https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-run-commands-on-workers.html](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-run-commands-on-workers.html)


#### Bandwidth monitoring

- Install `bwm-ng` using `apt install bwm-ng` to monitor the bandwith

```
bwm-ng v0.6.1 (probing every 0.500s), press 'h' for help
  input: /proc/net/dev type: rate
  -         iface                   Rx                   Tx                Total
  ==============================================================================
             eth1:           0.00 KB/s            0.00 KB/s            0.00 KB/s
             eth2:           0.23 KB/s            0.23 KB/s            0.47 KB/s
               lo:          19.19 KB/s           19.19 KB/s           38.38 KB/s
             eth0:           0.12 KB/s            0.24 KB/s            0.36 KB/s
  ------------------------------------------------------------------------------
            total:          19.54 KB/s           19.66 KB/s           39.20 KB/s
  
```

#### Check network traffic

- Install `iftop` using `apt install iftop`. This tool is to resource usage of network bandwith of active ethernet interfaces. 

- Install `jnettop` using `apt install jnettop`. The tool is to capture traffic coming across the host and can sort by bandwidth usage. 


## Escalation Policy

If the troubleshooting or remediation in the runbook does not resolve the issue, please escalate `#conductors` channel as well as opening a GHE issue [https://github.ibm.com/alchemy-conductors/team/issues](https://github.ibm.com/alchemy-conductors/team/issues).
