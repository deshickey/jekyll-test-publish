---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Covers how to use the Jenkins job to get or set a user's image quota.
service: Containers - Registry
title: Registry Quotas
runbook-name: "Registry Quotas"
link: /registry_quotas.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Registry Quotas

### Public

***NB:*** This section documents quotas for users on the Legacy pricing plan. Users on the Free plan can't adjust their quota, and users on the Standard plan can set their own quotas using `bx cr quota-set`. After the IBM Bluemix Container Registry launches billing, users can run `bx cr plan` to view their current pricing plan, and `bx cr plan-upgrade standard` to switch to the Standard plan.

The following are useful related documents/blog posts

- [Blog written by Registry squad](https://w3-connections.ibm.com/blogs/registry-ibmers/entry/legacy-action?lang=en_us)
- [Request Access for an Internal Bluemix (PaaS) Paid Account](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W6dc72a2df174_4a2f_bb64_86c59349be1d/page/Request%20Access%20for%20an%20Internal%20Bluemix%20(PaaS)%20Paid%20Account)



#### Getting a quota

1. Go to Jenkins and find [Containers_Quota_Utility](https://alchemy-containers-jenkins.swg-devops.com:8443/job/Containers-Registry/view/Utilities/job/containers_quota_utility/).
2. Select parameters as follows:
    * For `NODE_LABEL`, select the Jenkins slave for the environment to query. The label names start with "dockerbuild-vpn-shared-", followed by the environment name.
    * For `TARGET_ENV`, select the environment from the drop-down lists.
    * For `HOSTS`, leave "REG1" selected.
    * For `QUERY_TYPE`, select "Get".
    * For `NAMESPACE_TO_QUERY`, enter the namespace you want to get the quota for.
3. Click **Build**.
4. Once the build has completed, click on the build in the build history and click "Console Output". Inspect the output for a JSON object containing the results of the query.

#### Setting a quota

**All image quota increases require approval from Ralph or Stuart Hayton from the Registry squad**

1. Go to Jenkins and find [Containers_Quota_Utility](https://alchemy-containers-jenkins.swg-devops.com:8443/job/Containers-Registry/view/Utilities/job/containers_quota_utility/).
2. Select parameters as follows:
    * For `NODE_LABEL`, select the Jenkins slave for the environment to query. The label names start with "dockerbuild-vpn-shared-", followed by the environment name.
    * For `TARGET_ENV`, select the environment from the drop-down lists.
    * For `HOSTS`, leave "REG1" selected.
    * For `QUERY_TYPE`, select "Set".
    * For `QUOTAS_TO_SET`, edit the provided JSON and fill in `<namespace`> and `<limit`>.
3. Click **Build**.
4. Once the build has completed, click on the build in the build history and click "Console Output". Inspect the output for a JSON object containing the results of the query.

### Dedicated and Local

For the following API calls the variables below are retrieved from the environment's JML file.

    (${} indicates property in JML)
    API_HOST=containers-api.${bluemix_env_domain}
    API_USER=${main_user_name}
    API_PASSWORD=${password}

#### Getting a quota

    curl -u ${API_USER}:${API_PASSWORD} https://${API_HOST}/v3/admin/quota/registry/<namespace>
#### Setting a quota

  Expects a json object of the following format:

    '{
       "namespace": "example-namespace",
       "quotas": {
         "image_limit": "55"
         }
     }'
<!-- -->
    curl -X POST -u ${API_USER}:${API_PASSWORD} \
    -H "Content-Type: application/json" \
    -d ${json} \
    https://${API_HOST}/v3/admin/quota/registry
