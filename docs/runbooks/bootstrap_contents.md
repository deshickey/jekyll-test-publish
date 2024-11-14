---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: About the bootstrap process
service: Conductors
title: Bootstrap contents page
runbook-name: "Conductors: Bootstrap (ansible) documentation contents"
link: /bootstrap_contents.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Index of bootstrap related runbooks

## Detailed Information

The bootstrap process documented here is NOT related to the armada-bootstrap team or process.
This process is for applying common settings to Softlayer machines ordered by the SRE team that make up the control plane or infrastructure machines for the SRE team, for example, `carriers` and `infra` servers.

## Detailed Procedure

### Bootstrap Operations

*Updated for changes delivered Winter 2016*

The following documentation will help with the operations role, dealing with bootstrap issues or contributing to the bootstrap process.

1. [Overview of bootstrap setup](./bootstrap_overview.html) - Overview of bootstrap and how all the components hang together.

1. [Executing and debugging a bootstrap](./bootstrap_executing_and_debugging.html) - How to kick off , monitor and debug a bootstrap run.F


### Development

1. [How to add an extended environment to the bootstrap process](./bootstrap_add_extended_environment.html)

### Setting up brand new environments.

1. Deploy new instance of [bootstrap-one-server](https://github.ibm.com/alchemy-conductors/bootstrap-one-server) using [razeedash](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/bootstrap-one-server)
