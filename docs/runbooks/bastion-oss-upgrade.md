---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Automation bastion-oss-upgrade
type: Informational
runbook-name: "bastion-oss-upgrade"
description: "bastion-oss-upgrade"
service: Conductors
link: /docs/runbooks/bastion-oss-upgrade.html
parent: Armada Runbooks

---

Informational
{: .label }

# Automation - How To upgrade bastion OSS plugin 

## Overview

This document describes the procedure to upgrade bastion OSS plugin  via automation to ensure latest version is applied.

The following link is used as the primary source for these instructions: 

Jenkins job is located: [vsi-bastion-oss-upgrade](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/bastion-host/job/vsi-bastion-oss-upgrade/build?delay=0sec)



### Detailed Information on Jenkins Job

#### 1. Select the cloud enviornment

![image](https://media.github.ibm.com/user/57295/files/ad4e9f00-10a2-11ec-9e8f-54dc4d4d9d06)



#### 2. Enter the bastion Infra's IP's you want oss-plugin to upgrade 
Bastion Infra's IP's can be found from bastion repo below 
https://github.ibm.com/alchemy-conductors/bastion/blob/master/vsi-solution/automation/nodes/infra_hosts

Multiple IP's can be added ie - Space separated list of IP's: 10.10.10.10 10.10.10.11 10.10.10.12

![image](https://media.github.ibm.com/user/57295/files/fb63a280-10a2-11ec-9219-5cbb42d7a85f)

#### 3. Host file also can be provided if multiple regions are be to upgrade on same bastion registry
##### (**NOTE - ALL HOSTS GIVEN WILL BE REGISTERED TO THE SAME BASTION REGISTRY**)
![image](https://media.github.ibm.com/user/57295/files/6d3bec00-10a3-11ec-9667-d2504af062a4)


#### 4. Specify the branch, Default is Master ( Leave it default, unless testing)
![image](https://media.github.ibm.com/user/57295/files/b55b0e80-10a3-11ec-8186-134acc55e296)


#### 5. Pick the correct Registry ICR based on regions below
Multiple regions can be upgraded same time if they are using same registry, ie you can combine INFRA's IP of region `us-south ca-tor us-east regions ie prod-wdc, prod-tor, prod-dal` in one
host file and upgrade to `us.icr.io ` registry same time.

![image](https://media.github.ibm.com/user/57295/files/24853280-10a5-11ec-971b-9d59b3c592a9)
 Based on Registry ICR selected, Correct region is automatically populated.
 
 
#### 6. Please enter the version of oss-plugin to upgrade to
 ![image](https://media.github.ibm.com/user/57295/files/4ed6f000-10a5-11ec-96af-ff7b73a8affe)
 
 #### 7. Please enter the test url of trains, this can be console output link of dev bastion oss-plugin upgarde
 ![image](https://media.github.ibm.com/user/57295/files/6c0bbe80-10a5-11ec-8532-d201953b0485)


### Information on Automation in background.

#### Starts a new train, Check the host file and Registry provided and upgrade plugin one by one.
![image](https://media.github.ibm.com/user/57295/files/a4ab9800-10a5-11ec-835d-5444a72cd13c)


#### Upgrade the plugin on each infra node , output message and stop the train.

![image](https://media.github.ibm.com/user/57295/files/ed635100-10a5-11ec-84b3-6c9158e0481b)

