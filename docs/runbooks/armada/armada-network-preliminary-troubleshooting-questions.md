---
layout: default
title: "Armada - Kubernetes Networking Preliminary Questions"
description: "Armada - Kubernetes Networking Preliminary Questions"
runbook-name: "Armada - Kubernetes Networking Preliminary Questions"
tags: alchemy, armada, armada-network, calico, calicoctl, connect, ping, route, containers, kubernetes, kube, kubectl, network
type: Informational
service: armada
link: /armada/armada-network-preliminary-troubleshooting-questions.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

# Preliminary Troubleshooting Questions

## Overview

Below are generic questions that we ask almost anyone before we start debugging their cluster. If these questions are answered prior to the network team getting paged, looking at a customer ticket or before opening an issue against our team it would be greatly appreciated. We definitely understand not all these questions will be answered, but a good effort to figuring them out is all we are looking for. :smiley:

## Detailed Information - Network Preliminary Debug Questions

- Identify if a Vyatta or any other network appliance (Fortigate, dedicated firewall, etc) is being used by this cluster or Cloud account, and if so, how is it being used (i.e. only for public outbound traffic from workers with no public interface, for public inbound/outbound traffic to/from workers, private traffic between VLANs and/or subnets). Network diagrams are appreciated.
  - Is this vyatta shared with other clusters, and has this vyatta been checked to see if it is healthy and not maxing out its bandwidth during tests
- Have any network policies (Kube and/or Calico) been added or changed in this cluster recently. If so, try removing the non-default policies and see if the problem still occurs
- Identify the specific network issue that is being seen, providing the source and destination of the failing network connection or request. Also provide the known hops along the way (Vyatta, Fortigate, etc). Again, network diagrams are appreciated.
- Provide an easy way to recreate this if possible (a script that does a curl, nc, or ping maybe).
- Explain what troubleshooting has been done to rule out a problem with the app or service that is experiencing this problem
- Was this test/scenario working previously? If so, have you reverted the service and application code to the level it was at when it was working and re-run the test to rule out a bug with recent changes to the service or app
