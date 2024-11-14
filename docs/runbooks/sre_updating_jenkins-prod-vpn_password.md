---
layout: default
description: Runbook detailing how to update jenkins-prod-vpn password
service: "Infrastructure"
title: How to update jenkins-prod-vpn password
runbook-name: Runbook detailing how to update jenkins-prod-vpn password
link: /sre_updating_jenkins-prod-vpn_password.html
type: Troubleshooting
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

How to change and then update the relevant tools when the `jenkins-prod-vpn` user's password is about to expire.

The password needs to be reset every 3 months.

## What is this userid used for?

`jenkins-prod-vpn` is used by the Kubernetes Jenkins instances

The ID is associated with a taskid and is a member of the following AccessHub groups;
- BU044-ALC-Conductor_EU
- BU044-ALC-2FA-EXEMPT
- BU044-ALC-Conductor
- BU044-ALC-2FA

## Example alerts

- [AlchemyConductorsBuild *APPLICATION-ID* - Your SOS password will expire in 3 days](https://ibm.pagerduty.com/incidents/PRX80FL)

We will receive a pagerduty alert when the ID is about to expire.

Note that you have to look into the details of the alert to find the id that is expiring.
For example `Your SOSid is: jenkins-prod-vpn`

## Initial actions

Raise a [Conductors team ticket in GHE with the relevant template](https://github.ibm.com/alchemy-conductors/team/issues/new?assignees=&labels=interrupt&projects=&template=password_rotation_jenkins-prod-vpn.md&title=Users+with+password+expiry+approaching+or+locked+out+identified+-+jenkins-prod-vpn) to track the password update.

## Detailed information

We must process the ID reset in a timely manner or risk issues with VPN connections in our jenkins.

## Investigation and Action

### Scale deploy to 0

We scale the daemonset to zero to avoid locking the ID after changing the password. This can be achieved by temporarily adding a nodeSelector label with no matches.

`Account`: Alchemy Support (800fae7a41e7d4a1ec1658cc0892d233) <-> 278445 <br>
`Clusters`: jenkins-privileged (ccrfe9qf0i5no3ufe40g) and jenkins-privileged-us-east (cev4g5fw0vk2tu320510)

Repeat the below steps for both the clusters (NOTE: this will bring down all jenkins-vpn* pods):
```
ibmcloud ks cluster config -c $CLUSTER
kubectl -n jenkins-vpn patch daemonset jenkins-vpn -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existing-label": "true"}}}}}'
```

Make sure jenkins-vpn pods are terminated and no pod is running
```
kubectl get pods -n jenkins-vpn
```

### Reset and save the password

NB: The process must be followed in full, immediately after password reset or you risk having account lock-outs if the daemonset restarts and uses an old/cached password.

Change SOS IDmgt password via AccessHub
1. Login to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome) with `AlConBld@uk.ibm.com` using [Thycotic Shared Credentials](https://pimconsole.sos.ibm.com/SecretServer/app#/secret/checkout/27710)
1. Click on "Change Password for Self"
1. Add "SOS IDMGT" application to cart
1. Click on "Check Out"
1. Select `jenkins-prod-vpn` account for password change
1. Click on "Change password"
1. On a popup window to change password, click on "Type New Password" tab
1. Put random password and make a note of the password you put in.  
   _You can use `openssl rand -base64 15` to generate a random 15 character password._

### Update password and restart jenkins vpn containers

Repeat the below steps for both the clusters:
   
1. Create a temp file with following info
   ```
   VUSER=jenkins-prod-vpn
   VPASS='UPDATE_ME'
   ```
1. Run this to generate the base64-encoding of the file
   ```
   cat file | base64
   ```
1. Take output from above command and edit into `login.env` field via following cmd `kubectl edit secret -n jenkins-vpn ldap-login-openvpn-jenkins`
   1. If the secret doesn't exist, use this template:
      ```
      apiVersion: v1
      data:
        login.env: THE_BASE64_STRING_FROM_PRIOR_STEP_HERE
      kind: Secret
      metadata:
        name: ldap-login-openvpn-jenkins
        namespace: jenkins-vpn
      type: Opaque
      ```
1. Run this to scale the pods back up
   ```
   kubectl -n jenkins-vpn patch daemonset jenkins-vpn --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing-label"}]'
   ```
1. Update the password at [Thycotic shared credential](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/80293/general)

## Escalation policy

If you are unsure then raise the problem further with the SRE team.

Discuss the issues seen with the SRE team in `#conductors` (For users outside the SRE squad) or in `#conductors-for-life` or `#sre-cfs` if you have access to these private channels.

There is no formal call out process for this issue.
