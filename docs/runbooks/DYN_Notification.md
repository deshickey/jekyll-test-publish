---
playbooks: [ "" ]
layout: default
title: Issue - Dyn DNS Notifications
type: Informational
runbook-name: "Issue - Dyn DNS Notifications"
description: Issue - Dyn DNS Notifications
link: placeholder.html
service: "Containers APIs DNS"
parent: Armada Runbooks

---

Informational
{: .label }

There are now 3 classes of alerts automatically raised by Dyn DNS provider.

* Alchemy - Containers DYN Notifications
* Alchemy Registry DYN notifications
* Alchemy - Containers Kube DYN Notifications

These are triggered when something changes in DYN Traffic Director, this could be a manual configuration change (you should resolve)
or a change in the returned IP addresses (termed response pool) driven by the monitor which is polling the public endpoints for the service.

At this time the PD configuration is simple and will raise a new alert for each notification, if the content indicates 
down status and does not self clear (that means raise another alert within minutes with up status) then it should be escalated to the squad responsible. 
Note that the alerts might be triggered change of only 1 endpoint / ip address or all the endpoints in the service it is necessary to interpret the content of the notification. It should be possible to add more filtering to the PD service in time.
It is likely that sensu endpoint checks will be alerted at the same time as further confirmation that the service is down.


Escalations:
* Container API Squad for "Containers" notifications
* Registry Squad for Registry notifications (but please try to filter out the daily/weekly reboot if possible)
* for "Kube" i.e. Armada, the Registry Squad are temporarily covering this (IC17 week) however NetInt squad will be picking this up and Armada API Squad may also be able to help.

