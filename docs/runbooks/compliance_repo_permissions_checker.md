---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: repo permissions checker failed
type: Alert
runbook-name: "Fix repo permissions"
description: How to fix repo permissions failed alert
category: Armada
service: Containers
link: /compliance_repo_permissions_checker.html
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview
- This alert is triggered due to missmatch of repo permission found in the config file [here](https://github.ibm.com/alchemy-conductors/git-inspector-config/blob/master/config.yaml) and the actual repo.

## Example alert
- `Alchemy-containers/conductors repo permissions checker failed <jenkins_output> <runbook_url>`

## Actions to take
- Find the GHE opened by the jenkins job in alchemy-conductors/team [issues](https://github.ibm.com/alchemy-conductors/team/issues). Search for title `[alchemy-conductors]/[alchemy-containers] repos not configured correctly`
- Refer to this [documentation](https://github.ibm.com/alchemy-conductors/repo-protection) and use this [automation](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/fix-repo-protection/) to fix repo protection for each repo 
- Rerun the jenkins job [compliance-git-permission-validator](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-git-permission-validator/) until the issue is closed by the automation.

- The required branch protection rules are set in the config file [here](https://github.ibm.com/alchemy-conductors/git-inspector-config/blob/master/config.yaml). By default the following protections are required for a repo
```
default-branch-protection-rules:
        prs:
          approving-reviews: 1
          dismiss-stale-approvals: ignore
          owner-review: ignore
        status-checks:
          allow-other-checks: true
          up-to-date: ignore
        include-admins: true
```
If specific protection rules needs to be set for one or more repos, an exception should be specified in the config file. Raise a PR to update the config file.

- For new repos refer to the documentation [here](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/compliance_new_repo_creation.html)

## Automation
- Jenkins job: [fix-repo-protection](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/fix-repo-protection/)

## Escalation Policy 
- If the alert can't be resolved by this runbook. Please ping in `#conductors` with `@conductors-dublin-bnpp` or `@bnpp_iks_sre` 

## Reference