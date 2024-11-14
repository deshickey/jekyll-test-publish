---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: "How to get access to LaunchDarkly"
type: Operations
runbook-name: "How to request and grant access to LaunchDarkly"
description: "How to request access to LaunchDarkly and how to grant access"
service: cluster-updater
tags: razee, armada, launchdarkly
link: launchdarkly-access.html
failure: ""
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Use this runbook to request access to LaunchDarkly.

For SREs: Use this runbook to grant access to LaunchDarkly.

## Detailed Information

The first time you access LaunchDarkly use the link [https://ibm.biz/armada-ld](https://ibm.biz/armada-ld) which will create your user in LaunchDarkly.

If `writer` access is required an admin in LaunchDarkly must then change your default role from `reader` to `writer`.

## Detailed Procedure

### Requesting access

1. Go to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome).
1. Search for **IBM Kubernetes Service (IKS) Access** in the **Applications** search box.
1. Verify that under the value of the Dynamic Attribute as GitHub Username your GitHub user shows up.
1. Click **Add**.
1. Find the group `ROLE_LaunchDarkly_IKS-Writer_member`
1. Click **Select** on the above.
1. Click on **Done** at the bottom of the page.
1. Click **Review & Submit**
1. Enter a **business justification**.
   _This should detail the `squad` you are in, the `region` you are in (important for EU confirmation), and the reason you need access to each `group and role`._
1. Confirm your details and **Tick** the box.
1. Click **Submit**


- Once the access above is complete, you will be added to the following BlueGroup [containers-launchdarkly](https://w3-03.ibm.com/tools/groups/protect/groupsgui.wss?task=ViewGroup&gName=containers%2Dlaunchdarkly&showlist=true).
- Confirm that you are present in the above list.


### First time access

- The first time you access LaunchDarkly use the link [https://ibm.biz/armada-ld](https://ibm.biz/armada-ld) which will create your user in LaunchDarkly.


### Create a github issue

- In [Team Issues](https://github.ibm.com/alchemy-conductors/team/issues) create a new issue.
- Title: LaunchDarkly Writer Role `<NAME>`
- Content: I have completed the appropriate accesshub request. I need my role in launchdarkly changed to `Writer`
- Assign the issue to Colin Thorne.



### LaunchDarkly Admin: Changing role to writer

- Find the team member in LaunchDarkly [`Account Settings -> Team`](https://app.launchdarkly.com/settings/team).
- `Edit` the user and change Role to `Writer`.
