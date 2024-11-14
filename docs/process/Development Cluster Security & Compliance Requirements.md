---
layout: default
title: Development Cluster Security & Compliance Requirements
type: Process
parent: Policies & Processess
---

Process
{: .label .label-green}

**This document outlines the Security & Compliance requirements that Developers must follow for IKS Development Clusters that they own.**

### Requirements

#### 1. Use of SRE owned pipeline accounts is the desired location to create development owned clusters.  (i.e Alchemy Staging or Dev Containers)
- An exception must be approved to create in an IBM alternative account
([Cluster creation in non IKS pipeline account exception request](https://github.ibm.com/alchemy-conductors/security/issues/new?assignees=&labels=Non+pipeline+account+request&template=Non+pipeline+account+use+request.md&title=Non+pipeline+account+request+for+account%3A+))

#### 2. As a general rule, no clusters should last for over 6 days.
- if clusters are required > 6 days they must have csutils installed ([How to manually onboard the SOS csutils tool to a cruiser cluster](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/development_onboard_sos_tools.html))
- if csutil, change tracker or crowdstrike cannot be installed on clusters > 6 days then an exception must be approved
([IKS cluster exception request template](https://github.ibm.com/alchemy-conductors/security/issues/new?assignees=&labels=csutil-exception%2C+change-tracker+exception%2C+crowdstrike-exception&template=IKS+cluster+compliance+exception.md&title=IKS+Cluster+Compliance+Exception%3A+)
- clusters > 6 days without csutils installed or an approved exception will be automatically deleted

#### 3. Once csutils is installed, cluster owners are responsible for keeping their clusters compliant.  Compliance gaps observed from ongoing scanning should be fixed immediately.

#### 4. Cluster owners must resolve any security and compliance issues raised against them for the clusters they are responsible for, within the due date assigned.

#### 5. Cluster owners are required to raise a PCE risk if compliance of cluster cannot be maintained. ([PCE template](https://github.ibm.com/alchemy-conductors/security/issues/new?assignees=&labels=Compliance%2C+Risk+Request%2C+PCE+Request&template=exception-risk-request.md&title=))




### Below are useful links on the onboarding requirments and management of development clusters
- [How to manually onboard the SOS csutils tool to a cruiser cluster](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/development_onboard_sos_tools.html)
- [Information on what accounts dev squads should use to create test/dev/demo clusters](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/development_account_usage.html)
- [How development squads can onboard a non-pipeline account for use](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/development_onboard_non_pipeline_account.html)


### Reviews

Last review: 2023-06-14 Last reviewer: Hannah Devlin Next review due by: 2024-06-14


