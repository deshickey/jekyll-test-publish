---
layout: default
description: Runbook detailing how to update conauto password
service: "Infrastructure"
title: How to update conauto password
runbook-name: Runbook detailing how to update conauto password
link: /sre_updating_conauto_password.html
type: Troubleshooting
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

How to change and then update the relevant tools when the `conauto` users password is about to expire.

The password needs to be reset every 3 months.

## What is this userid used for?

`conauto` is used by [nessus_scan_ip_list_generator](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/nessus_scan_ip_list_generator) jenkins job. More information on this job is available at [compliance_nessus_scan_ip_list_generator](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/compliance_nessus_scan_ip_list_generator.html) runbook.

## Example alerts

- [#69591738 Users with password expiry approaching or locked out identified](https://ibm.pagerduty.com/incidents/Q1E473I2IZNJ4C), raised from https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/ldap-password-expiry-lockout-alert/

We will receive a pagerduty alert when the ID is about to expire.

## Initial actions

Raise a [Conductors team ticket in GHE with the relevant template](https://github.ibm.com/alchemy-conductors/team/issues/new?assignees=&labels=interrupt&projects=&template=password_rotation_conauto.md&title=Users+with+password+expiry+approaching+or+locked+out+identified+-+conauto) to track the password update.


## Detailed information

We must process the ID reset in a timely manner or risk having Jenkins job failures that uses this credential.

## Investigation and Action


## Reset and update the password 

Change SOS IDmgt password via AccessHub
1. Login to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome) with `conauto@uk.ibm.com` using [Thycotic Shared Credentials](https://pimconsole.sos.ibm.com/secretserver/app/#/secrets/92081/general)
1. Click on "Change Password for Self"
1. Add "SOS IDMGT" application to cart
1. Click on "Check Out"
1. Select `conauto` account for password change
1. Click on "Change password"
1. On a popup window to change password, click on "Type New Password" tab
1. Put random password and make a note of the password you put in.  
   _You can use `openssl rand -base64 15` to generate a random 15 character password._

## Update password in Jenkins and Thycotic

Update the password in Jenkins
1. Update [Jenkins credential](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/credentials/store/folder/domain/_/credential/Security-Compliance-SOS-Userid-Password/) with new password
1. Update the passworkd at [Thycotic shared credential](https://pimconsole.sos.ibm.com/SecretServer/app/#/secrets/27727/general)

## Escalation policy

If you are unsure then raise the problem further with the SRE team.

Discuss the issues seen with the SRE team in `#conductors` (For users outside the SRE squad) or in `#conductors-for-life` or `#sre-cfs` if you have access to these private channels.

There is no formal call out process for this issue.

