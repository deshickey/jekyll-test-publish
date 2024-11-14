---
layout: default
description: How to recover a machine that is stuck in Grub Rescue and has been migrated to HVM boot mode.
service: Containers
title: Recover a machine that is stuck in Grub Rescue and has been migrated to HVM boot mode.
runbook-name: "Recover from Grub Rescue"
playbooks: []
failure: []
link: /conductors_recover_grub_rescue_HVM_migration.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Recently IBM Cloud (formerly Softlayer) has been migrating all our systems from using a PV boot mode to using HVM bootmode.  This moves our boot loader from grub-legacy to grub2.  For whatever reason, most of our systems can not tolerate this migration and upon reboot will be stuck on the grub rescue menu.  This runbook details the steps involved in recovery of a machine in this state.

## Detailed Information

The sections below contain detailed information.

### Diagnoses

The following symptoms could be observed.

- Recent alerts for NodeNotReady for the node in question.
- Recent reboot of the node and it has not come back
- Being unable to ssh to the node
- Only way to get to the machine is via KVM and the machine will be sitting at the grub rescue prompt. 

## Detailed Procedure

The following procedure should be followed to fix the issue.

### Get the machine to boot

We cannot know what machine is tagged for migration, nor do we know if and when this change to HVM will take place.  If you have a machine that does not return from a reboot, check what the status of the machine is via the Softlayer console.  This is typically done via the Softlayer VPN (you cannot use OpenVPN) and vncviewer. Use this runbook to setup [Softlayer VPN](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/kvm_access.html#iaas--softlayer-vpn). If the console is showing the grub rescue< prompt then these instructions can be used to recover the machine.

At the grub rescue prompt type the following one at a time:

~~~
grub rescue> set prefix=(hd0,msdos2)/boot/grub
grub rescue> set root=(hd0,msdos2)
grub rescue> insmod linux
grub rescue> insmod normal
grub rescue> normal
~~~

After hitting enter on the last step you should see the machine start booting the kernel as normal.  Once it is back up proceed to the next step to prevent this from happening again.

### Fix for next boot

In order to prevent the machine from going back into the grub rescue prompt the next time it reboots we have to 'fix' grub.  We do this by reinstalling two packages:  grub-pc and grup-legacy-ec2.  Follow these steps at the console to recover:


THIS STEP IS NOT NECESSARY ON PROD MACHINES AS THEY HAVE BEEN PATCHED ALREADY TO HAVE THIS INSTALLED.  KEEPING THESE INSTRUCTIONS HERE FOR POSTERITY (and if we missed one)

**NOTE:** Just select /dev/xdva when prompted which drives to choose  
**NOTE 2:** If `apt-get update` fails with 404 you need to instruct `igor` bot in [#sre-cfs-patching](https://ibm-argonauts.slack.com/messages/G53A0G8CU) (private) to bring it to the latest stable version. UK squad has info.
~~~
apt-get update
apt-get install grub-pc -y
sed 's/^# groot=.*$/# groot=(hd0)/' /boot/grub/menu.lst > /boot/grub/menu.lst.tmp && mv /boot/grub/menu.lst{.tmp,}
apt-get install grub-legacy-ec2 -y
~~~

This should set the grub menu to properly boot the system for next time.  Nothing else should be done and the machine can be put back in service.

**NOTE:** Just to make double sure, you should reboot the machine, because it was seen that a machine was booting in the oldest kernel from the grub boot list and then again you verfied it can boot again.

## Detailed Information

If the above steps do not work, the machine must be osreloaded and Armada must be re-deployed onto the system.  These steps have been tested on many, many systems and should provide us with the means to bring the system out of the grub rescue and back into production as quickly as possible.

## Automation

None
