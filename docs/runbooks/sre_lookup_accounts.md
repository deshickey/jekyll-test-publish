---
layout: default
description: Runbook to help SREs lookup IBM Cloud account details
service: "Infrastructure"
title: How to look up IBM Cloud accounts
runbook-name: How to find account details
link: /sre_lookup_accounts.html
type: Operations
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

This runbook helps SRE team members lookup account details

## Useful links

- [ServiceNow] - link to the `IBM Accounts` view

## Detailed information

We are sometimes approached to help find out further information on accounts so customers can be contacted to resolve issues being seen.

## Detailed Procedure

There are various tools we can use to look up details of an account and it's owner.

### ServiceNow

- Log into [ServiceNow] - NB: this should take you directly to the `IBM Accounts` view.  If it doesn't, use the `Filter Navigator` to find it.
- With the Account ID provided in the request, use the search capability to track the account down.
- Provide the required details to the requestor via a direct message and not in a public slack channel

### xo-secure

- Navigate to `#xo-secure`
- `@xo cluster <clusterid> show=all` output will include the owner email address

### bss channel in slack

- The [#bss channel](https://ibm-cloudplatform.slack.com/archives/C081NLV9U/p1588695106425000) is a possible source of information for cluster owners - especially for internal users / stage accounts that don't appear in ServiceNow.

## Automation

None

## Escalation policy 

If you are unsure or are unable to find the information needed, then raise the problem further with the SRE team you are part of.  Speak to you squad lead as a first point of call.

Discuss the issues seen with the SRE team in `#conductors` or in `#sre-cfs`

There is no formal call out process for this issue but all SRE members should have access to [ServiceNow] to complete the investigation

[ServiceNow]: https://watson.service-now.com/nav_to.do?uri=%2Fu_ibm_accounts_list.do%3Fsysparm_userpref_module%3Db544f884db2943408799327e9d9619b5%26sysparm_clear_stack%3Dtrue
