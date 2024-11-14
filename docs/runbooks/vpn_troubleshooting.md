---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Troubleshooting openvpn issues
service: OpenVPN
title: Troubleshooting openvpn issues
runbook-name: "Troubleshooting openvpn issues"
link: /vpn_troubleshooting.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# Hints and tips troubleshooting openvpn issues.

## Overview
Hints and tips troubleshooting `openvpn` and `openconnect` issues.

## Detailed Information

Hints and tips diagnosing `openvpn` and `openconnect` issues.

The `infra-vpn` servers all run 2 VPN processes:
- `openvpn`  
for **users** and `jenkins` to connect to our environments, 
- `openconnect`  
only for use by **automation** (bots etc.) to connect to our environments 

This document helps debug common problems.

### VPNs use cloudflare endpoint

The latest client side openvpn code in [openvpn-clients GHE](https://github.ibm.com/alchemy-conductors/openvpn-clients/tree/static) configures the use a **single** `Cloudflare` url for either of our [2] VPN Endpoints.

Instead of the client configuration file having IP addresses for `remote` option, it has a url  
_for example `remote vpn.dev-mon01.containers.cloud.ibm.com`_

Using cloudflare gives us these benefits;
- `flexibility`  
if any VPN server is replaced, the new server IP address has to only be changed in Cloudflare and not by everyone with local client config
- `automatic loadbalancing`  
Cloudflare will route the VPN connection to an available VPN server

The `netint` squad should be contacted if you suspect any issues with Cloudflare or its configuration as they own the definitions and rules.

### openvpn connection waiting for response from server

Observed recently was an issue when trying to establish an openvpn to sup-wdc04.

Using tunnelblick, users reported that the connection was not established and remained on a prompt stating - `Waiting from response from server` (or similar).

Steps taken to debug:

1.  Used Softlayer vpn to establish a connection to the environment  
_see [this IBM Cloud document to install the softlayer vpn client](https://cloud.ibm.com/docs/infrastructure/iaas-vpn?topic=VPN-standalone-vpn-clients)_
   - Typically in _pre-prod_ accounts, SREs should have SoftLayer SSL openvpn access.
   - For _production_ accounts this is disabled by default.
   - To gain the permission for a temporary SoftLayer SSL VPN access, please see [Managing your userid and enabling VPN](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/kvm_access.html#managing-your-userid-and-enabling-vpn)

2. ssh to the VPN machines for the environment  
_to find the ones which should be currently in use, review the IP addresses set in [openvpn config](https://github.ibm.com/alchemy-conductors/openvpn-clients/tree/static)_

3. Once on the vpn server, review `/var/log/syslog` and/or `/var/log/openvpn.log`.  
An error such as below, means that the connection to the 2FA server has a problem.

   > Sep  7 09:38:41 prod-lon02-infra-vpn-01.alchemy.ibm.com openvpn[28126]: ERROR: pam_vrsn_otp: validateOTP returns err (validateOTP: Failed to invoke 'authenticate' [18517]:(Provider [VSRadiusClient] failed to invoke authentication request [-3] with error. Details [select [10.143.151.174] failed / timed out on socket 3])#012)
   > Sep  7 09:38:41 prod-lon02-infra-vpn-01.alchemy.ibm.com openvpn[28126]: ERROR: pam_vrsn_otp: pam_sm_authenticate for user (cullepl) returns error - 7
   
   _In this instance, the tunnel between the Softlayer environment and the SOS environment was down. Netint had to restore the tunnel_

### Temporarily disable 2FA for the environment to verify it is a 2FA issue.

To help rule out 2FA issues, one quick test is to temporarily disable 2FA on one of the openvpn servers in the environment you are having issues with.

On one of the openvpn servers in the environment, temporarily turn off 2FA then test the openvpn connection to the server.

To do this, edit `/etc/pam.d/openvpn`  
_NOTE: There is no need to restart the OpenVPN service after editing this file and existing connections will be unaffected._

In its **`2FA` disabled** state, the file looks something like the following  
_i.e. The `/lib64/security/pam_duo.so` is commented out!_

~~~
#auth [success=ok default=2] /lib64/security/pam_duo.so
auth    required pam_sss.so
account required pam_listfile.so onerr=fail item=group sense=allow file=/etc/openvpn.allow-group
account [default=bad success=done user_unknown=ignore] pam_sss.so
auth    sufficient pam_permit.so

# 2FA Exempt login
auth    required pam_sss.so
auth    required pam_listfile.so onerr=fail item=group sense=allow file=/etc/openvpn.exempt-group
account required pam_listfile.so onerr=fail item=group sense=allow file=/etc/openvpn.allow-group
account [default=bad success=done user_unknown=ignore] pam_sss.so
~~~

Notice, line 1 is commented out.
As `root`, make edit the file and save.

Once 2FA is disabled, attempt an openvpn connection to that specific openvpn server.
If this passes, then the problem is with connecting and authenticating with the 2FA server.

Possible issues are:
- Unknown at the time of writing as DUO processing is new, howevver, it **could** mean that the DUO service is down!

**NB: Remember to re-enable 2FA on the server if you disable ir!**

### Other useful checks to rule out connection issues

The following section may need to be removed as the DUO solution for 2FA may render it inappropriate!

---
~~~
The 2FA traffic is sent using `UDP` protocol on port `1826`. The SOS provided servers are listed in /etc/raddb/vrsn_otp. To test connectivity use the following script:

```
if [ -f /etc/raddb/vrsn_otp ]
then
    for twofa in $(cat /etc/raddb/vrsn_otp|awk '{print $1}')
    do
        echo $twofa
        IP=$(echo $twofa|cut -d: -f1)
        port=$(echo $twofa|cut -d: -f2)
        nc -vuz -w 5 $IP $port
    done
fi
```

which should also be in /root/2fa-test.sh


This should return a message similar to below

- `Connection to 10.143.151.175 1826 port [udp/*] succeeded!`

If no response is received, verify that firewall rules are in place , ask in `#netint` on slack, to make a request to allow the 2FA traffic.

If a response is received, ask in `#netint` during UK office hours, or page out netint out of hours, to verify that the tunnel between that environment and SOS is up and operational.

~~~
---

### Logs
The following logs can be used for troubleshooting.
- `/etc/openvpn/openvpn-status.log` - this log shows who is currently connected. helpful to identify if non-2fa users only are connected
- `/var/log/auth.log` - shows authentication challenges
- `/var/log/syslog` - shows openvpn/openconnect activity (on some machines it logs to `/var/log/openvpn.log`)

### Test ldap (USAM) connectivity
Run `/root/ldap-test.sh` with your userid as the parameter. That script tests for ping connectivity, port connectivity and finally ldap credential functionality.


### Contacting the SOS team for assistance.

If all our checks pass, then we will need assistance from the SOS networking team. 
To do this, raise and [SOS Support ticket](https://ibm.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3D45ef56a7db7c4c10c717e9ec0b96193a%26sysparm_link_parent%3D109f0438c6112276003ae8ac13e7009d%26sysparm_catalog%3De0d08b13c3330100c8b837659bba8fb4%26sysparm_catalog_view%3Dcatalog_default%26sysparm_view%3Dcatalog_default) and fill in the
following details.

- Assignment Group: `SOS 2FA`.
- Severity: as appropriate
- C_Code: `ALC`
- Short Description: `Describe the issue being observed`
- Description: `Detail the problem, the steps you've taken so far to diagnose and the help you are requesting`


## Client side Configuration
See the [VPN](vpn.html) runbook for details.

## Escalation Policy
If a 2FA server is not functioning correctly please ask in `conductors-2fa` on slack.

If there are issues with `openconnect` and you are unable to fix, please engage netint.
