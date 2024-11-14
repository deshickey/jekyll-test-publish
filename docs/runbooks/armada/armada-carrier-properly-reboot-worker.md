---
layout: default
description: Properly reboot Carrier Worker node
title: How to properly reboot a carrier worker node
service: armada
runbook-name: "Properly reboot Carrier Worker node"
tags: armada, armada, kubernetes, kube, kubectl, reboot, wanda
link: /armada/armada-carrier-properly-reboot-worker.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook covers how to properly reboot a carrier worker node in Armada.

## RUNBOOK MOVED

This runbook has moved to [here](./armada-carrier-node-troubled.html#rebooting-worker-node)
If brought here from another runbook, please get the runbook updated with this new link. 

For rebooting with a read-only filesystem please see the information below. 

### Rebooting to recover from read-only filesystem

<a name="read-only-filesystem"></a>
This section covers recovering from read-only filesystem problems.
Follow the procedure described in [rebooting worker node](./armada-carrier-node-troubled.html#rebooting-worker-node), but
when you get to the step to reboot the system, you will have to
reboot twice: once in rescue mode, and then normally.

You can tell a system has this issue when you see errors like this:

~~~
# touch /tmp/test-file
touch: cannot touch '/tmp/test-file': Read-only file system
~~~
where the file you touch is in the affected filesystem.

There are multiple filesystems this can affect:
* `/` (root filesystem)
* `/var/lib/docker`

This mount command will show read-only filesystems:

~~~
# mount | grep "ext4 (ro"
/dev/xvda2 on / type ext4 (ro,relatime,data=ordered) [cloudimg-rootfs]
~~~

If this shows read-only filesystems, you will need to have conductors boot the
system.  Systems should have `FSCKFIX=yes` so that a simple reboot will
fix the problem.  If the disk is still read-only after reboot, it is necessary
to boot into rescue mode and run `fsck` on the disk:
<br>
`fsck -v -f -y /dev/xvda2`
<br>
(use the mount command show above to verify the device) then reboot to bring it up
normally and continue with the rest of the procedure.

If the disks are SAN, it is possible that a networking problem can cause
read-only filesystems on several systems.  The following Jenkins job can be used
to check all hosts in a given carrier:

* Go to the [{{ site.data.cicd.jobs.armada-carrier-scripts.name }}]({{ site.data.cicd.jobs.armada-carrier-scripts.link }})
* In the script dropdown, select test-filesystem.sh
* Select the desired environment and carrier
* Click build

The job should run successfully if there are no problems. If there are read-only filesystems
or ssh errors, the job will fail.  The console output identifies the failing systems and
type of error.  For example:

~~~
10.135.28.94: Found read-only file systems
/dev/xvda2 on / type ext4 (ro,relatime,data=ordered)
/dev/xvdc on /var/lib/docker type ext4 (ro,relatime,data=ordered)
/dev/xvdc on /var/lib/docker/aufs type ext4 (ro,relatime,data=ordered)
~~~

## Detailed Information
None

Related script: [{{ site.data.teams.armada-carrier.name }}]({{ site.data.teams.armada-carrier.test-filesystem-sh }})
