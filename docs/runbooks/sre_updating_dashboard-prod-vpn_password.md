---
layout: default
description: Runbook detailing how to update dashboard-prod-vpn password
service: "Infrastructure"
title: How to update dashboard-prod-vpn password
runbook-name: Runbook detailing how to update dashboard-prod-vpn password
link: /sre_updating_dashboard-prod-vpn_password.html
type: Troubleshooting
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

How to change and then update the relevant tools when the `dashboard-prod-vpn` user's password is about to expire.

The password needs to be reset every 3 months.

## What is this userid used for?

`dashboard-prod-vpn` is used by the Alchemy Dashboard access at [alchemy-dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/)

The ID is associated with a taskid and is a member of the following AccessHub groups;
- BU044-ALC-Conductor_EU
- BU044-ALC-2FA-EXEMPT
- BU044-ALC-Conductor
- BU044-ALC-2FA

## Example alerts

- [Users with password expiry approaching or locked out identified](https://ibm.pagerduty.com/incidents/Q0JP3JVTMX86C2)

We will receive a pagerduty alert when the ID is about to expire.

Note that you have to look into the details of the associated [Jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/ldap-password-expiry-lockout-alert/) to find the id that is expiring.
For example:

```
INFO:root:User dashboard-prod-vpn has password expiry approaching. Only 4 days remaining. Consider rotating password.
```

## Initial actions

Raise a [Conductors team ticket in GHE with the relevant template](https://github.ibm.com/alchemy-conductors/team/issues/new?assignees=&labels=interrupt&projects=&template=password_rotation_dashboard-prod-vpn.md&title=Users+with+password+expiry+approaching+or+locked+out+identified+-+dashboard-prod-vpn) to track the password update.

## Detailed information

We must process the ID reset in a timely manner or risk issues with VPN connections in our bots.

## Investigation and Action

Account: `Alchemy Support (800fae7a41e7d4a1ec1658cc0892d233) <-> 278445`

### Scale deploy to 0

There are multiple instances that use this password. The following must be done for all:

> We need scale the deploy to zero to `avoid locking the account` after changing the password.

### Cluster `bots (d34580e8ca3a47939515766ff7d9d515)`
Please repeat the same steps to scale the deployment to the following (namespace and deployment name using kubectl syntax):

```
ibmcloud ks cluster config -c bots
kubectl scale deploy -n dashboard alchemy-dashboard --replicas=0
kubectl scale deploy -n dashboard ghe-watcher --replicas=0
kubectl scale deploy -n dashboard-test ghe-watcher-stage --replicas=0
``` 

Make sure dashboard pods are terminated and no pod is running
```
kubectl get pods -n dashboard
kubectl get pods -n dashboard-test
```


### Cluster `infra-accessallareas-stage (bmpe9euf00a3okg0u9vg)`
Please repeat the same steps to scale the deployment to the following second cluster (namespace and deployment name using kubectl syntax):

```
ibmcloud ks cluster config -c infra-accessallareas-stage
kubectl scale deploy -n dashboard alchemy-dashboard --replicas=0
``` 

Make sure dashboard pods are terminated and no pod is running
```
kubectl get pods -n dashboard
```

### Reset and save the password

NB: The process must be followed in full, immediately after password reset or you risk having account lock-outs if the dashboard restarts and uses an old/cached password.

Change SOS IDmgt password via AccessHub
1. Login to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome) with `AlConBld@uk.ibm.com` using [Thycotic Shared Credentials](https://pimconsole.sos.ibm.com/SecretServer/app#/secret/checkout/27710)
1. Click on "Change Password for Self"
1. Add "SOS IDMGT" application to cart
1. Click on "Check Out"
1. Select `dashboard-prod-vpn` account for password change
1. Click on "Change password"
1. On a popup window to change password, click on "Type New Password" tab (go to step 8) or choose "recommended password" (skip step 8, go to step 9)
1. If you choose "Type New Password", create a random password as below  
   _You can use `openssl rand -base64 15` to generate a random 15 character password._
1. To confirm new password updated, log into a us-south carrier node and try `ldapsearch` as below (or other region, but the `.idm.sos.ibm.com` hostname would need to change, based on the contents of the `/etc/sssd/sssd.conf` file)
```
ldapsearch -LLL -x -H ldaps://bu044-dal09-dir03.idm.sos.ibm.com -D dashboard-prod-vpn@sso.ad.isops.ibm.com -W -b DC=sso,DC=ad,DC=isops,DC=ibm,DC=com '(&(uid=dashboard-prod-vpn))'
   _Enter LDAP Password:<enter new password>_
```
   If the output is `ldap_bind: Invalid credentials (49)`, please check the account has been locked or the new password has not been updated yet.

### Update password and restart dasboard vpn containers
1. create a local temp file ldap-login-openvpn-dash with following info, make sure using single quote `'` for both VUSER & VPASS
   ```
   VUSER='dashboard-prod-vpn'
   VPASS='NEW-PASSWORD'
   ```
1. `cat ldap-login-openvpn-dash | base64`
1. take output from above command and edit into login.env field via following cmd
    ```
    kubectl edit secret -n <namespace> ldap-login-openvpn-dash
     ```   


### Cluster `bots (d34580e8ca3a47939515766ff7d9d515)`
```
ibmcloud ks cluster config -c bots
```

Update the `login.env:` value with output got in previous step `cat ldap-login-openvpn-dash | base64`
```
kubectl edit secret -n dashboard ldap-login-openvpn-dash
kubectl edit secret -n dashboard-test ldap-login-openvpn-dash
```

Example (it opens in `vim` or your chosen editor):
```
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
data:
  login.env: VlVT**********zducSc=
kind: Secret
metadata:
```

### Revert back to replica=1
```
kubectl scale deploy -n dashboard alchemy-dashboard --replicas=1
kubectl scale deploy -n dashboard ghe-watcher --replicas=1
kubectl scale deploy -n dashboard-test ghe-watcher-stage --replicas=1
```

### Restart the deployment
```
kubectl rollout restart deploy -n dashboard alchemy-dashboard
kubectl rollout restart deploy -n dashboard ghe-watcher
kubectl rollout restart deploy -n dashboard-test ghe-watcher-stage
kubectl delete pod prometheus-federation-0 -n dashboard-test
``` 

### Cluster `infra-accessallareas-stage (bmpe9euf00a3okg0u9vg)`
Please repeat the same steps to update new credential value into `login.env` to the following second cluster
```
ibmcloud ks cluster config -c infra-accessallareas-stage
```

Update the `login.env:` value with output got in previous step `cat ldap-login-openvpn-dash | base64`
```
kubectl edit secret ldap-login-openvpn-dash
kubectl edit secret -n dashboard ldap-login-openvpn-dash
```

### Revert back to replica=1
```
kubectl scale deploy -n dashboard alchemy-dashboard --replicas=1
```

### Restart the deployment
```
kubectl rollout restart deploy -n dashboard alchemy-dashboard
``` 

### Update the password
Update the password in [Thycotic shared credential](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/27745/general) `Secret Name` `dashboard-prod-vpn`

## Escalation policy

If you are unsure then raise the problem further with the SRE team.

Discuss the issues seen with the SRE team in `#conductors` (For users outside the SRE squad) or in `#conductors-for-life` or `#sre-cfs` if you have access to these private channels.

There is no formal call out process for this issue.
