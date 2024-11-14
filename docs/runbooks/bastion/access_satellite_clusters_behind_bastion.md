---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Access Satellite clusters behind Bastion
type: Informational
runbook-name: "Access Satellite clusters behind Bastion"
description: "Access Satellite clusters behind Bastion"
service: Conductors
link: /docs/runbooks/access_satellite_clusters_behind_bastion.html
parent: Bastion
grand_parent: Armada Runbooks
---

Informational
{: .label }

# How to access Satellite clusters behind IKS Bastion

## Overview
This document describe the steps to access Satellite clusters behind IKS Bastion.
For Bastion certificate renewal follow the steps in [Bastion certificate renewal](#bastion-certificate-renewal).

## Pre-requisites

1. SL account set up: [Request Softlayer Account](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#request-an-account-into-the-softlayer-commercial-environment-sl-imsad-credentials-and-a-yubikey-via-accesshub-iaas-access-management-application)
1. MFA setup:
    1. **Access required to pre-prod only**: Symantec VIP registration: [Symantec VIP Credential](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#register-the-symantec-vip-credential-id)
    1. **Access required to pre-prod and prod**: Yubi key registration: [Register your Yubikey](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#register-your-yubikey)
1. Global Protect(GP) package to be installed for MAC and Linux: [Global Protect VPN](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#setting-up-global-protect-vpn)
1. [Raise a Softlayer ticket to add users to GP Active Directoy(AD) groups](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_satellite_clusters_behind_bastion.html#raise-a-softlayer-ticket-to-add-users-to-global-protectgp-active-directoryad-groups)
1. Download tsh: [Gravitational Teleport](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_hosts_behind_bastion.html#5-gravitational-teleport)
1. Have a valid INC, CHG or CS number ready for SERVICE NOW ticket validation [ServiceNow Ticket Definition](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_hosts_behind_bastion.html#2-servicenow-ticket-definition)


Reference: VSI/Platform Bastion Runbook to [Access Hosts Behind Bastion](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_hosts_behind_bastion.html#iks-deployment-model)  <br>

## Detailed Information

### Steps to access
Refer to section [List of available IKS Bastion Proxies/Hosts/Clusters](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_satellite_clusters_behind_bastion.html#list-of-available-iks-bastion-proxieshostsclusters) for Bastion proxy details

#1 Login to GPVPN

#2 Recommended Shell Variables Configuration: <br>
Set shell variables ```bastion_auth_user``` and ```bastion_connect_user``` <br>

	Example: 
	export bastion_auth_user=Jane.Smith@ibm.com
	export bastion_connect_user=jane.smith

#3 Run tsh login to authenticate/login to bastion proxy for a given environment and region

	
	> tsh login --proxy BASTION-PROXY/HOST-ADDRESS:443 --request-reason=SERVICE-NOW-TICKET 
	    
	    or
	    
	An option to explicitly mention the bastion user:
	> tsh login --user=$bastion_auth_user --proxy BASTION-PROXY/HOST-ADDRESS:443 --request-reason=INCXXXX

Example: <br>
To authenticate to Satellite Stage Bastion proxy. <br>
Stage Bastion Proxy: ```c68s4b0d0g91aea13i00-owfxrxy72yvb59dimxnb.bastionx.cloud.ibm.com```

	> tsh login --proxy c68s4b0d0g91aea13i00-owfxrxy72yvb59dimxnb.bastionx.cloud.ibm.com:443 --request-reason=INCXXXX
	    or 
	> tsh login --user=$bastion_auth_user --proxy c68s4b0d0g91aea13i00-owfxrxy72yvb59dimxnb.bastionx.cloud.ibm.com:443 --request-reason=INCXXXX
	
(get Bastion proxy info from section [List of available IKS Bastion Proxies/Hosts/Clusters](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_satellite_clusters_behind_bastion.html#list-of-available-iks-bastion-proxieshostsclusters))

#4 Run kubectl commands on Bastion Cluster 

4.1 Login using ibmcloud: <br>
 	  	  						
		     > ibmcloud login --sso 
		     
4.2 When accessing for the first time, get Bastion cluster config: <br>
    		     
		    > ibmcloud ks cluster config --cluster BASTION-CLUSTER-NAME/ID
		
Example: ibmcloud ks cluster config --cluster stage-us-south-sb-carrier111

4.3 Run kubectl commands

#5 Run ```tsh clusters``` to view the list of available remote clusters

	Example: On Satellite Stage account
	
	> tsh clusters
	Cluster Name                          Status 
	------------------------------------- ------ 
	stage-us-south-sb-carrier111-bastion  online 
	stage-us-south-sl-carrier108-bastion  online 
	stage-us-south-sla-carrier109-bastion online 
	stage-us-south-sr-carrier107-bastion  online 
	stage-us-south-sd-carrier106-bastion  online 
	

#5 To access Bastion remote cluster: <br>
   	 Run tsh login  <br>

	  > tsh login BASTION-REMOTE-CLUSTER-NAME/ID
	  
   The Bastion remote cluster names are available from the output of "tsh clusters" as shown above.
	
   Example: <br>
   The command to access one of the Stage Bastion remote cluster ```stage-us-south-sla-carrier109-bastion``` <br>

	  > tsh login stage-us-south-sla-carrier109-bastion

#6 Run kubectl commands on the Bastion remote cluster: <br>

6.1 Login using ibmcloud: <br>
 	  	
		> ibmcloud login --sso
		
6.2 When accessing for the first time, get Bastion remote cluster config: <br>
    			
		> ibmcloud ks cluster config --cluster REMOTE-CLUSTER-NAME/ID
		
Example: ibmcloud ks cluster config --cluster stage-us-south-sla-carrier109

To use Remote cluster name for ibmcloud cluster config command, eliminate "-bastion" from the Bastion remote cluster name which is taken from the output of "tsh clusters": <br>

Example: <br>
		
Change it from stage-us-south-sla-carrier109-bastion to stage-us-south-sla-carrier109
		
6.3 Run kubectl commands

### List of available IKS Bastion Proxies/Hosts/Clusters


| Region | Authenticate via Web or CLI | Bastion Cluster name/id |
|-----------|-----------|-----------|
| `dev` | **Web:** [https://bt1ra3td0c4cfv4ia9l0-ysoauappc9svu07grzc8.bastionx.cloud.ibm.com](https://bt1ra3td0c4cfv4ia9l0-ysoauappc9svu07grzc8.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy bt1ra3td0c4cfv4ia9l0-ysoauappc9svu07grzc8.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXYYZZ` | dev-us-south-b-carrier109/ bt1ra3td0c4cfv4ia9l0 |
| `stage` | **Web:** [https://c8ep903d0tto8palftr0-8rjci05j4ye8v0pmh5pn.bastionx.cloud.ibm.com](https://c8ep903d0tto8palftr0-8rjci05j4ye8v0pmh5pn.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user  \`<br>` --proxy c8ep903d0tto8palftr0-8rjci05j4ye8v0pmh5pn.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXYYZZ` | stage-us-south-sb-carrier111/ c8ep903d0tto8palftr0 |
| `us-south` |  **Web:** [https://c7n11vnd0njif9jflaug-ajvu5svb9ha2sea7c5yf.bastionx.cloud.ibm.com](https://c7n11vnd0njif9jflaug-ajvu5svb9ha2sea7c5yf.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user  \`<br>` --proxy c7n11vnd0njif9jflaug-ajvu5svb9ha2sea7c5yf.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXYYZZ` | prod-us-south-sb-carrier129/ c7n11vnd0njif9jflaug |
| `us-east` |  **Web:** [https://c8e2p2ew05akt7nri610-08yhur1wgsvi7rks6rmr.bastionx.cloud.ibm.com](https://c8e2p2ew05akt7nri610-08yhur1wgsvi7rks6rmr.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user  \`<br>` --proxy c8e2p2ew05akt7nri610-08yhur1wgsvi7rks6rmr.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXYYZZ` | prod-us-east-sb-carrier119/ c8e2p2ew05akt7nri610 |
| `ap-north` | **Web:** [https://c8k3uh1t0e8s8d34ons0-spsafcp67khea5zery7m.bastionx.cloud.ibm.com](https://c8k3uh1t0e8s8d34ons0-spsafcp67khea5zery7m.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user  \`<br>` --proxy c8k3uh1t0e8s8d34ons0-spsafcp67khea5zery7m.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXYYZZ` | prod-ap-north-sb-carrier116/ c8k3uh1t0e8s8d34ons0 |
| `ap-south` | **Web:** [https://c8jr96ps0u7emrb7hsa0-9jji8zbgouvid7g6dhzw.bastionx.cloud.ibm.com](https://c8jr96ps0u7emrb7hsa0-9jji8zbgouvid7g6dhzw.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user  \`<br>` --proxy c8jr96ps0u7emrb7hsa0-9jji8zbgouvid7g6dhzw.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXYYZZ` | prod-ap-south-sb-carrier113/ c8jr96ps0u7emrb7hsa0 |
| `jp-osa` | **Web:** [https://c8ju8g5o04p4o2us8rk0-8afwct15h15sdz7efsav.bastionx.cloud.ibm.com](https://c8ju8g5o04p4o2us8rk0-8afwct15h15sdz7efsav.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user  \`<br>` --proxy c8ju8g5o04p4o2us8rk0-8afwct15h15sdz7efsav.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXYYZZ` | prod-jp-osa-sb-carrier110/ c8ju8g5o04p4o2us8rk0 |
| `ca-tor` | **Web:** [https://c8tb0err0s90ne22fjhg-2z2mcwfkcpv1cr8n6jzj.bastionx.cloud.ibm.com](https://c8tb0err0s90ne22fjhg-2z2mcwfkcpv1cr8n6jzj.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user  \`<br>` --proxy c8tb0err0s90ne22fjhg-2z2mcwfkcpv1cr8n6jzj.bastionx.cloud.ibm.com:443  \`<br>` --request-reason=INCXXYYZZ` | prod-ca-tor-sb-carrier113/ c8tb0err0s90ne22fjhg |
| `uk-south` | **Web:** [https://c8tfnjvl024jqipk6cug-00s2rvri3fvyzo21h8f4.bastionx.cloud.ibm.com](https://c8tfnjvl024jqipk6cug-00s2rvri3fvyzo21h8f4.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user  \`<br>` --proxy c8tfnjvl024jqipk6cug-00s2rvri3fvyzo21h8f4.bastionx.cloud.ibm.com:443  \`<br>` --request-reason=INCXXYYZZ` | prod-uk-south-sb-carrier115/ c8tfnjvl024jqipk6cug |
| `br-sao`|  **Web:** [https://c8tf0sfz030939mm8a00-bandr149j9m70vyamh2n.bastionx.cloud.ibm.com](https://c8tf0sfz030939mm8a00-bandr149j9m70vyamh2n.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user  \`<br>` --proxy c8tf0sfz030939mm8a00-bandr149j9m70vyamh2n.bastionx.cloud.ibm.com:443  \`<br>` --request-reason=INCXXYYZZ` | prod-br-sao-sb-carrier112/ c8tf0sfz030939mm8a00 |
| `eu-central`|  **Web:** [https://cbkecraf08llq49au7a0-fztvncsks7159unyksgv.bastionx.cloud.ibm.com](https://cbkecraf08llq49au7a0-fztvncsks7159unyksgv.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user  \`<br>` --proxy cbkecraf08llq49au7a0-fztvncsks7159unyksgv.bastionx.cloud.ibm.com:443  \`<br>` --request-reason=INCXXYYZZ` | prod-eu-central-sb-carrier127/ cbkecraf08llq49au7a0 |


### Raise a Softlayer ticket to add users to Global Protect(GP) Active Directory(AD) groups

#### Steps <br>

_**Note: If permissions to raise tickets are missing, they can be obtained by asking on SL helpdesk**_

1. Connect to GP VPN
1. Login to the [Softlayer Internal portal](https://internal.softlayer.com/) with Softlayer account credentials
1. At the top, select `Add Internal Ticket`
1. In the "Subject" drop down list, select `Change Account Request`
1. In the "Priority" drop down list, select `Severity 2 - Significant Business Impact`
1. In the "Group" drop down list, select `Help Desk - Account Request`
1. To add single user to single AD group: <br> 
```
Fill in & add the below template to the ticket:
         Email-id and SL user name (used for login to GPVPN) of the user
	 Justification to add the user
	 Multiple AD group names (refer below)
	 Email approval of user's Manager
```
To add multiple users (from same team) to multiple AD groups: <br> 
```
       - Raise one ticket for each AD group
       - Add below info/template to the each ticket:
         Email-id and SL user name (used for login to GPVPN) of the users
         Justification to add the users
         Single AD group name (refer below)
         Email approval of team's Manager
```
Below are the available AD groups:

		SRE users:
			Prod group name: IKS-VPN-AD-prod  
			Pre-Prod group name: IKS-VPN-AD-preprod
		Non-SRE users:
			Prod group name: satlite-ad-prod
			Pre-Prod group name: satlite-ad-preprod

[Example ticket](https://internal.softlayer.com/Ticket/ticketEdit/146206022) (login to GPVPN to access it)

SL Links for reference:
[SL GPVPN Link1](https://confluence.softlayer.local/display/HELPDESKPUB/Security+Group+Population) and [SL GPVPN Link2](https://confluence.softlayer.local/pages/viewpage.action?spaceKey=HELPDESKPUB&title=Submitting+a+Change+Request). <br>
These links can be accessed by connecting to GPVPN.

## IKS Bastion - Break the glass scenarios

Options to access the Bastion/Remote Cluster via ```Break the glass scenarios```:

Option #1 Enable Public End Point (PEP) of the ```Bastion Cluster```

- Get the ```Bastion Cluster``` name (Refer to [List of available IKS Bastion Proxies/Hosts/Clusters](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_satellite_clusters_behind_bastion.html#list-of-available-iks-bastion-proxieshostsclusters) table to get the cluster name) <br>
Example: <br>
Dev Bastion cluster name: ```dev-us-south-b-carrier109``` <br>

- Login to cloud.ibm.com `SoftLayer Account Satellite Production (e3feec44d9b8445690b354c493aa3e89) <-> 2094928` or `Satellite Stage (a8fd5d2f57b240f9b276a254c0fcb8a1) <-> 2146126`
- Navigate to ```IBM Cloud-->Kubernetes-->Clusters```
- Search the ```Bastion Cluster``` using it's name
- Once the cluster is found, go to ```Overview``` tab and locate ``` Public disabled ``` under ```Networking``` section 
- Click on ``` Public disabled ``` to enable it
- It will display ``` Public enabling ``` and will take around 15 mins to enable
- Once PEP is enabled the status will be changed to ``` Public enabled ```
- From a terminal, run ibmcloud login & get cluster config. And run kubectl commands.

Option #2 Use VSI/Platform Bastion to access clusters <br>

- Tsh login to environment/region (refer to [Access Hosts Behind Bastion](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_hosts_behind_bastion.html#iks-deployment-model))
- Tsh ssh to a carrier hub worker node
- Run invoke-tugboat to access cluster <br>
		```invoke-tugboat tugboat-name```
		
- Run kubectl commands

### Bastion certificate renewal

Currently there is a [jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/IKS-BASTION/job/IKS-Bastion-auto-query-and-upgrade-tls-cert/) to automatically upgrade the tls certificates. Re-run the job. Proceed with below steps if the job fails and to attempt a manual cert upgrade.

#### Pre-requisites
   1. Get the certificate expiry date, if it expires in less then 7 days, certificate needs to be upgraded, else no Action needed.
   Login to ibmcloud and set the context to the bastion cluster where cert renew needs to be done. List of all bastion proxies and cluster names are provided [here](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_satellite_clusters_behind_bastion.html#list-of-available-iks-bastion-proxieshostsclusters).
```
	> ibmcloud login --sso
	> ibmcloud ks cluster config --cluster BASTION-CLUSTER-NAME/ID
```
Example: ibmcloud ks cluster config --cluster stage-us-south-sb-carrier111

Use tsh login to access bastion clusters to run kubectl commands

		> tsh login --proxy <bastion-proxy> --request-reason=<incident id> 

Run the below `kubectl` command to get the expiry date: <br>

   		> kubectl get secret $bastionProxy -n teleport -o json | jq -r '.data["tls.crt"]' | base64 --decode | openssl x509 -noout -enddate | grep 'notAfter'| cut -d '=' -f2)" '+%s'

   2. Obtain Vault Role ID and Vault Secret ID from Thycotic.
   3. Install Vault on your local workstation. On MacOS, teleport can be installed using brew:
```
		> brew install vault
```
   4. Get the below vault parameters,
```
		VAULT_NAME
   		VAULT_ROLE
   		VAULT_SECRET
   		SERVICE_NAME=$ENV-$REGION-containers-kubernetes
```
   5. Execute deployment,
   Download the [iks-bastion bundles](https://github.ibm.com/Privileged-Access/classic-bastion-bundles) and run the below command. 
```
		> ./iks_deploy.sh -vr $VAULT_ROLE  -vs $VAULT_SECRET -vn $VAULT_NAME -sn $SERVICE_NAME --etcd icd:$ETCD_SC -n teleport -v $TELEPORT_VERSION --bastionx --update-tls
```
   6. Confirm the cert expiry,
   Confirm the expiry date by running the below command.
```
		> kubectl get secret $bastionProxy -n teleport -o json | jq -r '.data["tls.crt"]' | base64 --decode | openssl x509 -noout -enddate | grep 'notAfter'| cut -d '=' -f2)" '+%s'
```
		   
## References

- IKS Bastion documentation [LINK](https://test.cloud.ibm.com/docs/bastionx-working?topic=bastionx-working-bastion-host-overview)

- VSI/Platform Bastion Runbook to [Access Hosts Behind Bastion](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/access_hosts_behind_bastion.html#iks-deployment-model)  <br>

- IKS Bastion Automation

  - IKS Bastion Install/Upgrade-all/Update-tls [Jenkins Job]( https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/IKS-BASTION/job/IKS-Bastion-Install/)<br>
   
  - IKS Bastion Add/Remove Remote Clusters [Jenkins Job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/IKS-BASTION/job/IKS-Bastion-Add-Remove-Remote-Clusters/) <br>
  
  - IKS Bastion TLS certificate auto upgrade jenkins run [Jenkins Job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/IKS-BASTION/job/IKS-Bastion-auto-query-and-upgrade-tls-cert/)

  - IKS Bastion TLS certificate jenkins run to manually query the expiry date and upgrade selected certificates [Jenkins Job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/IKS-BASTION/job/IKS-Bastion-Cert-Operations/)
    
  - [Git Repo](https://github.ibm.com/alchemy-conductors/iks-bastion-automation) <br>
