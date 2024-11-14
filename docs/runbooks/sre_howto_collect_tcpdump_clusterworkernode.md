---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to run a tcpdump on a cluster worker node (classic carrier and tugboat)
service: Conductors
title: How to run a tcpdump on a cluster worker node (classic carrier and tugboat)
runbook-name: How to run a tcpdump on a cluster worker node (classic carrier and tugboat)
link: /sre_howto_collect_tcpdump_clusterworkernode.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
There are situations where communication from node(s) failing to reach other
node(s) located in same/another VLAN, though they been part of
the same Classic carrier or Tugboat. In this scenario, the SRE squad need to work with 
IaaS networking/NetworkResponseTeam (NRE) -  #network_response_team to further investigate the network issues.
This includes the deployment of tcpdump on a Classic carrier worker or Tugboat worker to collect the required dump and provide it to NRE.

The two scearios of running tcpdump are covered in this runbook:

- Running tcpdump - when an user can deploy, as cluster is responding

- Running tcpdump - when an user can't deploy, as cluster is NOT responding

## Detailed Information

### Running tcpdump -
#### when an user can deploy, as cluster is responding
The Tcpdump is a command line utility that allows to capture and analyze network
traffic going through a system. In order to run the commandline tool user
need to access the node either via shell or though any privilaged pod. Due to
security and compliance considerations direct shell access to the classic
cluster nodes and Turboat worker nodes are restricted. However,in a situation
as explained above SRE have to access the nodes to capture the data by running these
tools

#### Notify SOC squad - prior running the tcpdump
Note that all the prod resource/pod access is monitored by SOC squad and SRE will be
alerted with PDs if an attempt is made without notifying them in advance. So use "/notifysoc"
bot by filling the pop us message in "IBM Cloud Platform" slack channel - refer 
here for [more details](https://w3.ibm.com/w3publisher/ibm-cloud-soc-public-documentation/slackbot-for-demisto).
Contact SOC at slack channel `#soc-notify` for any help.


#### On a classic carrier worker
- `How to login to a classic carrier worker`: <br>
Access a Classic carrier worker (refer to [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_howto_loginto_a_clusterworkernode.html)) and
run tcpdump to capture packets.

- `Installing tcpdump`: <br> 
Run the install command: `apt install tcpdump` on the worker node.
Also consider to discuss with NRE team to know about which specific capture they want to analyze. The point here is to collect the packets
requested by NRE - to(destination/dst)/from(source/src) specific interface(s) - they want to inspect. The NRE squad will let SRE know whether they need entire dump or only with options like source,destination and port (more info in section `Examples to collect dump using tcpdump`).

- `Running tcpdump`: <br>
Refer to section `Examples to collect dump using tcpdump` for running tcpdump commands with examples.

#### On a Tugboat worker
- `How to login to a Tugboat worker`: <br>
The Tugboat workers are of a special case as a direct access to them is not allowed by default.
One approach is to use the "bes-local-client" POD running on Tugboat's worker node which is privileged with nsenter. 

- `Example on how to login to a Tugboat worker`: <br>
To login to Tugboat workernode - 10.208.88.227, which is from prod-dal10-carrier113, the following command can be used:
(Usually the NRE squad will let SRE know the Tugboat worker node name/ip, from where they want to collect the dump)

```
[prod-dal10-carrier113] epradeepk@prod-dal12-carrier2-worker-100:~$ export NODE=10.208.88.227;kubectl -n ibm-services-system exec -it $(kubectl describe node $NODE|grep bes-local-client|awk '{print $2}') -- nsenter -t 1 -m -u -i -n -p bash

[root@kube-brggn0qd0l9d4h0thrk0-produssouth-custome-0000a569 /]# yum info tcpdump
Loaded plugins: product-id, search-disabled-repos, subscription-manager
Available Packages
Name        : tcpdump
Arch        : x86_64
Epoch       : 14
Version     : 4.9.2
Release     : 4.el7_7.1
Size        : 422 k
Repo        : rhel-7-server-rpms/7Server/x86_64
Summary     : A network traffic monitoring tool
URL         : http://www.tcpdump.org
License     : BSD with advertising
Description : Tcpdump is a command-line tool for monitoring network traffic.
            : Tcpdump can capture and display the packet headers on a particular
            : network interface or on all interfaces.  Tcpdump can display all of
            : the packet headers, or just the ones that match particular criteria.
            : 
            : Install tcpdump if you need a program to monitor network traffic.

[root@kube-brggn0qd0l9d4h0thrk0-produssouth-custome-0000a569 /]# id
uid=0(root) gid=0(root) groups=0(root) context=system_u:system_r:unconfined_service_t:s0
```

- `Installing tcpdump`: <br>
Run install command: "yum install tcpdump" on the  worker node.

- `Running tcpdump`: <br>
Refer to section `Examples to collect dump using tcpdump` for running tcpdump commands with examples.

#### Examples to collect dump using tcpdump - for both Classic carrier worker and Tugboat worker
- Listing all the interfaces `tcpdump -D`

- Capture only tcp from single interface and save to a file `tcpdump -W file.pcap -i <interface> tcp`.
Here, the "file.pcap" contains the required dump and can be shared with the NRE team.
- Example of dump taken with source,destination and port number: `tcpdump -W file.pcap -i califb68278d2bf port <number> src <source-ip> dst <destination-ip>`
Example of taking entire dump: `tcpdump -W file.pcap -i califb68278d2bf`.
The SRE can input specific interface with option "-i" and this info is available from `tcpdump -D`.

### Running tcpdump -
#### when an user can't deploy, as cluster is NOT responding
Login to KVM and perform the above explained steps. If can't access KVM then enable it's ssh by logging into IPMI portal and retry.

### References
- Troubleshooting Load Balancers in IBM Cloud Kubernetes Service Using tcpdump [blog](https://www.ibm.com/cloud/blog/troubleshooting-load-balancers-in-ibm-cloud-kubernetes-service-using-tcpdump)
- Running tcpdump on Customer/Cruiser worker:
Access to customer/cruiser worker nodes is explained [here](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-cruiser-worker-access.html).
To obtain access to worker node, see [running commands on worker nodes runbook](./armada/armada-run-commands-on-workers.html)
