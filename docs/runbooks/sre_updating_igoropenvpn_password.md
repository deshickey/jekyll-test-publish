---
layout: default
description: Runbook detailing how to update igoropenvpn password
service: "Infrastructure"
title: How to update igoropenvpn password
runbook-name: Runbook detailing how to update igoropenvpn password
link: /sre_updating_igoropenvpn_password.html
type: Troubleshooting
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

How to change and then update the relevant tools when the `igoropenvpn` users password is about to expire.

The password needs to be reset every 3 months.

## What is this userid used for?

`igoropenvpn` is used by our `bots` to initiate a VPN connection to our IBM Infrastructure accounts using [OpenConnect](https://github.ibm.com/alchemy-conductors/openconnect-client) VPN.

The ID is associated with a taskid and is a member of the following AccessHub groups;
- BU044-ALC-Conductor_EU
- BU044-ALC-2FA-EXEMPT
- BU044-ALC-Conductor
- BU044-ALC-2FA

The bots which make use of this ID are as follows:

- igorina-ha
- smith-trigger-service
- victory
- netint services (such as inquisition)

## Example alerts

- [#65803287 Users with password expiry approaching or locked out identified](https://ibm.pagerduty.com/incidents/Q1PR11FCB4NXKU), raised from https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/ldap-password-expiry-lockout-alert/

We will receive a pagerduty alert when the ID is about to expire.

## Initial actions

Raise a [Conductors team ticket in GHE with the relevant template](https://github.ibm.com/alchemy-conductors/team/issues/new?assignees=&labels=interrupt&projects=&template=password_rotation_igoropenvpn.md&title=Users+with+password+expiry+approaching+or+locked+out+identified+-+igoropenvpn) to track the password update.


## Detailed information

We must process the ID reset in a timely manner or risk issues with VPN connections in our bots.

## Investigation and Action


## Reset and update the password 

**Pre-req**: make sure that both on-call SREs have access to the [alchemy-1337/chlorine-bot-creds](https://github.ibm.com/alchemy-1337/chlorine-bot-creds) repo, so that changes can be merged!

_**Careful planning is required as the process will involve re-deploying several of the bots used by critical SRE processes.**_

_**NB: The process must be followed _in full, immediately after password reset_ or you risk having account lock-outs if any of the bots restart and use an old/cached password.**_

- Change SOS IDmgt password via AccessHub
   - Login to [AccessHub](https://ibm-support.saviyntcloud.com/ECMv6/request/requestHome) with `SRE.Bot@uk.ibm.com` using [Thycotic Shared Credentials](https://pimconsole.sos.ibm.com/secretserver/app/#/secrets/checkout/92085)
   - Click on "Change Password for Self"
   - Add "SOS IDMGT" application to cart
   - Click on "Check Out"
   - Select `igoropenvpn` account for password change
   - Click on "Change password"
   - On a popup window to change password, click on "Type New Password" tab
   - Put random password and make a note of the password you put in.  
      _You can use `openssl rand -base64 15` to generate a random 15 character password. Make sure that it meeds the complexity requirements._

## Test the new password

Before updating the Consumers below, test that the new password authenticates successfully.

Use the credentials to open a Tunnelblick/openvpn connection to the `dev` VPN:

1. Clear your stored credentials for `dev-mon01`:
   1. Open Tunnelblick by clicking on the icon in the taskbar, and select `VPN Details...`
   1. Open the `Configurations` tab
   1. Click on `dev-mon01`
   1. Use the gear icon on the bottom to open the settings menu and click on `Delete Configuration's Credentials in Keychain`
1. Use `igoropenvpn` to log into vpn:
   1. Open the vpn connection to `dev-mon01` as normal
   1. Use `igoropenvpn` as the username
   1. Use the newly-generated password as the password
   1. Do not save in your keychain
1. If the vpn connection opens as expected, then disconnect and proceed below to update the Consumers.
   1. Else go back and change the password again

# Updating Consumers

## 1) update Jenkins

-  Update the password in Jenkins using the direct links below:

    - [Conductors Jenkins igoropenvpn](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/credentials/store/folder/domain/_/credential/igor_openvpn_creds)
    - [igoropenvpn Network-Intelligence folder](https://alchemy-containers-jenkins.swg-devops.com/view/Network-Intelligence/job/Network-Intelligence/credentials/store/folder/domain/_/credential/igoropenvpn/)


## 2) update the live AAA-stage cluster
1. To connect to the cluster:
   1. Login to the IBM Cloud: `ibmcloud login -sso`
   1. to ensure the set the appropriate region, if not already eu-de  
`ibmcloud target -r eu-de`
   1. Target `Alchemy Support (800fae7a41e7d4a1ec1658cc0892d233) <-> 278445`  
`ic ks cluster config --cluster infra-accessallareas-stage`

1. Update the password stored in kube secret `vpn-user-pass` in the namespaces:  
`default`, `metrics` and `sre-bots`

   1. put the username/password into a file  
   Example file contents when generating the base64 encoded userid/password.
      ```
      VUSER="igoropenvpn"
      VPASS="<thepasswordshouldgohere>"
      ```
   1. to view the base64 encoded contents of the file, run  
   `cat <file> | base64`
   1. update the k8s secrets to the base64 value using the command  
`kubectl edit secret`
      - Use `kubectl get secrets [-n namespace]` to view the secrets which exist
      - open the secret in edit mode and update the base64 value for `login.env` using  
       `kubectl edit secret vpn-user-pass [-n namespace]`  
       _It's a vi editing session so when done, to write and exit editing use: `<esc>:wq`_

## 3) update the live AAA cluster
Perform the same steps for `infra-accessallareas` as were performed for `infra-accessallareas-stage` cluster.  
`ic ks cluster config --cluster infra-accessallareas`, except that the namespaces will be:
`default`, `netint`, `metrics` and `sre-bots`

## 4) update 1337 repo
- Update password in repo storing Igorina's credentials. Updates are needed in multiple places:
   - **Pre-req**: make sure that both on-call SREs have access to the [alchemy-1337/chlorine-bot-creds](https://github.ibm.com/alchemy-1337/chlorine-bot-creds) repo, so that changes can be merged!
   - Search for `igoropenvpn` in the [alchemy-1337/chlorine-bot-creds](https://github.ibm.com/alchemy-1337/chlorine-bot-creds) repo and update all occurrences of the password

    Create a PR for the changes and get it merged.


## 5) Rebuild & redeploy bots

Once the above password updates have been completed, the following deploys need to occur in this specific order.


- `smith-trigger-service-dev` - as we use the kube secrets in this bot, a restart of the `smith-trigger-service-dev` pod should be fine 

- `smith-trigger-service-prod` - as we use the kube secrets in this bot, a restart of the `smith-trigger-service-dev` pod should be fine 

- `victory` - as we use the kube secrets in this bot, restart of the `victory` pod should be fine. Stage version is deployed in `infra-accessallareas-stage` cluster, hence make sure to restart pods there. 
- `victory-driveby` - as we use the kube secrets in this bot, restart of the `victory-driveby` pod should be fine. Stage version is deployed in `infra-accessallareas-stage` cluster, hence make sure to restart pods there. 

- chlorine must be rebuilt and redeployed to pick up the new password: <https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/chlorine-ha-build/>
   - promote the `iks-chlorine-ha-test-deploy` bot
   - you can test the chlorine VPNs by DMing in slack to the `Chlorine TEST bot (Igorina)`:
     - dev: `reboot dev-sjc04-carrier12-worker-1001 checkrequired outage:0` (or pick another node)
   - promote the `iks-chlorine-ha-deploy`
   - you can test the chlorine VPNs by DMing in slack to the `Chlorine bot (SRE)`:
     - prod: `reboot prod-dal10-carrier7-worker-1093 checkrequired outage:0` (or pick another node)
   - if there are problems, check in the [#iks_sre_development](https://ibm-argonauts.slack.com/archives/CDUHGBVV0) channel


## Escalation policy

If you are unsure then raise the problem further with the SRE team.

Discuss the issues seen with the SRE team in `#conductors` (For users outside the SRE squad) or in `#conductors-for-life` or `#sre-cfs` if you have access to these private channels.

There is no formal call out process for this issue.

