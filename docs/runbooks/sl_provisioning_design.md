---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Provisioning API - Troubleshooting and Design Notes
service: Runbook needs to be updated with service
title: Provisioning API - Troubleshooting and Design Notes
runbook-name: "Provisioning API - Troubleshooting and Design Notes"
link: /sl_provisioning_design.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# Design Notes

|  Source | (https://github.ibm.com/alchemy-conductors/provisioning-app)  |
|  ----  | --- |
| **Docker Image** | alchemyregistry.hursley.ibm.com:5000/slapi |
| **Jenkins** | https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/view/SL%20API |
| **Technologies** | Python, Flask, Apache |
| **Related** | [Provisioning a new Machine](./sl_provisioning.html)|

---

## Overview

The Provisioning Application is implemented as a web service that is deployed as kubernetes deployment that runs in the `dashboard` namespace in the `bots` cluster (ID: `d34580e8ca3a47939515766ff7d9d515`) in the support account (278445)

It is standalone and stateless. It doesn't store state in any database backend. Every transaction is the same. It only interacts with SoftLayer API endpoints.

The purpose of the provisioning application is not only to help with machine ordering. It contains functionality that simplifies operations involving SoftLayer machines and user accounts.

## Detailed information

The [`config` folder](https://github.ibm.com/alchemy-conductors/provisioning-app/tree/master/config) contains several files that are used for the configuration of the application.

| File | Purpose |
| --- | --- |
| [service_config.json](https://github.ibm.com/alchemy-conductors/provisioning-app/blob/master/config/service_config.json) | **Service Configuration**.<br> Defines the SL endpoint that will be used, as well as other deployment specific details. <br> This file can be overriden at runtime. So we can define for instance a stub implementation of the API for integration tests. <br>See, for example [run_test.sh](https://github.ibm.com/alchemy-conductors/provisioning-app/blob/master/run_test.sh). <br>Example:<br> { <br>"endpoint_url" : "SoftLayer.API_PRIVATE_ENDPOINT", <br>   "api_class" : "modules.sl_api.SoftLayerAPI", <br>  "prefix": "/prov/api", <br> "server_name" : "alchemy-prod.hursley.ibm.com", <br>"scheme": "https" <br>} |
| [templates.json](https://github.ibm.com/alchemy-conductors/provisioning-app/blob/master/config/templates.json)| **Templates Configuration**. <br>Contains the full list of templates that the service supports. |
| [initial_machine_config.py](https://github.ibm.com/alchemy-conductors/provisioning-app/blob/master/config/initial_machine_config.py) | **Post Provisioning Scripts**. It's a module that contains the mapping between environments and post provisioning scripts, as well as utility functions |
| [conductors_tag_list.json](https://github.ibm.com/alchemy-conductors/provisioning-app/blob/master/config/conductors_tag_list.json) | **Tags List**. <br>This file contains the list of tags that are added to machines. <br>They are used in the [Tags Update Job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/view/SL%20API/job/Softlayer_tag_all_machines/) that runs periodically to ensure that all the machines in SL have the right tags in them. |

## The Cache

The live version of the provisioning app does not use the cache. All calls are made directly to SL. The cache is still used for integration testing. https://github.ibm.com/alchemy-conductors/provisioning-app/issues/77 addressess getting rid of the cache completely.

We cache machine template and user template data. Calls are made directly to SL during runtime for all other data. We run a periodic job that refreshes the Cache.

The Jenkins job: [SL-API-Cache-Refresh](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/SL%20API/job/SL-API-Cache-Refresh/)

If the job fails, the cache will be in an inconsistent state. The application will probably fail due to missing cache. There is a Jenkins job to Rollback the cache to a previously good version:
[SL-API-Cache-Rollback](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/SL%20API/job/SL-API-Cache-Rollback/)

# Build and Deployment workflow


## The Pull Request Build

The PR build is the main gatekeeper of new changes in the production branch. It performs a few sanity checks as well as run the unit tests using `make test`. We use travis instead of jenkins for this. Look for the `.travis.yml` file in the project git repository.

## The Docker Image Build

Link: [SoftlayerAPI-build-container](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/SL%20API/job/SoftlayerAPI-build-container/)

Whenever a change is pushed into the master branch, it triggers a continuous delivery pipeline that starts with the image build, which basically runs the unit tests followed by docker build and docker push to the alchemy registry.
If this build is successfull, it will trigger a Deployment Build.

## Deployment Build

[Link:](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/SL%20API/job/SLAPI_deploy/)

After successful completion of the Docker Image build, the deployment build is triggered, which pushes the image into SoftLayer and then performs a docker pull followed by `docker run`. If the job is successful, it triggers
a Cache Refresh build.

## Cache Refresh

[Link:](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/SL%20API/job/SL-API-Cache-Refresh/)

The Cache refresh build runs every 30 minutes and it's also triggered after every successful deploy.

# Troubleshooting

## The Provisioning App is down

Usually if the provisioning app is down it's because of a bad deploy. The fastest way to restore the service back to normal is to re-run the previous good deploy build.

- Navigate to the Deploy [Jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/SL%20API/job/SLAPI_deploy))
- Click `Build Now`

If the rebuild fails, review the console output and seek assistance from the SRE team in [the sre-cfs slack channel](https://ibm-argonauts.slack.com/messages/G542S3W1L).

If necessary, raise a [GHE issues here](https://github.ibm.com/alchemy-conductors/team/issues/new) to track the issue and make others aware.

## Cache Refresh Fails

You can try to rollback the cache: [SL-API-Cache-Rollback](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/SL%20API/job/SL-API-Cache-Rollback/)

## Escalation policy

Any problems with the tool should be handled by the SRE team.

SRE members needing assistance, reach out in the [the sre-cfs slack channel](https://ibm-argonauts.slack.com/messages/G542S3W1L).

If you're not an SRE member, reach out via [#conductors slack channel](https://ibm-argonauts.slack.com/messages/C54H08JSK)
