---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to restart Jenkins openvpn containers
service: Conductors
title: How to restart Jenkins openvpn containers
runbook-name: "How to restart Jenkins openvpn containers"
link: /restart_openvpn_containers_swarm_jenkins.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Requests sometimes come in to restart the openvpn swarm containers on our jenkins server.  Here is how....

## Actions to take

Inform the jenkins users of an impending openvpn restart and a possible break in connection then restart the clients

## Detailed Information

TaaS controls the the servers, operating system, and networking. Therefore, they have provided a jenkins job to call into _their_ instance to restart our openvpn clients

## Detailed Procedure

- Post a notice to the Slack channel [#alchemy-toolchain](https://ibm-argonauts.slack.com/messages/C1UCLT4C9) along the lines of `@here restarting the OpenVPN clients on Jenkins in 15 minutes. Jobs connecting to Armada servers may or may not be affected`
- Wait 15 minutes to allow running jobs to complete
- Execute this [jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Jenkins/job/Alchemy%20-%20restart%20OpenVPN%20on%20swarm%20cluster/)

### Help needed?

Speak to other Conductors squad members if you hit issues
