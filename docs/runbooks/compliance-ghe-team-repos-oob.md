---
layout: default
title: Compliance Out of Band GHE Teams and Repos
type: Informational
runbook-name: Compliance OOB GHE Teams and Repos
description: compliance oob reconciliation of GHE teams and their repos
category: Armada
service: NA
tags: GITHUB, compliance
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
Every team that has access to any repositories in github with it's relevant permissions are committed into a [github repository](https://github.ibm.com/argonauts-access/role-config/blob/master/iks/github.json) in the form of json configuration. These access to the repositories for teams are provided after a Accesshub request. When the Accesshub requests are completed, it is expected that the relevant configurations are also updated in the previously mentioned [repo](https://github.ibm.com/argonauts-access/role-config/blob/master/iks/github.json) The following Github Organisations are covered under this compliance - `Alchemy-Containers, Alchemy-Conductors, Alchemy-registry, Alchemy-va, Alchemy-netint, Alchemy-auditree`

The usam-sync tool that runs every 6 hours, provides the ability to compare the teams in the github organisation with their access to repositories and the teams that are specified in the config under argonauts-access/role-config repo, then the tool reports the discrepancies if found any. These discrepancies are triggered as PagerDuty alerts for further action.

## Detailed Information
The code repository for the usam-sync tool is: https://github.ibm.com/mhub/usam-sync

The sync job that runs every 6 hours: 
https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-argonauts-access-reconcile-iks/

The location where the configurations are stored: 
https://github.ibm.com/argonauts-access/role-config/blob/master/iks/github.json

The result of the each job will be stored as a report in the following location:
https://github.ibm.com/argonauts-access/reports

## Investigation and Action
- Click on link to Jenkins build in the Details section of the incident. In the Jenkins build page click `Console Output` to display job output.
- Search the console output for all the occurences of the string `DISCREPANCY-` .
	- if the search leads to `DISCREPANCY-GHERepo` this means that there is a mismatch found between the Repositories found under the team mentioned in that line AND the actual Repositories found in the Github for that Organisation mentioned above that line: 
	
		- example scenario 1, the below states that in the Org `alchemy-containers` the team has access to the repo `armada-cruiser-automated-recovery` in github with no Accesshub request. Check with the team owner to remove the team's access to the repository until the accesshub request is complete. If the team owner can provide the accesshub request completed proof for that access, then the config needs to be added with this information. Submit a pull request to the [role-config/github.json](https://github.ibm.com/argonauts-access/role-config/blob/master/iks/github.json) with the required changes
		```
		Reporting DISCREPANCY from the Org alchemy-containers 
		DISCREPANCY: Below combination of Reponame|Permission PRESENT in github but NOT in config. May need deletion from github 
		---- armada-cruiser-automated-recovery|write for team hybridlink-dev 
		```
		for the above case, adding the below config under the team `hybridlink-dev` for the Org `alchemy-containers` would suffice
		```
		{
			"RepoName": "armada-cruiser-automated-recovery",
			"Permission": "write"
		}
		```
		
		- example scenario 2, the below states that in the Org `alchemy-containers` the team `armada-network-squad` does not have access to the repo `konnectivity-operator` in github but it is present in Accesshub / config. Check with the team owner to raise a Accesshub request to remove the team's access to the repository. If the team owner can provide the accesshub request completed proof for that, then the config needs to be removed. Submit a pull request to the [role-config/github.json](https://github.ibm.com/argonauts-access/role-config/blob/master/iks/github.json) with the required changes to remove access.
		```
		Reporting DISCREPANCY from the Org alchemy-containers 
		DISCREPANCY-GHERepo: Below combination of Reponame|Permission are PRESENT in config but NOT in github. May need Addition to github
		---- konnectivity-operator|write for team armada-network-squad 
		```
		
		- example scenario 3, this is different from scenario 1 & 2 because the repo mentioned is present both in github as well as config but the permissions are different. Hence the below states that in the Org `alchemy-conductors` the team `conductors` has access to the repo `advanced-customer-cluster-monitor` with permission set to `maintain` but in config (which is what was mentioned in the Accesshub request while requesting access) the team `conductors` has access to the repo `advanced-customer-cluster-monitor` with permission set to `write`. This needs to be in sync. Check with the owner of the team to fix it in the github to what matches in the config (in this case `write`) OR the team owner has to create the Accesshub request to make the permission to `maintain` and commit the relevant config [here](https://github.ibm.com/argonauts-access/role-config/blob/master/iks/github.json)
		```
		Reporting DISCREPANCY from the Org alchemy-conductors 
		DISCREPANCY-GHERepo: Below combination of Reponame|Permission PRESENT in github but NOT in config. May need deletion from github
		---- advanced-customer-cluster-monitor|maintain for team conductors
		DISCREPANCY-GHERepo: Below combination of Reponame|Permission are PRESENT in config but NOT in github. May need Addition to github
		---- advanced-customer-cluster-monitor|write for team conductors 
		```
		


	- if the search leads to `DISCREPANCY-Team` this means that there is a mismatch found between the teams present in the Github for that Organisation and the teams that are configured in the [github.json](https://github.ibm.com/argonauts-access/role-config/blob/master/iks/github.json): 
	
		- example scenario 1, the below states the Org `alchemy-conductors` contains the team `dublin-sre` but it is not part of the configuration. Check with the team owner to remove the team from the Org until the accesshub request is complete. If the team owner can provide the accesshub request completed proof, then the config needs to be added with this information. Submit a pull request to the [role-config/github.json](https://github.ibm.com/argonauts-access/role-config/blob/master/iks/github.json) with the required changes. 
		```
		Reporting DISCREPANCY from the Org alchemy-conductors
		DISCREPANCY-Team: Below Teams PRESENT in github but NOT in config. May need deletion from github
		-- dublin-sre
		```
		for the above adding the below config under the Org `alchemy-conductors` would suffice. If there are repos under the team then check if they are in accesshub and commit the relevant repos in the `Repos` section below:
		```
		{
			"TeamID": <The github teamID in int>,
			"TeamName": "<The team name in string>",
			"Repos": []
		},
		```
		
		- example scenario 2, the below states the Org `alchemy-conductors` doesn't have a team `dublin-sre` in it but it is part of the configuration. Check with the team owner to add the team to the Org as the accesshub request is complete. If the team owner needs to remove it from the config. Submit a pull request to the [role-config/github.json](https://github.ibm.com/argonauts-access/role-config/blob/master/iks/github.json) with the required changes to remove. 
		```
		Reporting DISCREPANCY from the Org alchemy-conductors
		DISCREPANCY-Team: Below Teams PRESENT in config but NOT in github. May need addition to github
		-- dublin-sre
		```


## Escalation Policy
1.  Check in the #conductors-for-life channel if you need help or not able to figure out the owner of a team etc
