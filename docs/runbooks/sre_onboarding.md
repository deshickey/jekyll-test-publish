---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Onboarding to the Armada SRE Squad.
service: Conductors
title: Onboarding to the Armada SRE Squad.
runbook-name: Onboarding to the Armada SRE Squad.
link: /sre_onboarding.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# Onboarding to the Armada SRE Squad.

## Overview

This document details how new SRE members should onboard to SRE squads.

Work with your local squad lead to get your access granted and your workstation setup ready.

## Detailed Information

### Production onboarding

Read through [production onboarding checklist](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/process/production_onboarding.html) and complete following trainings. Remember, you need to send evidence (screenshots) of production onboarding alongside `production onboarding checklist` to WCP HIPAA Focal and Service Compliance Focal.

#### Policies and procedures to adhere to

Please read and follow the details on [Privileged user procedure](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/process/privileged_user_procedure.html).

#### HIPPA Training

Complete the following HIPAA education on Your Learning.
* [EL05-00000039 - HIPAA Overview: Health Insurance Portability and Accountability Act](https://yourlearning.ibm.com/activity/EL05-00000039)


#### Workstation and Email Encryption compiance

Complete the WST registration and encryption instructions. See instructions (Actions 2-4) on [WCP HIPAA Training and Workstation Procedures](https://pages.github.ibm.com/ibmcloud/Security/guidance/WCP-HIPAA-Training.html).  
_To obtain certificate for Email TLS encryption go to [article on Help@IBM](https://w3.ibm.com/help/#/article/02109)_

### Access requests

- If you're a member of the **worldwide** SRE squad follow [Access requests for Armada SRE Squad](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html) runbook to obtain required permissions to perform SRE tasks.

- If you're a member of the **dedicated eu-fr2** SRE squad follow [Access requests for Armada dedicated eu-fr2 SRE Squad](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests_eu_fr2.html) runbook to obtain required permissions to perform SRE tasks in eu-fr2 region.

<span stype="color:red">*IMPORTANT*:</span> Mandatory trainings and WST security compliance *MUST* be completed before any access request to be submitted. Non-conformance will result in violating `Control HR.02 - Late Completion of Mandatory courses`.


### Must have training

Complete following trainings as soon as possible.

- [IKS](https://ibm.ent.box.com/file/558912808046)
- [Classic Infrastructure](https://ibm.ent.box.com/file/571666768239)
- [Kubernetes in 5 minutes](https://www.youtube.com/watch?v=PH-2FfFD2PU)
- [Useful bots and Slack Channels](https://ibm.ent.box.com/file/658922624214)
- [Machine order part 1](https://ibm.ent.box.com/file/658439612698)
- [Machine order part 2](https://ibm.ent.box.com/file/658883843608)
- [IKS patching process](https://ibm.ent.box.com/file/606784494940)
- [Expectations when working as the interrupt pair in conductors](./conductors_interrupt_pair.html)

### Good to have training

- [Container & Kubernetes Essentials with IBM Cloud](https://cognitiveclass.ai/courses/kubernetes-course)
- [Docker Essentials: A Developer Introduction](https://cognitiveclass.ai/courses/docker-essentials)

### Useful links

- [SRE Contents](./sre_contents.html) - main landing page for SRE. The page details links to tools and processes the SRE squad are responsible for.

### Tools to install on your privileged workstation

* `xcode-select` command line tools (MacOS only)
  * `xcode-select` is a command-line utility that facilitates switching between different sets of command line developer tools. It is used to set a system default for the active developer directory, and may be overridden by the `DEVELOPER_DIR` environment variable. To install, run:  
    `xcode-select --install`

* `ibmcloud` cli (Linux/MacOS/Windows)
  * Linux and MacOS  
    `curl -sL https://ibm.biz/idt-installer | bash`  

  * Windows
    Right-click the Windows™ PowerShell icon, and select **Run as administrator**, then run the following command in PowerShell  
    `[Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11, Tls, Ssl3"; iex(New-Object Net.WebClient).DownloadString('https://ibm.biz/idt-win-installer')`

  _More information is available on [IBM Cloud docs](https://cloud.ibm.com/docs/cli?topic=cli-getting-started)._

* `detect-secrets` tooling (Linux/MacOS/Windows)
  * `detect-secrets` is a tool that scans git commits for secretes you might have accidentally tried to push.
  * Linux and MacOS   
    Netint have a handy [wiki page with install instructions]( https://github.ibm.com/alchemy-netint/team/wiki/Detect-Secrets)
  * Windows  
    Offical instructions on install can be found on w3 https://w3.ibm.com/w3publisher/detect-secrets/developer-tool 


### ZenHub setup

1. Go to [ZenHub app](https://zenhub.ibm.com/app)
1. Sign into ZenHub with GitHub using w3 credentials.
1. Allow ZenHub to use GitHub account. 

Once ZenHub is authorized by GitHub install ZenHub plugin onto your browser to view ZenHub flow inside GitHub.

1. Go to [ZenHub](https://zenhub.ibm.com/)
1. Under `ZenHub Browser Extension` click on `Install ZenHub for <your favorite browser>`  
   _This will take you to a ZenHub plugin on web store and you need to install ZenHub plugin on your browser._
