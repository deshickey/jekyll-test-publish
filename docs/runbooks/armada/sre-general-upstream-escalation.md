---
layout: default
description: General SRE Runbook for Upstream Escalation
title: Upstream Escalation
service: armada
runbook-name: Upstream Escalation
tags: escalation, redhat, letsencrypt, akamai, launchdarkly
link: /armada/sre-general-upstream-escalation.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This Runbook contains information for on-call SRE to utilize when escalating with external upstream dependencies such as RedHat, LetsEncrypt, Akamai, and LaunchDarkly

## Detailed information
### Table of Contents

1. [RedHat](#redhat)
2. [Lets Encrypt](#letsencrypt)
3. [Akamai](#akamai)

### RedHat

1. Open a case with RedHat via the [customer portal](https://access.redhat.com/support/cases/#/case/new/get-support?caseCreate=true)
   1. For armada-deploy related issues, particularly surrounding cluster creation and quay.io. Please include information surrounding our consumption of the OpenShift API. See [RedHat Boilerplate](#redhat-boilerplate)
2. Make sure to attach [sosreports](https://access.redhat.com/solutions/3592), [must-gathers](https://docs.openshift.com/container-platform/4.15/support/gathering-cluster-data.html)(if applicable), and other applicable information to the case.
3. Send an email with the Case Information to partnertechdesk@redhat.com and Cc  mpeterma@redhat.com (Note: Morgan Peterman is our Support TAM)
4. For severity 1 or 2 cases please follow up with a phone call at 888-GO-REDHAT.
   1. Please have the Case Number ready to provide to Red Hat Support.
5. Use the following escalation steps if necessary:
   1. [General Escalation steps from RedHat](https://access.redhat.com/support/escalation)
      1. NOTE:  Recommended (from the above options) from the case you wish to escalate , click Request Escalation located on the right under recommended solutions.
   1. Add the webex link to the Support Case
   1. Confirm the above Request Escalation results in the Support Manager on Call joining the webex

### LetsEncrypt
For Let’s Encrypt, we don’t have a support contract since they don’t provide direct support. However, we have had contact with the following individuals that have helped us:
1. Jillian Karner jkarner@letsencrypt.org – Has helped us with technical issues over email
2. Dan Fernelius dfern@letsencrypt.org – Is a Director of ISRG – who is the main org behind let’s encrypt. We contact him via e-mail if we need quota adjustments.
3. Rate limit adjustments can be done using the form specified here: https://letsencrypt.org/docs/rate-limits/#a-id-overrides-a-overrides
4. IBM is a sponsor for Let’s Encrypt. We can also potentially get help if we e-mail sponsor@letsencrypt.org
5. For non-urgent issues, you can use this forum: https://community.letsencrypt.org/
6. Let’s encrypt status can be found here: https://letsencrypt.status.io/

### Akamai
Engagement with an internal team that has access to the Akamai Control pane is ideal, as phone support is the number one way provided from Akamai to receive Sev-1 support. However, it is mentioned in their support documentation that opening a case before-hand is better for tracking purposes
1. Open a ticket on [the portal](https://control.akamai.com)
   1. Include all relevant details including impacted services being consumed, and relevant endpoints.
   2. Include the Webex link for the ongoing issue
2. Phone Akamai, to escalate the case with their internal support (Sev-1 only), and request the Duty Manager join our Webex for the ongoing issue.
   1. 1-877-4-AKATEC or 1-617-444-4699
   2. Enter our Express Routing Code `BLMX (2569)`


### RedHat Boilerplate
Armada-Deploy context.
```
IBM Cloud runs a managed container platform where we deploy OCS clusters into our own infrastructure and provide the clusters to consumers of our service independently from RedHat's container offering. As part of this we consume some APIs provided on the api.openshift.com endpoint including those responsible for creation of pull secrets on quay.io, to allow for consumers of our service to pull images from quay.io if they so choose.

We are experiencing issues with ....
```
