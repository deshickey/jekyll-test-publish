---
layout: default
title: cluster-squad - Red Alert - Subnet in VPC Gen 2 Service Account
type: Alert
runbook-name: "cluster-squad - Red Alert - Subnet in VPC Gen 2 Service Account"
description: Armada cluster - Subnet in VPC Gen 2 Service Account
service: armada-cluster
link: /cluster/cluster-squad-subnet-service-account.html
ownership-details:
- owner: "armada-cluster"
  corehours: UK
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview

This alert will fire if a subnet has been created in the `IKS.Prod.VPC.Service` account on `https://cloud.ibm.com`

This account should NEVER have a subnet in it and it should be deleted from the service account as soon as possible. A subnet in the service account represents a security and compliance risk for the IKS and ROKS platform.

## Example Alert

- `bluemix.containers-kubernetes.prod-dal10-carrier105.armada-provider-riaas_service_subnets_count_g2.us-south`

## Action to take

1. Page the on-call troutbridge squad member for assistance in identifying the resources involved
1. Notify Ralph or his delegate of the situation
1. Remain on hand for the troutbridge squad member as SRE assistance will be required in deleting the resources

### Follow on questions

Once the situation has been resolved, an RCA will need to be performed by the SRE team

1. What user ID was used to create the identified resources?
1. What other actions did the user perform alongside the creation of subnets or VSIs?
1. Were any other resources created that have not already been identified and deleted?
1. What processes need to be reviewed to prevent this happening again?

### Guidance for the troutbridge squad member

This is an extremely sensitive situation and needs a quick resolution, the only course of action is to identify the resources involved and work with SRE to delete things manually via the CLI.

If required, page out troutbridge squad leads for additional assistance.

#### Identify the resources requiring deletion

1. Gather subnet ID's
    1. Open the LogDNA instance for the region affected
        1. Access LogDNA by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `LogDNA` icon in the alerted environment
        1. In the left hand pane under `CLUSTER-SQUAD` open the view called `default-view`
        1. Search for the string `"Subnet identified in service account"`
        1. Capture the value of the `subnet` field of the message
1. Screenshare with SRE
1. Request they login to IBM Cloud UI at `https://cloud.ibm.com` and access the account `IKS.Prod.VPC.Service` account
1. Navigate to `https://cloud.ibm.com/vpc-ext/network/subnets`
1. Select the region which the alert applies to
1. For each subnet in the list
    1. Verify the ID and Name match what has been identified in the logs
    1. Review the `Attached Instances` table on this page
        1. For each VSI in the table, view it and collect the name and ID
1. For each VSI identified
    1. Request SRE login to `https://cloud.ibm.com` via the CLI, target the `IKS.Prod.VPC.Service` account and affected region
    1. Execute `ibmcloud is instance <ID>`
        1. Capture the Name and ID of any `Data volumes` on a VSI

#### Deleting the identified resources

*DO NOT DELETE ANYTHING WITHOUT APPROVAL FROM RALPH*

1. Raise a [new issue on SRE](https://github.ibm.com/alchemy-conductors/team/issues/new)
    1. Title: `Delete resources from IKS Production Service Account`
    1. The issue body should contain
        1. A brief description of the situation
        1. A link to the page notifying us of the problem
        1. Name, ID and type of each individual resource to be deleted
1. Request approval from Ralph (or his delegate) for the manual deletion of the identified resources
1. Request SRE login to `https://cloud.ibm.com` via the CLI, target the `IKS.Prod.VPC.Service` account and affected region
1. Install or update the infrastructure service CLI plugin
    1. Install: `ibmcloud plugin install vpc-infrastructure`
    1. Update: `ibmcloud plugin update vpc-infrastructure`
1. For each VSI identified:
    1. Execute `ibmcloud is instance <ID>` and verify the name matches what was collected above
    1. If it does AND approval from Ralph has been given. Execute `ibmcloud is instance-delete <ID>`
1. For each volume identified:
    1. Execute `ibmcloud is volume <ID>` - Verify that either ...
        1. the volume can not be found
        1. the volume name matches the name identified earlier
    1. If the volume exists AND approval from Ralph has been given. Execute `ibmcloud is volume-delete <ID>`
1. For each subnet identified:
    1. Execute `ibmcloud is subnet <ID>` and verify the name matches what was collected above
    1. If it does AND approval from Ralph has been given. Execute `ibmcloud is subnet-delete <ID>`

#### Verify account is clear of all subnets

1. Login to the VPC OPS Dashboard to review the [IKS Service Account](https://opsdashboard.w3.cloud.ibm.com/ops/accounts/bab556e1c47446ef8da61e399343a3e7)
1. Scroll down to the subnets section and confirm it is empty
1. If it is not empty, identify the region of the subnet and work through the [Identification](#identify-the-resources-requiring-deletion) and [Deletion](#deleting-the-identified-resources) steps for each subnet

## Escalation Policy

PagerDuty:
  Escalate the issue via the [troutbridge](https://ibm.pagerduty.com/escalation_policies#PQORC98) PD escalation policy

Slack Channel:
  You can contact the dev squad in the [#armada-cluster](https://ibm-argonauts.slack.com/archives/C54FV49RU) channel
