---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Automation Rotate serviceID Api key
type: Informational
runbook-name: "Rotate serviceID Api keys"
description: "Rotate serviceID Api keys"
service: Conductors
link: /docs/runbooks/rotate_serviceID_API_Key.md
parent: Armada Runbooks

---

Informational
{: .label }

# How To Rotate serviceID API keys via automation 

## Overview

This document describes the procedure to Rotate serviceID API keys via automation to ensure a human will not see the api key

The following link is used as the primary source for these instructions: 

Jenkins job is located: [rotate_serviceID_API_Key](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/rotate_serviceID_API_Key/build?delay=0sec)



### Detailed Information on Jenkins Job

#### 1. Select the cloud account where serviceID exist

<img width="919" alt="Screen Shot 2021-05-12 at 12 04 36" src="https://media.github.ibm.com/user/57295/files/9f805a00-b3df-11eb-9fc3-ec2acae476a6">


#### 2. Select correct region from dropdown list

<img width="229" alt="image" src="https://media.github.ibm.com/user/57295/files/07cf3b80-b3e0-11eb-912e-25d48908d7b6">

#### 3. Enter the Keyname and serviceID 
##### (If you want to create API keys for multiple serviceID then upload the file and leave Keyname and serviceID blank)
<img width="1343" alt="image" src="https://media.github.ibm.com/user/57295/files/377e4380-b3e0-11eb-8bf5-82ba43735ede">

#### 4. Specify the below parameters ( this is needed to create yaml)
<img width="1343" alt="image" src="https://media.github.ibm.com/user/57295/files/a0fe5200-b3e0-11eb-96ea-607354564f6b">

### Detailed Information on Automation in background.

#### 1. Logs in to provided cloud account, Creates a new branch and imports public key
<img width="1174" alt="image" src="https://media.github.ibm.com/user/57295/files/31d52d80-b3e1-11eb-856f-d3aec8ac67e2">

#### 2. Creates a new API key using serviceID provided and encrypts the API key

<img width="1174" alt="image" src="https://media.github.ibm.com/user/57295/files/7cef4080-b3e1-11eb-8b5c-2ebe24a32325">

#### 3. Pushes the changes (Encrypted API key and Yaml file) to github and creates a PR for review

<img width="1174" alt="image" src="https://media.github.ibm.com/user/57295/files/c9d31700-b3e1-11eb-85b2-ac18152690bb">

#### 4. Example of Encrypted key and Yaml file created
<img width="1174" alt="image" src="https://media.github.ibm.com/user/57295/files/28989080-b3e2-11eb-8478-87e0a8964b5d">
