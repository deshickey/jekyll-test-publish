---
layout: default
description: Runbook detailing how to update jenkinsvpn password
service: "Infrastructure"
title: How to update jenkinsvpn password
runbook-name: Runbook detailing how to update jenkinsvpn password
link: /sre_updating_jenkinsvpn_password.html
type: Troubleshooting
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

How to change and then update the relevant tools when the `jenkinsvpn` user's password is about to expire.

The password needs to be reset every 3 months.

## What is this userid used for?

`jenkinsvpn` userid is the SOS id used to connect to our openvpn endpoints and is used by the Alchemy Docker Swarm in all of our Jenkins instances. 

## Example alerts

- [AlchemyConductorsBuild *APPLICATION-ID* - Your SOS password will expire in 7 days](https://ibm.pagerduty.com/incidents/PARB994)

We will receive a pagerduty alert when the ID is about to expire.

Note that you have to look into the details of the alert to find the id that is expiring.  
For example `Your SOSid is: jenkinsvpn`

## Initial actions

Raise a [Conductors team ticket in GHE](https://github.ibm.com/alchemy-conductors/team/issues/new) to track the password update.

## Detailed information

We must process the ID reset in a timely manner or risk issues with Jenkins jobs being unable to connect into any of our environments if the password expires.

## Investigation and Action

### Engage taas team member

Before passwords are reset, we **MUST** pre-arrange a time to do this with the TaaS team.

Reach out in the channel [#taas-jenkins-help](https://ibm-argonauts.slack.com/archives/C56Q2JUKS) and liaise with a TaaS team member ready to receive password update.


_(In the past, Andy Taylor from the UK TaaS squad has performed this update, but there is a TaaS runbook linked below so any team member can help.)_

**NOTE:** It is crucial that someone is ready to receive password and update it on appropriate places to avoid longer downtime for Jenkins jobs.

Announce on [#conductors](https://ibm-argonauts.slack.com/archives/C54H08JSK) channel that you are about to change the password and it may result in small vpn downtime for Jenkins jobs running.

### Reset and save the password

**NB** Only when TaaS are ready to perform the update should these steps be followed!

Change SOS IDmgt password via AccessHub
1. Login to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome) with `AlConBld@uk.ibm.com` using [Thycotic Shared Credentials - `alconbld w3 id`](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/checkout/27710)
1. Click on "Change Password for Self"
1. Add "SOS IDMGT" application to cart
1. Click on "Check Out"
1. Select `jenkinsvpn` account for password change
1. Click on "Change password"
1. On a popup window to change password, click on "Type New Password" tab
1. Put random password and make a note of the password you put in.
   - _You can use `openssl rand -base64 15` to generate a random 15 character password, but additional special characters may be needed. Alternatively, use a tool like 1Password to generate the password._
   - Note the complexity requirements from <https://pages.github.ibm.com/SOSTeam/SOS-Docs/idmgt/policies/passwordrules/#password-complexity-requirements> - **ensure that the password satisfies them**
   - In particular: **`Note: AccessHub does not support the following characters for passwords: <>:^{}[]`**
1. Update the password in [Thycotic - `jenkinsvpn password for openvpn`](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/27773/general)
1. Send the password to the team member enaged earlier in an encrypted email.

### Alchemy Docker Swarm VPN password change

SRE have no specific actions here.

After the password is updated and emailed to TaaS, the docker swarms we use need to have their password updated.
This process is executed by the TaaS team.  They should be aware of this process.  The [alchemy-vpn-password-change runbook](https://pages.github.ibm.com/TAAS/taas-runbook/Docker-Swarm/runbooks/alchemy-vpn-password-change) documents this process can be given to them if they are unsure what process to follow.

Once the swarms are updated, the TaaS team will monitor them to ensure they all restart without error.  They will inform you once this is complete.

Once all VPNs are confirmed as updated and are running without error, the password update is considered complete and our team GHE can be closed out.

The following Grafana [dashboard](https://grafana.swg-devops.com/d/alchemy-tunnels/alchemy-tunnels?var-node=All&orgId=1&refresh=30s) can be used to verify that the tunnels are back up - check the `tunnel` graphs:
- A `0` value means down
- A `1` value means up

### Checking LDAP account lockout status

Note that after changing the user password in AccessHub, the old password may still be in use in TaaS Jenkins, and so the account could get locked out due to incorrect password attempts.

We can query LDAP to see the status of the user, in particular whether it is locked out due to password failures.

The `ldapsearch` query can be run from any worker or master node.

First check which LDAP server is appropriate for the node:
```
patrick.doyle@stgiks-dal10-carrier0-worker-8007:~$ sudo grep server /etc/sssd/sssd.conf
krb5_server = bu044-dal10-dir03.idm.sos.ibm.com
```

Then query for the `jenkinsvpn` user (supplying your own SOS username and password):

```
patrick.doyle@stgiks-dal10-carrier0-worker-8007:~$ ldapsearch -LLL -x -H ldap://bu044-dal10-dir03.idm.sos.ibm.com -D YOUR_SOS_USERNAME_HERE@sso.ad.isops.ibm.com -W -b DC=sso,DC=ad,DC=isops,DC=ibm,DC=com '(&(uid=jenkinsvpn))'
Enter LDAP Password:
dn: CN=AlchemyConductorsBuild  *APPLICATION-ID*,OU=UserAccts,DC=sso,DC=ad,DC=i
 sops,DC=ibm,DC=com

badPasswordTime: 133056432843000811
lastLogon: 133057221038239501
pwdLastSet: 133056419686644966
lockoutTime: 0
```

In the above case, the account is not locked out: `lockoutTime: 0`

If you find that the account is locked out, then go back to AccessHub and request an `Unlock` for the account. It should only take a few minutes for the unlock to propagate to all LDAP servers.

## Escalation policy

If you are unsure then raise the problem further with the SRE team.

Discuss the issues seen with the SRE team in one of the following channels
- **Conductor** (or access to the following restricted channels): `#conductors-for-life` or `#sre-cfs`
- **Others** (users outside the SRE squad) : #conductors

There is no formal call out process for this issue.
