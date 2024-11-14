---
layout: default
description: Procedure to check docker-engine health and recover it
title: armada-docker - Procedure to check docker-engine health and recover unhealthy docker-engine
service: armada
runbook-name: "armada - Procedure to check docker-engine health and recover unhealthy docker-engine"
tags: alchemy, armada, health, docker
link: /armada/armada-docker-health-check.html
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

## Overview

The purpose of this runbook is to detect health issues with docker-engine and recover unhealthy docker-engine.

## Example Alert(s)

Docker-engine has dependencies on various Kernel modules like netlink for networking, devicemapper for LVM2,
user-namespace, cgroup and others. Most of the time, issues/defects in Kernel modules or any other module  can
cause system calls from docker getting stuck and it results in unresponsive docker.

If you have received following PagerDuty alert for Armada, this runbook will help you to resolve the issue.

1. `Critical:` `<Hostname / Host IP>_docker_not_healthy`

1. `Critical:` `<Hostname / Host IP>_unable_to_recover_docker`

1. `Critical:` `<Hostname / Host IP>_docker_health_monitor_inactive`

1. `Critical:` `<Hostname / Host IP>_containerd_not_healthy`

1. Warning: `<Hostname / Host IP>_docker_maybe_unhealthy`

1. Warning: `<Hostname / Host IP>_container_removal_failing`

1. Warning: `<Hostname / Host IP>_docker_health_partially_verified`

## User Impact

Because of unresponsive docker-engine the operation on containers, like start/stop/pause/unpause/remove,
fail for the containers hosted on the worker node with hang docker.<br>

This may impact POD deletion, auto-recovery and auto-scaling.

Unresponsive docker has no impact on the active container applications, it does not terminate or freeze any container.

## Investigation and Action

1. `Critical: <Hostname / Host IP>_docker_not_healthy`:<br>
   - Find worker node IP which is included in PD alert name (ex: `<Hostname / Host IP>_docker_not_healthy`).<br>
     Or find the worker node IP in the PD details like `- hostname = 10.171.220.205`<br>
   - SSH to worker node and get root access `sudo -i`<br>
   - Execute command `/usr/local/bin/docker-health-recovery.sh`<br>
     to verify if docker is still getting reported as unhealthy.<br>
     If last line of output contains `INFO: Docker is healthy.`,<br>
     then docker is healthy and resolve PD alert manually,<br>
     else go to section **How to detect unhealthy docker-engine?**<br>
     and follow `Check Containerd health` & `Try to create and remove a simple container`<br>

1. `Critical: <Hostname / Host IP>_unable_to_recover_docker`:<br>
   Go to section **Manual Docker-engine recovery**

1. `Critical: <Hostname / Host IP>docker_health_monitor_inactive`:<br>
   Go to section **Manual Docker-health-monitor recovery**

1. `Critical: <Hostname / Host IP>_containerd_not_healthy`:<br>
   Go to section **Manual Containerd recovery**

1. Warning: `<Hostname / Host IP>_docker_maybe_unhealthy`:<br>
   Go to section **How to detect unhealthy docker-engine?**<br>
   and follow `Check Containerd health` & `Try to create and remove a simple container`

1. Warning: `<Hostname / Host IP>_container_removal_failing`:<br>
   Go to section **How to detect unhealthy docker-engine?**<br>
   and follow `Check Containerd health` & `Try to create and remove a simple container`

1. Warning: `<Hostname / Host IP>_docker_health_partially_verified`:
   Not able to execute all checks to verify the docker-engine health.
   This may be due to some intermittent issues. Wait for 15mins, if it occurs again
   then post the issue in [#armada-docker](https://ibm-argonauts.slack.com/archives/C54G8FPEK) and escalate to `Alchemy - Containers Tribe - armada-docker`

## Capture following logs and info from the worker node

Capture following logs and information to share with [#armada-docker] while escalating the issue to the Squad.
- /var/log/syslog
- /var/log/docker.log
- /var/log/containerd.log
- /var/log/docker-health-monitor/service.log
- /var/log/kern.log
- systemctl cat docker.service
- systemctl cat docker-health-monitor.service
- ps -o pid,lstart,args --pid $(pidof dockerd)
- ps -o pid,lstart,args --pid $(pidof docker-containerd)

In case you have to escalate the issue to [#armada-docker], please create an issue under https://github.ibm.com/alchemy-containers/armada-docker and upload the logs & info captured above.

## How to detect unhealthy docker-engine?

- Find worker node IP which is included in PD alert name (ex: `<Hostname / Host IP>_docker_not_healthy`).<br>
  Or find the worker node IP in the PD details like `- hostname = 10.171.220.205`<br>
- SSH to worker node and get root access `sudo -i`<br>
- If docker-health-monitor service is installed on a node<br>
  Check for script `ls /usr/local/bin//docker-health-recovery.sh`. If the script is there, then execute it once without any argument<br>
  `/usr/local/bin//docker-health-recovery.sh`

### Check Containerd health
1. Check the Containerd health
   `docker-containerd-ctr --address unix:///var/run/docker/libcontainerd/docker-containerd.sock version`<br>
   If the above cmd return with `rpc error` then wait for 10secs and retry above cmd
   If on second try also the cmd is returning `rpc error` then Docker and Containerd are in bad health,
   please follow **Manual Docker-engine recovery** otherwise continue

### Try to create and remove a simple container<br>
1. Create a container
   `timeout -s 9 180 docker run --name check_dockerhealth_01 alpine date; echo "RC=$?"`<br>
   If the container creation fails with `docker: Error response from daemon: grpc: the connection is unavailable.`,<br>
   then go to **Manual Docker-engine recovery** otherwise continue with next step

   If the above cmd `docker run` terminates with `RC=137`<br>
   Wait for 2-3mins and repeate `Create container`. If it terminates with `RC=137` on second execution as will
   then go to **Check for docker hang**.

1. Remove the container
   `timeout -s 9 180 docker rm check_dockerhealth_01; echo "RC=$?"`<br>
   If the above cmd terminates with `RC=137`<br>
   then check container state<br>
   `docker inspect check_dockerhealth_01 | grep "Running"`<br>
   If in the ouput you get `"Running": true,` <br>
   then go to **Manual Docker-engine recovery** otherwise continue with **Check for docker hang**<br>

### Check for docker hang

The main symptom of docker hang is `docker ps` command execution hangs<br>
ssh to **worker node** (ex: stage-dal09-carrier1-worker-01)<br>

1. Make sure docker is not overloaded and busy,
   run `timeout -s 9 300 docker images; echo "RC=$?"`<br>
   if the command terminates with `RC=137`, it means the docker is busy and overloaded<br>
   Wait for 2-3mins and repeate this setp once more. On second attempt also docker
   not responding, then docker hang might have occured go to **Manual Docker-engine recovery**.

1. Execute `docker-containerd-ctr --address unix:///var/run/docker/libcontainerd/docker-containerd.sock version`<br>
   If the above cmd return with `rpc error` then got to **Manual Docker-engine recovery**.<br>

1. Execute `timeout -s 9 300 docker ps; echo "RC=$?"` on the worker node, if the cmd terminates with `RC=137` then
   got to **Manual Docker-engine recovery**.<br>

1. Check for NFS issue<br>
   On the work node execute<br>
   `grep "timed out" /var/log/kern.log`<br>
   In the ouput if you see server timeouts like `nfs: server nfslon0202a-fz.service.softlayer.com not responding, timed out`
   Then chances are, docker hang may be becuase of NFS issue. Go to **NFS  troubleshooting**

1. If you are looking into resolution for following PD Alerts and reached here
   - `docker_maybe_unhealthy`
   - `container_removal_failing`<br>

   then stop here and post the issue in [#armada-docker](https://ibm-argonauts.slack.com/archives/C54G8FPEK)

## Docker-engine recovery

### Manual Docker-engine recovery
Note: While recovery the node will be in `SchedulingDisabled` and may go to `NotReady` state for a short duration.

1. SSH to **Worker node**. You can get the worker node IP from PD details like `- hostname = 10.171.220.205`<br>

1. Get root access `sudo -i`

1. Get the Node name<br>
   `grep 'THIS_NODE=' /usr/local/bin/docker-health-recovery.sh`<br>
   output will be similar to `THIS_NODE="10.171.220.205"` where `10.171.220.205` is **node name**

1. Cordon the node<br>
   `armada-cordon-node  --reason "docker-engine recovery in-progress"  <node name>`<br>

   Or if `armada-cordon-node` is not installed

   `kubectl cordon <node name>`<br>
   `now=$(date -u --iso-8601=seconds); kubectl annotate node <node name> --overwrite node.cordon.reason="$now docker-engine recovery in-progress"`

1. Stop docker-engine<br>
  `timeout -s 9 300 systemctl stop docker; echo "RC=$?"`<br>
   If cmd is terminating with `RC=137` then reboot is required for worker node<br>
   go to runbook [reboot-worker](./armada-carrier-node-troubled.html#rebooting-worker-node)

1. Start docker-engine<br>
   `systemctl start docker`

1. Wait for docker to listen over Socket<br>
   Execute following cmd at the interval for 30seconds until you get `docker up`<br>
   `ss -lx | grep -q /var/run/docker.sock; [[ $? -eq 0 ]] && echo "docker up"`

1. Verify docker is up<br>
   `timeout -s 9 120 docker info`

1. Restart Kubelet<br>
   `systemctl restart kubelet`

1. Uncordon the node<br>
   `armada-uncordon-node <node name>`<br>

   Or if `armada-uncordon-node` is not installed

   `kubectl uncordon <node name>`<br>
   `kubectl annotate node <node name> node.cordon.reason-`

1. Verify that calico-node pod has started correctly: `kubectl get pods -n kube-system -l k8s-app=calico-node -o wide | grep <WORKER_IP>`

   If calico-node does not get to `2/2    Running` status, then there might still be docker problems.  If no other pods show indications of problems with docker, then use the [Kubernetes Networking Calico Node Troubleshooting Runbook](./armada-network-calico-node-troubleshooting.html) to get calico-node running again.

### Manual Docker-health-monitor recovery

1. Check the docker health monitor status is inactive<br>
     `curl http://<host private net ip normally start with 10>:65510/get/summaryMetrics`<br>
    Verify the output of the above command failed for `curl: (7) Failed to connect to <host private net ip> port 65510: Connection refused` then Docker-health-monitor is inactive

1. Restart docker health monitor<br>
    `systemctl restart docker-health-monitor`

1. Check the docker health monitor status<br>
    `curl http://<host private net ip normally start with 10>:65510/get/summaryMetrics`<br>
    Verify the output of the command contains "docker_health_status":"1", which is active

### Manual Containerd recovery

1. SSH to **Worker node**. You can get the worker node IP from PD details like `- hostname = 10.171.220.205`<br>

1. Get root access `sudo -i`

1. Get the Node name<br>
   `grep 'THIS_NODE=' /usr/local/bin/docker-health-recovery.sh`<br>
   output will be similar to `THIS_NODE="10.171.220.205"` where `10.171.220.205` is **node name**

1. Cordon the node<br>
   `armada-cordon-node  --reason "docker-engine recovery in-progress"  <node name>`<br>

   Or if `armada-cordon-node` is not installed

   `kubectl cordon <node name>`<br>
   `now=$(date -u --iso-8601=seconds); kubectl annotate node <node name> --overwrite node.cordon.reason="$now docker-engine recovery in-progress"`

1. Stop docker-engine<br>
  `timeout -s 9 300 systemctl stop docker; echo "RC=$?"`<br>
   If cmd is terminating with `RC=137` then reboot is required for worker node<br>
   go to runbook [reboot-worker](./armada-carrier-node-troubled.html#rebooting-worker-node)

1. Check if Containerd is managed by Systemd then stop the Containerd<br>
   Execute `systemctl is-enabled containerd`<br>
   If the output is `enabled` then stop the continerd `systemctl stop containerd`<br>
   If the output is `Failed to get unit file state for containerd.service: No such file or directory` then skip this step<br>

1. Find container with corrupted metadata<br>
   Check the container folders under `/var/run/docker/libcontainerd/containerd/<container-id>/init` is missing any one of the files - `/var/run/docker/libcontainerd/containerd/<container-id>/init/process.json`,  `/var/run/docker/libcontainerd/containerd/<container-id>/init/log.json` or `/var/run/docker/libcontainerd/containerd/<container-id>/init/shim-log.json`<br> by executing the below command <br>
   `find /var/run/docker/libcontainerd/containerd -mindepth 2 -maxdepth 2 -type d '!' -exec sh -c 'ls -1 "{}"|egrep -i -q "(process|log|shim-log).json"' ';' -print`<br>

   Sample output<br>
   `/var/run/docker/libcontainerd/containerd/2825d1fff32f6472ea2b0b84245e5b1378b6d9e1bc515b08c73ad9dcfd307914/init`<br>
   `/var/run/docker/libcontainerd/containerd/5ad35a976303cf4331470c8c38231a2a958c350428b8d436bae3036de1b5f769/init`

1. Remove the container dir<br>
    Remove the each container folder which has corrupted metadata
    `rm -R /var/run/docker/libcontainerd/containerd/<container-id>`<br>

    Example<br>
    `rm -R /var/run/docker/libcontainerd/containerd/2825d1fff32f6472ea2b0b84245e5b1378b6d9e1bc515b08c73ad9dcfd307914`<br>
    `rm -R /var/run/docker/libcontainerd/containerd/5ad35a976303cf4331470c8c38231a2a958c350428b8d436bae3036de1b5f769`

1. Check if Containerd is managed by Systemd then restart the Containerd<br>
   Execute `systemctl is-enabled containerd`<br>
   If the output is `enabled` then restart continerd `systemctl restart containerd`<br>
   If the output is `Failed to get unit file state for containerd.service: No such file or directory` then skip this step<br>

1. Restart docker-engine<br>
   `systemctl restart docker`

1. Check Containerd<br>
    `docker-containerd-ctr --address unix:///var/run/docker/libcontainerd/docker-containerd.sock version`

1. If still Docker and Containerd unhealthy escalate to `armada-docker`.
   Create an issue under https://github.ibm.com/alchemy-containers/armada-docker and upload the logs and info captured above.

## NFS  troubleshooting
Even after following the steps the issue is re-occurring or not getting resolved, then check for NFS access issue

1. Get the docker-engine thread list stuck in uninterruptible sleep
   `sudo ps -p $(pgrep 'bin/dockerd' -f) -m eo pid,lwp,stat,wchan:20 | grep ' D'`

1. Check the stack for each thread in uninterruptible sleep
   `sudo cat /proc/$(pgrep 'bin/dockerd' -f)/task/<thread id>/stack`

   Example:

   ```
   sudo ps -p 854 -m eo pid,lwp,stat,wchan:20 | grep ' D'
       -    3262 Dsl  rpc_wait_bit_killable
   sudo cat /proc/854/task/3262/stack
   [<ffffffffc012d444>] rpc_wait_bit_killable+0x24/0xb0 [sunrpc]
   [<ffffffffc012e53d>] __rpc_execute+0x14d/0x440 [sunrpc]
   [<ffffffffc013155e>] rpc_execute+0x5e/0xb0 [sunrpc]
   [<ffffffffc0125210>] rpc_run_task+0x70/0x90 [sunrpc]
   [<ffffffffc04e3176>] nfs4_call_sync_sequence+0x56/0x80 [nfsv4]
   [<ffffffffc04e4a47>] _nfs4_proc_access+0x107/0x170 [nfsv4]
   [<ffffffffc04ee95e>] nfs4_proc_access+0x4e/0xc0 [nfsv4]
   [<ffffffffc0211136>] nfs_do_access+0xe6/0x3b0 [nfs]
   [<ffffffffc0211542>] nfs_permission+0x112/0x1a0 [nfs]
   [<ffffffff812084a4>] __inode_permission+0x64/0xc0
   [<ffffffff81208518>] inode_permission+0x18/0x50
   [<ffffffff8120a9da>] link_path_walk+0x29a/0x560
   [<ffffffff8120ad9f>] path_lookupat+0x7f/0x110
   [<ffffffff8120d3bc>] filename_lookup+0x9c/0x150
   ```
1. If there is nfs4 or nfs related call in the stack, then post the issue in [#armada-docker](https://ibm-argonauts.slack.com/archives/C54G8FPEK) on Slack
   or pageout the Docker-Infra (Armada-Docker) Squad `Alchemy - Containers Tribe - armada-docker`

## Escalation Policy

If you have any problems with the above steps, feel free to talk to anyone from the [#armada-docker](https://ibm-argonauts.slack.com/archives/C54G8FPEK) on Slack or page out the Armada-Docker Suqad uisng `Alchemy - Containers Tribe - armada-docker`.
