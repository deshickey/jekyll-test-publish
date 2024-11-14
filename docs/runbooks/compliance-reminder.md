---
layout: default
title: Compliance Reminder
type: Informational
runbook-name: Compliance Reminder
description: reliably remind SRE teams that a review is needed 
category: Armada
service: NA
tags: GITHUB, compliance, SRE, reminder
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
The purpose of this tool is to reliably remind SRE teams that a review is needed including due dates and reminders and also to store evidence once the review is done. The evidences are needed for audit purposes, especially the SOC2 Type 2 audit which requires evidence that we are taking daily actions to remain in a compliant state. Ideally this is a generic tool that all squads and services can use.

## Detailed Information
This tool is being run via a Jenkins job [(named compliance-reminder)](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-reminder/) on a daily basis everyday at 11:08 UTC time.  

The tool scans a **template directory** [(`.../compliance-reminder-templates/template_dir`)](https://github.ibm.com/alchemy-conductors/compliance-reminder-templates/tree/master/template_dir) of template files (both files per squad and separate files) and looks to see if any new GHE issues need to be created.

_The README file in the [template directory](https://github.ibm.com/alchemy-conductors/compliance-reminder-templates/tree/master/template_dir) provides a sample template file with the correct fields and its value formats, as well as all the information about individual fields._

If a new issue is needed (note issues about duplication below), the tool will check for any incomplete fields in the template.
   - If yes, then a pagerduty alert is sent to SRE with template file link which needs attention and iterates to next template.

Also checked for is that there is no existing open GHE issue that matches what it intends to create (to avoid duplicates).
   - If a duplicate is found with already existing open issues in the repo, a pagerduty alert is raised with SRE with template URL.

If all is well and no duplicate is found, then the tool will create a new GHE issue matching the creation date mentioned in template file and sends a pagerduty alert to SRE with newly created issue's `html url`.

### PD Alert
The SRE on-call receiving this alert should notify the compliance team who will debug and resolve the problem using the guidance as follows:

1. Check alert `Summary` to take any of the following actions  
If the `Summary` includes:
   - **template has incomplete fields**  
   review the template file (Link provided in the `Summary`) for any manadatory fields with no/null values.  
   Actions should be taken to provide correct values in those empty fields.  
   Once SRE fills out those emply fields, the scanner will review the template file in the next iteration.
   
   - **Found duplicate open issue**  
   review the link (provided in `Summary`) of the template file which has duplicacy conflict with an already open issues(link provided in `Summary`) in the same repository in which a new issue was supposed to be created. The SRE will either remove the template from [template directory](https://github.ibm.com/alchemy-conductors/compliance-reminder-templates/tree/master/template_dir) or change the title and details so that the new issue will not match an existing open issues.
   
   - **New issue created from template**  
   the SRE can review the newly created issue and continue working with enough evidence to close that issue until due date. The SRE can also provide more details such as labels, milestones, assignees etc. in the issue if required.
   
   - **Template has wrong formatted values**  
   review the template file (Link provided in the `Summary`) for any fields with values in wrong format. Follow the format given in the README file of the  [template directory](https://github.ibm.com/alchemy-conductors/compliance-reminder-templates/template_dir). Actions should be taken to provide correct values in those fields. Once done, the scanner will review the template file in the next iteration.

2. Once the SRE takes proper actions, he/she can resolve the alert. No other actions needed.


## Further Information
If you want to see the flow digaram and understand the `reminder` tool works, you can check the [compliance reminder repository](https://github.ibm.com/alchemy-conductors/compliance-reminder) for more details.
