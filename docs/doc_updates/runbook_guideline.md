---
layout: default
title: Runbook Guideline
type: Informational
parent: Documentation Contribution
---

Informational
{: .label }

# Runbook Guideline

## Background

IBM Cloud public service is being delivered as a product to Wanda, our partner
 in China. Wanda will be deploying and operating the IBM cloud. The kubernetes
 Container service, Registry and Vulnerability Advisor are part of this delivery.

As part of the delivery we need to give the Wanda SREs the runbooks needed to
 operate the container service. Currently our runbooks are aimed for internal
 use, and refer to tools that Wanda will not be using, such as Pagerduty
 and ServiceNow.

Based on initial investigation, the current alchemy runbooks have certain
 groupings of content that would need to be replaced or eliminated before we
 can package them for Wanda. For more details, see [Runbooks Investigation](https://github.ibm.com/alchemy-containers/armada-wanda/blob/master/runbooks/productize-runbooks.md).

To make it easier to maintain our runbooks and to deliver them to Wanda, we
 provide this runbook guideline which you can follow when adding/updating runbooks.

## Runbooks type

There are four runbook types:

1. Alert
1. Informational
1. Operations
1. Troubleshooting

The type of runbook must be one of them, otherwise it will not pass the build check.


## Runbook Required Metadata

    layout: default
    title: <replace with a title to appear on the runbook page>
    type: <Alert, Informational, Operations or Troubleshooting>
    runbook-name: <replace with runbook-name. Surround with inverted commas>
    description: <replace with description>
    category: <replace with the product name, e.g. Armada>
    service: <replace with service, e.g. Containers>
    tags: <replace with the tags, e.g. wanda>
    link: <link to Runbook - replace .md with .html>

If one runbook needs to be delieved to Wanda, it must have the `wanda` tag.

Example:
~~~
layout: default
title: How to view logs of the armada-deploy microservice
type: Informational
runbook-name: "How to view logs of the armada-deploy microservice"
description: How to view logs of the armada-deploy microservice.
category: armada
service: armada-deploy
tags: alchemy, armada, kubernetes, armada-deploy, microservice, logs, wanda
link: /armada/armada-deploy-operation-failures.html
~~~

##Runbook Template

### Alert Runbook Template
    ## Overview (Required)
    - Why the user is directed to this runbook and what the issue is

    ## Example alert(s) (Required)
    - A list of all possible alerts which could bring the user to this runbook

    ## Automation (Required)
    - Point out any automation scripts or Jenkins jobs that can be used to either
      fix the alert or at least collect important information

    - Put None if there is no automation available yet

    ## Action|Actions to take (Required)
    - Clear, short steps to fix the issue

    ## Escalation Policy (Required)
    - If the alert can't be resolved by this runbook, how to escalate this alert

    ## Reference (Optional)


### Informational Runbook Template
    ## Overview (Required)
    - Purpose for this runbook

    ## Detailed Information (Required)
    - Detailed information on this topic

    ## Further Information (Optional)
    - How to get further information about this topic


### Operations Runbook Template
    ## Overview (Required)
    - Purpose for this runbook

    ## Example alerts (Required)
    - A list of all possible alerts which could bring the user to this runbook

    ## Detailed Information (Required)
    - Detailed information on this topic

    ## Detailed Procedure (Required)
    - Detailed procedure for this operation

    ## Automation (Required)
    - Point out any automation scripts or Jenkins jobs that can be used to either
      finish the operation or at least help to do some routine work

    - Put None if there is no automation available yet


### Troubleshooting Runbook Template
    ## Overview (Required)
    - Purpose for this runbook

    ## Example alert(s) (Optional)
    - A list of all possible alerts which could bring the user to this runbook

    ## Investigation and Action (Required)
    - Determine datails about the failure, collect logs / information

    ## Escalation Policy(Required)
    - If the alert can't be resolved by this runbook, how to escalate this alert

    ## Automation (Required)
    - Point out any automation scripts or Jenkins jobs that can be used to collect
      trouble shooting information like logs, dump messages.

    - Put None if there is no automation available yet


### Escalation Policy
Each pagerduty & troubleshooting runbooks should define "Escalation Policy", if the alert can't be resolved by this runbook, how to escalate this alert.

For IBM, the "Escalation Policy" should include three parts:
- pagerduty escalation policy
- the slack channel information
- GHE link to open issue

For Wanda, they should define their own "Escalation Policy"

Example:
~~~
## Escalation Policy

For more help in searching the logs, please visit the [{{site.data.teams.armada-deploy.comm.name}}]({{site.data.teams.armada-deploy.comm.link}}) slack channel.

If you are here because of a PD incident and need more help on an issue, you can escalate to the development squad by using the [{{site.data.teams.armada-deploy.escalate.name}}]({{site.data.teams.armada-deploy.escalate.link}}) PD escalation policy.

If you run across any armada-deploy problems during your search, you can open a GHE issue for armada-deploy [{{site.data.teams.armada-deploy.name}}]({{site.data.teams.armada-deploy.issue}}).
~~~


## Runbook Process Approach (For Wanda)

### There are two main categories for substitution needs in the runbooks
1. Replaceable Sections, e.g. Escalation Paths, Example Alert or Example Error, Notable links, References.
2. Replaceable Phrases, e.g. IBM, GHE links, Slack channels

#### For Replaceable Sections

Note: We should use replaceable sections as less as possible. It will cause the
 update to Wanda awkward and difficult to maintain.

###### Capture Tag

`capture` is a built-in variable tag of liquid template language, it can be used to store the result of a block into a variable. See [Liquid-for-Designers](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers) for more details.

1. Use `capture` tag to store the content of "Replaceable Sections" into a capture variable, then render the variable, such as:

   ```
   {% raw %}
   {% capture capture_example %}
   IBM internal info
   {% endcapture %}
   {{ capture_example }}
   {% endraw %}
   ```

2. While delivering IBM Runbook to Wanda, the capture tag block will be removed for IBM, it will look like as following:

   ```
   {% raw %}
   {{ capture_example }}
   {% endraw %}
   ```

3. Since the capture content is remove, Wanda needs to replace the empty capture variable with their own content to render:

   ```
   Wanda internal info
   ```

Example:
[capture example](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/master/docs/runbooks/armada/armada-carrier-pods-in-bad-state.md), the content of the escalation policy section is stored in the capture variable.

Note:
1. To make Wanda to provide their content easily for each capture variable, please give each variable a meaningful name.
2. The `capture` and `endcapture` must start in a newline.


#### For Replaceable Phrases

##### Jekyll Variables
Jekyll supports loading data from YAML/JSON/CSV files located in the _data directory, we should put all variable info of runbooks into the _data file, below is an example:

1. Define variables for "Replaceable Phrases" like GHE repos in the _data/ibm/ghe.yml:

   ```
   repos:
     armada-deploy:
       name: armada-deploy
       link: https://github.ibm.com/alchemy-containers/armada-deploy
     ...
   ```

2. Load the variable to refer to this link:

   ```
   {% raw %}
   [{{ site.data.teams.armada-deploy.name }}]({{ site.data.teams.armada-deploy.link }})
   {% endraw %}
   ```

3. While deliver IBM Runbooks to Wanda, all values of variables in the _data directory will be removed, Wanda needs to provide their own variable value.


Example:
[Jekyll data variable example](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/9f3b54f6d6fb6224aa62e57a8eaabe5c07958faf/docs/runbooks/armada-runtime-properly-reboot-worker.md#steps-to-take).


## Runbook Pipeline

### Background

- There will be only one documentation repository for IBM Armada team

- Armada runbook will also move from **alchemy-prod.hursley.ibm.com** to **GHE pages**

- Update tags to define the runbook list that needed to deliver to Wanda

- Update existing runbooks

- To deliver armada runbook to Wanda, this [pipeline job](https://alchemy-containers-jenkins.swg-devops.com/job/armada-runbooks-delivery-wanda-pipeline/) to package the necessary runbooks to Artifactory repository

### Automated PR Check
- check if the runbook include all **required section** defined on template

- check if runbook doesn't include specified key word, such as: IBM, Bluemix, Softlayer...

- check if all links can be replaced by "Wanda"

- run jekyll syntax check

### New Runbook Process

- write a new runbook following runbook template

- submit GHE PR

- automated PR check

- review the PR and commit it to master branch

- **[Jenkins job]** remove all IBM related informations, including capture variable content, jekyll data variable values(Jenkins job).

- **[Jenkins job]** zip and upload to Artifactory repository


## Runbook Example:

### Alert Runbook
[armada-deploy-master-update-failures](../runbooks/armada/armada-deploy-operation-failures.html)

### Information Runbook
[armada-cluster-sl-api-queries](../runbooks/cluster/cluster-squad-sl-api-queries.html)

### Operations Runbook
[armada-ops-add-monitoring-checks-in-sensu-uptime](../runbooks/armada/armada-ops-add-monitoring-checks-in-sensu-uptime.html)

### Troubleshooting Runbook
[armada-carrier-pods-in-bad-state](../runbooks/armada/armada-carrier-pods-in-bad-state.html)
