---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Access Hosts Behind Bastion
type: Informational
runbook-name: "Access Hosts Behind Bastion"
description: "Access Hosts Behind Bastion"
service: Conductors
link: /docs/runbooks/access_hosts_behind_bastion.html
parent: Bastion
grand_parent: Armada Runbooks
---

Informational
{: .label }

# How To Access Hosts Behind Bastion

## Overview

This document describes the procedure to connect to hosts behind a bastion proxy.

The following link is used as the primary source for these instructions: [Bastion Teleport Scenario](https://test.cloud.ibm.com/docs/bastionx?topic=bastionx-onboarding-for-hamilton-4q2020-guidelines-for-service-teams#bastion-teleport-scenario)

## Pre-requisites

1. SL account set up: [Request Softlayer Account](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#request-an-account-into-the-softlayer-commercial-environment-sl-imsad-credentials-and-a-yubikey-via-accesshub-iaas-access-management-application)
1. MFA setup:
    1. **Access required to pre-prod only**: Symantec VIP registration: [Symantec VIP Credential](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#register-the-symantec-vip-credential-id)
    1. **Access required to pre-prod and prod**: Yubi key registration: [Register your Yubikey](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#register-your-yubikey)
1. GP package installed for MAC and Linux: [Global Protect VPN](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#setting-up-global-protect-vpn)
1. Onboarded to GP Active Directory Groups: [Self onboard to GP VPN profile](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/sre_access_requests.html#ticket-for-self-onboarding-to-global-protect-vpn-profile)
1. tsh downloaded: [Gravitational Teleport](#5-gravitational-teleport)
1. Have a valid INC, CHG or CS number ready for ticket validation [ServiceNow Ticket Definition](#2-servicenow-ticket-definition)


### Typical example of authenticate and connect over CLI

Typical example of how to authenticate and connect using `tsh` on the command-line, assuming [recommended shell variables](#7-recommended-shell-variables-configuration) are configured:

```
# Step 1: Authenticate to bastion proxy for a given region
tsh login --user=$bastion_auth_user \
          --proxy 659397-mmcc9tosjaaq2hxzommkwobkj.bastionx.cloud.ibm.com:443 \
          --request-reason=INCXXXXXX0

# Step 2 (optional): List nodes registered to the bastion
tsh ls

# Step 3a: Log into a particular node via IP; OR
tsh ssh -l $bastion_connect_user 10.131.16.191

# Step 3b: Log into a particular node via FQDN
tsh ssh -l $bastion_connect_user dev-mex01-carrier11-master-01.alchemy.ibm.com

# Step 3c: Log into nodes in multiple regions while cert is valid ( duration is 1hr)
tsh ssh --proxy <bastion-proxy> -l $bastion_connect_user <node>
```

For more details, see later sections.

## Detailed Information

### VSI Bastion Model

#### Proxies


| Region | Authenticate via Web or CLI |
|-----------|-----------|
| `dev` | **Web:** [https://659397-mmcc9tosjaaq2hxzommkwobkj.bastionx.cloud.ibm.com](https://659397-mmcc9tosjaaq2hxzommkwobkj.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy 659397-mmcc9tosjaaq2hxzommkwobkj.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` |                                                                                   
| `stage` | **Web:** [https://1858147-vju3e3f3obub487driyhfbzzc.bastionx.cloud.ibm.com](https://1858147-vju3e3f3obub487driyhfbzzc.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user\ `<br>` --proxy 1858147-vju3e3f3obub487driyhfbzzc.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` |
| `au-syd` / `ap-south` | **Web:** [https://531277-3e15f8uabxjxsc21fireqysx1.bastionx.cloud.ibm.com](https://531277-3e15f8uabxjxsc21fireqysx1.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user\ `<br>` --proxy 531277-3e15f8uabxjxsc21fireqysx1.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` |
| `jp-tok` / `ap-north` | **Web:** [https://531277-spr73przoohj99sxi9gykuyp8.bastionx.cloud.ibm.com](https://531277-spr73przoohj99sxi9gykuyp8.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy 531277-spr73przoohj99sxi9gykuyp8.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` |
| `jp-osa` | **Web:** [https://531277-pg90cc24542fey15aucs4ujy3.bastionx.cloud.ibm.com](https://531277-pg90cc24542fey15aucs4ujy3.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy 531277-pg90cc24542fey15aucs4ujy3.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` |
| `eu-de` / `eu-central`  <br> `eu-es` | **Web:** [https://531277-xhvr3ksnx8z15tfj8g39w09xt.bastionx.cloud.ibm.com](https://531277-xhvr3ksnx8z15tfj8g39w09xt.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy 531277-xhvr3ksnx8z15tfj8g39w09xt.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` |
| `eu-gb` / `uk-south` | **Web:** [https://531277-pkdbhhfb2bwazz6gmqmk2nvrh.bastionx.cloud.ibm.com](https://531277-pkdbhhfb2bwazz6gmqmk2nvrh.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy 531277-pkdbhhfb2bwazz6gmqmk2nvrh.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` |
| `us-east`  | **Web:** [https://531277-o2gg8bueqkymks2oy8ykww1gp.bastionx.cloud.ibm.com](https://531277-o2gg8bueqkymks2oy8ykww1gp.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy 531277-o2gg8bueqkymks2oy8ykww1gp.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` |
| `us-south` | **Web:** [https://531277-x8f2nxmi6jdn9ck8kxhk4rnnt.bastionx.cloud.ibm.com](https://531277-x8f2nxmi6jdn9ck8kxhk4rnnt.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy 531277-x8f2nxmi6jdn9ck8kxhk4rnnt.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` |
| `ca-tor` | **Web:** [https://531277-00awi33rt10ab9re1yod67jmk.bastionx.cloud.ibm.com](https://531277-00awi33rt10ab9re1yod67jmk.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy 531277-00awi33rt10ab9re1yod67jmk.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` <br><br> **This bastion has nodes from carrier1 and carrier3**|
| `br-sao` | **Web:** [https://531277-v8hc0hyvmtzdh5zgz9i4y97b8.bastionx.cloud.ibm.com](https://531277-v8hc0hyvmtzdh5zgz9i4y97b8.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy 531277-v8hc0hyvmtzdh5zgz9i4y97b8.bastionx.cloud.ibm.com:443 \`<br>` --request-reason=INCXXXXXX0` <br><br> **This bastion has nodes from carrier1 and carrier8**|
| `eu-fr2` | **Web:** [https://2051458-4sv3wgpmw0b2u8ci3wa33qu9j.bastionx.cloud.ibm.com](https://2051458-4sv3wgpmw0b2u8ci3wa33qu9j.bastionx.cloud.ibm.com) <br><br> **CLI:** `tsh login --user=$bastion_auth_user \`<br>` --proxy 2051458-4sv3wgpmw0b2u8ci3wa33qu9j.bastionx.cloud.ibm.com:443  \`<br>` --request-reason=INCXXXXXX0` <br><br>Use one of the BNPP-specific portals e.g. `bnpp.eu1.gp.softlayer.com` in Global Protect |

##### Note: all Madrid `eu-es` machines are registered under the `eu-de` / `eu-central` bastion.

#### Which usernames to use

##### Authenticating to the bastion proxy

When **authenticating to the bastion proxy** on the command-line, you will likely have to specify the `--user` flag:

  - if your local username (e.g. jsmith) is not the same as your **IBM ID Jane.Smith@ibm.com (Case Sensitive)**, then supply the `--user` flag to `tsh login`.
  - your IBM ID is the one displayed on your w3.ibm.com blue pages profile.

For example:

```
$ tsh login --user=Jane.Smith@ibm.com --proxy ......
```

##### Connecting to the host

When **connecting to a host** on the command-line, you will likely have to specify the login username:

  - if your local username (e.g. jsmith) is not the same as your **username part of your email address jane.smith@ibm.com (lowercase)**, then supply the `-l` flag to `tsh ssh`.
  - this may be different from your usual SSO username (e.g. `jsmith1`). However `jane.smith` will still have `sudo` access.

For example:

```
$ tsh ssh -l jane.smith 10.x.x.x

$ tsh ssh    jane.smith@10.x.x.x
```

#### LogDNA instances

The following URLs can be used to access logs related to bastion hosts:

  1. For `eu-central` use this [URL](https://app.eu-de.logging.cloud.ibm.com/ddfc9c8033/logs/view?q=bastionx)
  2. For rest of the regions use this [URL](https://app.us-south.logging.cloud.ibm.com/442ca9392b/logs/view?q=bastionx)

### IKS Deployment Model

Once you have authenticated, then you can use for example the command `tsh ls`, for the _Mixed Scenario_, in order to list the ssh nodes (target nodes), as in the case of Infrastructure Deployment Model (see the previous section).

_In case of the Standard Scenario the list will be empty._

For the _Multiple Cluster scenario_ you can list/check for other Teleport clusters by running the command: `tsh clusters`:

```
Cluster Name               Status
-------------------------- ------
iks-cluster1-bastion       online
iks-cluster2-bastion       online
...
iks-clusterN-bastion       online
```

To get the IKS config from one of your clusters, you can then execute:

```
tsh login iks-clusterN-bastion
```

_(There should not be any need to re-authenticate)_


#### Access IKS Resource

Once logged in, you should be able to run any `kubectl` commands against the IKS cluster.

You can for example run this to return the pods list in the teleport namespace:

```
$ kubectl get pods -n teleport
NAME                        READY   STATUS    RESTARTS   AGE
teleport-57846d6896-5qjbp   1/1     Running   0          7m21s
```

This command runs an interactive session `-it /bin/bash` on the `teleport-xxx` pod (returned from the previous command) of the teleport namespace:

```
$ kubectl exec teleport-xxx -n teleport -it /bin/bash
```

This command displays the teleport deployment into the teleport namespace:

```
$ kubectl get deploy teleport -n teleport
```

For further details for getting what is running on your IKS cluster please refers to [GETTING STARTED](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands).


## References

### 1. Learning Resources

- Conductor playback: [Demo of FS Bastion](https://ibm.box.com/s/k61mx8s046vyg526abmmxjj0xaluuzd2)
- Global Protect VPN: [PaaS Service - Wave 1](https://ibm.ent.box.com/folder/127192196001)

### 2. ServiceNow Ticket Definition

A valid ServiceNow ticket must be used when logging into the bastion proxy. We can use:

- `Incidents (INCxxx)` when investigating a particular incident, or while on PD (see below for different scenarios)
- `Change Requests (CHGxxx)` when supporting a particular change request
- `Customer Support requests (CSxxx)` when supporting a particular customer issue

The validation of the ServiceNow incident/change request ticket is performed based on the following criteria:

- the ticket must be active (i.e. open status)
- the ticket must be either assigned to the operator accessing the cloud resources (for change requests) or assigned to the `Containers SRE` group (for incidents)

### 3. Ticket Validation Guidelines

- SN tickets should ideally be linked to the specific issue being investigated.
- Please consider that we support several types of SN tickets: incidents, change requests, cases and problems. So depending on the situation being addressed, you might need to consider using one or another.
- For example usually incidents get opened when a problem occured in a prod env, and potentially they come from a support request. In that case you will use that incident only for dealing with that specific problem  and will close it once the problem is solved.
- If you need to access the prod envs to troubleshoot an issue and understand if an incident ever occurred, in that case the recommended approach is to have some automation that would collect the troubleshooting info for you, so your operators won’t have to login to access the systems just for collecting logs.
- If that is not possible for whatever reason, you migth want to create a SN case or a problem that might eventually evolve into an incident if anything is found during investigation. Also on this case we discourage using the same SN ticket for investigating multiple issues. In other words, is not allowed opening a single SN ticket and use it for the whole day of activities, nor to have long lasting tickets that are open for days/weeks/months...
- Please consider that a single SN ticket can be shared among the operators contributing to the resolution of the same:
  - the logic we implemented in teleport is to check that the requestor, passing the SN ticket number at login time, is either part of the assignment group of a ticket, or part of one of the contributing groups subscribed to the same ticket. 
  - Personal assignment and validation is only implemented for the Change requests type of ticket: in that case you can pass a CR number only if that was assigned personally to you
- We should certainly be using CS when we are investigating reported issues..
- We should be using INC for anything our automation finds or if we need to look at things proactively..
- We should be using CHG if we are debugging something due to a CHG as that will already have been raised.

### 4. Conductors Use Cases

**Q. I am a primary and need to access multiple prod. What ticket type do I need to use and how often can I use?**  
A. Create an INC in https://watson.service-now.com. Add a note saying you are accessing the env to investigate issues for the PD shift.
- Select appropriate `Detection Source`
- Select `containers-kubernetes` as the `Configuration Item`
- Select `Containers SRE` as the `Assignment Group`

**Q. I am a secondary and received a request from #conductors.**  
A. Go ahead and create an INC for the request. Add a link to the request in the channel to the Description.

**Q. I am asked to help out Primary when PD madness started.**  
A. Share the same INC created for the shift by Primary of the day to work on the same issues.
 
**Q. I am not sure if I need to raise an INC or not.**  
A. An INC needs to be related to an issue. Raise an INC to address a specific issue.
 
**Q. I am asked to help out EU request from #conductors.**  
A. If secondary of the day has already created an INC for the request, share it. If not, a new INC should be created.
 
**Q. I need to access prod to investigate a Customer ticket.**  
A. SRE can use CS number from Customer ticket. Currently, a CS ticket is only assigned to `acs fabrics` team. to enable the access for SREs:
1. Go to the ticket in  https://watson.service-now.com    
2. Unlock `Assistant Groups`
3. Add `Containers SRE`
4. Lock it again
5. Click `Update` to save the ticket


### 5. Gravitational Teleport

Gravitational documentation: [tsh cli docs](https://goteleport.com/teleport/docs/cli-docs/#tsh)

Download links for the specific OS and teleport version can be found here: [https://goteleport.com/teleport/download](https://goteleport.com/teleport/download)

#### Installing `teleport/tsh`

On MacOS, install a specific version manually, per the instructions below:

```bash
$ curl -O https://get.gravitational.com/teleport-10.3.12.pkg

# Installs on Macintosh HD
$ sudo installer -pkg teleport-10.3.12.pkg -target / 
Password:
installer: Package name is teleport-10.3.12.pkg
installer: Upgrading at base path /
installer: The upgrade was successful.

$ which teleport
/usr/local/bin/teleport
```

On Linux, download a specific version from one of these (find the latest version from [https://goteleport.com/teleport/download](https://goteleport.com/teleport/download)):

- https://get.gravitational.com/teleport-10.3.12-1.x86_64.rpm
- https://get.gravitational.com/teleport_10.3.12_amd64.deb


### 6. Break The Glass Scenario

The initial rollout will leave OpenVPN and port 22 open, so as a temporary measure if the bastion is unavailable SREs can ssh as before.

#### Bastion break-glass scenario

Details in this runbook: [Break the glass scenarios for bastion installation in FS Cloud](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/bastion/platform_bastion_break_the_glass_scenarios.html)

### 7. Recommended Shell Variables Configuration

Recommend to add the following variables to your shell `rc` file [See [Which usernames to use](#which-usernames-to-use)].

```
export bastion_auth_user=Jane.Smith@ibm.com
export bastion_connect_user=jane.smith
```
