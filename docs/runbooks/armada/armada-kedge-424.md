---
layout: default
description: Armada-Kedge users are hitting dependency 424 errors.
title: armada-kedge dependency 424 errors
service: armada
runbook-name: "armada-kedge 424 errors"
tags: armada, kedge, logging, carrier, monitoring, logdna, sysdig, metrics
link: /armada/armada-kedge-424.html
type: Alert
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

# Armada-Kedge 424 errors

## Overview

Armada-Kedge customers are hitting dependency 424 errors.

## Example alert
Pending alert creation.

## Action to take

### Verify the reasons for this 424 error.

You can get this error for the following three different reasons -

1. Check if your account has access to the specified instance
   You can check by using the following command - `ibmcloud resource service-instances` or `ibmcloud resource service-instance <instance-name>`

2. Check if the specified instance exist.
   You can check by using the following command - `ibmcloud resource service-instances` or `ibmcloud resource service-instance <instance-name>`

3. IAM might be down
   Check if other environments are experiencing the same error.
    - Check slack channel ([#iam-issues](https://ibm.enterprise.slack.com/archives/C3C46LY7N)) for any issues with IAM.

4. Check if the error is caused due to a single cluster.
   Go to <https://cloud.ibm.com/observe/logging> under AlchemyProduction account and launch the regional LogDNA dashboard where the issue is seen in.
   Look for error related to cluster state, for eg.,
   ```
   IKS error: Could not connect to the master to configure the RBAC roles that authorize permissions
   to Kubernetes resources in the cluster. Check the cluster state and master status, and try again
   when the cluster is healthy.
   ```

5. Identify the cluster causing this error. Depending on the type of error, the SRE will need to fix the cluster or contact the cluster's owner.
   - Create an issue like this <https://github.ibm.com/alchemy-containers/armada-deploy/issues/4586> when there are issues with a user cluster.

6. Suggested steps to identify the clusters that could be causing the 424 alert are -
   - First query in the LogDNA Dashboard, for logs with `"Request for" "rc=424"`, create a text file with these log lines, say `clusters.txt`
   - Run this script against clusters.txt
     ```
     var=$(cat clusters.txt|grep -wo  "req-id.*"|cut -d '"' -f 3|sort -u|awk '{ print "\""$0"\""}' |sed -e 's/$/ OR /'); echo ${var%O*}
     ```


## Escalation Policy
If IAM is down, then escalate {{ site.data.teams.IAM.escalate.name }} at [here]({{ site.data.teams.IAM.escalate.link }})

If IAM is not down, please notify {{ site.data.teams.armada-kedge.comm.name }} on Argonauts and create an issue [here]({{ site.data.teams.armada-kedge.link }})

Escalation policy - `Armada - Kedge`
