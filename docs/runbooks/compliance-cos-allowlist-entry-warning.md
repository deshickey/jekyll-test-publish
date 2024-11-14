---
layout: default
description: COS CBR/Allowlist entry warning
service: Security
title: COS CBR/Allowlist automation
runbook-name: "COS CBR/Allowlist entry warning"
link: /compliance-cos-allowlist-entry-warning.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# COS CBR/Allowlist automation

## Overview

This runbook shows IKS SRE how to address `COS Allowlist Entry Warning` PagerDuty incidents.

## Detailed Information

This section covers some background information on the COS allowlist entry warning, please feel free to skip straight to the [Actions required](#actions-required) section to address PagerDuty incidents.

### Background

Cloud Object Storage (COS) resources allow you to implement allowlists to restrict access to each bucket. Each bucket is limited to `1000` allowlist entries.

If the COS allowlist automation generates an allowlist that is greater than 1000 entires it will fail to apply the updated allowlist and the Jenkins job will fail. This has the potential to cause outages and possibly trigger a CIE. This alert attempts to prevent this situation occurring by triggering `[WARNING]` alerts once the allowlist entries exceed 80% of the total allowlist entry limit. 


#### More information

If you want more information of why this allowlisting automation exists and how it works, please refer to the background section of the [compliance-update-cos-allowlists](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/compliance-update-cos-allowlists.html#background) runbook.


### Actions required


1. From the PagerDuty incident title, please take note of the `Region` and `account`. [Example Alert](#cos-example-alert)
1. Clone the [cbr](https://github.ibm.com/alchemy-conductors/cbr) repository.
1. Open Jenkinsfile.COS
1. In the `triggers { parameterizedCron(` section of the Jenkinsfile, comment out any crons that contain this region and account, by typing `#` before cron: `# H 8 * * * % Account=`.
    - TIP: use `command/ctrl + f` to search for `Account={Account}; Region={Region}` to narrow down the results quickly.
1. Save the changes
1. Create a new branch with the name `cos-allowlist-entry-warning-{PD Alert ID}`
1. Push changes to the new branch
1. Create a PR with the following information:
    - Title: Disabling COS cronjob for {Region} region, in account {Account}.
    - Reference GHE Issue or Issue Description: PD: `pagerduty link`
    - Description of change: Commenting out the following scheduled jobs: `Copy and paste in the lines being commented out`
    - Testing that was done: N/A
1. Request that the PR is reviewed and merged to master to prevent further scheduled jobs from running.
1. Notify IKS EU SRE team


#### COS Example Alert

In this example, there is an issue with a COS instance in the `au-syd` region, in account `531277`. Link to PD alert:

https://ibm.pagerduty.com/incidents/Q2KKQPOHEWS53Q

Alert:

<img src="allowlist-entry-warning-alert-cos.png" alt="ICD Allowlist Entry Warning PD Alert" width="800">

Alert Details:

<img src="allowlist-entry-warning-alert-details-cos.png" alt="ICD Allowlist Entry Warning PD Alert Details" width="800"> 

Based on the details in this alert we can determine that we need to disable any COS cronjobs for instances in the `au-syd` region, in account `531277`such as: 

`H 14 * * * % Account=argonauts-production-531277; Region=au-syd; Delete=false; Dryrun=false`

Commenting out this entry:

```Groovy
triggers {
        parameterizedCron('''
             ####-- Argonauts Production --####

            #### ca-tor 531277 ####
            H 8 * * * % Account=argonauts-production-531277; Region=ca-tor; Delete=false; Dryrun=false

            #### jp-tok 531277 ####
            H 09 * * * % Account=argonauts-production-531277; Region=jp-tok; Delete=false; Dryrun=false

            #### us-east 531277 ####
            H 10 * * * % Account=argonauts-production-531277; Region=us-east; Delete=false; Dryrun=false

            #### us-south 531277 ####
            H 11 * * * % Account=argonauts-production-531277; Region=us-south; Delete=false; Dryrun=false

            #### jp-osa 531277 ####
            H 12 * * * % Account=argonauts-production-531277; Region=jp-osa; Delete=false; Dryrun=false

            #### global 531277 ####
            H 13 * * * % Account=argonauts-production-531277; Region=global; Delete=false; Dryrun=false

            #### au-syd 531277 ####
            # H 14 * * * % Account=argonauts-production-531277; Region=au-syd; Delete=false; Dryrun=false

        ''')
    }

```

## Escalation Policy

1. Raise a team GitHub issue: [ICD or COS allowlist update](https://github.ibm.com/alchemy-conductors/team/issues/new?assignees=&labels=&template=icd_cos_allowlist.md&title=) to track.
1. Add any relevant information including a links to the PR created and PD alert.
1. Notify in [#iks_cos_allowlist](https://ibm-argonauts.slack.com/archives/C02PZ56C5AL) slack channel with GHE issue raised.
