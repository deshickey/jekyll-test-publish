---
layout: default
description: "Customer Service Endpoints for Tugboats"
title: "Customer Service Endpoints for Tugboats"
runbook-name: "Customer Service Endpoints for Tugboats"
service: armada
tags: cruiser, worker, node, access, alchemy, armada, containers, kubernetes, pod, tugboat, cse, customer-service-endpoint, endpoint, jenkins
link: /armada/jenkins-cse-operations.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

# Customer Service Endpoints for Tugboats

## Overview
This runbook serves to provide information around customer service endpoint (CSE) operations and troubleshooting. There will be a focus on the Jenkins Job functionality in this runbook. 

Additional information regarding CSE can be found in this [repository](https://github.ibm.com/alchemy-conductors/carrier-service-endpoints)

[Current Jenkins Job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-CSE-operations-pipeline/)

## Detailed Information

### CSE Operations Jenkins Job
The main function of this [jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-CSE-operations-pipeline/) is to assist in creating, modifying, viewing CSEs of IKS carriers and tugboats. Our current job has include functionality that has increased validation and measures to prevent accidently modification to existing CSEs. 

The general workflow for this job is for the user to go through each of the selectors which define the target environments.

- ARMADA_ENV
- REGION
- OPERATION
- CHANGE_REQUEST_ID (as required)
- DRYRUN (optional)
- GHE_ISSUE_URL (as required)
- CARRIER_OR_TUGBOAT_WITH_NUM (as required)

Depending on which operation is selected, a change request and an additional GHE issue may be required to be created for additional inputs and peer review. The parameters scraped by the URL of the GHE issue will be used to compared against the other selected values in the job to provide an additonal layer of validation. 

### Query Functions
**verifyCSE** - Verify the creation of CSEs for specific tugboats. It will return filtered information to assist in DNS procurement. Additionally, it will also provide the complete list of CSEs in that region. 

**verifyETCD** - Verifies that there is an existing ETCD CSE for a particular region. If there is an existing ETCD CSE, it will provide additional details on the CSE. Additionally, it will also provide the complete list of CSEs in that region. 

**downloadCSE** - Provides a complete list of CSEs in a selected region.

**downloadProxy** - Provides a complete list of Proxy details in a selected region.

### Modification Functions
The following operations require a change request and also are encouraged to utilise the dry run function before actual execution. 

Each of these operations will have similar requirements of creating a GHE issue using one of the [templates](https://github.ibm.com/alchemy-conductors/carrier-service-endpoints/issues/new/choose) from the repo with specific parameters unique to each function. Alternatively, these issues could be generated from Shepherd. Additional information on each parameter can be found under the **Property Definitions** section and also from the original [repo](https://github.ibm.com/alchemy-conductors/carrier-service-endpoints/blob/master/README.md). 

Further, each issue must be peer reviewed and have label "approved" added to each issue before the job can be run successfully. 

**createCSE** - Creates a CSE for a tugboat using the required parameters. Pre-requisites include having [Netint create and provision vlans](https://github.ibm.com/alchemy-netint/firewall-requests/issues/2914). There are two templates that can be selected, SZR and MZR, depending on whether the tugboat has single or multiple DCs. 

**deleteCSE** - Deletes a CSE for a tugboat. It is essential to do a in depth peer-review for this function as well as dry-run to prevent removing CSEs unintentionally which can cause a CIE. 

**createETCD** - Creates an ETCD CSE for a region using the required parameters. Only one ETCD CSE is needed for each region, meaning that if there is an existing ETCD CSE, a new one is not required to be created. 

**addACL** - Updates the existing ACL list of a CSE with provided ip addresses. 

**deleteACL** - Removes specified ip addresses from the ACL list of a CSE. 

**addServiceAddress** - Updates the existing Service Addresses of a CSE with provided ip addresses. 

**deleteServiceAddress** - Removes specified ip addresses from the Service Addresses of a CSE. 

## Troubleshooting CSEs
Here are some techniques which you can use to troubleshoot and verify whether CSEs are working as expected. 

### Nslookup

You should be able to find the DNS entry through a quick search for one of Netint's [DNS procurement request](https://github.ibm.com/alchemy-netint/firewall-requests/issues/2919) issues from their [repo](https://github.ibm.com/alchemy-netint/firewall-requests/issues) for the tugboat in question. Nslookup should return three entries for MZR and a single entry for SZR.

MZR
```
james.trinh1@prod-dal10-carrier2-worker-1002:~$ nslookup c131.private.us-south.satellite.cloud.ibm.com
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
c131.private.us-south.satellite.cloud.ibm.com	canonical name = prod-us-south-tugboa-155981.us-south.serviceendpoint.cloud.ibm.com.
Name:	prod-us-south-tugboa-155981.us-south.serviceendpoint.cloud.ibm.com
Address: 166.9.48.38
Name:	prod-us-south-tugboa-155981.us-south.serviceendpoint.cloud.ibm.com
Address: 166.9.58.204
Name:	prod-us-south-tugboa-155981.us-south.serviceendpoint.cloud.ibm.com
Address: 166.9.51.179
```

SZR
```
$ nslookup c101.private.us-south.containers.cloud.ibm.com
Server:		2600:1700:1d2:4000::1
Address:	2600:1700:1d2:4000::1#53

Non-authoritative answer:
c101.private.us-south.containers.cloud.ibm.com	canonical name = prod-sao01-tugboat10.us-south.serviceendpoint.cloud.ibm.com.
Name:	prod-sao01-tugboat10.us-south.serviceendpoint.cloud.ibm.com
Address: 166.9.16.5
```

Curl the IP(s) from a worker/master and make sure the service is healthy and reachable:
```
james.trinh1@prod-dal10-carrier2-worker-1002:~$ curl -k https://166.9.48.38:30001
<html><body><h1>200 OK</h1>
Service ready.
</body></html>
```

Checking certificate health in respect to CSE
```
james.trinh1@prod-dal10-carrier2-worker-1002:~$ curl https://c131.private.us-south.containers.cloud.ibm.com:30001/ --resolve c131.private.us-south.containers.cloud.ibm.com:30001:166.9.48.38
<html><body><h1>200 OK</h1>
Service ready.
</body></html>
```

### CSE healthcheck pods

If any of the above is failing, it is worth checking that the cse-health-check service/pods is up and running on the tugboat. If there are any issues with the pods, you can do a rollout restart to attempt to restore the service. Further troubleshooting can involve looking into the pod logs, and investigating whether any new changes in [Razee](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/cse-health-check) have impacted these pods. This healthcheck service is a pre-requisite for the CSE to be functional. 


```
[prod-dal10-carrier131] james.trinh1@prod-dal10-carrier2-worker-1002:~$ kubectl -n armada get svc -owide | grep cse-health-check
cse-health-check                 NodePort    172.19.29.109    <none>        443:30001/TCP   221d   app=cse-health-check

[prod-dal10-carrier131] james.trinh1@prod-dal10-carrier2-worker-1002:~$ kubectl -n armada get pod -owide | grep cse-health-check
cse-health-check-859994c5cb-bmfhj                     1/1     Running   0               10d     172.18.19.194    10.177.5.209     <none>           <none>
cse-health-check-859994c5cb-ll486                     1/1     Running   0               25d     172.18.184.32    10.185.238.151   <none>           <none>
cse-health-check-859994c5cb-qh2zs                     1/1     Running   0               25d     172.18.196.57    10.186.168.134   <none>           <none>
```

More information about the required HTTPS health check can be found [here](https://github.ibm.com/NetworkTribe/MISsupport/wiki/CSE-health-check-information).


### dnsstatus

Additionally, you can download the complete list of CSEs in the region (downloadCSE), and dig further into the specific details of CSE. The key field to lookout for are the following:

```
"dnsStatus": "Y",
```

If dnsStatus is "F", it usually confirms that there is some issue with the CSE and requires investigation through the methods above.

## Development

There are two sections that we need to consider when we are adding new features into this jenkins job. The first is adding the new feature and second is the testing component.

### Adding the new feature

In order to add a new feature to this jenkins job, you will need to have created the logic via bash script or GO and have it in the [carrier-service-endpoint repository](https://github.ibm.com/alchemy-conductors/carrier-service-endpoints/tree/master/service-eps).

Next, you will need to edit the following jenkins files and they are:

#### action.groovy

In this [file](https://github.ibm.com/alchemy-conductors/carrier-service-endpoints/blob/master/jenkins/action.groovy), you will see that each action has a case function where Jenkins will use to create the selectors and functions associated with them. You will need to add the new feature to the case function as well as create a new function with your logic pointing to any shell scripts or equivalent that you have created. Additionally, you can reference variables that have been captured from the GHE issue if you have enabled this feature. It is encouraged to create a dry run feature for all jobs, especially those that can impact production environments to prevent any accidents. 

#### jenkinsfile (optional)

In this section, you will need to add the function to this [list](https://github.ibm.com/alchemy-conductors/carrier-service-endpoints/blob/master/jenkins/jenkinsfile#L106) if you require the job to scrape and validate against a GHE issue in the repository. 

```
                        ops_applied = ['createCSE',
                                       'deleteCSE',
                                       'createETCD',
                                       'addACL',
                                       'deleteACL',
                                       'addServiceAddress',
                                       'deleteServiceAddress'
                                       ]
```

### Testing the feature
To avoid testing on the live jenkins job, we should create a new jenkins job with the same configuration as the original job. This is simple as the jenkinsfile will create all the parameters for you. 

To create a new job:
1. [Create a new item](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/newJob)
2. Name the job, select ```Pipeline``` project and then enter any description.
3. Scroll down to Pipeline section. Under Definition, select ```Pipeline script from SCM``` from the drop down menu. 
4. Under SCM, select ```Git```. 
5. Specify the Repository URL as ```git@github.ibm.com:alchemy-conductors/carrier-service-endpoints.git```
6. Specify the Credentials as ```ssh key for conauto@uk.ibm.com for GHE```
7. Define Branch Specifier as your testing branch. 
8. Specify the Script Path as ```jenkins/jenkinsfile```

After the job has been created, you will need to run the job twice. The first time will populate the inputs and parameters for the jenkins job. The second time is where you can test your inputs and job. After testing, make sure to delete the jenkins job that you have created. 

## Onboarding new CSE keys
The steps to onboard new CSE keys are as follows:
1. Create the new ServiceID
2. Onboard the new ServiceID to the MIS service by raising a ticket e.g. https://github.ibm.com/NetworkTribe/MISsupport/issues/907. 

Note: in the onboard request, they will ask you to specify whether you are looking to onboard to staging or production. This is referring to their service endpoints. It makes no difference to us as IKS. They have limited capacity for staging, and will provide more support for the production endpoint. The difference is that if you request to be onboarded for staging, you will need to have a staging iam token, which means that your ServiceID should be under test.cloud.ibm.com rather that cloud.ibm.com (which is for the production endpoint). 

```
The service endpoint production API server: https://api.serviceendpoint.cloud.ibm.com
The service endpoint staging API server: https://stagingapi.serviceendpoint.test.cloud.ibm.com/
```

For all of our cases, we have requested to onboard to their production endpoint and create the serviceID under the relevant prod accounts in cloud.ibm.com. See [here](#generate-temp-apikey) for current serviceIDs and their accounts.

Additonally, the onboarding request will require the following information. This information will depend on the use case of the CSE - you can refer to other onboarding requests (e.g. https://github.ibm.com/NetworkTribe/MISsupport/issues/907) to assist with filling out the information. 

```
Department Name: 
Division:
Department:
Major:
Minor:
Project: 
```

3. Once onboarded by the MIS team, you can create an apikey from the ServiceID and call their endpoint to test. To test, you will need to generate an IAM token, and then run the following command and not get any authentication errors:

```
[root@cse-vsi-1 ~]# curl "https://apiserver.serviceendpoint.cloud.ibm.com/v2/serviceendpoints" -H "Authorization: Bearer $IAM_TOKEN"
[]
```

4. Create a new credential in jenkins e.g. https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/credentials/store/folder/domain/_/credential/a15502f8-15bb-4ea0-b7be-179770f52baa/
5. Update the following jenkins config with the correct regions
```
https://github.ibm.com/alchemy-conductors/carrier-service-endpoints/blob/master/jenkins/jenkinsfile#L69
https://github.ibm.com/alchemy-conductors/carrier-service-endpoints/blob/master/jenkins/utils.groovy#L96
```

New region rollouts may need an additional step where the apikey is gpg encrypted for armada-network -
1. Define a new secure environment variable for the Private CSE ACL Automation apikey by creating the files below in build-env-vars/armada-network-microservice/

```
PROD_AU_SYD_NETMS_IKS_CSE_API_KEY_20240919.gpg                                          
PROD_AU_SYD_NETMS_IKS_CSE_API_KEY_20240919_metadata.yaml
```

2. Update the destination in the service-endpoint-config.yaml configmap e.g. armada-secure/secure/armada/ap-south/service-endpoint-config.yaml
 

## Generate Temp APIKEY
If you require a temporary CSE apikey, you may create an apikey under the following ServiceIDs. Please remember that this is not advised and should be used as a last resort. All temporary keys must be deleted after use.

| Account | CSE Region Selector | ServiceID |  
| ----------- | ----------- | ----------- |
| 531277 Argonauts Production | prod_us-south | [ServiceId-6ff79776-93e5-4df4-821b-17bd6b1f8410](https://cloud.ibm.com/iam/serviceids/ServiceId-6ff79776-93e5-4df4-821b-17bd6b1f8410) |
| 531277 Argonauts Production | prod_us-east | [ServiceId-dcd1fb47-e1dc-4a8c-bd8e-1378e7b979ee](https://cloud.ibm.com/iam/serviceids/ServiceId-dcd1fb47-e1dc-4a8c-bd8e-1378e7b979ee) |
| 531277 Argonauts Production | prod_eu-central | [ServiceId-3fcfda39-f7ba-4c14-8f42-11045c204d8d](https://cloud.ibm.com/iam/serviceids/ServiceId-3fcfda39-f7ba-4c14-8f42-11045c204d8d) |
| 531277 Argonauts Production | prod_uk-south | [ServiceId-abe8c25b-9a3d-4746-a324-17bd6cfef15e](https://cloud.ibm.com/iam/serviceids/ServiceId-abe8c25b-9a3d-4746-a324-17bd6cfef15e) |
| 531277 Argonauts Production | prod_ap-north | [ServiceId-4e0bfc48-cd01-4d76-a292-60e4b72a8ab5](https://cloud.ibm.com/iam/serviceids/ServiceId-4e0bfc48-cd01-4d76-a292-60e4b72a8ab5) |
| 531277 Argonauts Production | prod_ap-south | [ServiceId-b3d7ef8a-0040-48c0-b0d8-6573a1a5bd8f](https://cloud.ibm.com/iam/serviceids/ServiceId-b3d7ef8a-0040-48c0-b0d8-6573a1a5bd8f) |
| 531277 Argonauts Production | prod_jp-osa | [ServiceId-a03f54db-7d8c-4f7a-b2d6-39bf282f9b19](https://cloud.ibm.com/iam/serviceids/ServiceId-a03f54db-7d8c-4f7a-b2d6-39bf282f9b19) |
| 531277 Argonauts Production | prod_ca-tor | [ServiceId-e7d15eeb-d5fd-4694-bc8a-5442dc7957b7](https://cloud.ibm.com/iam/serviceids/ServiceId-e7d15eeb-d5fd-4694-bc8a-5442dc7957b7) |
| 531277 Argonauts Production | prod_br-sao | [ServiceId-279efda1-e48e-47d6-9cf2-4f270a613fa7](https://cloud.ibm.com/iam/serviceids/ServiceId-279efda1-e48e-47d6-9cf2-4f270a613fa7) |
| 531277 Argonauts Production | prod_eu-es | [ServiceId-1f9c3a18-2e7e-45f7-a695-9285f5a35b94](https://cloud.ibm.com/iam/serviceids/ServiceId-1f9c3a18-2e7e-45f7-a695-9285f5a35b94) |
| 531277 Argonauts Production | stage_us-south | [ServiceId-7fcb927a-1696-43a2-a964-042f63eda160](https://cloud.ibm.com/iam/serviceids/ServiceId-7fcb927a-1696-43a2-a964-042f63eda160) |
| 2051458 IKS BNPP Prod | prod_eu-fr2 | [ServiceId-a346b37d-8d15-4d1f-af29-1c03e140de60](https://cloud.ibm.com/iam/serviceids/ServiceId-a346b37d-8d15-4d1f-af29-1c03e140de60) |
| 1858147 Argo Staging | stgiks_us-south | [ServiceId-833bc6e4-bf8a-47d9-898b-d45db30d5f5e](https://cloud.ibm.com/iam/serviceids/ServiceId-833bc6e4-bf8a-47d9-898b-d45db30d5f5e) |
| 659397 Argonauts Dev | prestage_us-south | [ServiceId-b4969d21-e3fc-4f71-afd2-df76882bf9ef](https://cloud.ibm.com/iam/serviceids/ServiceId-b4969d21-e3fc-4f71-afd2-df76882bf9ef) |
| 659397 Argonauts Dev | dev_us-south | [ServiceId-ac80091d-edf8-4b7c-9a4f-ead06d28f4e3](https://cloud.ibm.com/iam/serviceids/ServiceId-ac80091d-edf8-4b7c-9a4f-ead06d28f4e3) |
| 659397 Argonauts Dev | roks-dev-controlplane | [ServiceId-a4eff083-e646-41b2-a269-846617738f86](https://cloud.ibm.com/iam/serviceids/ServiceId-a4eff083-e646-41b2-a269-846617738f86) |
| 2094928 Satellite Production | satellite_us-south | [ServiceId-4fbb4b18-0912-482b-91c4-86c272a35f9d](https://cloud.ibm.com/iam/serviceids/ServiceId-4fbb4b18-0912-482b-91c4-86c272a35f9d) |
| 2094928 Satellite Production | satellite_us-east | [ServiceId-1a10a717-c157-4402-a157-3dd54e56243a](https://cloud.ibm.com/iam/serviceids/ServiceId-1a10a717-c157-4402-a157-3dd54e56243a) |
| 2094928 Satellite Production | satellite_eu-central | [ServiceId-88d8c8a3-a715-4799-b1ba-16a58ed8a285](https://cloud.ibm.com/iam/serviceids/ServiceId-88d8c8a3-a715-4799-b1ba-16a58ed8a285) |
| 2094928 Satellite Production | satellite_uk-south | [ServiceId-bddf36ab-53e3-466c-8126-4fdeedf43ec3](https://cloud.ibm.com/iam/serviceids/ServiceId-bddf36ab-53e3-466c-8126-4fdeedf43ec3) |
| 2094928 Satellite Production | satellite_ap-north | [ServiceId-00486e26-cc40-49f4-8750-7a2e90085ae4](https://cloud.ibm.com/iam/serviceids/ServiceId-00486e26-cc40-49f4-8750-7a2e90085ae4) |
| 2094928 Satellite Production| satellite_ap-south | [ServiceId-e09771fe-5353-49ad-8ce7-b370114cb998](https://cloud.ibm.com/iam/serviceids/ServiceId-e09771fe-5353-49ad-8ce7-b370114cb998) |
| 2094928 Satellite Production | satellite_jp-osa | [ServiceId-fc96b99e-2835-41a8-a8f8-d2851b7f7408](https://cloud.ibm.com/iam/serviceids/ServiceId-fc96b99e-2835-41a8-a8f8-d2851b7f7408) |
| 2094928 Satellite Production | satellite_ca-tor | [ServiceId-401fbd82-1218-457c-9779-a3ae63eec0a8](https://cloud.ibm.com/iam/serviceids/ServiceId-401fbd82-1218-457c-9779-a3ae63eec0a8) |
| 2094928 Satellite Production | satellite_br-sao | [ServiceId-f0fe4537-5077-4390-a793-fa25c08ea86](https://cloud.ibm.com/iam/serviceids/ServiceId-f0fe4537-5077-4390-a793-fa25c08ea865) |
| 2094928 Satellite Production | satellite_eu-es | [ServiceId-05dc1218-d7ae-4cf5-9a5d-c742b7bb2d2a](https://cloud.ibm.com/iam/serviceids/ServiceId-05dc1218-d7ae-4cf5-9a5d-c742b7bb2d2a) |
| 2146126 Satellite Stage | stage_satellite_us-south | [ServiceId-8963a15c-0df1-4f6e-9ca5-b2eece74dc23](https://cloud.ibm.com/iam/serviceids/ServiceId-8963a15c-0df1-4f6e-9ca5-b2eece74dc23) |
| 2353671 Satellite Dev | prestage_satellite_us-south | [ServiceId-fafd9fe9-5aea-4747-bb8b-4a0d5bab5645](https://cloud.ibm.com/iam/serviceids/ServiceId-fafd9fe9-5aea-4747-bb8b-4a0d5bab5645) |
| 2353671 Satellite Dev | prestage_satellite_link_us-south | [ServiceId-c7744b96-612b-475a-9505-d5f37768b90b](https://cloud.ibm.com/iam/serviceids/ServiceId-c7744b96-612b-475a-9505-d5f37768b90b) |
| 2353671 Satellite Dev | dev_satellite_us-south | [ServiceId-7df00d25-14ff-4184-b741-61694421b60e](https://cloud.ibm.com/iam/serviceids/ServiceId-7df00d25-14ff-4184-b741-61694421b60e) |
| 2353671 Satellite Dev | dev_satellite_link_us-south | [ServiceId-28cb39de-450e-40b5-b408-fcd7a5911a5f](https://cloud.ibm.com/iam/serviceids/ServiceId-28cb39de-450e-40b5-b408-fcd7a5911a5f) |


## Escalation

If there are any issues with the Jenkins Job, you can reach out to @conductors-aus team in #conductors-for-life slack channel. 

If there is an issue with the CSE, it is the responsibility of IKS SRE to investigate. If there are no issues on IKS side, we can reach out to the service endpoint team to assist in our investigation:

- Slack: [#service-endpoint-sre](https://ibm.enterprise.slack.com/archives/C060URT5761)
- GitHub: https://github.ibm.com/IBM-Cloud-Platform-Networking/MISsupport or https://github.ibm.com/NetworkTribe/MISsupport/issues
