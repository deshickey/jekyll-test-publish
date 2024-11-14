---
layout: default
description: Deploying new qradar EP machines
title: Deploy qradar EP
service: qradar, deploy
runbook-name: "QRadar EP Deploy"
tags: syslog
link: /qradar_ep_deploy.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document describes the process for deploying a HA pair of qradar EPs for an environment. 

## Detailed Information

Read and follow process [Boarding - QRadar](https://pages.github.ibm.com/SOSTeam/SOS-Docs/qradar/qradar-boarding-instructions-and-guidelines.html). This runbook just streamlines the process for Alchemy. 

1. Fill out the [SOS sizing chart](https://github.ibm.com/SOSTeam/SOS-Docs/raw/master/sosdocs/qradar/ISIE-QRadarV2-Sizing-Calculator-v1-2.xls).
   - Only the `UNIX and Linux Servers` row on tab `Customer Inputs` is required
   - Count the number of c-plane servers (infra, carriers and vyattas) that will use these EPs, and add a *fudge* factor for growth (e.g. 2*x*) and insert into that field.
1. Open a [SOS Service Request](https://ibm.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_category_view.do%3Fv%3D1%26sysparm_parent%3D109f0438c6112276003ae8ac13e7009d%26sysparm_no_checkout%3Dfalse%26sysparm_ck%3De0132c2b1ba240d08111da01ec4bcb19715a4435b9ba5fee8152e714707d658262265e63%26sysparm_view%3Dcatalog_default%26sysparm_catalog%3De0d08b13c3330100c8b837659bba8fb4%26sysparm_catalog_view%3Dcatalog_default)  
   - Attach the SOS sizing chart.
   - Specify the Softlayer account these EPs will be in.
   - Indicate that they will attach to the shared 4 console. 
1. SOS will respond in the ticket with specifications on the EP (cpus, cores, disk size etc) and the amount of offline storage required.
   - Order the storage and a pair of identical servers  
   _Give both servers access to the storage!_
   
   _**Note**: when ordering the servers_
   - _A large number of small disks is better that a small number of large disks for the data (due to the characteristics of RAID10)_
   - _Servers are ordered without an OS (they are **not** bootstrapped)_
   - _Servers are always baremetal_
   
1. Order 3 VIPs for this EP pair (from netint).  
   One for each server and one that floats. Note which one is floating; that is the IP that the syslog servers will use for communictation.
1. Open a firewall request for the EPs.  
   The netint team knows what ports need to be open, but you can point them to this [vpn-and-network-configuration](https://pages.github.ibm.com/SOSTeam/SOS-Docs/network/vpn-and-network-configuration-boarding.html).
1. When complete,respond in the ticket with the following information
   - For each server
     - IPMI address, subnet and gateway
     - IPMI username and password
     - VIP
   - Mount information for the offline (backup) storage
   - Floating VIP
   
   _**Note**: there is usually some **back and forth** between netint and SOS at this point while the SOS team tries to install from a virtual disk mounted via IPMI. If you start a slack group chat with the netint and SOS team members working on the ticket things will go much faster (when compared to SRE being the middle man)._
   
1. Once it is all sorted, in the ticket request a TLS certificate to use to encrypt data to the qradar EPs.  
   Save the TLS cert in bootstrap `playbooks/certs/qradar`
   - Name is typically the name of the EP in qradar console e.g. `alc-stage-dal10-infra-qradar.crt`
   - Name must end in `.crt`
1. Update the bootstrap `group_vars` for the environment

   ~~~
   # qradar
   qradar_ip: "{{ hostvars['<name of the floating IP from inventory>']['ansible_ssh_host'] }}"
   qradar_port: 6514
   qradar_cert: "<filename of TLS cert>"
   ~~~
1. If there are syslog servers for the environment, bootstrap them to pick up the new variables.  
   Otherwise proceed to deploy syslog servers.  
   _**Note**: If you are using syslog servers to log forward to Qradar inform the SOS team, as they will have to carry out extra steps._
