---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Explains the process required to get access to Alchemy environments and systems.
service: Runbook needs to be updated with service
title: How to get access to Alchemy Environments and Systems
runbook-name: "How to get access to Alchemy Environments and Systems"
link: /usam_account_access.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook is an Informational runbook about USAM account access.

NOTE: The word "System" in the title of this runbook means "computer".  This runbook *DOES NOT* attempt to address all of the many kinds of authorization you will need.  


## Detailed Information

The following sections contain detailed information.

## Single sign-on account access

All Alchemy squads use [USAM](https://usam.svl.ibm.com:9443/AM/) to manage user access to all environments in SoftLayer.  

Each squad service group has a development, pre-staging, staging, and production environment.  A majority of squad members only require access to the development and pre-staging environments and should only select the developer role for their squad.

The SRE Squad (conductors) should request the conductor role granting them access to all servers in all unrestricted environments.

As a result of recent EU changes, some production environments have more restricted access and access is only granted to persons in the EU.  If you are in SRE or development and are based in the EU, then you also need additional access via groups with the `_EU` suffix.  

VPN access is also controlled via USAM groups - details can be found [here](/docs/runbooks/vpn.html)

If you have any further question or have problems with your SSO/USAM id, consult the Conductors squad via [{{ site.data.teams.containers-sre.comm.name }}]({{ site.data.teams.containers-sre.comm.link }})

## Definition of groups

NB:  Only the first part of the group name is mentioned.  Most groups have a `Developer`, `Staging` and `Production` version of the group.  You should request access to the group which represents the squad you work in.


#### Request access to the Alchemy systems in SoftLayer via [USAM](https://usam.svl.ibm.com:9443/AM/)

1. Click on [Request access to a System](https://usam.svl.ibm.com:9443/AM/idman/AddSystemAccess).
2. In the system search field enter **SOS-IDMgt**.  **Search**.
3. Check the system name **SOS-IDMgt** only.
4. Click **Submit**
5. Enter a **Userid** for yourself (for example, use your intranet short name, NB: This must NOT clash with any local user account on any machine - see NOTE below).
6. Enter a **business justification**.  This should be short and too the point.
7. Select the role you require.  This is a role add only and any existing assigned roles should not be selected
  * BU044-ALC-Conductor - if you are member of the conductors squad
  * BU044-ALC-IDCC-XXXX - if you are a member of a containers squad, where XXXX is the environment you need access to. XXXX is Developer for Dev/Test, Staging for Staging, and Production for Production. (Note that those groups will give you access to all locations for that environment, e.g. London + Dallas for production)
  * Other Roles follow the same rules as point (2) above, but with "IDCC" replaced with the appropriate squad name
  * NB: Sudo access is only granted in the Dev/Test environment, except for Conductors who have sudo access in all environments
  8. Click **Submit**

NOTE on usernames: when creating a new USAM user you must avoid picking any username that appears on any machine that supports USAM logins --- even if that username belongs to you for some other reason and your intention is to retire it.  This stricture is not checked by USAM.  If you violate this restriction, it will cause pain down the road for several people.  Perhas some wizard can augment this note with a way to check for yourself before submitting your proposed username.


#### Approval process

Each request requires approval from your manager, a technical approval, and then sys-admin level approval.  You can check your [approval status here](https://usam.svl.ibm.com:9443/AM/idman/MyUseridsPending).

#### Post-approval / Expired password /  Forgotten password

Once your account has been created, you will be assigned a password that expires on first log-in. Due to the way accounts are handled on linux machines you may be unable to log in until you have changed your password.  There is no generic site at which you can check or change your password; your can only try the facilities of particular projects that are using USAM for their access control.  Following are two particular ones you can try.


##### At the CAA VPN Website / Algo system

1. Visit the [CAA VPN Website](https://170.224.212.4/dana-na/auth/url_default/welcome.cgi)
2. Log in with your SSO username and password.
3. If you enter your credentials correctly and your password has expired then you will be prompted to change it.
4. If you enter your credentials incorrectly then you will get the message "You are not allowed to sign in. Please contact your administrator."
5. If you enter your credentials correctly, your password has NOT expired, and you are NOT authorized to access the Algo system then, too, you will get the message "You are not allowed to sign in. Please contact your administrator."

For an explanation that is not written for our use case and consequently is of little use here, see [this wiki page](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W953987d3a804_496d_8732_32502cd696b7/page/SSL%20VPN%20Information%20%28SV2%20-%20DC5%20-%20TY2%20-%20NK1%20-%20CAA%20-%20CAB%20Access%29?section=How%20to%20change%20initial%20password)


##### At USAM Password reset site

1. Visit this [page](https://w3.sos.ibm.com/changePassword.html)
2. Log in with your *intranet* credentials.
3. You will then get to a page for "USAM password change".
4. Select the USAM SSO credentials you intend to change (you may have multiple), and enter and password (twice, of course), then click OK.
5. In the success case you will be taken to a web page with a heading of "Password change" and content that says "Your password has been successfully changed".


#### USAM userid management site

Go to [USAM](https://usam.svl.ibm.com:9443/AM/)

1. Click on [My userids/access](https://usam.svl.ibm.com:9443/AM/idman/MyUseridsCurrent)
2. For the **SOS-IDMgt** system click on **"Password Reset"**.
3. Click **OK**.


#### Add an additional role

To add access to one or more groups go to [USAM](https://usam.svl.ibm.com:9443/AM/).

1. Click on [My userids/access](https://usam.svl.ibm.com:9443/AM/idman/MyUseridsCurrent).
2. For the Alchemy system click on **"Manage Groups/Privileges"**.
3. Select the role you require access.
4. Click **Submit**.

#### Delete role or access

##### To remove access to one or more groups go to [USAM](https://usam.svl.ibm.com:9443/AM/).

1. Click on [My userids/access](https://usam.svl.ibm.com:9443/AM/idman/MyUseridsCurrent).
2. For the **SOS-IDMgt** system click on **"Manage Groups/Privileges"**.
3. Select the role to remove.
4. Click **Submit**.

##### To remove your access to all of the Alchemy systems go to [USAM](https://usam.svl.ibm.com:9443/AM/).

1. Click on [My userids/access](https://usam.svl.ibm.com:9443/AM/idman/MyUseridsCurrent).
2. For the system name **SOS-IDMgt** click on **delete**.
3. Confirm the deletion.

----

## How to configure single sign-on LDAP access

#### To setup the LDAP access for the Alchemy systems follow the instructions at the following links

- [Firewall rules required for Active Directory to work](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W239e36fa8923_49da_b5f8_d3a524dbeed6/page/ID%20Mgt%20-%20Firewall%20Rules)
- [Linux Configuration](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/SSO%20Authentication%20Configuration%20Guide%20for%20Linux%20Systems)
    - [RedHat Configuration](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/SSO%20AD%20Authentication%20Configuration%20Guide%20(RHEL6))
    - [Ubuntu 14.04 LTS Configuration](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/SSO%20AD%20Authentication%20Configuration%20Guide%20(Ubuntu%2014.04%20LTS)New%20Page)
    - [Ubuntu 12.04 LTS Configuration](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/SSO%20AD%20Authentication%20Configuration%20Guide%20(Ubuntu%2012.04%20LTS)%20Page)
