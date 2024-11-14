---
layout: default
title: Softlayer Emergency Evacuatiion and Host Outage Notification
type: Informational
runbook-name: "Softlayer Emergency Evacuatiion and Host Outage Notification"
description: Information about how to handle Softlayer Emergency Evacuatiion and Host Outage Notification
category: armada
service: sre_operations
link: /softlayer_emergency_evacuation.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook describes the steps on how to handle Softlayer Emergency Evacuatiion and VSI/Cloud Host Outage Notifications.

Softlayer will be evacuating the VSI to new host when there is issue in the device. It is recommended us to take actions to minimize the impact of the outage before (or during) the actual evacuation. It includes cordoning and draining the nodes to prevent service disruption which can cause CIE.
The most common symptom during the evacuation is that we will get multiple Pagerduty alerts such as pod or service down on the worker node. 

## Notification

The notification will be sent to interrupt via #sre-cfs channel or Pagerduty alert. 
- Emergency VSI Host Evacuation
- VSI Host Outage Notification
- Cloud Host Outage Notification

The original notification is sent from the following sources.
`Examples)`
- SoftLayer ticket: https://internal.softlayer.com/Ticket/ticketEdit/153224448
- IBM Cloud support case: https://cloud.ibm.com/unifiedsupport/cases?accountId=e223e119c9be31669e5688bb376411f7&number=CS3312828

## Detailed Information

The following sections contain detailed information.

## Investigation and Action

Based on the notification sent to the interrupt, find the original notification and gather the information.
1. Find out the devices affected
2. If it is before or during the evacuation, it is recommended to cordon/drain the worker node. (with the delay of the notificatiion, if the evacuation already completed, no action required.)
3. After the evacuation completes (by checking status in the ['Softlayer ticket'](https://internal.softlayer.com/Ticket/ticketEdit/153224448) or ['IBM Cloud support ticket'](https://cloud.ibm.com/unifiedsupport/cases?accountId=e223e119c9be31669e5688bb376411f7&number=CS3312828) or ['Device details page of the node'](https://cloud.ibm.com/gen1/infrastructure/virtual-server/61576031/details#main)), uncordon the worker node.


## Reference

- IBM Cloud support tickets: https://cloud.ibm.com/unifiedsupport/cases
- Softlayer tickets: https://internal.softlayer.com/Ticket/

## Escalation

For escalation, please communicate with the Softlayer team through the original tickets above.
