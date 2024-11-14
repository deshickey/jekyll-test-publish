---
layout: default
title: How to handle IKS Cloud freezes.
type: Informational
runbook-name: "How to handle IKS Cloud freezes"
description: "IBM Cloud freezes are a normal periodic occurrance.  All SRE need to be able to properly handle various duties to ensure proper adherence to IBM policies."
service: Conductors
link: /sre_handle_freeze.html
parent: Armada Runbooks

---

Informational
{: .label }

# How to handle IBM IKS Cloud freezes.  

## Overview

This document details how to handle issues during an IBM Cloud freeze.  



## Detailed information

This runbook will guide IKS SRE on the proper handling of the day to day operations during an IBM Cloud Freeze.  The link  https://ibm.biz/cloud_public_freeze_window details the freeze dates for the current year.  It also discusses various concepts such as Hard and Soft freezes.  The important thing to keep in mind is the following: 

A hard freeze means that all code releases and maintenance activities will be halted for the specified period.  Only emergency fixes are allowed during this time and only Ralph Bateman can approve any exceptions. 

A soft freeze means that all non-disruptive or high risk maintenance actvities will be halted.  The product teams should be aware of the differences, but SRE should treet every prod-train as potentially harmful and question the submission about potential effects and side effects.  If there are doubts reach out to your team lead. 

Typically the following activites are excempted:  Vulnerability fixes (+ smith patching), va-reloads, netint HA proxy, firewall, monitoring, and (OPS) operations.  These are activities that are necessary for the stability of the service.


## Stopping the Trains

Trains are usually stopped by Ralph Bateman at the start time of the freeze.  The command 'stop trains all <Message> <regions>' will instruct Fat Controller to display the message and list the regions that are stopped.  Fat Controller will no longer autoapprove trains for the listed regions.  It will also remind the submitter of the freezes.



## Re-starting the Trains 

The command 'start trains' will restart the trains for the regions and remove the messaging posted.

Traditionally IKS SRE do not approve changes on Friday afternoons.  In the event of a freeze ending on Thursdays, Fridays, or Saturdays IKS SRE will choose to extend the freeze to the following Monday morning 12am.  This is to preserve the stability of the service during the Weekend shift when we are on minimal staffing.  


##  Possible Issues

Usually, the issues that come up are due to emergency fixes.  Always get Ralph, Colin or Trey involved when these come up.  Only they can approve any exceptions. 

If you cannot get a hold of them, contact your Team Lead.  Do not be pressured to approve a train during a freeze, always cite that you will have to get additional approvals.



## Escalation Policy

There is no formal escalation policy.

This is an SRE owned process so should be raised and discussed in either

- `#conductors` if you are not a member of the SRE Squad.
- `#sre-cfs`, `#conductors-for-life` if you are a member of the SRE squad (these are internal private channels)

If you have any concerns, please raise them with your SRE Leads.
