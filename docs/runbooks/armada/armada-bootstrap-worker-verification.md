---
layout: default
description: Verifying dependencies of the bootstrap process on a worker
title: armada-bootstrap - How to verify all bootstrap dependencies functioning properly
service: armada-bootstrap
runbook-name: "armada-bootstrap - general worker verification"
tags: alchemy, armada, bootstrap,
link: /armada/armada-bootstrap-worker-verification.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

The bootstrap process is run on customer workers during a cluster deploy. This process injects worker specific variations and installs various apt binaries to turn the worker into a functioning Kuberentes node. It also pulls various docker containers that need to be ran on the worker in order for it to be a functioning Kuberentes worker (like Calico). This runbook walks through all the steps needed to verify the worker can successfully interact with all it's dependencies.

## Example Alerts
- none

## Investigation and Action

## Dependencies of the bootstrap process

The bootstrap process current list of dependencies is shown below
- Apt repository that the workers can interact with
- Network connectivity to *all* carrier hubs supporting a region (usually 2 carriers in 2 AZs behind a single DNS route).
- Functioning docker registry that contains all the images needed in the bootstrap process
- Functioning master API server

Below we list ways to verify each dependency. Each of these require ssh access to the worker node. Please work with the customer to gain this access so the necessary debugging can be done.

### Verifying Apt Repositories
The bootstrap process will make calls to apt-repos in order to download and install necessary apt binaries. apt-get install, apt-get upgrade, apt-get update, etc all need to work and point to a apt repo that contains all the necessary binaries. There also needs to be no other processes locking the apt-lock (/var/lib/dpkg/lock, /var/lib/apt/lists/lock, etc) on the worker. Verify this by running multiple apt commands and make sure they complete successfully

~~~~~
for i in {1..40}; do apt-get update -y; done
apt-get install apache2-utils -y
apt-get upgrade -y
~~~~~

These commands plus others should be ran over a few minutes to make sure the apt-repo is consistently up. If these commands are failing, the apt list should be verified (https://wiki.debian.org/SourcesList). In addition, one should contact the maintainers of the apt repo to see if the repo is currently down. *The repo has to be up or the bootstrap process will continue to fail*


### Verifying Network Connectivity To All Carrier Hubs

The worker will need network connectivity to all carrier hubs. Custom firewalls are malfunctioning routers can cause this connectivity to be lost. *The bootstrap process will not work if the worker cannot conenct to all carrier hubs for a region*. The subnets that connectivity are needed for are listed in the docs here: https://console.bluemix.net/docs/containers/cs_troubleshoot.html#cs_firewall.

First, verify the worker can resolve the DNS route that points to the carrier hubs. This should be well known for the region and is the same as the api endpoint (example for us-south: us-south.containers.bluemix.net). Verify this through nslookup

~~~~~
nslookup us-south.containers.bluemix.net
~~~~~

Nslookup should resolve to an IP address of one of the carrier hubs. If the command is ran multiple times, one can see it resolve to the multiple carrier VIPs that back the DNS endpoint.

Next, mtr should be used to verify the network hops look proper to the carrier. The mtr output should resolve all the way to the destination IP found from nslookup. Commands are listed below (docs are here: https://www.linode.com/docs/networking/diagnostics/diagnosing-network-issues-with-mtr).

~~~~~
apt-get update -y
apt-get upgrade -y
apt-get install mtr-tiny -y
mtr -rw <DNS NAME ex) us-south.containers.net>
~~~~~

Analyze the mtr report to make sure the network path looks good and healthy. If that looks good, try and curl the carrier

~~~~~
curl -v https://<DNS NAME ex) us-south.containers.net>
~~~~~

The curl request should return some sort of response (404/ error response is fine: we are just testing network connectivity).

**If any of the above commands fail or show suspicious output, the networking needs to be corrected to allow the worker to talk to the carrier hubs. This may involve reconfiguring custom firewalls or looking at why the networking on the host is not routing properly**.


### Functioning docker registry

One should know the registry the bootstrap process is trying to pull from. One can use the query below to determine it if they don't know what one is trying to be used.

~~~~~
cat /tmp/bootstrap/bootstrap_base.log | grep "docker pull"
~~~~~

The output should show a line that actually executes an example pull request that was executed on the worker node. The command will have the image name and registry it is stored in. Once that information is known, one should attempt to pull an image from the registry. Any image one knows exists in the registry can be used for the test.

~~~~~
sudo su
docker pull <regitry>/<image> (example: docker pull registry.ng.bluemix.net/armada/bootstrap:1145)
~~~~~

The pull request should execute successfully. If it does not, this problem needs to be fixed. More in depth logs can be found with

~~~~~
journalctl -u docker
~~~~~

The pull request needs to work since it is testing basic functionally that has to be provided by the registry.


### Functioning Kubernetes Master with network connectivity
The worker needs to be able to properly communicate with a functioning master api server for the cluster. A functioning master is needed in order for the Kuberentes cluster to work. This can be tested by executing kubectl commands on the worker.

~~~~~
sudo su
kubectl get pods --all-namespaces (should return all pods in the cluster)
kubetclt get nodes (should return all nodes in the cluster)
~~~~~

If these commands are not working, the master is either down or the worker cannot contact the master. Network connectivity needs to be restored (firewall changes, router fixes, etc) or the master needs to be corrected in order for the worker to successfully enter the cluster.



## Accessing A Worker

### SSH to worker

1. Use the armada private key [here](https://github.ibm.com/alchemy-1337/environment-dev-mon01/blob/master/SecretKeys/armada_ssh.key) and ssh into the worker. `ssh -i ~/.ssh/armada armada@<privateIPOfWorker>` (this requires openvpn to the specific environment). If this is not applicable then work with the customer to gain access to the worker.



## Escalation Policy
Please follow the [escalation guidelines](./armada-bootstrap-collect-info-before-escalation.html) to engage the bootstrap development squads.
