---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: "Troubleshooting IBM Cloud Object Storage"
type: Informational
runbook-name: "armada-cos-problems"
description: "The IBM Cloud Object Storage service is not functioning properly."
service: Razee
tags: razee, armada
link: /armada/armada-cos-problems.html
failure: ""
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
Several armada carrier services rely on IBM Cloud Object Storage
[(COS)](https://cloud.ibm.com/objectstorage/create)
including etcd-operator, armada-log-collector, and armada-cluster-store.
COS must be accessible and healthy for these services to function.

## Detailed Information
1. Sign into [IBM Cloud](https://cloud.ibm.com/)  
_Expect to use your Yubikey for access_
1. Having selected the the account `Argonauts Production` (531277), head to the Dashboard and look for the troubled instance.
1. Ensure that the buckets exist and contain objects.
   -  If not, escalate to the appropriate armada team.
1. Ensure you can ping the endpoint at `s3-api.us-geo.objectstorage.softlayer.net`.
   - If not [escalate](#escalation-policy).

## Escalation Policy
Contact the team in the [#object-storage](https://ibm-argonauts.slack.com/messages/C0VJSU370) channel or follow the [support](https://cloud.ibm.com/docs/cloud-object-storage/help/support.html#troubleshooting) documentation for help.
