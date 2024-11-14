---
layout: default
title: Compliance Checker
type: Informational
runbook-name: Compliance Checker
description: compliance checker logs guide
category: Armada
service: NA
tags: GITHUB, compliance
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
We keep security compliance records checked into some GitHub Enterprise repositories. These are the outputs of running various security compliance tools to collect the evidence we need for audits, especially the SOC2 Type 2 audit which requires evidence that we are taking daily actions to remain in a compliant state.

The compliance-checker tool checks the GHE repositories where the daily compliance tool records should be committed. If it finds at least one repository that hasn't had a commit in the last `max_commit_age` hours then it means that one of the compliance tools is failing and that needs to be investigated otherwise we will lose our SOC2 compliance.  
`max_commit_age` is 24 by default unless configured otherwise (see Detailed Information).

The output from the tool includes the names of the repositories under https://github.ibm.com/alchemy-conductors where there is no recent commit. Each compliance records repository has a link to the build job that should have checked in some records, so that it's possible to follow the issue back to the failing build.

## Example alert(s)
GHE compliance checker scan failed. See https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/compliance-checker.html. Build output: https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-checker/38/

## Detailed Information
- Click on the link to the compliance-checker Jenkins build in the Details section of the incident.
- In the Jenkins build page click `Console Output`  to display job output.
- Search for `[compliance-checker]`, which is followed by compliance-checker tool execution output.
- The `ERROR` message at the end contains JSON object with keys with following meaning:
    - `out_of_date_repos`: repositories with no commits in last 24 hours - i.e. repos which FAILED the test. These are the ones to investigate.
    - `up_to_date_repos`: repositories with commits newer then 24 hours - i.e. repos which PASSED the test. These are OK and can be ignored.
    - Note: `max_commit_age` is also displayed for each repository in the `ERROR` message as part of output JSON object.

- SRE should investigate the `out_of_date_repos` repositories. The out of date repository will link to the source code for the checks being run, and the Jenkins job where the compliance tool should be running. Follow the link from the repository to the Jenkins job and look for failed (red) builds in the job history. Check the console log of the build for the details of the failure.  

- With the details of the failure:
    - Check [Conductors Team GHE](https://github.ibm.com/alchemy-conductors/team/issues) for already opened issues describing the problem.
    - Raise an issue if one is not already open.
    - Investigate the problem by reviewing the jenkins job for the compliance tool which has not had its results updated - the issues are likely to be found here.
    - SRE should work with the Security Focal to drive resolution of the problems found.

- To change `max_commit_age` for any repo raise issue in [Conductors Security GHE](https://github.ibm.com/alchemy-conductors/security/issues).

#### Links
[Compliance Checker GHE repository](https://github.ibm.com/alchemy-conductors/compliance-checker)  
[Compliance Checker GHE Jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-checker/)
[compliance-vyattaversion-records jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/parrot-checker/)