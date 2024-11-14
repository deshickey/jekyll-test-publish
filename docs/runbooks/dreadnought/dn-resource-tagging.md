---
layout: default
title: "Dreadnought - How to tag resources for specific scenarios"
runbook-name: "How to tag resources"
description: "How to tag resources in Dreadnought on different accounts based on environment"
category: Dreadnought
service: dreadnought
tags: dreadnought, dreadnought tags, resource-tagging
link: /dreadnought/dn-resource-tagging.html
type: Informational
grand_parent: Armada Runbooks
parent: Dreadnought
---

Informational
{: .label }

## Overview
This runbook describes on tagging of resources on different accounts of a specific cabin based on the environment 

## Detailed Information

#### Why tagging is needed for resources
- Resource tagging allows service teams to filter resource instances based on their categorization.
- We use an automation script for tagging instead of relying solely on TaaS resource creation because resources can also be created outside of schematics.
- Each cabin team must maintain resource tags in the `cabin-config` repository, and following this process should be mandatory for service teams.

#### Steps involved
- Initially provide input for the environment which you want to tag, the git token, service name, provisioning account api for that environment and few other inputs necessary(will be detailing further below if any inputs is necessary to mention)
- Using the provisioning account api key, we parse through the secrets manager and get the account names and its api-keys for their respective cabin accounts.
- We can get the `tags.json` in defs folder of the service-teams in cabin-config repository
- We login through each of these accounts one by one and tag them sequentially. 
- Get the `cabin default` and `dn-default` resource groups from the cabin-config definitions.json file and tag the resources with the respective resource groups in the account.
- As of next step, we get the clusters from the same `definition.json` file for each of these accounts and tag these clusters with the respective tags mentioned in tags.json file.
- We extract the region and resource group of each of these clusters and tag the `Observability`, `Key Protect` and `Cloud Object Storage` instances with that particular region and resource group we extracted from these clusters of the account.
- Additional Information: The automation script is written in such a way that the code is split into modules based on their functionality for better understandability and to achieve lesser cohesion between modules.

#### Where to find the script
- The script is currently in a folder name `resource-tagging` in the branch `main` of the repository `dn-operation-toolbox` 
- The pipeline configurations of this can be found in `automations/resource-tagging/.tekton`

#### Inputs needed
- CABIN_CONFIG_BRANCH - branch of the cabin-config repo(main)
- CABIN_CONFIG_PATH - path of the cabin-configs.json file to locate file path for different service-teams(cabin-configs.json)
- CABIN_CONFIG_REPO - dreadnought/cabin-config
- GIT_ACTION - attach/detach the tags
- GIT_BRANCH - branch in which the script exists
- GIT_ENV - the accounts of an environment that needs to be tagged (dev/stage/prod)
- GIT_TOKEN - PAT needed to access the repository
- PROV_ACCOUNT - the name of the provisioning account of the respective environment chosen to tag
- PROV_API_KEY - api-key for the provisioning account
- SERVICE_NAME - the service(cabin) team in which its accounts have to be tagged
- SM_ENDPOINT - Secrets manager endpoint of the provisioning account where we can extract sm id and sm region from this endpoint
- dockerconfigjson - ops-dockerconfigjson secret from the provisioning account
- SLACK_CHANNEL(optional) - the channel name required to send alerts/notifications
- GENERIC_GROUP(optional) - the resource group shared between service-teams

#### How to run the script
- Currently the pipeline is in the provisioning account of the current environment in a toolchain named `common-automation-toolchain` with a pipeline named `resource-tagging-pipeline`
- We can run the trigger to perform the operation. The run may take a minimum of 10-15 minutes. 
- Once it ran, hurray your resource instances should be tagged successfully.

## References 
- [Automation Script can be found here](https://github.ibm.com/dreadnought/dn-operation-toolbox/tree/karthick-resource-tagging){:target="_blank"}
- [Cabin Config Repository](https://github.ibm.com/dreadnought/cabin-config/){:target="_blank"}
- [CD Pipeline for dev (dn-dev-s-provisioning)](https://cloud.ibm.com/devops/pipelines/tekton/fbe107ac-c629-454e-bc09-cff0425c9e1c?env_id=ibm:yp:us-east){:target="_blank"}
- [CD Pipeline for stage (dn-stage-s-provisioning)](https://cloud.ibm.com/devops/pipelines/tekton/263165ad-2632-4b6c-af08-54e6d1297f86?env_id=ibm:yp:us-east){:target="_blank"}
- [CD Pipeline for prod (dn-prod-s-provisioning)](https://cloud.ibm.com/devops/pipelines/tekton/a1ed384e-229f-464d-9c33-4e84dc2d5a00?env_id=ibm:yp:us-east){:target="_blank"}
