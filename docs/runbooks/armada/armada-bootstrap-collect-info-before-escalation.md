---
layout: default
description: Collecting info to escalate to the bootstrap squad
title: armada-bootstrap - Collecting info before escalation
service: armada-bootstrap
runbook-name: "armada-bootstrap -  Collecting info before escalation"
tags: alchemy, armada, bootstrap,
link: /armada/armada-bootstrap-collect-info-before-escalation.html
type: Operations
parent: Armada
grand_parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview
### Collecting info before escalating to the bootstrap team

The problem you are escalating to the bootstrap team likely has a worker associated with it that you want debugged. When escalating to the bootstrap squad you will need to collect the following information about your problem for the team to analyze. The workerID will be specified in the customer ticket or pager duty incident.

## Detailed Information

### Checking for Worker Operating System

1. Query for worker pool info in #armada-xo
   ```
   @xo cluster <clusterID>
   @xo workerPool <workerPoolID>
   ```

2. From the above output, find `"OperatingSystem"`

3. Determine if the worker OS is x86 or s390x:
    - x86: Includes "_64" suffix (e.g. UBUNTU_18_64, UBUNTU_20_64, REDHAT_8_64)
    - s390x: Includes "_S390X" suffix (e.g. UBUNTU_18_S390X, UBUNTU_20_S390X)

### Retrieving the Bootstrap Logs through jenkins job

1. Go to the jenkins job [armada-retrieve-bootstrap-logs](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-retrieve-bootstrap-logs/) and select `Build with Parameters`

2. Use the defaults `master` for the BRANCH and ENV_BRANCH parameters

3. Enter the worker id to get the logs along with the index. The format would be `<workerid>_0`. Worker index starts at 0 and maxes at 9. The first failure attempt is 0, so it is a good one to start with!  If needed you can get the worker-ID from: `@xo clusterWorkers <CLUSTER_ID>`   for example: `kube-cd2ofprd0gcbdjv2dj3g-stage4ussou-custome-00000581_0`

4. For the tugboat name, enter in the microservice tugboat for the region:
    - us-south: prod-dal10-carrier105
    - us-east: prod-wdc04-carrier103
    - ca-tor: prod-tor01-carrier102
    - br-sao: prod-sao01-carrier102
    - eu-central: prod-fra02-carrier105
    - uk-south: prod-lon04-carrier101
    - ap-north: prod-tok02-carrier105
    - ap-south: prod-syd01-carrier102
    - jp-osa: prod-osa21-carrier100
    - eu-fr2: prodfr2-par04-carrier100
    - dev: dev-dal10-carrier104
    - prestage: prestage-dal10-carrier101
    - stage-main: stage-dal10-carrier103
    - stage-performance-env-4: stage-dal10-carrier401
    - stage-performance-env-5: stage-dal10-carrier501

NOTE: If the ones listed above don't work, then use this [armada-envs repo search URL](https://github.ibm.com/alchemy-containers/armada-envs/search?q=MicroservicesAndEtcd) to find the right tugboat for the region.  For instance if you are looking for the us-east microservices tugboat, find the carrierXXX.yml file in the search results from us-east (currently it is prod-wdc04/carrier103.yml).  Then run the job again using that tugboat (replacing the '/' with a '-', and leaving off the `.yml`), and then update this runbook.

5. For the carrier, from the dragdown choose a carrier within the same datacenter.  If that one doesn't return the logs, try again with a different one from that region.

6. Once job has finished, review the artifacts for the logs. 
  - artifacts can be found at the base of the job that was built
  - if logs were found, an artifact named after the `WORKER_ID_AND_INDEX ` parameter will be present.
  - if no logs are found, it is possible that the wrong tugboat was chosen, or the worker could not post logs back to the bootstrap microservice due to firewall rules of the customer, or the bootstrap microservice pods might have restarted or deleted the logs due to time/space constraints.

7. If the job can not retrieve the logs, ask the customer to try to deploy another node to recreate the problem, and when that one fails, run the jenkins job on that worker ID immediately to try to get the log again.

### Collecting Worker Logs on the node

For classic clusters, help the customer SSH into the worker and provide the output of the following commands.  For VPC clusters, ask the customer to create a VSI in the same VPC and subnet as the problem worker (since they can not SSH into VPC workers).  Then have the customer run the commands below to troubleshoot.  Name the saved terminal output of the listed commands based off the name specified above the commands. Save each set of commands as a separate output clearing the terminal screen after each set<br><br>


**Classic Only:** *workerID*-firstboot.log (example: kube-dal10-cr2ceff3fc1e214d66a1400ca632c61e59-w131-firstboot.log)

~~~~~
cat /var/log/firstboot.log
~~~~~

**Classic Only:** *workerID*-bootstrap_base.log

~~~~~
cat /tmp/bootstrap/bootstrap_base.log
~~~~~

**Classic and VPC:** *workerID*-apt-get.log (Testing apt get commands work)

~~~~~
for i in {1..15}; do apt-get update -y; done
apt-get install apache2-utils -y
apt-get upgrade -y
~~~~~

**Classic and VPC:** *workerID*-carrier-networking.log (Testing that networking works)

~~~~~
for i in {1..7}; do nslookup <carrier DNS>; done (example for us-south: nslookup us.icr.io)
apt-get update -y
apt-get upgrade -y
apt-get install mtr-tiny -y
mtr -rw <carrier DNS> (example for us-south: mtr -rw us.icr.io)
curl -v https://<carrier DNS>  (example for us-south: curl -v https://us.icr.io)
~~~~~

**Classic and VPC:** *workerID*-docker-connectivity.log (Testing connectivity to the proper registry)

~~~~~
sudo su
docker pull <regitry>/armada-master/hyperkube-amd64 (this will just test connectivity. Example for us-south us.icr.io/armada-master/hyperkube-amd64)
journalctl -u docker
~~~~~


## Detailed Procedure

The following is only needed if jenkins is down and the job above can not be run.

### Collecting Logs For the worker on all backing carriers
Log into each carrier master that backs the region the worker is in and save the terminal output based with the same name<br><br>
*AZ*-*carrierIdentifier*-*WorkerID*-bootstrap-pods.log <br> (example for us-south: dal12-carrier2-kube-dal10-cr2ceff3fc1e214d66a1400ca632c61e59-w131-bootstrap-pods.log and dal10-carrier3-kube-dal10-cr2ceff3fc1e214d66a1400ca632c61e59-w131-bootstrap-pods.log)

~~~~~
WORKER_ID="workerID" (example: WORKER_ID="kube-dal10-cr2ceff3fc1e214d66a1400ca632c61e59-w131")
for i in `kubectl -n armada get pods | grep "armada-bootstrap" | awk '{print $1}'`; do echo "NODEID $i"; kubectl -n armada logs --tail=500 $i; done | grep "Received Logs From Worker: $WORKER_ID" > file
awk '{gsub(/\\n/,"\n")}1' file > formatted.log
cat formatted.log
~~~~~

*AZ*-*carrierIdentifier*-*WorkerID*-general-worker.log <br>

~~~~~
WORKER_ID="workerID" (example: WORKER_ID="kube-dal10-cr2ceff3fc1e214d66a1400ca632c61e59-w131")
for i in `kubectl -n armada get pods | grep "armada-bootstrap" | awk '{print $1}'`; do echo "NODEID $i"; kubectl -n armada logs --tail=500 $i; done | grep "$WORKER_ID" > file
awk '{gsub(/\\n/,"\n")}1' file > formatted.log
cat formatted.log
~~~~~

*AZ*-*carrierIdentifier*-*WorkerID*-master-info.log <br>

~~~~~
WORKER_ID="workerID" (example: WORKER_ID="kube-dal10-cr2ceff3fc1e214d66a1400ca632c61e59-w131")
CLUSTER_ID=$(echo $WORKER_ID | cut -f3 -d '-' | cut -c 3-)
kubectl -n kubx-masters get all | grep $CLUSTER_ID
~~~~~

*AZ*-*carrierIdentifier*-*WorkerID*-bootstrap-config.log <br>

~~~~~
kubectl -n armada get cm armada-bootstrap-config -o yaml
~~~~~

## Escalation
Tar up all these files and add the tar in an issue. Open an issue in the [{{ site.data.teams.armada-bootstrap.name }}]({{ site.data.teams.armada-bootstrap.issue }}) GitHub repository. If paging, include the link to the issue that has the tar of all the above commands/output.

If a CIE has been raised and you need assistance, you can engage the development squads depending on the impacted situation. Please refer to the guidance below:

1. If there is already an ongoing issue in the environment and a new issues comes in for s390x, there will no need to reach out to the Z development squad. IKS development squad is already actively engaged and will loop in Z development squad, if needed.
    - e.g. VPC capacity issues in Madrid. x86 workers are failing to provision. An s390x customer comes in to try to provision and fails, triggering a new alert. No need to triage the new alert - we can include it in the existing issues.
1. If new alerts are triggered AND workers are BOTH x86 and s390x, this can be routed directly to the IKS development squad.
    - e.g. CBR issues causing workers unable to contact armada-bootstrap microservice.
1. If conditions 1 and 2 are NOT met, AND the architecture is s390x, please page out to the Z development squad.

PagerDuty Escalation Policies:
- IKS development squad: [{{ site.data.teams.armada-bootstrap.escalate.name }}]({{ site.data.teams.armada-bootstrap.escalate.link }})
- Z development squad: [{{ site.data.teams.armada-hyper-protect.escalate.name }}]({{ site.data.teams.armada-hyper-protect.escalate.link }})

NOTE: If the Z development squad does get paged for whatever reason, they should feel empowered to page out the IKS development squad/US Bootstrap squad if they get stuck and are unsure how to progress further.

If this is not a CIE, you can reach out using the [{{ site.data.teams.armada-bootstrap.comm.name }}]({{ site.data.teams.armada-bootstrap.comm.link }}) Slack channel or create a issue in the [{{ site.data.teams.armada-bootstrap.name }}]({{ site.data.teams.armada-bootstrap.issue }}) GitHub repository for later follow-up.
