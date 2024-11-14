---
layout: default
description: Runbook detailing how to resolve vulnerability issues for LogDNA agent
service: "Infrastructure"
title: How to resolve vulnerability issues for LogDNA agent
runbook-name: How to resolve vulnerability issues for LogDNA agent
link: /sre_logdna_agent_vuln_issue.html
type: Informational
failure: ["Runbook needs to be updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Ops
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

How to resolve vulnerability issues for LogDNA agent.

## Detailed Information

### Check details of vulnerabilities

Check details of vulnerability issues in [compliance-vuln-scan-carrier](https://github.ibm.com/alchemy-containers/compliance-vuln-scan-carrier/issues) repo. If all vulnerabilities are OS level security issues, continue to follow the steps in section [Rebuild image](#rebuild-image). 

Otherwise, open a support ticket under `531277 - Argonauts Production` account, ask LogDNA team to fix the vulnerabilities. The version we are using is `logdna-agent:v2-stable`. You can also query the issue in slack channel [#ibm-logdna-guest-help](https://ibm-argonauts.slack.com/archives/GDBQH3B8W). After the vulnerabilities are fixed in the base image, continue to follow the steps in section [Rebuild image](#rebuild-image).

### Rebuild image

Follow the guide [here](https://github.ibm.com/alchemy-containers/armada-ansible-external-images#updating-the-images) to rebuild the logdna-agent image. If you don't have permission to run the `tag-publish.sh` script, ask for help in the [{{ site.data.teams.armada-deploy.comm.name }}]({{ site.data.teams.armada-deploy.comm.link }}) slack channel.

Check the log of [travis build](https://travis.ibm.com/alchemy-containers/armada-ansible-external-images). If the build is passed, you can see the latest tag of the image as shown below.
```
REPOSITORY                   TAG                 IMAGE ID            CREATED                  SIZE
armada-master/logdna-agent   v2-stable-IKS-129   d3b8c32cd548        Less than a second ago   237MB
```

### Check VA scan result

1. Log in ibm cloud platform with ibmcloud cli
```
ibmcloud login --sso
```

2. Select `2. Alchemy Production's Account (cc7530878c499d74ad77f31c918c626e) <-> 1185207` from the account list.

3. Log in container registry
```
ibmcloud cr login
```

4. Set a target region, e.g. us-south
```
ibmcloud cr region-set us-south
```

5. Search logdna-agent images in container registry. Be patient, this command needs some time to return the result.
```
ibmcloud cr images --va --include-ibm --restrict armada-master/logdna-agent
```

6. If you see `No Issues` in the image with the latest tag, all vulnerabilities are fixed in that image. If you see `Scanning`, wait for the scan to complete, then check again.
```
us.icr.io/armada-master/logdna-agent v2-stable-IKS-129   c084feb7b9c1   armada-master   1 hour ago       99 MB    No Issues
```

### Update image version

Create a PR in [iks-management-clusters-addons](https://github.ibm.com/alchemy-containers/iks-management-clusters-addons) repo to update the image used in our environments. The code you need to modify is:
* [ldna-ds.yaml#L31](https://github.ibm.com/alchemy-containers/iks-management-clusters-addons/blob/master/config-src/ldna-ds.yaml#L31).
* [atracker-ds.yaml#L31](https://github.ibm.com/alchemy-containers/iks-management-clusters-addons/blob/master/config-src/atracker-ds.yaml#L31).

After the PR get reviewed and merged, promote it to production before the due date.

### Promote to production

Go to [razee dashboard](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/iks-management-clusters-addons), and follow the process to promote the latest version of `iks-management-clusters-addons` to each environment (dev/prestage/stage/prod). 
  
Run this [jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/promotion-verification/) to verify the status of each promotion.  If the Jenkins job is unavailable or failing to build, [access a tugboat](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-tugboats.html#access-the-tugboats) in the env/region, and manually check the status of the daemonset and rollout. Ensure that the daemonset is using the new image and that the rollout is successful before moving to the next env/region.

```
$ $ kubectl -n kube-system get ds/logdna-agent -o wide
NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE      CONTAINERS     IMAGES                                                  SELECTOR
logdna-agent   45        45        45      45           45          <none>          3y336d   logdna-agent   us.icr.io/armada-master/logdna-agent:v2-stable-IKS-67   app=logdna-agent


$ kubectl -n kube-system rollout status ds/logdna-agent
daemon set "logdna-agent" successfully rolled out
```

## Escalation policy

If you are unsure then raise the problem further with the SRE team.

Discuss the issues seen with the SRE team in `#conductors` (For users outside the SRE squad) or in `#conductors-for-life` or `#sre-cfs` if you have access to these private channels.

There is no formal call out process for this issue.
