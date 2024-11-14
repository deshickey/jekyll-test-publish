---
layout: default
title: Handling_Nessus_Vulnerabilities
type: Informational
runbook-name: "Handling_Nessus_Vulnerabilities.md"
description: Handling_Nessus_Vulnerabilities
service: Conductors-Infrastructure
link: /Handling_Nessus_Vulnerabilities.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
This runbook is used to provide an overview of
- Details about Nessus Vulnerabilities (NVs)
- List of NVs that are addressed so far and resolutions/how they fixed
- Automation
  - List of the 'Automation Possible' NVs and their status
  - 'Automation Possible' NVs - how they are manually fixed
  - Automation applied for 'Automation Possible' NVs

## Detailed Information

## Details about Nessus Vulnerabilities (NVs)
- NVs Sites <br />
  (a) https://w3.sos.ibm.com/inventory.nsf/vulnerabilities.xsp?c_code=alc <br />
  (b) https://w3.sos.ibm.com/bi/ - SOS IDMgt login

## List of NVs that are addressed so far and resolution/how they fixed
- The list of NVs and fixes are mentioned in the box note - [Details on Nessus Vulnerabilities](https://ibm.ent.box.com/folder/53122626439)

## Automation

### List of the 'Automation Possible' NVs and their status

- IPMI Certificate Update: NVs Plugins 15901, 35291 and 69551<br />
Jenkins Job created

- Strong Cipher: NVs Plugins 70658,90317 and 71049 <br />
Jenkins Job created. Though the fix is made part of Bootstrap process,there are scenarios when bootstrap fails on a vulnerable system, Nessus detects and reports it. Instead of waiting for bootstrap to fix it (may take a longer time), can use this Junkins Job to quickly fix and eliminate the system from NVs list. 

- Purge mrmonitor service: NVs Plugins 20007,78479 and 26928<br />
Added as part of Bootstrap process

- SSL RC4 Cipher  Suites Support: NVs Plugin 65821<br />
Code changes made in Bootstrap repository 

More details in [Details on Nessus Vulnerabilities](https://ibm.ent.box.com/folder/53122626439)

### 'Automation Possible' NVs - how they are manually fixed

#### IPMI Certificate Update: NVs Plugins 15901, 35291 and 69551
15901: SSL Certificate Expiry  <br />
35291: SSL Certificate Signed Using Weak Hashing Algorithm  <br />
69551: SSL Certificate Chain Contains RSA Keys Less Than 2048 bits  
  
Above NVs can be fixed using ipmi-cert-udpater tool which is available at <br />
https://github.ibm.com/messagehub/ipmi-cert-updater <br />
User need to set up pre-requisites (listed in the above link) prior to running the tool.
  
  `NOTE`: Troubleshooting/Special Scenarios
  1. "Asymmetric Routing Issue": <br />
    In this scenario the ipmi-cert-updater can't be executed from a user terminal.
    - It wont be possible to connect to an ipmi IP address of a system (port 443) on the same VLAN as the openvpn systems if
    you're using openvpn to connect
    - Need to use socks5 tunnel to access those IPMI IPs. From User terminal, use Socks5 tunnel to connect to a system on
    other subnet (not the subnet where IPMI IP is present) and from that system can access the IPMI IP. Run the 
    ipmi-cert-updater from there (after pre-requisite setup). <br />
    https://www.digitalocean.com/community/tutorials/how-to-route-web-traffic-securely-without-a-vpn-using-a-socks-tunnel
  2. "Manual Renewal of Certificates":<br />
     There is a possibility that a process (example: nginx) running is vulnerable as it's SSL Certificate is expired.
     In this scenario, SRE need to identify the owner of the process and let them (or SRE itself) renew the certificate.
     This scenario can be identified by reviewing the Vulnerability link that provides system,port and other details.
  
   Refer to [Details on Nessus Vulnerabilities](https://ibm.ent.box.com/folder/53122626439)
   for specific details and discussions about the above scenarios.
  
#### Strong Cipher NVs Plugins 70658,90317 and 71049 
  70658: SSH Server CBC Mode Ciphers Enabled <br />
  90317: SSH Weak Algorithms Supported <br />
  71049: SSH Weak MAC Algorithms Enabled
  
  The above NVs can be fixed by sshing to reported system, checking cipher info using "sshd -T | grep -e ciphers -e macs", 
  updating strong ciphers (as mentioned in related Jenkins Job code), verying using "sshd -T | grep -e ciphers -e macs"
  and restarting ssh service.
  
## 'Automation Possible' NVs - Automation applied 

#### IPMI Certiciate Update: NVs Plugins 15901, 35291 and 69551

`NOTE`: Troubleshooting/Special Scenarios listed in MANUAL approach are not covered using Automation. They need to be fixed Manually.

Jenkins Job to [Update IPMI Certifciate](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Security-Compliance/job/IPMI%20Certificate%20Auto%20Update%20Options/build?delay=0sec)

Code Base: ```https://github.ibm.com/alchemy-conductors/IPMI-Certificate-Update```

#### Toggle IPMI Interface

Jenkins Job to [Toggle IPMI Interface](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Security-Compliance/job/Toggle%20IPMI%20Interface/build?delay=0sec)
  
Code Base: ```https://github.ibm.com/alchemy-conductors/IPMI-Toggle-Interface```

#### Strong Cipher NVs Plugins 70658,90317 and 71049 

Jenkins Job to [Update Strong Ciphers](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Security-Compliance/job/cipher_vulnerability_update/)

Code Base: ```https://github.ibm.com/alchemy-conductors/Nessus-Cipher-Update```

`NOTE`: ```There could be Jenkins Job failures in some cases like``` <br />
(a) Time-outs as Priviate IP not accessible <br />
(b) SSH is not successfull if Private IP is down <br />
(c) The 'Asymmetric Routing Issue' as explained in Troubleshooting section <br />
So after execution of the Jenkins Job it is recommended to review the OUTPUT of it. <br />
And fix the issues that are beyond the scope of this Jenkins Jobs automation.
