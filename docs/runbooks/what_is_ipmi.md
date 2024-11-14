---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: What is IPMI and what IP addresses does it use?
service: NetInt
title: What is IPMI and what IP addresses does it use?
runbook-name: "What is IPMI and what IP addresses does it use?"
link: /what_is_ipmi.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

The IPMI controller is a miniature computer attached to the motherboard of a bare metal server. Every bare metal server has its own IPMI controller. The IPMI controller allows low-level control and access to the bare metal server. For example, you can use it to reboot the bare metal server (via the SoftLayer control portal/API) or you can connect to it via HTTPS in order to get console access.

When you access the KVM Console feature in the SoftLayer control portal, it uses the IPMI controller to gain direct access to the bare metal server console.

## Detailed Information

Each IPMI controller has its own private IP address on the same subnet as the private primary IP of the attached bare metal machine. When looking at a private IP address, always keep in mind that the IP could belong to the IPMI controller for a bare metal server.

It's important to understand the difference between the two IP addresses, especially when trying to resolve Nessus vulnerability findings.

Consider the following [example](https://github.ibm.com/alchemy-netint/network-source/blob/02bcd46db7bb0d010ff26cbefed60208ad6874db/softlayer-data/Acct531277/devices.csv#L2260) from account 531277's devices.csv:

Device Name|Device Type|Location|Public IP|Private IP|Management IP
 --------- | --------- | ------ | ------- | -------- | ----------- 
stage-dal09-infra-vpn-01.alchemy.ibm.com|Bare Metal Server|Dallas 9|169.55.35.40|10.143.138.138|10.143.138.134

Note the two different private 10.x.x.x IP addresses:

- The **Private IP** 10.143.138.138 belongs to the operating system on the bare metal server. Processes running on the bare metal server can listen on this IP address (and may cause Nessus findings).

    To understand what is running listening on the private IP address you can log on to the server and use `netstat` to query for listening processes. For example, on Linux:
    ```
    $ sudo netstat -A inet -anop | grep LISTEN
    tcp        0      0 127.0.1.1:53            0.0.0.0:*               LISTEN      1817/dnsmasq     off (0.00/0/0)
    tcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN      1646/postgres    off (0.00/0/0)
    ```

    Focus on the fourth column (e.g. `127.0.0.1:5432`). In this example, the processes shown are only listening on a 127.x.x.x loopback IP address. If no IP is shown they are listening on all addresses. The number after the colon is the listening port number.

- The **Management IP** 10.143.138.134 belongs to the IPMI controller. Anything listening on this IP address is outside the scope of the operating system. Common TCP listener ports here are:
    - 22 IPMI SSH interface - risky, should be disabled
    - 80 IPMI HTTP interface - recommended enabled to redirect to port 443 otherwise the SoftLayer portal KVM console feature breaks
    - 443 IPMI HTTPS interface - useful, should be enabled
    - 623 SuperMicro IPMI RMCP - required for SoftLayer portal
    - 5900 VNC (protocol 3.8) - required for SoftLayer portal console login

    We cannot log in to the IPMI controller and run commands, we can only use the web interface to configure it. The IPMI control web interface allows some configuration and might allow certain features to be disabled: exactly what features can be controlled depends on the IPMI hardware model and firmware version.

    In general you can connect to https://MANAGEMENT_IP/ to control the server. You must be connected to the appropriate VPN for the environment. You will see a certificate warning because the IPMI controller certificates are self-signed.
    
    To log in, you will need to use the root user with the password from the SoftLayer control portal Remote Management tab for the bare metal server. Note that this root password is NOT the root password for the operating system; it is a different password.

## Finding IP Addresses in Slack

You can private message the bot `@netmax` to find out more information. In particular, send it the IP address to find out what machine it belongs to.

The `Management IP` field returned by Netmax shows the IPMI IP address.

## Finding IP Addresses in GIT

The full inventory of machines is available in [GIT](https://github.ibm.com/alchemy-netint/network-source/tree/master/softlayer-data). Inside this folder there is a sub-directory of accounts. Each folder contains a `details.json` containing the details of the account owner, name etc. and then devices.csv which contains information on all the hosts in the account.

A device can be located using IP address information in the devices.csv file. The `Management IP` column contains the IPMI controller address.
