---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to add and configure a user to IBM Cloud accounts
service: sre
title: Runbook for Adding and Configuring a user to IBM Cloud accounts
runbook-name: "Adding and Configuring a user to IBM Cloud accounts"
link: /ibmcloud_account_management.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

How users are added to IKS Tribe IBM Cloud accounts

## Detailed information

### Adding and removing users

Adding and removing users is managed by AccessHub group membership and Access Groups within IBM Cloud.

**WARNING**: Any users manually added to an IBM Cloud account will likely be automatically removed within a 24 hour period as automation is in place to regularly sync AccessHub approved users into our onboarded accounts.

Automation runs after a user has an AccessHub request approved and will add them to the relevant IBM Cloud accounts and into the necessary IBM Cloud access group(s) depending on the role requested in AccessHub.

Please consult the following documentation on [Accesshub user management](./../process/access_control_using_accesshub.html) for more information and reach out to SREs if you have any further questions.

### Applying IBM Cloud Classic Infrastructure permissions to a user

Classic Infrastructure permissions are also controlled via AccessHub.

Please consult the following documentation on [Accesshub user management](./../process/access_control_using_accesshub.html) for more information and reach out to SREs if you have any further questions.

## Escalation policy

Speak to the SRE squad in [#conductors](https://ibm-argonauts.slack.com/messages/C54H08JSK) channel