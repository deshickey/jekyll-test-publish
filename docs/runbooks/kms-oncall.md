---
title: KMS On-call runbooks
description: Lists available on-call runbooks
updated: 2022-03-29
version: 1.0.0
layout: runbooks
type: Informational
runbook-name: "KMS On-call runbooks"
category: Security 
service: kms
tags: kms, runbooks
link: runbooks/kms-oncall.html
parent: Armada Runbooks

---

Informational
{: .label }

# KMS On-call runbooks

This page lists the on-call runbooks that are available for operating our
service.

## Overview

The table in this topic contains information regarding Key Protect runbooks.

## Detailed Information

Each runbook is labeled with a title linking to the source and its description.

| Runbook title                                                          | Description                                                                             |
| ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| [Handling disk full failures](https://pages.github.ibm.com/kms/docs/on-call/runbooks/handling-diskfull-error/)         | Describes how to handle full disk failure.  |
| [Handling etcd config load failures](https://pages.github.ibm.com/kms/docs/on-call/runbooks/etcd-config-load-fail/)         | Describes how to handle etcd config load failure.                                       |
| [Handling HTTP 429 errors](https://pages.github.ibm.com/kms/docs/on-call/runbooks/http-429-errors/)                         | Describes how to handle HTTP POST or GET 429 errors in `<service-name>`.                |
| [Handling HTTP 500 errors](https://pages.github.ibm.com/kms/docs/on-call/runbooks/http-500-errors/)                         | Describes how to handle HTTP POST or GET 500 errors in `<service-name>`.                |
| [Handling HTTP 502 errors](https://pages.github.ibm.com/kms/docs/on-call/runbooks/http-502-errors/)                         | Describes how to handle HTTP POST or GET 502 errors in `api`.                           |
| [Handling 'mechanism is invalid' errors](https://pages.github.ibm.com/kms/docs/on-call/runbooks/http-500-errors-mechanism/) | Describes how to handle 500 errors due to _mechanism parameter is invalid_ in the logs. |
| [Handling secret generation failures](https://pages.github.ibm.com/kms/docs/on-call/runbooks/secret-generation-fail/)       | Describes how to handle secret generation failures reported by smoke tests.             |
| [Handling secret importing failures](https://pages.github.ibm.com/kms/docs/on-call/runbooks/secret-imports-fail/)           | Describes how to handle secret importing failures reported by smoke tests.              |
| [Handling SOC monitoring alerts](https://pages.github.ibm.com/kms/docs/on-call/runbooks/soc-monitoring-alerts/)             | Describes how to handle monitoring alerts reported by the SOC.                          |
| [Handling private network issues](https://pages.github.ibm.com/kms/docs/on-call/runbooks/private-network-debugging/)        | Describes how to handle private network HAProxy cluster errors.                         |
| [Handling KMIP for VMware issues](https://pages.github.ibm.com/kms/docs/on-call/runbooks/kmip-support/)                     | Describes where to forward KMIP for VMware support issues.                              |
| [Handling Hyperwarp issues](https://pages.github.ibm.com/kms/docs/on-call/runbooks/hyperwarp/)                              | Describes how to handle Hyperwarp outages and registration information.                 |


