---
layout: default
tile: End of Life Technology Review Process
type: Process
parent: Policies & Processess
---

Process
{: .label .label-green}

# Overview
Process for review of hardware and software types in use by IBM Cloud Kubernetes (IKS) and Satellite Services 

# Control details

PCI 4.0 - 12.3.4 
  
  Hardware and software technologies in use are reviewed at least once every 12 months, including at least the following:
• Analysis that the technologies continue to receive security fixes from vendors promptly.
• Analysis that the technologies continue to support (and do not preclude) the entity’s PCI DSS compliance.
• Documentation of any industry announcements or trends related to a technology, such as when a vendor has announced “end of life” plans for a technology.
• Documentation of a plan, approved by senior management, to remediate outdated technologies, including those for which vendors have announced “end of life” plans.

HITRUST - 0628.10h1System.6
 
  If systems or system components in production are no longer supported by the developer, vendor, or manufacturer, 
  the organization is able to provide evidence of a formal migration plan approved by management to replace the system or system components 


# Process
This process must be completed at least annually and within a calendar year of the previous review. 

We are required to perform an annual review of the hardware and software types in use within the environment. The review should demonstrate the technologies still receive security fixes, are supported by the vendor, approved by management, and End-of-life status with remediation plans tracked for outdated technologies

All services are required to ensure that all components in use are not end-of-life (EOL) or unsupported. In case of anyoutdated technologies, including those for which vendors have announced “end of life” plans, there needs to be a documented plan for remediation approved by senior management.



Review Steps:
1.	Reminder for review is generated annually for each team
2.	Compliance team perform review of assets to ensure compliance with policy
3.	Any individual findings (Hardware/Software approaching end-of-life) are reported to asset owner with a GitHub Enterprise Ticket in the owners repo
4.	Exceptions where end-of-life software is in use are required to be handled via the Pubic Cloud Exception Process (PCE). 

Below is a summary of the methods and tools that are utilised to obtain an inventory of devices, their current version, and other associated metadata. 

1.	Firmware embedded in any device
-	Owning Team for Non-Firewall Devices: SRE - https://cloud.ibm.com/docs/bare-metal?topic=bare-metal-bm-faq#bm-out-of-date-firmware
-	Owning Team for Vyatta Firewalls: NetInt (Network Intelligence) 
- Inventory Report: <To be updated>

2.	Operating systems used on any device
-	Owning Team: SRE
-	Inventory Report: Cognos System Export Report

3.	Operating systems used by any container image 
-	Owning Team: Image Owners
-	Inventory Report: Jenkins job provides list of OS used by container images - https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/compliance-list-image-os/19/

4.	Databases that the service controls the version in use of - We can get the list of DBs and versions via the ibmcloud cli: 'ibmcloud cdb ls' and 'ibmcloud cdb deployment-about'

-	Owning Team: Teams deploying database instances
- Inventory Report: <To be updated>  

5.	Other servers deployed directly on devices or in containers such as nginx, squid, haproxy, etc. List to be obtained from Mend inventory reports for the 3 orgs. 
-	Owning Team: Any team deploying servers
-	Service Repositories: alchemy-containers, alchemy-conductors, alchemy-netint
- Inventory Report: Inventory extract from Mend

6.	Distribution of Kubernetes used by the service (IKS, RoKS, Rancher, etc) 
-	Owning Team: SRE
-	Reference: https://w3.ibm.com/w3publisher/supplier-security-risk-management/critical-software/cicd-pipeline

7.	Version of languages/runtimes used in/by the service's production code such as golang, Java, node.js, etc - List to be obtained from Mend inventory reports for the 3 orgs. 
-	Owning Team: Code owners 
-	Service Repositories: alchemy-containers, alchemy-conductors, alchemy-netint
- Inventory Report: Inventory extract from Mend

# Additional References:

IT Security Standard (ITSS): https://pages.github.ibm.com/ciso-psg/main/standards/itss.html

IBM Cloud policy : https://pages.github.ibm.com/ibmcloud/Security/policy/RA-Policy.html#supported-versions

Critical Software - https://w3.ibm.com/w3publisher/supplier-security-risk-management/critical-software/

Public Cloud Exception Process - https://pages.github.ibm.com/ibmcloud/Security/guidance/formal-risk-evaluation.html

Arch Framework for Deprecated software - https://test.cloud.ibm.com/docs/service-framework?topic=service-framework-deprecation-offeringplanfeature-requirements-for-end-of-support-eos
