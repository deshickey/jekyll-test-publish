---
layout: default
description: Runbook to address issues reported by patch gap check Jenkins job
service: "Infrastructure"
title: Addressing Patching gaps in Alchemy Squads environment
runbook-name: Addressing gaps in our patching.
link: /sre_patch_gap_issues.html
type: Troubleshooting
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

A jenkins job was created to check that;

1.  The phases files in [Smith trigger service GHE] contain references to machines in our devices.csv files
2.  The devices in the [devices csv files] are all referenced by patching strings in the phases files.

This means we should get alerted if 

- new groups of machines are created, but do not match any patching definitions.
- machines are deleted from Softlayer but we still reference them in our patching

## Useful links

- [Patch gap check Jenkins job]
- [Smith trigger service GHE]
- [devices csv files]

## Detailed information


## Example alerts

No alerts will currently be triggered to pagerduty.

The error will be reported in to the [sre-cfs-patching channel] 
It will be the responsibility of the developer tasked with patching to investigate failures.

## Investigation and Action

You'll be reading this runbook as a result of either a failed  execution of [Patch gap check Jenkins job]

### Review the console output

Open and review the console output for the job.  Navigate to the bottom where a summary of issues are reported.

### Investigating the problems

Output will be similar to this.

~~~
********************************************
Checking 531277 production patch coverage
********************************************
SUCCESS: The check against devices.csv and our patch list is reporting no gaps in our patching
SUCCESS: The check of patch lists against the devices.csv shows that appear to be patching valid machine definitions
********************************************
Checking 278445 production patch coverage
********************************************
SUCCESS: The check against devices.csv and our patch list is reporting no gaps in our patching
SUCCESS: The check of patch lists against the devices.csv shows that appear to be patching valid machine definitions
********************************************
Checking stage 531277 patch coverage
********************************************
SUCCESS: The check against devices.csv and our patch list is reporting no gaps in our patching
SUCCESS: The check of patch lists against the devices.csv shows that appear to be patching valid machine definitions
********************************************
Checking dev 659397 patch coverage
********************************************
SUCCESS: The check against devices.csv and our patch list is reporting no gaps in our patching
*********************************************************************************
FAILED: We appear to attempt patching these envs but they are not defined in devices.csv!
*********************************************************************************
dev-mon01-infra-repo
********************************************
Checking prestage 659397 patch coverage
********************************************
SUCCESS: The check against devices.csv and our patch list is reporting no gaps in our patching
SUCCESS: The check of patch lists against the devices.csv shows that appear to be patching valid machine definitions
*********************************************************************************
*********************************************************************************
FAILED: Errors  have been found, review output of this job for full details
*********************************************************************************
*********************************************************************************
~~~

## Fixing problems

### Example 1:

```
********************************************
CRITICAL FAILURE - We appear to be missing patching these envs!
********************************************
prestage-mon01-carrier1-haproxy-01.alchemy.ibm.com
prestage-mon01-carrier1-haproxy-02.alchemy.ibm.com
prestage-mon01-infra-iemrelay-01.alchemy.ibm.com
prestage-mon01-infra-nessus-01.alchemy.ibm.com
```

This error shows that we are not patching a particular environment.
The check has found machines in devices.csv, but has not found a patching string which would mean these machines get patched.

To fix, an update should be made to [Smith trigger service GHE] phases file to include these machines.

Some examples of fixes/ PRs:

- [Fixing prestage patching](https://github.ibm.com/alchemy-conductors/smith-trigger-service/pull/339)
- [Fixing dev patching](https://github.ibm.com/alchemy-conductors/smith-trigger-service/pull/334)
- [Adding prod-mil01-carrier8](https://github.ibm.com/alchemy-conductors/smith-trigger-service/pull/241)

### Example 2:

```
*********************************************************************************
We appear to attempt patching these envs but they are not defined in devices.csv!
*********************************************************************************
dev-mon01-infra-repo
```

This means we have a definition in our phases file, but no machines in our devices.csv files match this string so we need to remove this from the phases file.

To fix, an update should be made to [Smith trigger service GHE] phases fils to remove the definition. 

## Investigating, other, undocumented errors

Reach out to the SRE team in `#conductors` or in `#sre-cfs` for assistance.

## Manually re-running the job

Once you've corrected the problems, you can re-execute the jenkins job if you wish.


## Escalation policy

If you are unsure then raise the problem further with the SRE team.

Discuss the issues seen with the SRE team in `#conductors` or in `#sre-cfs`

There is no formal call out process for this issue.

[Patch gap check Jenkins job]: https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/armada-server-patching-gap-checker/
[Smith trigger service GHE]:https://github.ibm.com/alchemy-conductors/smith-trigger-service
[devices csv files]: https://github.ibm.com/alchemy-netint/network-source/tree/master/softlayer-data
[sre-cfs-patching channel]: https://ibm-argonauts.slack.com/messages/G53A0G8CU
