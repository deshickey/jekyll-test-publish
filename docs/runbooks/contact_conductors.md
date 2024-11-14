---
layout: default
description: Information how to contact conductors
service: Conductors
title: Contacting conductors
runbook-name: "contacting conductors"
tags: conductors support
playbooks: ["Runbook needs to be Updated with playbooks info (if applicable)"]
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
link: /contact_conductors.html
type: Informational\
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document details how to contact the IBM Containers SRE squad.

## Detailed information

The following sections describe the ways to engage with the IBM Containers SRE squad.

## Creating issues

Alchemy conductors are using Github issues to keep track of our work items.

Navigate to [our Github Repository](https://github.ibm.com/alchemy-conductors/team/issues/new) and manually create a new issue.

## Out of hours support

Out of hours support is currently: 23:00 Friday -> 23:00 Sunday UTC

During out of hours support, we only monitor production environments. We will not always be monitoring slack, so if you require our help for a production issue you can page out out with the instructions below, otherwise wait until 23:00 Sunday UTC, where the Australian conductors start their normal coverage again.

## Paging us out

In the case of a production outage over the weekend, and conductors aren't aware/responding in slack you are able to page us out on PagerDuty.

Please follow the details in the [Closed Loop mechanism runbook](./../runbooks/clm-incidents.html)

## Global coverage

During the week, 23:00 Sunday -> 23:00 Friday UTC we are avalible 24/7 for all environments.

If you need to talk to a conductor, you can ask in our slack channel #conductors.
Alternativly if there's no awnser you can use the command @interrupt to find out who is currently on their shift, and send them a direct message.

The shifts (in UTC) are currently:

23:00 -> 05:00 UTC: Australia
05:00 -> 11:00 UTC: India
11:00 -> 17:00 UTC: Europe 
17:00 -> 23:00 UTC: North America

## IBM Cloud CIE's

You can see if there's any known IBM Cloud issues [here](http://ibm.biz/bluemixstatus)

You can check in the [{{site.data.cie.containers.comm.name}}]({{site.data.cie.containers.comm.link}}) slack channel for status or further information on the CIE.
