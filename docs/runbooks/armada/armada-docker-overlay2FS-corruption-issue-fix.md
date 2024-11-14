---
layout: default
description: Procedure to detect and fix overlay2FS corruption issue
title: armada-docker - Procedure to detect and fix overlay2FS corruption issue
service: armada
runbook-name: "armada - Procedure to detect and fix overlay2FS corruption issue"
tags: alchemy, armada, health, docker, overlay2
link: /armada/armada-docker-overlay2FS-corruption-issue-fix.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Content
{:.no_toc}

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

---

## Purpose

The purpose of this runbook is to detect and fix container metadata and container images (under overlay2FS) corruption issue on worker nodes where `docker_data` device is getting used for storing docker root(`/var/lib/docker/`) data.

## Technical Details

This issue occurs on worker nodes of cluster when `docker_data` device (the encrypted device) is getting activated after docker engine start. Due to this behaviour docker metadata is getting out of sync.<br>

For example, `var/lib/docker/plugins` and `/var/lib/docker/overlay2` are on Primary disk as shown below:

~~~~~
/var/lib/docker/plugins and /var/lib/docker/overlay2 on primary device
/dev/sda6 on / type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
/dev/sda1 on /boot type ext2 (rw,relatime,block_validity,barrier,user_xattr,acl,stripe=256)
/dev/sda6 on /var/lib/docker/plugins type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
/dev/sda6 on /var/lib/docker/overlay2 type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
~~~~~

Once `docker_data` device is activated and mounted on `/var/lib/docker`, the data/files under `/var/lib/docker/overlay2` and `/var/lib/docker/plugins` is getting out of sync giving the impression of Overlay2 FS corruption.<br>

Once the `docker_data` is in use for docker root, the `/var/lib/docker/overlay2` and `/var/lib/docker/plugins` should be on `docker_data` like below:

~~~~~
/dev/sda6 on / type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
/dev/sda1 on /boot type ext2 (rw,relatime,block_validity,barrier,user_xattr,acl,stripe=256)
/dev/mapper/docker_data on /var/lib/docker type ext4 (rw,relatime,stripe=64,data=ordered)
/dev/mapper/docker_data on /var/lib/docker/plugins type ext4 (rw,relatime,stripe=64,data=ordered)
/dev/mapper/docker_data on /var/lib/docker/overlay2 type ext4 (rw,relatime,stripe=64,data=ordered)
~~~~~

## User Impact

Because of overlay2FS corruption issue on a worker node, new pods scheduled on that worker node may stuck in `ContainerCreating` state and container lifecycle operations on containers present on that worker node may fail.

## How to detect Overlay2FS corruption issue

1. Check the POD status.<br>
   `kubectl describe pod <POD_NAME> -n <NAMESPACE>`

1. If the status is `BackOff / FailedSync` under `Events:` section,
   then check the POD logs `kubectl logs <POD_NAME> -n <NAMESPACE>`<br>
   or in case of multi-container pod, run<br>
   `kubectl logs <POD_NAME> -c <CONTAINER_NAME> -n <NAMESPACE>`<br>
   and if the log contains entry like

   ```
   /var/lib/docker/overlay2/ddb9ba284e273e286999658be9a28e8b59fb44c2b019334026b79848ad75f2dc: no such file or directory
   ```

   it means Container Image or OverLay2 FS corruption issue.

1. Find out the worker node IP(`<WORKER_NODE_IP>`) where above pod stuck in `ContainerCreating` state is
   scheduled.<br>
   `kubectl get pod <POD_NAME> -n <NAMESPACE> -o wide`<br>
   Sample output:

   ```
   NAME       READY   STATUS    RESTARTS   AGE   IP        NODE
   test-pod   1/1     Running   0          3d    x.x.x.x   y.y.y.y    
   ```

   In above output, IP mentioned under column `NODE` is worker node IP where pod landed.

1. SSH to worker node by following instructions
   [here](./armada-cruiser-worker-access.html) and get root access `sudo -i`.<br>

1. Check the `docker_data` device status by running below command<br>
   `cryptsetup status docker_data`<br>

   If output shows `/dev/mapper/docker_data is inactive.`, then fix for issue is not covered in this runbook.
   Please post issue in [#armada-docker](https://ibm-argonauts.slack.com/archives/C54G8FPEK) on slack with
   complete details.<br>
   If output shows `/dev/mapper/docker_data is active and is in use.`, then continue.

1. Check device tree by running command `lsblk`<br>
   Sample Output:

   ~~~~~
   # lsblk
   NAME            MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
   sda               8:0    0  1000G  0 disk  
   |-sda1            8:1    0   243M  0 part  /boot
   |-sda2            8:2    0     1K  0 part  
   |-sda5            8:5    0   976M  0 part  [SWAP]
   `-sda6            8:6    0 998.8G  0 part  /
   sdb               8:16   0   6.3T  0 disk  
   `-sdb1            8:17   0   6.3T  0 part  
     `-docker_data 252:0    0   6.3T  0 crypt
   ~~~~~

1. Check the device mounts by running command `mount | grep '^/dev'`<br>
   Sample output:

   ~~~~~
   # mount | grep '^/dev'
   /dev/sda6 on / type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
   /dev/sda1 on /boot type ext2 (rw,relatime,block_validity,barrier,user_xattr,acl,stripe=256)
   /dev/sda6 on /var/lib/docker/plugins type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
   /dev/sda6 on /var/lib/docker/overlay2 type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
   /dev/mapper/docker_data on /var/lib/docker type ext4 (rw,relatime,stripe=64,data=ordered)
   ~~~~~

   if `/var/lib/docker` is mount point for `docker_data` device but `/var/lib/docker/overlay2` and `/var/lib/docker/plugins` are not on `/dev/mapper/docker_data` as given in above sample output,
   then goto section **Steps to fix Overlay2FS corruption issue** for fixing the improper target device
   and docker metadata synchronisation causing overlay2FS corruption.

## Steps to fix Overlay2FS corruption issue

1. Stop docker and containerd.

   ~~~~~
   # systemctl stop docker
   # systemctl stop containerd
   ~~~~~

1. Deactivate `docker_data`.

   ~~~~~
   # umount /var/lib/docker
   # cryptdisks_stop docker_data
       Stopping crypto disk...
       docker_data (stopping)...
   ~~~~~

1. Unmount `/var/lib/docker/overlay2`.

   ~~~~~
   # umount /var/lib/docker/plugins
   # for mp in $(mount | grep 'type overlay' | awk '{ print $3 }'); do umount $mp; done
   # umount /var/lib/docker/overlay2
   ~~~~~

1. Check the mounted device by running `mount | grep '^/dev'`.<br>
   Sample output:

   ~~~~~
   # mount | grep '^/dev'
   /dev/sda6 on / type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
   /dev/sda1 on /boot type ext2 (rw,relatime,block_validity,barrier,user_xattr,acl,stripe=256)
   ~~~~~

1. Now activate `docker_data` device by running `cryptdisks_start docker_data`.<br>
   Sample Output:

   ~~~~~
   # cryptdisks_start docker_data
       Starting crypto disk..
       docker_data (starting)..
       docker_data (started)...  
   ~~~~~

   Also, verify device tree and device mounts. Sample output:

   ~~~~~
   root@kube-lon04-cr17e57b18b8e04e5ebbfe4abee0f205a3-w15:/var/log# lsblk
   NAME            MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
   sad               8:0    0  1000G  0 disk  
   |-sda1            8:1    0   243M  0 part  /boot
   |-sda2            8:2    0     1K  0 part  
   |-sda5            8:5    0   976M  0 part  [SWAP]
   `-sda6            8:6    0 998.8G  0 part  /
   sdb               8:16   0   6.3T  0 disk  
   `-sdb1            8:17   0   6.3T  0 part  
     `-docker_data 252:0    0   6.3T  0 crypt

   # mount | grep '^/dev'
   /dev/sda6 on / type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
   /dev/sda1 on /boot type ext2 (rw,relatime,block_validity,barrier,user_xattr,acl,stripe=256)
   ~~~~~

1. Mount `/var/lib/docker` by running `mount /var/lib/docker`<br>
   Now, verify device mounts. Sample output:

   ~~~~~
   # mount | grep '^/dev'
   /dev/sda6 on / type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
   /dev/sda1 on /boot type ext2 (rw,relatime,block_validity,barrier,user_xattr,acl,stripe=256)
   /dev/mapper/docker_data on /var/lib/docker type ext4 (rw,relatime,stripe=64,data=ordered)
   ~~~~~

1. Start containerd and docker

   ~~~~~
   # systemctl start containerd.service
   # systemctl start docker.service
   ~~~~~

   Now, verify device mounts again. Sample output:
   
   ~~~~~
   # mount | grep '^/dev'
   /dev/sda6 on / type ext4 (rw,relatime,errors=remount-ro,stripe=64,data=ordered)
   /dev/sda1 on /boot type ext2 (rw,relatime,block_validity,barrier,user_xattr,acl,stripe=256)
   /dev/mapper/docker_data on /var/lib/docker type ext4 (rw,relatime,stripe=64,data=ordered)
   /dev/mapper/docker_data on /var/lib/docker/plugins type ext4 (rw,relatime,stripe=64,data=ordered)
   /dev/mapper/docker_data on /var/lib/docker/overlay2 type ext4 (rw,relatime,stripe=64,data=ordered)
   ~~~~~

## Escalation

If you have any problems with the above steps, feel free to talk to anyone from the [#armada-docker](https://ibm-argonauts.slack.com/archives/C54G8FPEK) on Slack or page out the Armada-Docker Suqad uisng `Alchemy - Containers Tribe - armada-docker`.
