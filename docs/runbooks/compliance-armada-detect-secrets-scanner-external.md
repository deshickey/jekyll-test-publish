---
layout: default
description: How to take an action on armada-detect-secrets-scanner-external alert 
service: Compliance
title: Armada-detect-secrets-scanner-external  
runbook-name: "armada-detect-secrets-scanner-external"
link: /armada-detect-secrets-scanner-external.html
type: Alert
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

# Armada-detect-secrets-scanner-external

## Overview

This runbook is to explain how to take an action on `armada-detect-secrets-scanner-external job failed` alert.  
The scan is using `detect-secrets` tool to check if any internal secret might be included into public github projects that are maintained by Armada developlement squads. 

It is a FSCloud control to ensure scanning runs every 6 hours and take appropriate actions in case of leakage. 

## Example alert(s)

There would be 2 type of alert from the scanner

- When detect-secrets detects potential secrets in a project repository under github.com
- When the Jenkins pipeline run fails due to the service or code base. 
```
- armada-detect-secrets-scanner-external job failed for armada-ballast
- armada-detect-secrets-scanner-external job failed for Build failure
```

## Automation

Scanner runs with scheduled job for every 6 hours 
Link: https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/armada-detect-secret-scanner-external/

## Actions to take 

- When an alert triggered by detecting potential secrets found in github.com, you need to open a GHE issue to the associated squad and notify them via a slack channel. It is important for the squad to take an action to revoke the leaked APIKEY immediately to avoid any potential security risk
- When an alert triggered because the Jenkins pipeline has runtime errors
  - If it's due to temporary Jenkins issue, then rerun the pipeline manually to complete the scanning
  - If the error(s) is related to a bug, then open an issue in https://github.ibm.com/alchemy-conductors/detect-secrets-scanner and notify in the #conductor-for-life channel. Currently IKS SRE AU squad is the maintainer.

## Escalation Policy

If there is any unclear issue found, please use #conductor-for-life channel with tagging `conductors-aus` including details. 
