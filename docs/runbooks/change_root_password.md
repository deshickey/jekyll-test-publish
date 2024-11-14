---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to check and change status of root password
service: BMs and VMs
title: change_root_password
runbook-name: Change Root Password
link: /change_root_password.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook describes how to change the root password for a vm or bm managed by IaaS (not IKS).

Under normal operation, a weekly [jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Maintenance/job/bootstrap-change-root-password/) will rotate the root password if it is due to expire within 30 days. This job can also be run off-schedule by an SRE if required and SRE can change the password locally on the node.

## Detailed Information

### Check `root` password expiration

Use `chage -l root` to view expiration details:

```
prod-dal09-infra-syslog-01:~$ sudo chage -l root
Last password change                                    : Oct 25, 2019
Password expires                                        : Oct 24, 2020
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 7
Maximum number of days between password change          : 365
Number of days of warning before password expires       : 7
```

### Change `root` password

If the root password has expired or must be changed, we can take 2 options.

#### Option 1. Run a Jenkin Job : [bootstrap-with-latest-playbooks](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Maintenance/job/bootstrap-with-latest-playbooks/)

1. Details are [HERE](https://github.ibm.com/alchemy-conductors/bootstrap-one/blob/master/playbooks/roles/chg_root_pw/README.md)
1. Parameters
   - BRANCH : orgin/master
   - ENVIRONMENT : < environment the server is in >
   - HOSTS : < short hostname >
   - ROLE : chg_root_pw
   - EXTRA_OPTS : -e forcePasswordUpdate=1 #to enforce pwd renew before it's expired
   - example [Jenkins Execution](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Maintenance/job/bootstrap-with-latest-playbooks/1154/parameters/)

#### Option 2. If Jenkins is unavailable, the Manual Steps to change the password are as follows

1. Update the root password locally on the node with `passwd` (suggest using 1Password to generate a random password; ensure that it meets [ITSS password standards](https://pages.github.ibm.com/ciso-psg/main/standards/itss.html#40-access-control))
1. Run `chage` again and verify that the `Last password change` and `Password expires` dates have been updated.
1. Update the password in the cloud.ibm.com Password manager
   - Login to [cloud.ibm.com](https://cloud.ibm.com) for the appropriate account (e.g. 531277)
   - Navigate to `Classic Infrastructure` >> `Device List` and search for the node name, then click it
   - Click `Passwords` from the navigation menu
   - On the line for the `root` user, click the `Actions` menu and select `Edit Credentials`
   - Enter the new password, adding a note to say why it was changed.

### Password compromise

In case of suspected compromise of a server password, first contact [SOC](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/methods_to_contact_public_cloud_SOC.html)

The password must then be changed, using one of the methods above.
