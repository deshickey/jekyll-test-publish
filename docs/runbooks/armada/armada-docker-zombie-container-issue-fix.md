---
layout: default
description: Procedure to detect and fix zombie container issue
title: armada-docker - Procedure to detect and fix zombie container issue
service: armada
runbook-name: "armada - Procedure to detect and fix zombie container issue"
tags: alchemy, armada, health, docker, zombie
link: /armada/armada-docker-zombie-container-issue-fix.html
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

The purpose of this runbook is to detect and fix zombie container issue.

## Technical Details

Zombie container issue refers to the situation where the container is active for docker-engine but the actual container process exited/terminated.<br>
This is basically docker-engine bug. This issue happens when docker-engine is internally not able to sync with `docker-runc` that means container is active/running for docker-engine but container is not in existance for docker-runc.

## User Impact

Because of zombie container issue, some pods maybe stuck in `Terminating` state and stop/kill operation
on some/all docker containers (which are part of pod stuck in `Terminating` state) may not work as expected.

## How to detect zombie container issue

1. Find out the worker node IP(`<WORKER_NODE_IP>`) where pod stuck in `Terminating` state landed.<br>
   `kubectl get pod <POD_NAME> -n <NAMESPACE> -o wide`<br>
   Sample output:

   ```
   NAME       READY   STATUS    RESTARTS   AGE   IP        NODE
   test-pod   1/1     Running   0          3d    x.x.x.x   y.y.y.y    
   ```

   In above output, IP mentioned under column `NODE` is worker node IP where pod landed.

1. SSH to worker node by following instructions
   [here](./armada-cruiser-worker-access.html) and get root access `sudo -i`.<br>

1. Execute below command to detect zombie container issue:

   ~~~~~
   for id in $(docker ps -q); do pid=$(docker inspect --format='{{"{"}}{{"{"}}.State.Pid}}' $id); ps -o pid,lstart,status,cmd --no-headers --pid $pid > /dev/null; if [[ $? -ne 0 ]]; then echo "ZOMBIE Container  $id => $pid"; echo $id >> /tmp/zombie_container_list.txt; fi; done;
   ~~~~~

   Check whether output of above command contains lines starting with prefix `ZOMBIE Container` as given below:

   ~~~~~
   ZOMBIE Container  ce1a936e715c => 36773
   ZOMBIE Container  93ea4ba775ce => 36615
   ZOMBIE Container  77245be9576b => 52899
   ZOMBIE Container  ed39a8c3af36 => 18611
   ZOMBIE Container  5621fa177feb => 18471
   ZOMBIE Container  9a7b6019e5b2 => 38910
   ZOMBIE Container  19b14722b3f7 => 38399
   ~~~~~

   If output of above command contains lines starting with prefix `ZOMBIE Container` that means docker-engine
   hit with zombie container issue and all such zombie container's id will be saved in file `/tmp/zombie_container_list.txt`. In this case, please goto section **Steps to fix zombie container issue**.

## Steps to fix zombie container issue

To fix zombie container issue, We need to remove all such zombie containers from worker node.<br>
Execute below command in worker node which will get id of all zombie containers from file `/tmp/zombie_container_list.txt` and remove all such zombie containers:

~~~~~
docker rm -f $(cat /tmp/zombie_zontainer_list.txt)
~~~~~

Also, delete file `/tmp/zombie_container_list.txt` by running command `rm /tmp/zombie_container_list.txt`.

After executing above commands, please verify that all pods which were stuck in `Terminated` state (and landed on
worker node where we executed above commands) should be deleted now. Below command **should not** return any pod stuck
in `Terminated` state.

~~~~~
kubectl get pods --all-namespaces |grep '<WORKER_NODE_IP>'
~~~~~

## Escalation

If you have any problems with the above steps, feel free to talk to anyone from the [#armada-docker](https://ibm-argonauts.slack.com/archives/C54G8FPEK) on Slack or page out the Armada-Docker Suqad uisng `Alchemy - Containers Tribe - armada-docker`.
