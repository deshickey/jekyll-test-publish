---
layout: default
title: Patch Management Evidence for IDR Request
type: Informational
runbook-name: "Patch Process Runbook of Type 'Informational'."
description: "This runbook explains the process for gathering information for IDR audit requests relating to patch management."
service: Conductors
link: /doc_updates/patching_evidence_idr_request.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview/Purpose of Runbook

This runbook explains the process for gathering information for IDR audit requests relating to patch management of ALC machines.

## Introduction

As part of Audit requests, we may need to supply supporting evidence relating to patching of ALC workers and non-worker nodes.

The goal is to demonstrate that changes relating to patching are controlled via change management.

The Compliance team will open a Conductors team issue with the requested details, and SRE will attach the information to that GHE.

### Example request

Conductors team issue [17705](https://github.ibm.com/alchemy-conductors/team/issues/17705) shows a typical SOC2 Evidence request:

> Data Request:
>
> Command on Server testing is a Change Management testing procedure completed to gain comfort that the change ticketing tool (i.e. Service Now) includes all changes made in the environment. An implemented change on a device is evidenced through querying a change on the device in terminal, tracing that change to a particular change management ticket, and lastly ensuring that change shows up on the change management population provided by the service offering team.
>
> For the selected system(s), please provide screenshot evidence showing the most recently installed change (i.e. patch, password rotation, etc) with installation dates included (e.g. obtained via Command such as `rpm qa --last |head`). Please ensure that the server name or IP address is included in the evidence. [*Alternatively, please schedule a web meeting where PwC can observe the list of recently installed changes]
>
> Please provide the change ticket associated with the most recently installed change from the above listing. The change ticket evidence should include any attachments that list included patches or affected devices.
>
> **NOTE: ANY SCREENSHOTS PROVIDED MUST CONTAIN A DATESTAMP OR THE REQUEST WILL BE RETURNED**


## Detailed Information

### Types of ALC systems

Relating to gathering evidence for patching, there are 2 types of ALC nodes:

1. Non-worker nodes - infra, master, bastion, syslog, haproxy etc
   1. These are patched and rebooted via the Smith patching system, and are not typically OS-reloaded.
1. Carrier worker nodes
   1. These are patched and rebooted via the Smith patching system.
   1. These are also routinely and regularly OS-reloaded, either by operators or via automation.

For the operations in _2.ii_ above, a new IaaS OS image is regularly built, containing the latest Smith prod-level of patches, so that nodes which are reloaded will be compliant with respect to patches. This image is referred to as the "immutable image" or "worker image".

## Steps to Gather Evidence for non-worker nodes

These are the steps to gather evidence for non-worker nodes, and also for worker nodes which were most recently changed by a patch.

_This example uses `prod-lon02-infra-nessus-03` as the example hostname from an IDR request._

1. Log into the particular node.
   - Run this command and take a screenshot of the output: `cat /opt/smith-agent.log`. If the file is large, multiple screenshots may be necessary.
   - Take note of the line which includes `Build=` (this will either be a number `Build=1351`, or `Build=prod`) and the timestamp.
     - The number `1351` is the smith build number.
     - OR if it `prod`, then it is the current _prod-level_ smith and we will have to determine the actual build number.
1. If the build is `prod` (the logfile has `Build=prod`), then review the [smith-prod-symlink](https://github.ibm.com/alchemy-conductors/team/tree/master/train_evidence/smith-prod-symlink) evidence repo, and find the file `smith-prod-symlink-NNNN-evidence.txt` which was created prior to the timestamp in the logfile
   - It will probably be the most recent comment
   - In this example, it is <https://github.ibm.com/alchemy-conductors/team/blob/master/train_evidence/smith-prod-symlink/smith-prod-symlink-1351-evidence.txt>
   - That number `1351` is the smith build number
   - Take note of the prod symlink evidence file URL. Note that changing of the prod symlink requires trains, and they are included in the evidence file.
1. Taking note of the build number (e.g. `Build=1351`), then open <https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues> and search for the hostname `prod-lon02-infra-nessus-03`
      - In the search results, look for the most recent issue with title `BUILD #1351 ...` and verify that the hostname appears in the body of that issue
      - In this example, it is <https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues/9007>
1. Take note of the the corresponding `CHG..` request for the patching of the requested hostname.
   - The `CHG..` requests are towards the top of the issue, and are organised by region (`us-south`, `uk-south` etc)
   - In this case for issue 9007 it is the comment:
     ```
     Waiting for approval of CHG4479999 region: uk-south for step
     ```
   - So the change request is `CHG4479999`
1. Go to the ServiceNow `CHG..` entry ([CHG4479999](https://watson.service-now.com/nav_to.do?uri=%2Fchange_request.do%3Fsysparm_query%3Dnumber%253dCHG4479999%26sysparm_view%3Ddefault%26sysparm_view_forced%3Dtrue) in this example) and find the `CTASK..` entry which includes the particular node ([CTASK3916327](https://watson.service-now.com/nav_to.do?uri=%2Fchange_task.do%3Fsys_id%3D19488b431b7591107c4d7445cc4bcb88%26sysparm_view%3Ddefault%26sysparm_record_target%3Dchange_task%26sysparm_record_row%3D5%26sysparm_record_rows%3D6%26sysparm_record_list%3Dchange_request%253D8687c78f1b3591107c4d7445cc4bcb9f%255Ecmdb_ci.u_tribe.u_segment.u_type%253Dcloud%255EORDERBYnumber) in this example), and take note of the timestamp of when it was patched.
   - In this case:
     ```json
     {"machinename":"prod-lon02-infra-nessus-03","patchstatus":"complete","statusstring":"2022-09-13T05:18:03Z [complete] Completed successfully"}
     ```
   - Take a screenshot of the ServiceNow page.
1. In the <https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues> repo, search for the `Epic` issue with smith build number in the title:
   ```
   BUILD #1351 : Tracking Patching for Worldwide Rollout
   ```
   - In this example, it is <https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues/8991>
1. Verify that the GHE has a comment with the file attached `1351-ubuntu-18-packageList.txt`
   - In this example, it is <https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues/8991#issuecomment-48073672>
   - Take note of the comment URL

### Evidence for the IDR

Attach these to Conductors team issue:

1. The screenshot(s) of the output of `cat /opt/smith-agent.log`
1. The patch Change Request and Change Task numbers (e.g. CHG4479999 and CTASK3916327)
1. The screenshot of the CTASK screen from ServiceNow.
1. The link to the Smith patching Epic comment found above, which contains the package list (e.g. <https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues/8991#issuecomment-48073672>)
1. If the `/opt/smith-agent.log` file showed `Build=prod`, then include the URL of the relevant `prod` evidence file (e.g. <https://github.ibm.com/alchemy-conductors/team/blob/master/train_evidence/smith-prod-symlink/smith-prod-symlink-1351-evidence.txt>)


## Steps to Gather Evidence for worker nodes

Worker nodes may have been most recently changed via patching, or via OS-reload.

### Determine the most recent patch-related change type

Firstly determine what was the most recent change:

1. Log into the particular node.
   - Run this command and take a screenshot of the output: `ls -ltr /opt/*.log`
1. Take note of the relative timestamps of the `smith-agent.log` and `immutable_image.log` files
   1. IF the timestamps are roughly the same (within an hour or so), THEN the node was last changed by an OS-reload operation, and proceed **below** to [gather evidence for worker OS-reloads](#gather-the-evidence-for-worker-os-reloads)
   1. ELSE if the timestamps are different then the node was last changed by patching, and proceed per the [non-worker instructions above](#steps-to-gather-evidence-for-non-worker-nodes) instructions **above**

### Gather the evidence for worker OS-reloads

_This example uses `prod-syd04-carrier2-worker-45` as the example hostname from an IDR request._

1. Log into the particular node.
   - Run this command and take a screenshot of the output: `cat /var/log/apt/history.log`. If the file is large, multiple screenshots may be necessary.
1. There will be 2 sets of timestamps of note:
   - The most recent timestamps will be on the date of the OS-reload
   - The previous timestamps will be on the date of the building of the OS image (aka "immutable image" or "worker image")
1. Run this command and take a screenshot of the output: `cat /opt/bootstrap.lastrun.summary.json`
   - In particular, take note of the number in this line:
     ```
     SOFTLAYER_IMAGE_TEMPLATE_ID": "12556958"
     ```
   - That number `12556958` is the image ID of the immutable image in SoftLayer.
   - Also note the `DATE` and `TIME` entries.
1. Search in the [bot-chlorine-logging](https://ibm-argonauts.slack.com/archives/CDG1R2D5Y) Slack channel for the hostname, and find the most recent `Processing OS reload for node` entry for the node
   - The OS reload may have been initiated by an Operator, or by automation (`carrier autorecovery`)
   - Take note of the `CHG..` request of the reload operation.
   - In this example it is `CHG4419833`
   - The timestamp should match up with the DATE/TIME entries from the `/opt/bootstrap.lastrun.summary.json` file.
1. Search for the image ID in https://github.ibm.com/alchemy-conductors/team/tree/master/train_evidence/smith-immutable-image to find the corresponding "immutable image" aka "worker image"
   - In this case: https://github.ibm.com/alchemy-conductors/team/blob/master/train_evidence/smith-immutable-image/immutableimage_707-1350-1170-20220901-prod_evidence.md#L7
   - Take note of the evidence file URL
1. The evidence filename tells you the smith build: the image variation name `707-1350-1170-20220901` is comprised of:
   - `707` = build number from the image build job https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/oceanPI/job/immutable_image/707/
   - `1350` = smith build number
   - `1170` = bootstrap-one-server build number
   - `20220901` = the image build date
1. Take note of the smith build number, e.g. `1350`
1. In the <https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues> repo, search for the `Epic` issue with smith build number in the title:
   ```
   BUILD #1350 : Tracking Patching for Worldwide Rollout
   ```
   - In this example, it is <https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues/8954>
1. Verify that the GHE has a comment with the file attached `1350-ubuntu-18-packageList.txt`
   - In this example, it is <https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues/8954#issuecomment-47879184>
   - Take note of the comment URL

### Evidence for the IDR

Attach these to Conductors team issue:

1. The screenshot(s) of the output of `cat /var/log/apt/history.log`
1. The screenshot of the output of `cat /opt/bootstrap.lastrun.summary.json`
1. The reload Change Request number (e.g. `CHG4419833`)
1. The Smith Immutable Image evidence file URL, (e.g. <https://github.ibm.com/alchemy-conductors/team/blob/master/train_evidence/smith-immutable-image/immutableimage_707-1350-1170-20220901-prod_evidence.md>)
1. A link to the Smith patching Epic comment found above, which contains the package list (e.g. <https://github.ibm.com/alchemy-conductors/smith-trigger-service/issues/8954#issuecomment-47879184>)
