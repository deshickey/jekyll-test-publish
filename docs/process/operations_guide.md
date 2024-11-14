---
layout: default
title: Operations Guide
type: Policy
parent: Policies & Processess
---

Policy
{: .label .label-purple}

This document details policies and decisions relating to requirements in the [IT Security Standard](https://pages.github.ibm.com/ciso-psg/main/standards/itss.html) 

Numbered mappings to sections of ISO 27001 are shown.

### **ISO 27001 Controls**

#### **8.1 Responsibility for Assets**

##### **8.1.1 Inventory of Assets**

Control Statement: *Assets associated with information and information processing facilities should be identified and an inventory of these assets should be drawn up and maintained.*

Control Implementation: Assets associated with information and information processing facilities are identified and an inventory of these assets kept as part of the [Shared Operational Services (SOS)](https://pages.github.ibm.com/SOSTeam/SOS-Docs/inventory/aboutinventory.html) Asset and MAD Database Service.

##### **8.1.4 Return of assets**

Control Statement: *All employees and external party users should return all of the organizational assets in their possession upon termination of their employment, contract or agreement.*

Control Implementation: The following process is for Conductors responsible for decommissioning assets such as SoftLayer CCI's or baremetals, VMs or containers.

  1. Determine all storage attached to the asset
  2. Securely wipe all the attached storage
  3. Reinstall base OS image.
  4. Return asset (eg: return machine to SoftLayer).

#### **9.1 Business Requirements of Access Control**

##### **9.1.1 Access control policy**

See [access control documentation](/docs/process/access_control.html)

#### **9.2 User Access Management**

##### **9.2.2 User Access Provisioning**

See [access control documentation](/docs/process/access_control.html)

##### **9.2.4 Management of Secret Authentication Information of Users**

Control Statement: *The allocation of secret authentication information shall be controlled through a formal management process.*

Control Implementation: All middleware passwords for services are stored encrypted in Jenkins and are retrieved from armada-secure https://github.ibm.com/alchemy-containers/armada-secure/blob/master/README.md which has restricted access and all secrets are GPG encrypted.

All passwords are changed as per the [IT Security Standard](https://pages.github.ibm.com/ciso-psg/main/standards/itss.html). No vendor default passwords are used.

Secret authentication information granting access to IBM Cloud systems is classified as IBM Confidential and handled as per [IBM Corporate Instruction LEG 116](https://w3-03.ibm.com/ibm/documents/corpdocweb.nsf/ContentDocsByTitle/Corporate+Instruction+LEG+116/). All contracts signed by the relevant users restrict the disclosure of IBM Confidential information as per LEG 116.

##### **9.2.5 Review of User Access Rights**

Control Statement: *Asset owners shall review users’ access rights at regular intervals.*

Control Implementation: The managers of the Squads are responsible for ensuring revocation of user access rights after any change of employment status. Manager must perform a regular review of users to confirm that roles and responsibilities are correct.  This review will be conducted by the managers every CBN in AccesHub.
##### **9.2.6 Removal or Adjustment of Access Rights**

Control Statement: *The access rights of all employees and external party users to information and information processing facilities shall be removed upon termination of their employment, contract or agreement, or adjusted upon change.*

Control Implementation: Management are responsible to ensure that, when a user changes squad, that user's access is revoked from the previous squad and they are then added to the new squad access. In cases where IBM terminates the user's employment, the user's access shall be revoked on the same business day as the termination.

#### **10.1 Cryptographic Controls**

##### **10.1.2 Key Management**

Control Statement: *A policy on the use, protection and lifetime of cryptographic keys shall be developed and implemented through their whole lifecycle.*

Control Implementation:

Keys used to interact with external (non-IBM) systems are obtained through DigiCert in accordance with DigiCert's security policies. DigiCert is a member of the CA/Browser Forum body which sets best practices for public key cryptography for the industry.

Internal keys and secrets are obtained through the conductors squad who handle key management, including the issuance, management, and revocation of certificates. All certificates have an expiry period to limit the duration of their use.

### **12.1 Operational Procedures and Responsibilities**

##### **12.1.3 Capacity Management**

Control Statement: *The use of resources is be monitored, tuned and projections made of future capacity requirements to ensure the required system performance.*

Control Implementation: Currently this is a manual process, and is monitored by the squads using Logging and Monitoring. In case of a capacity issue, the Conductors squad is notified and are responsible for addressing the issue.

#### **12.2 Protection From Malware**

##### **12.2.1 Controls against malware**

Control Statement: *Detection, prevention and recovery controls to protect against malware shall be implemented, combined with appropriate user awareness.*

Control Implementation:

  * Obtain and use the IBM approved anti-virus programs. These programs are available at [http://w3.ibm.com/virus/](http://w3.ibm.com/virus/).  

    The list of approved anti-virus programs available for download is at [http://w3-03.ibm.com/virus/download/certsoftware_sep.html](http://w3-03.ibm.com/virus/download/certsoftware_sep.html)

    This section additionally has a note;

  * If an approved anti-virus program is not available for your system's operating system from the CERT website, you are not required to take any additional action to obtain and install an anti-virus program.  

    The approved anti-virus programs for Linux require the installation of kernel modules to operate. Docker containers do not have their own kernel so the anti-virus programs would not operate.  
    As such IBM created and managed containers are not required to be installed with an anti-virus program.

    For host systems running Ubuntu the approved anti-virus programs are SEP 12.1.5 and SAV 1.0.13  
    The latest level supported by these packages is Ubuntu 13.04 with Linux kernel 3.8.0  
    [Supported Linux kernels for Symantec Endpoint Protection](https://support.symantec.com/en_US/article.TECH223240.html)  
    [System requirements for Symantec AntiVirus for Linux 1.0](https://support.symantec.com/en_US/article.TECH101598.html)

    Alchemy Ubuntu systems are based on 14.04 with Linux kernel 3.13.0, there is no approved anti-virus program for this platform and so these host systems are not required to be installed with an anti-virus program.

  * Customer created containers are outside the remit of these policies. However, security modules are used to restrict the actions of code inside each container: AppArmor is being used on all Ubuntu hosts and SELinux for RedHat hosts. This prevents malware inside a container from breaking out into the host system.

#### **12.3 Backup**

##### **12.3.1 Information Backup**

Control Statement: *Backup copies of information, software and system images shall be taken and tested regularly in accordance with an agreed backup policy.*

Control Implementation: High availability will be configured for the environments where appropriate. Maintaining multiple systems with live copies of the data provides online backup capabilities.

#### **12.4 Logging and Monitoring**

##### **12.4.1 Event Logging**

Control Statement: *Event logs recording user activities, exceptions, faults and information security events shall be produced, kept and regularly reviewed.*

Control Implementation:

Logged events are monitored by QRADAR.

This covers all relevant system administration operations. In addition to the QRADAR monitoring, Jenkins logs all administrative activities that occur for deploys.

##### **12.4.2 Protection of Log Information**

Control Statement: *Logging facilities and log information shall be protected against tampering and unauthorized access.*

Control Implementation: Logs are sent directly to QRADAR via rsyslog and so can not be tampered.

##### **12.4.3 Administrator and Operator Logs**

Control Statement: *System administrator and system operator activities shall be logged and the logs protected and regularly reviewed.*

Control Implementation: Logged events are monitored by QRADAR.

This covers all relevant system administration operations.

Logs are transferred securely to QRADAR via rsyslog. Log review is a manual process initiated by the Security Compliance squad and recorded in an IDS work item.

##### **12.4.4 Clock Synchronisation**

Control Statement: *The clocks of all relevant information processing systems within an organization or security domain shall be synchronised to a single reference time source.*

Control Implementation: The security bootstrap job that is run when a machine is provisioned sets NTP to the SoftLayer NTP server to ensure a single reference time source.

#### **12.6 Technical Vulnerability Management**

##### **12.6.1 Management of Technical Vulnerabilities**

Control Statement: *Information about technical vulnerabilities of information systems being used should be obtained in a timely fashion, the organization's exposure to such vulnerabilities evaluated and appropriate measures taken to address the associated risk.*

Control Implementation: The team uses the IBM [Product Security Incident Report Tool (PSIRT) process](./psirt.html) to identify, assess and mitigate technical security vulnerabilities.



##### **12.6.2 Restrictions on Software Installation**

Control Statement: *Rules governing the installation of software by users shall be established and implemented.*

Control Implementation: All software is approved prior to inclusion in the production environment. Project management and Legal representatives participate in the approval process. All software has default passwords changed during or immediately after installation.

Additionally, systems used to access the production environment are subject to strict controls on software installation and usage as per IBM's Privileged User security policy: see section 2.6 of [this](http://w3-03.ibm.com/transform/sas/as-web.nsf/ContentDocsByTitle/Security+and+Use+Standards+for+IBM+Employees) document.

#### **13.1 Network Security Management**

##### **13.1.2 Security of Network Services**

Control Statement: *Security mechanisms, service levels and management requirements of all network services shall be identified and included in network services agreements, whether these services are provided in-house or outsourced.*

Control Implementation: The Security Compliance squad is responsible for changes to the firewalls and review any network infrastructure changes. These are always approved by a named list of approvers through the use of Gerrit and stored in Git. Access to Git and Gerrit for firewalls and network infrastructure is managed by the Security Compliance squad.

#### **13.2 Information Transfer**

##### **13.2.3 Electronic Messaging**

Control Statement: *Information involved in electronic messaging shall be appropriately protected.*

Control Implementation: The squads use:

  * IDS for tracking tasks - some communication occurs herein. Access to IDS is via an HTTPS encrypted website requiring authentication from an IBM employee.

  * Slack as the main communication vehicle


### Reviews

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14
