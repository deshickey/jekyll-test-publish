---
layout: default
description: Process all squads should follow for deploying or killing the auto approval service(hofund)
title: How to deploy or kill the auto approval service(hofund) in production 
service: Conductors
runbook-name: "How to deploy or kill the auto approval service(hofund) in production "
link: /auto_approval_service.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }


# How to deploy or kill the auto approval service(hofund) in production 

## Overview 
This runbook describes how to deploy or kill the auto approval service(hofund) in production. 

When a train is created, the system checks the service’s current availability value to see if its within the agreed service level objective. If so the train is auto approved. If the service fails to keep the agreement within the agreed time range then their prod trains will be manually approved by SRE as oppose to auto approved.


## Actions to take 

### How to deploy the auto approval service(hofund)
For `deploying the auto approval service(hofund)` do the following: 

Create a new build by triggering this [jenkins job](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/hofund-build/). This will create the docker image.

If the build completes with no errors, the `hofund-test` version will be automatically promoted to the `infra-accessallareas` cluster via promotion step in the Jenkins job. 

Promote the production instance (`hofund`), Click Promotion Status on the left pane in the Jenkins job, and manually approve the promotion.
    
Auto approval service(hofund) is deployed as a micro-service on IKS using helm charts. This helm chart can be found in the charts [repository](https://github.ibm.com/alchemy-conductors/charts).

### How to Kill auto approval service(hofund)
Note: Only EU conductors will be able to kill the auto approval service(hofund), as it's deployed to the EU AAA cluster infra-accessallareas

You can kill auto approval service(hofund) by following the steps below:

1. `bx api https://api.eu-de.bluemix.net`
2. `bx login --sso`  
_choose:  `IBM (800fae7a41e7d4a1ec1658cc0892d233) <-> 278445`_
3. `bx cs cluster-config infra-accessallareas`  
_run the `export KUBECONFIG=/....` command_
4. kubectl get deployment -n sre-bots | grep hofund
5. kubectl delete deployment `<hofund-pod-id>`  -n sre-bots

## Detailed Information

### Components and Understanding
As the volume of prod train increases, there becomes a need to create a framework for auto approving prod trains. This is the base for creating the auto approval service(hofund and mimir)

Services have an agreement with SRE - that their service's availability would meet a certain level over a certain period. We agree a set of numerical targets for their service availability which can be measured using various data sources including but not limited to status cake, Pagerduty and Prometheus.



<img width="924" alt="screen shot 2019-02-26 at 14 23 20" src="https://media.github.ibm.com/user/119796/files/20ef9b80-39d2-11e9-8988-783bd3544faf">

Hofund watches for active Mimir's (which are automatically discovered) and queries them to get a confidence level of a service when request is sent in from Elba. Hofund then and sends a yes or no auto-approval to Elba if the the service queried was operating within its SLO. If services are outside their SLO their deployments should be manually inspected, with the expectation that they should be bug fixes rather than new code.

### Escalation Policy

Escalate the issue to the conductors 24x7 team 

Slack contact 
- @eu-conductors
- c.mcallister@uk.ibm.com ( Slack: @cam)
- matt.shaw@uk.ibm.com (slack @mattshaw)
- emmanuel.nnorom1@ibm.com (slack @emmanuel.nnorom1)


Slack Channel: https://ibm-argonauts.slack.com/messages/C534XTE49 (#armada-ops)
GitHub Issues: https://github.ibm.com/alchemy-conductors/hofund/issues


