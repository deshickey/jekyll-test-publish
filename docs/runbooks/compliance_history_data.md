---
layout: default
title: Compliance History Data
type: Informational
runbook-name: Compliance History Data
description: Compliance history data logs guide
category: Armada
service: NA
tags: GITHUB, compliance, history
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
The purpose of the compliance history data tool runs daily and collect the currently compliance data and save it to the history data collection compliance. We keep various security compliance data checked into a GitHub Enterprise repositories. These are the outputs of security compliance history data to collect the evidence we need for audits.

The code repository in this Jenkins job is: https://github.ibm.com/alchemy-conductors/compliance-inventory-checker/, and the repository for sotre the compliance history data is: https://github.ibm.com/alchemy-conductors/compliance-inventory-history-records 

## Detailed Information
This tool generates 4 json files and save them to the data repository. Each file been overwritten by a new version file everytime after the jenkins job runs. The commit history on those 4 files will be the history data. Git will compress the history as necessary to keep the history data manageable.

The detail information of those json file please referance to: https://github.ibm.com/alchemy-conductors/compliance-inventory-checker/blob/master/README_COMPLIANCE_HISTORY_DATA.md.

## Investigation and Action
1. View the Jenkins build output
   - Click on link to in the `Event Details` section of the incident  
   _Open the `Event Details` by following the `View Message` link on the PD alert_
1. Look for `[compliance-history]` in the Jenkins build page `Console Output`, which is followed by compliance-history tool execution output.

The SRE receiving this alert should
1.  Check [Conductors Team GHE](https://github.ibm.com/alchemy-conductors/team/issues) for already opened issues.
2.  Raise an issue if one is not already open.
3.  Investigate the problem by reviewing the jenkins job for the compliance tool which has not had its results updated - the issues are likely to be found here.
4.  SRE should work with their Compliance Focal to drive resolution of the problems found.
