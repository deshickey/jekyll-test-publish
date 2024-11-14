---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Troubleshooting failed Jenkins node label docker image builds
service: Jenkins
title: Troubleshooting failed Jenkins node label docker image builds
runbook-name: "Troubleshooting failed Jenkins node label docker image builds"
link: /jenkins_build.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
This document is intended to aid the oncall interrupt pair resolve issues with failed Jenkins node label docker images builds. You have been redirected here from a Pager Duty alert.

### Important
This job is only available to Conductors/SRE to view. Therefore troubleshooting by the interrupt pair is required to identify the reason for the failed build.

## Detailed Information

The majority of the time, the build job that led you here is automatically kicked off by a merged PR in the [pipeline-build repo](https://github.ibm.com/alchemy-conductors/pipeline-build/). PRs could come from the SRE team or someone else after merging by an SRE.

There are a multitude of reasons for the failed build. Looking at the console of the failed build will aid in troubleshooting. Since only conductors/SRE are able to view the job, the interrrupt pair will have to troubleshoot and identify the reason for the failed build 

The alert that brought you here has a URL for a Jenkins job. Go look at the 
- status page 
- console page

### Status page
The status page could either have 
- Started by GitHub push by
- Started by user 

#### Started by GitHub push by ...
This statement may or may not be a red herring, as this will show the name of the approver of the PR in the [pipeline-build repo](https://github.ibm.com/alchemy-conductors/pipeline-build/) that automatically kicked off the build. Check the PR before contacting the owner of the email 

#### Started by user ...
This statement may or may not be a red herring. The user id listed manually kicked off the job. Ask the person, why and follow up with the owner of the request. Help the owner of the request identify issues with the job.

### Console page
Any and all errors will be listed here. Go thru the output and identify the error. Once identified, go to the [pipeline-build repo](https://github.ibm.com/alchemy-conductors/pipeline-build/) and fix the necessary files.

## Job Configuration page
The job Configuration page will **ALWAYS** list `maarafa@us.ibm.com` as the last person to change the configuration of the page. This is false information as **ALL** JJB managed jobs will list that same email address. Do **NOT** contact the owner of this email based on this information.

## Escalation Policy
Escalate to the oncall/interrrupt SRE pair