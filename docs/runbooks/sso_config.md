---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: SOS IDMgt Installation and Configuration
service: SOS IDMgt
title: SOS IDMgt Installation and Configuration
runbook-name: "Configuring a Host for SSO"
link: /sso_config.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

Initial Setup
-------------

## Overview

Runbook detailing configuration info and validation steps for SOS IDMgt config.

## Detailed Information

This document compliments the automated steps in the [Conductors bootstrap code](https://github.ibm.com/alchemy-conductors/bootstrap-one/tree/master/playbooks/roles/usam)

This document assists with debugging when SOS IDMgt related issues such as logon and connectivity are observed.

## Detailed Procedure

The following sections contain the detailed steps to validate manually

## Reference material

The following sections are heavily based on information provided by the SOS team and is available [here](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/SSO%20Linux%20Guide)


### Firewall holes

Access is needed to the local AD server on ports 88 (Kerberos), 389 (ldap), 3269 (global catalog, RHEL only)
Access is needed via a Tunnel to CSS from the local AD server.

### Software install needed

* apt-get update
* apt-get install sssd
* apt-get install sssd-tools
* apt-get install ldap-utils

Versions installed and tested were:

* `sssd       - 1.11.5-1ubuntu3`
* `sssd-tools - 1.11.5-1ubuntu3`
* `ldap-utils - 2.4.31-1+nmu2ubuntu8.1`

### Gotcha's

* don't use the same SSO user id as a local user, this causes the Conductors SRE bootstrap scripts to have issues
* configuration examples on the SSO wiki refer to "proj-adsso-001.sso.ad.isops.ibm.com", this should always be replaced with the name of your local AD server. In our case all the examples are from stage-dal09 and use the machine `alwg9-adsso-001.sso.ad.isops.ibm.com`

Machine Configuration
---------------------

* Add the local AD server to /etc/hosts so it can be resolved by name: `10.142.198.71   algw9-adsso-001.sso.ad.isops.ibm.com algw9-adsso-001`
* Change /etc/nsswitch.conf so that it references "sss" as an auth scheme:
  * `passwd:         files sss`
  *	`group:          files sss`
  *	`shadow:         files sss`
* Change/create [/etc/krb5.conf](usam/krb5.conf) (permissions = 644)
* Change/create [/etc/sssd/sssd.conf](usam/sssd.conf) (permissions = 600)
* Create [/etc/sys-auth.allow-group](usam/sys-auth.allow-group) (permissions = 0400), then depending on the environment add one of the following:
  1. For dev/test: BU044-ALC-IDCC-Developer
  2. For staging: BU044-ALC-IDCC-Staging
  3. For production: BU044-ALC-IDCC-Production
* Edit /etc/sudoers using visudo -f /etc/sudoers so that it has the include directive: #includedir /etc/sudoers.d
* Create the file [/etc/sudoers.d/500-Alchemy](usam/500-Alchemy) (permissions = 0400). For a dev/test machine also add BU044-ALC-IDCC-Developer to allow sudo for dev/test machines
* Update the following pam files:
  1. [common-auth](usam/common-auth)
  2. [common-account](usam/common-account)
  3. [common-session](usam/common-session)
  4. [common-session-noninteractive](usam/common-session-noninteractive)
* crate /home/SSO (permissions = 755)


Debugging
---------

Check that your user hasn't been locked out, we only allow 5 attempts, if you have logged in before and had a number of failures greater than 5 then you will need someone to reset your SSO user id using:

`pam_tally --user birchst7 --reset`

Check you can reach the AD server on the required ports:
  * `nc -zv algw9-adsso-001.sso.ad.isops.ibm.com 88`
  * `nc -zv algw9-adsso-001.sso.ad.isops.ibm.com 389`
  * `nc -zv algw9-adsso-001.sso.ad.isops.ibm.com 3269` (RHEL ONLY)

Check ldap can find your user:

`ldapsearch -LLL -x -H ldap://10.142.198.71 -D 'srowles@sso.ad.isops.ibm.com' -w '<YOURPASS>' -b "DC=sso,DC=ad,DC=isops,DC=ibm,DC=com" '(&(objectclass=user)(uid=srowles))'`

Check that ldap can find your user using the SSO credentials:

`ldapsearch -LLL -x -H ldap://algw9-adsso-001.sso.ad.isops.ibm.com -D 'bindisops@sso.ad.isops.ibm.com' -w '<PASSWORD>' -b "DC=sso,DC=ad,DC=isops,DC=ibm,DC=com" '(&(objectclass=user)(uid=srowles))'`

Run `id` to verify that your ID as the appropriate groups:

`id srowles` which will output: `uid=56029(srowles) gid=20002(Domain Users) groups=20002(Domain Users),20582(BU044-ALC-ISIE-AV),20603(BU044-ALC-IDCC-Developer),20604(BU044-ALC-IDCC-Staging),20605(BU044-ALC-ISIE-Reports),20606(BU044-ALC-ISIE-Security)`

If the `ldapsearch` checks pass, but `id <SOS IDMgt user>` fails, check sssd service is running with command, `service sssd status`.  If stopped, restart it.

If one or all of your roles don't show up, you will need to contact the CSS team and get them to fix the Role definitions, they are probably missing unix permissions

Check groups resolve to users by running the following for one of the machines you belong to:

`getent group BU044-ALC-ISIE-Security` and ensure it lists your user id
