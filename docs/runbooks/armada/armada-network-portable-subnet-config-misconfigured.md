---
layout: default
description: Debugging misconfigurations of the Cloud Provider VLAN IP Config Map
title: Runbook for Cloud Provider VLAN IP Config Map Misconfigured
service: armada-network-microservice
runbook-name: "Cloud Provider VLAN IP Config Map Misconfigured Runbook"
tags: alchemy, armada, armada-network-microservice
link: /armada/armada-network-portable-subnet-config-misconfigured.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# Cloud Provider VLAN IP Config Map Misconfigured Runbook

## Overview

**NOTE: IF THIS IS A FREE CLUSTER THIS CONFIG MAP WILL NOT BE GENERATED BECAUSE INGRESS/ LOAD BALANCER ARE NOT SUPPORTED FOR FREE CLUSTERS.**

**This runbook requires the user to know how to use `etcdctl` to list/get key values**

This issue appears when ingress and load balancer cannot be configured properly in a customer cluster. Symptoms will include:

- Customer not being able to use the load balancer properly
- No portable subnets appearing to belong to cluster (partial/non-existant `ibm-cloud-provider-vlan-ip-config` config map)
- Ingress service not behaving properly (relies on reserved IPs set by network)

Specifically this problem occurs when the cloud provider VLAN IP config map is not set properly (should contain all bound portable subnet information along with the reserved IPs).
The `bx cs subnets | grep <cluster-id>` command can be used to determine the portable subnets bound to the cluster.

## Example Alerts

Not available.

## Verification steps

- Verify the cloud provider VLAN IP config map is in proper format by running the `kubectl get cm ibm-cloud-provider-vlan-ip-config -n kube-system -o yaml` command.
  The config map should be in the following format (values will be different but have same structure). **Note:** You may only/also find the config map in the
  `ibm-system` namespace on older clusters.

```yaml
apiVersion: v1
data:
  cluster_id: 44b99585803b4ee99728d8dc9981a742
  reserved_private_ip: 10.131.28.254
  reserved_private_vlan_id: "1502187"
  reserved_public_ip: 169.57.65.30
  reserved_public_vlan_id: "1502189"
  vlanipmap.json: |-
    {
      "vlans": [
        {
          "id": "1502187",
          "subnets": [
            {
              "id": "1408393",
              "ips": [
                "10.131.28.250",
                "10.131.28.251",
                "10.131.28.252",
                "10.131.28.253"
              ],
              "is_public": false
            }
          ]
        },
        {
          "id": "1502189",
          "subnets": [
            {
              "id": "1462707",
              "ips": [
                "169.57.65.26",
                "169.57.65.27",
                "169.57.65.28",
                "169.57.65.29"
              ],
              "is_public": true
            }
          ]
        }
      ],
      "reserved_ips": [
        {
          "ip": "169.57.65.30",
          "subnet_id": "1462707",
          "vlan_id": "1502189",
          "is_public": true
        },
        {
          "ip": "10.131.28.254",
          "subnet_id": "1408393",
          "vlan_id": "1502187",
          "is_public": false
        }
      ]
    }
kind: ConfigMap
metadata:
  creationTimestamp: 2017-05-08T16:40:56Z
  name: ibm-cloud-provider-vlan-ip-config
  namespace: kube-system
  resourceVersion: "1266"
  selfLink: /api/v1/namespaces/kube-system/configmaps/ibm-cloud-provider-vlan-ip-config
  uid: 1bcb0964-340d-11e7-af64-6ec81206a62d
```

- There are a few things to look for in the config map.
    - If subnet ordering is enabled, there should be one subnet for every VLAN that has an active armada worker in it.
    - If there are both private and public VLANs (look at the is_public field), there should be at least one IP reserved from a private portable subnet and a public portable subnet.
    - The IPs section for each entry in the "vlans" key should contain a subset of the total IPs in the IP block of the subnet. Reserved IPs should be filtered from this block. In addition, some reserved IPs that are kept for SL should be filtered as well (broadcast address, network gateway, etc.)

If the config map does not look like it is in the proper format, see Investigation and Action. Otherwise, the problem lies outside of the armada-network microservice.

## Investigation and Action

If this config map was not generated properly, the following steps should be done to diagnose the problem. This will involve execing into armada-etcd and viewing keys.

**To enter armada-etcd**
- Log into a carrier master/worker in the proper env through ssh
- Run `kubectl -n armada get pods`
- Find a pod that has `armada-etcd` in the name and run `kubectl -n armada exec -it armada-etcd-<hash>-<hash> -- /bin/sh`


**FOR EACH DEPLOYED WORKER** `/:region/actual/clusters/:clusterid/workers/:workerid/state == deployed`
- Find the public/private VLAN the worker belongs to
    - Note the values of the following fields:
    - `/:region/actual/clusters/:clusterid/workers/:workerid/private_vlan`
    - `/:region/actual/clusters/:clusterid/workers/:workerid/public_vlan`

- Check that each of these VLANs have **at least 1 portable subnet** in the data model. Note XXXXXX_vlans can either be *public_vlans* or *private_vlans* depending on the VLAN type being checked.
    - List all keys beneath the portable subnet base key `/:region/actual/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/`.
        - **If the portable subnets key does not exist**, Check to see if proper keys set to trigger an order
    - Under this directory, you should see at least one guid.  `/:region/actual/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/:subnetguid/`
        - If no keys, Check to see if proper keys set to trigger an order
    - List all the keys under `/:region/actual/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/:subnetguid/`.
    - First check state `/:region/actual/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/:subnetguid/state`.
        - If **state equals created**, there should be:
            - `/:region/actual/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/:subnetguid/cidr` that contains the cidr for the subnet (ie. 192.168.0.0/24)
            - `/:region/actual/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/:subnetguid/subnet_id` that contains the actual SL subnet ID (ie. 4241242)
            - If those are **not set properly**, armada-cluster did not set the keys properly after completing the order. Please work with the cluster team to investigate the issue with them.
            - If those **are set properly**, the config map should contain information for the subnet. Scan the "vlans" key to see if the data is reflected in the config map (check for an entry with a matching subnet_id).
            - If an entry does not exist, armada-network did not properly reflect that data in the config map. Looking at the logs of armada-network is the best way to debug. Could be because the customer cluster master api server was not reachable by armada-network or a bug in the armada-network microservice.  
        - If **state contains an error** (will have error somewhere in the value of the key), armada-cluster failed to order the subnet. Check the following key `/:region/actual/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/:subnetguid/error_message`.
            - The error message will give more details about why it failed. Some common cases:
                - **Quota Reached**. This means that the maximum amount of subnets tied to a VLAN has been reached. In order for ordering to work, subnets need to be removed from Soft Layer. Also, ordering will not work for this cluster anymore **since the first order failed**. The user will have to manually add an existing subnet to the cluster in order to properly configure ingress and the load balancer.
            - If the error message is not one of these common cases, work with the armada-cluster team to understand why the order failed.

Repeat for all VLANs that have an active worker deployed in them.

- Check that the reserved IP is properly set (if only private vlans private_ip will be the only key set).
	- `/:region/desired/clusters/:clusterid/ingress/public_ip`
	- `/:region/desired/clusters/:clusterid/ingress/private_ip`
	- The value of this key should have the following format  `[{"ip":"<ip>","subnet_id":"<subnet_id>","vlan_id":"<vlan_id>"}]`
	- **If not set**, armada-network did not set the key properly in etcd.  This could be due to network errors, armada-etcd being down, or a bug in armada-network. Please look at the logs of armada-network to determine what the actual problem was.



### Common Actions

#### Check to see if proper key set to trigger an order

When doing this note the VLAN ID the subnet was expected to be ordered for and if the VLAN was private or public. Follow these steps:

- List all keys under `/:region/desired/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/` (Fill in the proper values for all fields)
- There should be at least one guid under the `/:region/desired/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/` path that holds the order info.
    - **If no GUID under the directory**, network did not successfully place the order. **This could be caused by a bug in armada-network or armada-etcd being unavailable when network went to place the order**. The best way to check this is through the logs of armada-network
- If at least one GUID exists, list keys under that GUID to see if the order was successfully placed. (`/:region/desired/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/:subnetguid/`)
    - The following keys should be set:
    - `/:region/desired/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/:subnetguid/ip_count`
    - `/:region/desired/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/:subnetguid/state=created`
    - **If those keys are not set**, the order request was not properly set. **This could be caused by a bug in armada-network or armada-etcd being unavailable when network went to place the order**. The best way to check this is through the logs of armada-network
- If those keys are set, the request to order a subnet was properly set in etcd.

#### Trace Logs In Armada Network

- Filter for logs containing the proper trigger key.
    - `/:region/actual/clusters/:clusterid/:XXXXXX_vlans/:vlanid/portable_subnets/:subnetguid/cidr`
    (with filled in values for each field)
- Look specifically for error logs to see if the error can be diagnosed
    - level = error in the log message
- The error log should say what the operation failed on (creating config map, contacting etcd, calling softlayer).
    - If Softlayer Calls are failing with 500 errors, it is likely either due
    to a soft layer outage or a rate limit issue. The problem is likely transient
    and will likely be successful on the next retry (~15 minutes).
     - If creating the config map failed due to timeouts, it is likely the network
     is down or in a degregaded state. The issue is likely transient and will be solved
     on the next retry (~15 minutes).
     - If etcd cannot be contacted, then armada-etcd is in a degregaded/ failed state
     and needs to be restarted. This lies outside the relm of armada network. It
     could also be a transient networking issue that will be solved on the next retry
     (~15 minutes).

If the issue is transient, the alert can be resolved. If the issue resides in
an external dependency (general networking, armada-etcd, customer master deployment (armada-deploy))
please escalate to the proper team.

For issues likely to be resolved on the next retry, you can snooze the alert until ~20 minutes
passes by and then check to see if it is resolved. Armada-network can tolerate outages in all it's dependencies
through its retry logic. Therefore, most issues that are not code related will be resolved on the
next try.

## Escalation Policy

If unable to resolve problems with the cloud provider VLAN IP config map, involve the `armada-network` squad:
  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channels: [#armada-dev](https://ibm-argonauts.slack.com/messages/armada-dev), [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)
