---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Restarting the VPN clients on the jenkins instances
service: Jenkins
title: Restarting the VPN clients on the jenkins instances
runbook-name: "Restarting the VPN clients on the jenkins instances"
link: jenkins/jenkins_vpn_restart.html
type: Informational
grand_parent: Armada Runbooks
parent: Jenkins
---

Informational
{: .label }

## Overview

What follows is the process to restart the VPN clients on the Jenkins instances

## Detailed Information

The Jenkins instances are managed by @taas_squad in #taas-jenkins-help. As such, Conductors/SRE have limited access to the underlying operating system where the VPN clients run.

Therefore, the TaaS squad has made available to us a [jenkins job to allow SRE to restart the VPN clients](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Jenkins/job/Alchemy%20-%20restart%20OpenVPN%20on%20swarm%20cluster/) whenever necessary

## Process
**BEFORE** proceeding, verify there is indeed an issue with the VPN clients by runnin the Jenkins job called [Simple Ping Test](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Simple_Ping_Test/)

In #conductors, first announce to everyone something along the lines of `@here the VPN clients on all 3 Jenkins instances will be restarted, a blip in the network connectivity may be seen and jobs _MAY_ fail.`

Next, kick off the [jenkins job to restart the VPN clients](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Jenkins/job/Alchemy%20-%20restart%20OpenVPN%20on%20swarm%20cluster/)

## Escalation

  * @interrupt in #conductors
  * @taas_squad in #taas-jenkins-help