---
layout: default
title: cargo-etcd - how to resolve cargo etcd database issues
description: How to resolve cargo etcd database issues
service: cargo-etcd
runbook-name: "cargo-etcd - issues"
tags: alchemy, armada, cargo, etcd
link: /armada/cargo-etcd.html
type: Operations
parent: Cargo ETCD
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

This runbook describes how to handle cargo etcd database issues.

Cargo etcd is on the Armada micro-service tugboat.
It's used for non-critical customer status information.

## Example Alerts

`CargoEtcdSizeCritical`
`CargoEtcdBrokeQuorum`
`CargoEtcdUnhealthyOperator`
`CargoEtcdDefragFailure`
`CargoEtcdDataErrorCount`

## Detailed Information

Concept Doc: https://github.ibm.com/alchemy-containers/armada/pull/3435

## Detailed Procedure

Can use escalation policy for now.

## Escalation Policy

Reach out to the @ballast handle in #armada-ballast or escalate to [Alchemy - Containers Tribe - Ballast](https://ibm.pagerduty.com/schedules#PP1MP9Q)
