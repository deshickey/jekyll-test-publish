---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: 'Troubleshooting IBM Cloud Object Storage for Satellite config'
type: Informational
runbook-name: 'Satellite Config COS problems'
description: 'The IBM Cloud Object Storage service is not functioning properly.'
service: Satellite Config
tags: satellite-config
link: /satellite-config/satellite-config-cos-problems.html
failure: ''
grand_parent: Armada Runbooks
parent: Satellite Config
---

Informational
{: .label }

---

## Overview

This alert fires when there are errors completing the daily backup of the Satellite Config Cloud Object Storage buckets. This can not cause a CIE, but should be addressed in a timely manner. Information about IBM Cloud Object Storage can be found at [(COS)](https://cloud.ibm.com/catalog/services/cloud-object-storage). COS must be accessible and healthy for these services to function.

Satellite Config/COS reference table. Note all resources are in account 2094928 - Satellite Production.
| Region      | COS Instance  | Config Bucket | Resources Bucket | Backup Bucket**s** | logDNA      |
| ----------- | -----------   | -----------   | -----------   | -----------      | -----------   |
| ap-north    | Satellite-Config-Cos-Prod-jp-tok | satcon-prod-encrypted-jp-tok-configs | satcon-prod-encrypted-jp-tok-resources | satcon-prod-encrypted-jp-tok-daily-backup | [Satellite-Config-LogDNA-STS-Prod-jp-tok](https://cloud.ibm.com/observe/logging/33555a62-bbf3-4c69-a95c-1302bdd4821a/overview)    |
| br-sao      | Satellite-Config-Cos-Prod-br-sao | satcon-prod-encrypted-br-sao-configs | satcon-prod-encrypted-br-sao-resources | satcon-prod-encrypted-br-sao-daily-backup | [Satellite-Config-LogDNA-STS-Prod-br-sao](https://cloud.ibm.com/observe/logging/bcb65a15-96a4-4854-9d57-23ed86a8b78f/overview)    |
| ca-tor      | Satellite-Config-Cos-Prod-ca-tor | satcon-prod-encrypted-ca-tor-configs | satcon-prod-encrypted-ca-tor-resources | satcon-prod-encrypted-ca-tor-daily-backup | [Satellite-Config-LogDNA-STS-Prod-ca-tor](https://cloud.ibm.com/observe/logging/59abd45e-0546-4289-87a5-7e636f3e052e/overview) |
| eu-central  | Satellite-Config-Cos-Prod-eu-de | satcon-prod-encrypted-eu-de-configs | satcon-prod-encrypted-eu-de-resources | satcon-prod-encrypted-eu-de-daily-backup | [Satellite-Config-LogDNA-STS-Prod-eu-de](https://cloud.ibm.com/observe/logging/16906e4c-098d-4c5d-a63d-919522c82e2d/overview)      |
| uk-south    | Razee-Hosted-Cos-Prod-eu-gb | satcon-prod-encrypted-eu-gb-configs | satcon-prod-encrypted-eu-gb-resources | satcon-prod-encrypted-eu-gb-daily-backup | [Razee-Hosted-LogDNA-STS-Prod-eu-gb](https://cloud.ibm.com/observe/logging/c1ec5c45-46b5-48ca-9495-dc94ee2bbe4c/overview) |
| us-east     | Razee-Hosted-Cos-Prod-us-eas | satcon-prod-encrypted-us-east-configs | satcon-prod-encrypted-us-east-resources | satcon-prod-encrypted-us-east-daily-backup | [Razee-Hosted-LogDNA-STS-Prod-us-east](https://cloud.ibm.com/observe/logging/06ac13ee-3cf3-445d-8ff0-619a14130ec5/overview) |
| us-south    | Satellite-Config-Cos-Prod-us-south | satcon-prod-encrypted-us-south-configs | satcon-prod-encrypted-us-south-resources | satcon-prod-encrypted-us-south-daily-backup | [Satellite-Config-LogDNA-STS-Prod-us-south](https://cloud.ibm.com/observe/logging/e206a368-c1b2-480b-9e39-4328e70e1728/overview)] |

In addition to the daily backup bucket, there is also a monthly backup take on the first day of the month. Substitute *monthly* for *daily* in the bucket name for the unique name.

## Detailed Information

1. Determine the affected regions from the PD alert
2. Confirm that the COS endpoint is reachable with `ping` for the affected [region](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-endpoints#endpoints-region). If not [escalate](#escalation-policy) to the IBM COS team.
3. Sign into [IBM Cloud](https://cloud.ibm.com/) account `2094928 Satellite Production`
4. Check the logDNA instance for the region. Filter messages to just those from `cos-backup`. If there is an error with obvious cause, take appropriate action.
5. Access the Satellite Config cluster for the region, as identified by the PD alert.
6. Check if the Job completed successfully: `kubectl -n razee get jobs -l app=satellite-config`. Describe any that are in failed state.
7. Check the pods: `kubectl -n razee get pods -l app=satellite-config`. Check the logs of any that are failing.
8. Try rerunning the job `kubectl -n razee create job --from=cronjob/satellite-config-daily-backup-cos <job-name>` where \<job-name> is any valid kube resource name.
9. Watch the pods as they attempt to run. If the pod can't be scheduled, proceed with the usual steps for debugging scheduling issues. If the pod starts, follow the logs with: `kubectl -n razee logs -l app=satellite-config -f`
10. If the Job completes successfully, `kubectl -n razee delete job <job-name>`, and resolve the alert.
11. If all efforts fail, [escalate](#escalation-policies) to Satellite-Config.


## Escalation Policies

* Contact the COS team in the [#object-storage](https://ibm-argonauts.slack.com/messages/C0VJSU370) channel or follow the [support](https://cloud.ibm.com/docs/services/cloud-object-storage/help/support.html#troubleshooting) documentation for help with COS outages.

* Contact the Satellite Config squad in the [#satellite-config](https://ibm-argonauts.slack.com/archives/CPPG4CX3N) slack channel for interactive assistance

* PD escalation policy : During US East business hours, escalate to [Alchemy - Satellite - Config](https://ibm.pagerduty.com/escalation_policies#P42GAQ1)
