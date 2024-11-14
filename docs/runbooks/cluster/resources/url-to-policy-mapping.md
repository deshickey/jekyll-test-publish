---
layout: default
title: cluster-squad - Map URL to a Service escalation policy
type: Informational
runbook-name: "cluster-squad - Map URL to a Service escalation policy"
description: "cluster-squad - Map URL to a Service escalation policy"
service: armada
link: /cluster/url-to-policy-mapping.html
playbooks: []
failure: ["Map URL to a Service escalation policy"]
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Informational
{: .label }


## Overview

The following table lists select URLs we are dependant upon for the processing of resource operations. They also link to either a slack channel or escalation policy where we can request additional help.

## Detailed Information

### Mapping Table

| URL                                         	| Escalation Policy                                                                                         	|
|---------------------------------------------	|-----------------------------------------------------------------------------------------------------------	|
| <https://billing.cloud.ibm.com>             	| [Bluemix BSS Metering](https://ibm.pagerduty.com/escalation_policies#PICP7UN)                             	|
| <https://resource-controller.cloud.ibm.com> 	| [Bluemix BSS Provisioning and Resource Controller](https://ibm.pagerduty.com/escalation_policies#PGPNMQI) 	|
| <https://iam.cloud.ibm.comc>                	| [IAM-Issues](https://ibm-cloudplatform.slack.com/archives/CS62UR3RD)                                      	|
| <https://.*iaas.cloud.ibm.com>              	| [IPOPS VPC](https://ibm-cloudplatform.slack.com/archives/CS62UR3RD)                                       	|
| <https://api.service.softlayer.com>         	| Raise Sev1 SoftLayer support ticket and engage with the SoftLayer team.                                   	|
