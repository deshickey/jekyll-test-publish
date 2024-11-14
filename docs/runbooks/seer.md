---
layout: default
title: PD Incident Runbook Template
type: Informational
runbook-name: "debugging seer"
description: "debugging seer"
service: Conductors
link: /doc_updates/elba_fat_controller.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
Seer is a microservice running in the AAA cluster that is used (mainly by igorina) to look up information on machines and tugboats.

## Detailed information

The seer service can only be accessed by other services running on the AAA cluster:
```
$ kubectl -n sre-bots get service
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)               AGE
seer                       LoadBalancer   172.21.130.142   10.194.55.182   8080:31064/TCP        452d
```

Seer runs with 2 redundant pods behind the load balancer above.
```
$ kubectl -n sre-bots get pods
NAME                                        READY   STATUS    RESTARTS   AGE
seer-9555b6746-hmhnx                        1/1     Running   0          12d
seer-9555b6746-zbshm                        1/1     Running   0          12d
seer-test-5549744d5b-dsms6                  1/1     Running   0          12d
seer-test-5549744d5b-pddqs                  1/1     Running   0          12d
```

It gathers its information from the following sources:
* armada-envs - for carrier & machine information
  * https://github.ibm.com/alchemy-containers/armada-envs.git
* LaunchDarkly - for what OS image ID should be used for each machine.
* tugboat-cluster-monitor
  * https://github.ibm.com/alchemy-containers/tugboat-cluster-update-monitor.git
* tugboat-worker-info
  * https://github.ibm.com/alchemy-containers/tugboat-worker-info.git


### Seer Useful links:
* source code : https://github.ibm.com/alchemy-conductors/seer
* deploy job: https://alchemy-containers-jenkins.swg-devops.com/job/Support/job/seer-build/

### Deployment Description
* Runs on the `Access All Areas` cluster in Fra02 (eu-central)


## Common problems

### If a machine is not found
For example igorina may return: `I failed when looking up machine prod-hou02-carrier6-worker-1138 (IP=10.76.204.212), returned 0 entrines (I'm expecting 1)`
  
* is the machine newly provisioned?
Sometimes it takes a while for the repositories to be updated and for seer to pick up the changes.  you might want to try again in 30 minutes.
  
* Does netmax understand the machine?
If netmax does not know that machine, then it either:
  * does not exist
  * is not in one of our accounts.
either way our automation should nt be touching it.
  
* is the machine a kubernetes worker?
If the machine is prefixed by `kube-` it might not be in our accounts - seer only knows machines owned by IKS.
  
### Last resort - kick seer
If after running the above checks, you think the machine SHOULD be found, then try redeploying seer.
Navigate to the build job:
* deploy job: https://alchemy-containers-jenkins.swg-devops.com/job/Support/job/seer-build/
find the last deployment (gold star), select it and redeploy the production version.

# Escalation policy
There is no on-call pagerduty service to page out for this service.
We will need a [GHE issue](#raise-a-ghe) to be raised and let the eu-conductors know.

## Raise a GHE
If this runbook doesnt help with resolution, Raise a GHE in: <https://github.ibm.com/alchemy-conductors/seer>   
and ping it to `@eu-conductors` in the `#conductors-for-life` slack channel.

