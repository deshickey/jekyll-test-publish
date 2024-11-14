---
layout: default
description: Useful information for browsing the IBM Cloud classic Infrastructure API
service: armada
runbook-name: "Useful information for browsing the IBM Cloud classic Infrastructure API"
link: /cluster/cluster-squad-sl-api-queries.html
tags: SoftLayer, API, queries, softlayer
type: Informational
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Informational
{: .label }

# Useful queries for the IBM Cloud classic Infrastructure API

## Overview

This runbook is intended to provide some useful information on browsing the IBM Cloud classic Infrastructure (SoftLayer) API.

## Detailed Information

This runbook assumes you already have access to an IBM Cloud classic Infrastructure account, and that you have an IBM Cloud classic Infrastructure username and API key.

All of these queries can be entered into a browser, and then the IBM Cloud classic Infrastructure username and API key for the account to be checked should be entered in the prompt.

Alternatively, curl can be used to query the URLs. The username and API key forms the basis of the basic auth when using curl.

# Useful Queries

## Worker package related

There are 7 packages from which IKS can order IBM Cloud classic Infrastructure workers:

Package Key Name | Package ID | IKS Worker Types
-- | -- | --
CLOUD_SERVER | 46 | Patrol VSI flavor (plus all VSIs in dev-south)
BLUEMIX_CONTAINER_SERVICE | 801 | Paid VSI flavors (1, 2 and 3 series)
RESERVED_INSTANCE_FOR_IKS_ROKS_WORKERS | 2732 | Reservation VSIs (3 series)
2U_BARE_METAL_CONTAINER_V2 | 2696 | BM larger flavors (4 series)
2U_BARE_METAL_CONTAINER_EDGE_V2 | 2698 | BM edge flavors (4 series)
2U_BARE_METAL_CONTAINER | 995 | DEPRECATED BM large flavors (1, 2 and 3 series)
BARE_METAL_CONTAINER_EDGE | 997 | DEPRECATED BM edge flavors (1, 2 and 3 series)

Note: All packages can be listed using `ibmcloud sl order package-list`

### IBM Cloud classic infrastructure (SoftLayer) API Reference Links

[SoftLayer Product_Package API Reference](https://sldn.softlayer.com/reference/services/SoftLayer_Product_Package/)

#### To list the regions in which a package can be ordered

https://api.softlayer.com/rest/v3/SoftLayer_Product_Package/XXX/getRegions

where XXX is the package ID, e.g. 46 or 801 for Virtual Guests.

_Note: The results of this query can vary depending on the IBM Cloud classic Infrastructure account that you are authenticated with._

#### To list the items available in a package

https://api.softlayer.com/rest/v3/SoftLayer_Product_Package/XXX/getItems

where XXX is the package ID, e.g. 46 or 801 for Virtual Guests.

_Note: The results of this query can vary depending on the IBM Cloud classic Infrastructure account that you are authenticated with._

## Order related

### IBM Cloud classic infrastructure (SoftLayer) API Reference Links

[SoftLayer Billing_Order API Reference](https://sldn.softlayer.com/reference/services/SoftLayer_Billing_Order/)

#### To search for an order by worker hostname

https://api.softlayer.com/rest/v3/SoftLayer_Billing_Order/getAllObjects?objectFilter={"items":{"hostName":{"operation":"WORKER_ID"}}}&objectMask=mask[items[hostName,domainName,billingItem[cancellationDate,parentId]]]

where WORKER_ID is the ID of the worker, e.g. `kube-dal10-pa000000000000000000000000-w1` or `test-bltvf5d20g03tt6it3eg-gapaid20190-default-00000229`.

If an order cannot be found for an adopted worker, then try this query to see if the problem can be spotted. If this query returns an object, check whether it has a cancellation date. If this query does not return an object, then try removing the domainName or hostName sections from the filter to see if you can find the order, and then determine which field was not set correctly in the initial order.

#### To check whether an order (for a worker or a subnet) has been cancelled

https://api.softlayer.com/rest/v3/SoftLayer_Billing_Order/XXXXXXXX?objectMask=mask[items.billingItem[id,cancellationDate]]

where XXXXXXXX is the numeric order ID of the order. The order ID for a worker, or for a subnet created by Armada can be found using armada-xo.

If a cancellationDate is specified, then the cancellation of the item has been requested. In the case of subnets, this can take a few days to be actioned (or the subnet could be reassigned to the next request for a subnet without being deleted first).

## Worker related

### IBM Cloud classic infrastructure (SoftLayer) API Reference Links

[SoftLayer Account API Reference](https://sldn.softlayer.com/reference/services/SoftLayer_Account/)
[SoftLayer Virtual_Guest API Reference](https://sldn.softlayer.com/reference/services/SoftLayer_Virtual_Guest/)

#### To search for a virtual guest by hostname

https://api.softlayer.com/rest/v3/SoftLayer_Account/getVirtualGuests/?objectFilter={"virtualGuests":{"hostname":{"operation":"WORKER_ID"}}}

where WORKER_ID is the ID of the worker, e.g. `kube-dal10-pa000000000000000000000000-w1` or `test-bltvf5d20g03tt6it3eg-gapaid20190-default-00000229`.

#### To search for a physical machine by hostname

https://api.softlayer.com/rest/v3/SoftLayer_Account/getHardware?objectFilter={"hardware":{"hostname":{"operation":"WORKER_ID"}}}

where ORDER_ID is the numeric order ID, which can be found using armada-xo, and WORKER_ID is the ID of the worker, e.g. `kube-dal10-pa000000000000000000000000-w1` or `test-bltvf5d20g03tt6it3eg-gapaid20190-default-00000229`.

#### To see details about a specific virtual worker

This query will show:

- The IMS Account ID of the worker
- The fully qualified domain name of the worker
- The CPU core count of the worker
- The total memory for the worker
- The Isolation (typeId) of the worker
- The ID of the image installed on the worker

https://api.softlayer.com/rest/v3/SoftLayer_Virtual_Guest/XXXXXXX?objectMask=mask[accountId,fullyQualifiedDomainName,maxCpu,maxMemory,typeId,blockDeviceTemplateGroup]

where XXXXXXXX is the numeric machine ID of the worker. This can be found using armada-xo, for example:

~~~json
{
"ProviderInstanceID": "virtual:11111111",
}
~~~

would mean you need to check https://api.softlayer.com/rest/v3/SoftLayer_Virtual_Guest/11111111?objectMask=mask[fullyQualifiedDomainName,blockDeviceTemplateGroup]

## Miscellaneous

### IBM Cloud classic infrastructure (SoftLayer) API Reference Links

[SoftLayer Virtual_Guest_Block_Device_Template_Group API Reference](https://sldn.softlayer.com/reference/services/SoftLayer_Virtual_Guest_Block_Device_Template_Group/)
[SoftLayer_Location](https://sldn.softlayer.com/reference/services/SoftLayer_Location/)

#### To see available public images, including their description and global identifier

https://api.softlayer.com/rest/v3/SoftLayer_Virtual_Guest_Block_Device_Template_Group/getPublicImages

#### To list all IBM Cloud classic Infrastructure datacenters

https://api.softlayer.com/rest/v3/SoftLayer_Location/getDatacenters

This query can be used to help determine the ID of a datacenter, this is useful when adding new IBM Cloud classic infrastructure zones into armada-config-pusher

## Further Information

Please contact the troutbridge squad in the #armada-cluster slack channel during UK office hours for further information.
