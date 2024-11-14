---
layout: default
title: containers-registry - User has exceeded their quota
type: Troubleshooting
runbook-name: "User has exceeded their quota"
description: "A user has exceeded their Registry Traffic or Storage quota"
service: Registry
failure: []
playbooks: ["https://github.ibm.com/alchemy-conductors/cfs-runbooks/blob/master/playbooks/registry/recoveryTool/user-quota.yml"]
link: /runbooks/registry_quota_exceeded.html
parent: Armada Runbooks

---

Informational
{: .label }

## Issue

A user has questioned why their `docker push` or `docker pull` has failed, with an error telling them they have exceeded their quota for Storage or Pull Traffic.

## Explanation

Users on the Free plan are limited to 500MB of storage in the registry, and 5GB of pull traffic (docker pull) per month. Users on the Standard plan have unlimited quotas by default.
In either case, users can opt to impose their own quotas as long as those do not exceed the limits for their pricing plan.

Registry quotas are applied based upon what's already in your registry. Due to the way that the Registry works, we can't tell how much of your quota a particular action will use until you've already done it. As a result, Registry quotas prevent you from performing subsequent actions once you've exceeded the set amounts of usage, rather than preventing you from using more than that amount.

Note that the Registry quotas are independent of one another; for example, exceeding your pull traffic quota prevents you from pulling subsequent images, but you can still push images until you exceed your storage quota.

The quotas are provided as a convenience feature, and they aren't a substitute for vigilance. Customers should continuously keep an eye on their usage.

## Resolution

The customer can check their own Plan and Quota settings (including current usage) by using the following commands:
  * `bx cr plan`
  * `bx cr quota`

If the customer has not provided this information, you can derive this by running the following Jenkins job, providing the region and account being queried:
  * [registry-plan-quotas-usage](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Registry/view/Playbooks/job/registry-plan-quotas-usage/)

The Jenkins job linked above drives the following Ansible playbook:
  * [user-quota playbook](https://github.ibm.com/alchemy-conductors/cfs-runbooks/blob/master/playbooks/registry/recoveryTool/user-quota.yml)

If the customer has exceeded their storage quota, they can delete one or more images to drop back below their quota and regain the ability to push images. Storage is billed in Gigabyte-months, and their bill will reflect the additional usage for this time, but customers can avoid large charges by acting quickly to resolve the overage.

If the customer has exceeded their traffic quota, they must wait for their traffic usage to reset. This reset happens at 00:00 UTC on the first of each calendar month.

Alternatively, the customer can use `bx cr quota-set` to increase the quota which has been exceeded in order to regain use of the Registry. Of course, by doing this they acknowledge that the extra usage will incur extra charges. 
Users on the Free plan can adjust their quota up to a maximum of 5GB traffic and 500MB storage, after which they must upgrade to Standard (`bx cr plan-upgrade standard`). Users on the Standard plan can set their quota to any number up to 9 yottabytes - although actually using this much storage would cost orders of magnitude more money than there is in the world economy, and use orders of magnitude more storage than exists on the planet!

## Additional information for internal users

In order to upgrade to a Standard account with `bx cr plan-upgrade standard` users need a PayAsYouGo (PAYG) Bluemix account - the free trial account that many IBMers have will not work. 
You can check your account type using `bx iam accounts`. Instructions for upgrading accounts can be found [here](https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W6dc72a2df174_4a2f_bb64_86c59349be1d/page/Request%20Access%20for%20an%20Internal%20Bluemix%20(PaaS)%20Paid%20Account). 

## Escalation

Support tickets should be escalated through the Containers Tribe customer ticket process. This issue does not represent a customer outage, so should not be escalated to Severity 1 or warrant a PagerDuty alert.

The Registry squad can be found in the shared [registry-va-users](https://ibm-argonauts.slack.com/messages/C53RR7TPE) channel.

## Further reading

  * [IBM Bluemix Container Registry Docs - Introduction to Plans](https://console.bluemix.net/docs/services/Registry/registry_overview.html#registry_plans)
  * [IBM Bluemix Container Registry Docs - Managing Quota Limits](https://console.bluemix.net/docs/services/Registry/registry_quota.html#registry_quota)
  * [IBM Bluemix Container Registry CLI Reference](https://console.ng.bluemix.net/docs/cli/plugins/registry/index.html)
  * [Containers Tribe Customer Ticket Process](https://ibm.box.com/v/CustomerTicketFlow)
