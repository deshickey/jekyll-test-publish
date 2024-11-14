---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to add an extended environment
service: Conductors
title: How to add an extended environment
runbook-name: "How to add an extended environment"
link: /bootstrap_add_extended_environment.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

An extended environment is an environment which extends from one of the main environments we have.

For example, dev-mex01 is an extension of dev-mon01.

This means the `Netint` team are more than likely have already added tunnels from the main environment and you are reading this as you are being asked to add a new extended environment.

## Detailed Information

## Detailed Procedure

Review the following files add make changes were necessary

### Update devices_parser

Create a PR for the `cfs-inventory` code:

1. Check [cfs-inventory devices_parser code](https://github.ibm.com/alchemy-conductors/cfs-inventory/blob/master/lib/devices_parser.py) and add in the extended environment.

1. Check [cfs-inventory push script](https://github.ibm.com/alchemy-conductors/cfs-inventory/blob/master/scripts/push_inventory.sh) - if the devices are in a new Softlayer account, we script will need updating to pull the devices.csv file for that account.

Create a PR for the `inventory-tools` code:

1. Check [inventory-tools devices_parser code](https://github.ibm.com/alchemy-conductors/inventory-tools/blob/master/inventory_tools/devices_parser.py) and add in the extended environment.

Create a PR for the `conductors-jenkins-jobs` code:

1. Check the [alchemy-bootstrap job config](https://github.ibm.com/alchemy-conductors/conductors-jenkins-jobs/blob/master/alchemy-conductors/Conductors/job/alchemy-bootstrap.yml) and add in the new datacenters.

Create a PR for the `bootstrap-one-server` code:

This is only necessary if files need changing!

1. Review the [bootstrap base script](https://github.ibm.com/alchemy-conductors/bootstrap-one-server/blob/master/etc/bootstrap_base.sh)

Create a PR for the `operations_user-image` code:

1. Review and update the [ssh config section](https://github.ibm.com/alchemy-conductors/operations_user-image/blob/master/Dockerfile#L19-L32) - There is a restriction on our servers that we reject logon attempts from the same session if we hit 5.  We have had to configure the ssh config to point at particular ip ranges.  Check the entry for the environment you are extending from, and add relevant IP addresses.

Create a PR for the `provisioning app` code:

1. map the new dc appropriately in [initial_machine_config](https://github.ibm.com/alchemy-conductors/provisioning-app/blob/master/config/initial_machine_config.py)

### Merging the pull requests.

Once all the above changes are in place, ensure that you merge the changes in this order.

* `cfs-inventory` - then let subsequent automated [jenkins](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/Bootstrap/job/conductors-bootstrap-update-cfs-inventory/) build to complete

If the job is green, the check that `cfs-inventory files` are being created for the [extended environment](https://github.ibm.com/alchemy-conductors/cfs-inventory/tree/master/inventory)

* `inventory-tools` - then let subsequent automated jenkins builds complete

### Updating other resources

1.  Add the new environment to the [jenkins bootstrap job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/job/alchemy-bootstrap/)


### Validating

Ways to validate can be any of the following.

1.  OSReload an existing, or order a new machine in this environment.
1.  Bootstrap a machine via jenkins
1.  Bootstrap a machine from the command line.

### Examples

Here is an example [GHE issue for devwat-dal10](https://github.ibm.com/alchemy-conductors/development/issues/269)

### Help needed?

Speak to the UK Conductors who have executed this many times.
