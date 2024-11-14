---
layout: default
description: Responsibilities of SRE/Conductors with regard to Jenkins
title: SRE Jenkins Responsibilities
service: Conductors
runbook-name: "SRE Jenkins Responsibilities"
link: /sre_jenkins_responsibilities.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# SRE Jenkins Responsibilities

## Overview

This runbook describes the responsibilities of the SRE/Conductors squad with regards to Jenkins


Jenkins along with Travis is an integral part of our CI/CD cycle. As such, we try to maintain the service as available as possible


The Jenkins service is provided by the Toolchain as a Service (Taas) group. However, the SRE/Conductors squad are admins on Jenkins. As such, the division of responsibilities is more or less pretty clear; the server, operating system are the responsibilities of the TaaS squad.

---

## Detailed information

### Instances

SRE/Conductors run 3 instances of Jenkins in our organisation and they are:
- [Containers](https://alchemy-containers-jenkins.swg-devops.com/)
- [Conductors](https://alchemy-conductors-jenkins.swg-devops.com/)
- [Testing](https://alchemy-testing-jenkins.swg-devops.com/)

### Sample TaaS Responsibilities

- disk full
- server down
- network issue
- upgrade Jenkins
- update OpenVPN clients

### Sample SRE/Conductors Responsibilities

- upgrade plugins
- restart OpenVPN clients
- build docker images used as node labels

### disk full

Responsibility is shared here between Taas, Conductors/SRE and the job owners. Conductors should initiate returning the jenkins instance to service by using the disk usage plugin to identify which job(s) are using up the most space. Click on the column titles to sort in descending or ascending order.

[Example link to Disk usage plugin](https://alchemy-containers-jenkins.swg-devops.com/disk-usage-simple/) on one of the instances

#### disk full - Job Owner
Once the job has been identified, contact the squad or last know person to modify the job. To find the last person to modify the job, check "Job Config History". Double check first to ensure whether the job is managed by "Jenkins Job builder".

The job owner will have to reconfigure the job to use up less space. They should keep in mind their audit requirements when they do so.

Some actions the owner could take include but is not limited to:
- configure -> Discard old builds -> set days and number of builds to keep
- configure -> Discard old builds -> advanced -> set days and number of artifacts to keep


### disk full - Conductors/ SRE 
After the job is reconfigured, the SRE will have to go to click on "run cleanup" in the Disk usage plugin page for that job. It will take a **long** time for the difference to show up.

#### disk full - TaaS
TaaS is contacted if none of the above steps are able to be implemented or fail to solve the issue or exepediency is necessary. Note that TaaS will work from the operating system level and may have to delete logs, files, etc that could be required for auditors

### Docker images used

The node labels are in actual fact docker images. They are currently stored in the [pipeline-build](https://github.ibm.com/alchemy-conductors/pipeline-build/) repo

The job to build these images is called [Build Docker Images](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Jenkins/job/Build_Docker_Images/) . The default parameter is "all" which is misleading as that is a static list and may not be updated in the repo. If a specific image needs to be built, it is best to provide the Dockerfile name as a parameter to the job

See the [useful links](#useful-links) section which has links to education on completing RCAs, amoung other things.


### Description of Setup

The 3 instances are located in SoftLayer's San Jose data center. TaaS has set up a private docker swarm for Alchemy's Jenkins instances. This swarm has 3 nodes.


### OpenVPN client

TaaS has their own version of Alchemy's [OpenVPN clients](https://github.ibm.com/alchemy-conductors/openvpn-clients) repo located [here](https://github.ibm.com/Cloud-DevOps-Transformation-Services/alchemy-vpn). It is manually updated by the SRE/Conductor. Once the SRE/Conductor has opened a PR, ping a TaaS squad member and ask them to merge. They will most likely _NOT_ review before merging.

### Restarting Jenkins' OpenVPN clients

**NOTE**: Sometimes new subnets are pushed to the openvpn server and the openvpn clients need to be restarted.

The process to restart the clients is to
- post a notice to the Slack channel [#alchemy-toolchain](https://ibm-argonauts.slack.com/messages/C1UCLT4C9) along the lines of `@here restarting the OpenVPN clients on Jenkins in 15 minutes. Jobs connecting to Armada servers may or may not be affected`
- wait 15 minutes to allow running jobs to complete
- restart the openvpn clients by running this [job](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Jenkins/job/Alchemy%20-%20restart%20OpenVPN%20on%20swarm%20cluster/) set up by TaaS for Alchemy SRE/Conductors as a self-service function.


### Escalation

Alchemy team members escalate to SRE/Conductors. SRE/Conductors are not responsible for helping team members to write their jenkins jobs for them. In this situation, it might be helpful to redirect them to the jenkins documentation on the internet or to the [TaaS jenkins help channel](https://ibm-cloudplatform.slack.com/messages/C56Q2JUKS)

In the event that the Jenkins issue falls within the responsibilities of TaaS, call out `@TaaS_squad` from within the (#taas-jenkins-help)[https://ibm-cloudplatform.slack.com/messages/C56Q2JUKS] channel. This is a group name valid only in that Slack workspace.

In the event of customer-facing issues consider [raising a sev1 to page out TaaS](https://taas-accounts.w3ibm.mybluemix.net/continueOAuth). The oncall will then join you in #taas-jenkins-help.

### Restarting Jenkins

Whenever possible avoid an immediate shutdown. Always use `safe restart` function to allow running jobs to complete before restarting

---

## Further Questions

Any questions to the process or the runbook, please ask in the [{{ site.data.teams.containers-sre.comm.name }}]({{ site.data.teams.containers-sre.comm.link }}) slack channel.

## Useful links

- [Restart OpenVPN for Jenkins](restart_openvpn_containers_swarm_jenkins.html)
- [Jenkins images](jenkins/jenkins_images.html)
- [Jenkins Squad Security](jenkins/jenkins_squad_security.html)
- [Jenkins Homepage](https://jenkins.io/)
- [TaaS Homepage](https://taas.w3ibm.mybluemix.net/)
- [Open a TaaS ticket](https://jazz-taas.rchland.ibm.com:15443/ccm/web/projects/Tool%20Chain%20as%20a%20Service%20%28TaaS%29#action=com.ibm.team.workitem.newWorkItem&type=userRequest&ts=1546616908000)