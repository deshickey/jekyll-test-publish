---
layout: default
description: Steps to switch from one CSE to another
title: Steps to switch from one CSE to another
service: armada-infra
runbook-name: "Steps to switch from one CSE to another"
tags:  armada, carrier, tugboat, cse
link: /armada/sre-switch-cse-steps.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook describes the general steps to take when we need to switch a CSE that a tugboat or legacy carrier is using in our IKS/ROKS classic control plane.  These steps are only applicable to two types of control plane clusters:
1. Tugboats that are hosting cluster masters, so ones with a tugboat_purpose of `CustomerWorkloadOpenshift` or  `CustomerWorkloadCruiser` in https://github.ibm.com/alchemy-containers/armada-envs/)
2. Legacy Carriers since they also host old IKS and ROKS cluster masters

One examples of when this is needed is when CSE was created in a different region or zone than is ideal.  See https://github.ibm.com/alchemy-containers/armada-network/issues/9220 for information about CSEs for a Sao Paulo tugboat that were originally created in Dallas, and needed to be switched to ones in Sao Paulo.

## Detailed Information

Depending on what workload the tugboat or legacy carrier is running, some of the steps below might not be necessary.  Each step will try to explain why and when it is needed.

## Steps to Switching to a Different CSE to Another

In general these steps should be followed in order.

### Gather Data For Tugboat or Carrier Involved

In order to decide what steps are needed in what order we need to determine whether this control plane cluster currently hosts any VPC cluster masters.  This can be done using a XO query: `@xo sqlQuery region=us-east SELECT cluster.cluster_id, cluster.actual_state, default_provider, carrier from cluster where actual_state <> 'deleted' and carrier = 'prod-wdc04.carrier100' and default_provider = 'g2'`.  Make sure to specify the correct `region` and `carrier`.  If the query returns no cluster, then verify you had the correct parameters by removing the `and default_provider = 'g2'` and ensuring some clusters are returned.

### Create the New CSE

I don't know any details about this, the SREs can add details if they would like to.

Important Notes
* Do NOT ask Netint to change the tugboat or carrier DNS entries to use these CSEs yet
* Do NOT merge any armada-secure changes yet

### Test the New CSE

Make sure that the new CSE is properly configured to forward traffic on to the right tugboat or legacy carrier.  One way to do this is just to use curl commands to connect through the new CSE to the tugboat/carrier.  Here is how to do that, with a recent example from testing a new CSE for prod-mad02-carrier1 (a legacy carrier).

1. Find two clusters with masters on this control plane cluster you have the new CSE for, that have private service endpoint enabled and no CBR rules and no private service endpoint allowlists.  One way to do this is to use an a query in XO, something like: `@xo sqlQuery region=us-east SELECT * from cluster where actual_state <> 'deleted' and carrier = 'prod-wdc04.carrier100'`.  Look for a cluster in the data that is returned that has a private service endpoint.  If the cluster is private service endpoint only then the data will have a URL with "private" in it, like: `https://cX[XX].private.<REGION>.containers.cloud.ibm.com:YYYYY`.  If you don't see any of these in the data, then look for a VPC cluster by finding one with `g2` in the data as the DefaultProvider since those always have a private service endpoint.  If you still can't find any then you will need to look up the cluster details for some of these clusters using XO until you find two that have a `ActualPrivateServiceEndpointURL` (you can do this in the next step)
2. Verify that the two clusters you selected do not have CBR rules and do not have private service endpoint allowlist enabled.  This can be done using `xo cluster <CLUSTERID> show=all` and verifying that:
    - `ActualCSEACLList` and `DesiredCSEACLList` are both null
    - `ActualContextBasedRestrictionEventID` and `DesiredContextBasedRestrictionEventID` are both null
    - When you verify that the cluster meets the criteria above, note the `ActualPrivateServiceEndpointURL` because that is one of the URLS you will curl in the tests below.  The two clusters we tested for the new CSEs for prod-mad02-carrier1 were
        - cg8u79km0rej0701qcog - https://c1.private.eu-es.containers.cloud.ibm.com:25713
        - cg9uvemm043co39s2t70 - https://c1.private.eu-es.containers.cloud.ibm.com:24369
3. Get the new CSE IPs (that have not yet been switched to in the DNS records).  For this you will need the CSE name(s) so you can use `dig` to look up the corresponding IPs.  For prod-mad02-carrier1 we were replacing all 4 CSEs (the multi-zone one with three IPs, as well as the three single-zone CSEs), so that is the example below.  If you are only replacing one CSE, or if this is a single zone region with only one CSE, then you will just need to look up the single CSE that was created.

```
laptop ~ dig +short prod-eu-es-carrier1.eu-es.serviceendpoint.cloud.ibm.com
166.9.94.55
166.9.95.55
166.9.96.54
laptop ~ dig +short prod-mad02-carrier1.eu-es.serviceendpoint.cloud.ibm.com
166.9.94.54
laptop ~ dig +short prod-mad04-carrier1.eu-es.serviceendpoint.cloud.ibm.com
166.9.95.54
laptop ~ dig +short prod-mad05-carrier1.eu-es.serviceendpoint.cloud.ibm.com
166.9.96.53
laptop ~
```

4. Correlate the IPs with the existing hostnames (that have the old IPs in DNS entries currently).  To do this correlation note that the multi-zone CSE will use the form cX for legacy carrier or cXXX for tugboat, while the single zone CSEs will use the cX-N-1 or cXXX-N-1 where the N is 1, 2, or 3 corresponding to the zone.  This is what we will be asking Netint to change the DNS entries to after we confirm the CSEs work via these tests:

```
c1.private.eu-es.containers.cloud.ibm.com: 166.9.94.55, 166.9.95.55, and 166.9.96.54
c1-1-1.private.eu-es.containers.cloud.ibm.com: 166.9.94.54
c1-2-1.private.eu-es.containers.cloud.ibm.com: 166.9.95.54
c1-3-1.private.eu-es.containers.cloud.ibm.com: 166.9.96.53
```

5. Curl the cluster's apiservers using the existing CSEs that need to be replaced just to make sure the clusters are responding and the apiserver ports you gathered above are valid.  Here are those commands. Make sure to set `APISERVER_PORT_1` and `APISERVER_PORT_2` to the ports you found in step 2 above, and set `CARRIER` to the proper `cX` for legacy carriers or `cXXX` for tugboats and set `REGION` to the correct region part of the URL found in step 2
  * Multizone CSE: `for i in $(seq 5); do for port in $APISERVER_PORT_1 $APISERVER_PORT_2; do echo -n "Destination port $port: "; curl -k --connect-timeout 5 https://$CARRIER.private.$REGION.containers.cloud.ibm.com:$port/version -o /dev/null -s -w "%{http_code}" || echo ": TIMEOUT"; echo; echo; done; echo; echo; done`

  * Single zone CSEs (not applicable for single zone regions such as prod-sao01-carrier101):
      * `for cse in 1 2 3; do for port in $APISERVER_PORT_1 $APISERVER_PORT_2; do echo "Destination cse=$cse and port=$port"; curl -k --connect-timeout 5 https://$CARRIER-$cse-1.private.$REGION.containers.cloud.ibm.com:$port/version -o /dev/null -s -w "%{http_code}" || echo ": TIMEOUT"; echo; echo; done; done`

6. Assuming the checks above of the old CSEs worked as expected and returned 200 HTTP codes for all the calls, now check the new CSEs by using their new IPs that you obtained in steps 3 and 4 above.  The `APISERVER_PORT_N`, `CARRIER`, and `REGION` will be the same, but in addition, you will need to set the following (or a subset of these if you are only changing a single CSE)

```
export MULTIZONE_CSE_NEW_IP_1=166.9.94.55
export MULTIZONE_CSE_NEW_IP_2=166.9.95.55
export MULTIZONE_CSE_NEW_IP_3=166.9.96.54

export SINGLEZONE_CSE_NEW_IP_1=166.9.94.54
export SINGLEZONE_CSE_NEW_IP_2=166.9.95.54
export SINGLEZONE_CSE_NEW_IP_3=166.9.96.53
```

Multizone CSE:
`for addr in $MULTIZONE_CSE_NEW_IP_1 $MULTIZONE_CSE_NEW_IP_2 $MULTIZONE_CSE_NEW_IP_3; do for port in $APISERVER_PORT_1 $APISERVER_PORT_2; do echo "Destination $addr:$port"; curl -k --connect-timeout 5 https://$CARRIER.private.$REGION.containers.cloud.ibm.com:$port/version --resolve $CARRIER.private.$REGION.containers.cloud.ibm.com:$port:$addr -o /dev/null -s -w "%{http_code}" || echo ": TIMEOUT"; echo; echo; done; echo; echo; done`

Single zone CSEs (not applicable for single zone regions such as prod-sao01-carrier101)::
`for port in $APISERVER_PORT_1 $APISERVER_PORT_2; do echo "Destination $SINGLEZONE_CSE_NEW_IP_1:$port"; curl -k --connect-timeout 5 https://$CARRIER-1-1.private.$REGION.containers.cloud.ibm.com:$port/version --resolve $CARRIER-1-1.private.$REGION.containers.cloud.ibm.com:$port:$SINGLEZONE_CSE_NEW_IP_1 -o /dev/null -s -w "%{http_code}" || echo ": TIMEOUT"; echo; echo; done`

`for port in $APISERVER_PORT_1 $APISERVER_PORT_2; do echo "Destination $SINGLEZONE_CSE_NEW_IP_2:$port"; curl -k --connect-timeout 5 https://$CARRIER-2-1.private.$REGION.containers.cloud.ibm.com:$port/version --resolve $CARRIER-2-1.private.$REGION.containers.cloud.ibm.com:$port:$SINGLEZONE_CSE_NEW_IP_2 -o /dev/null -s -w "%{http_code}" || echo ": TIMEOUT"; echo; echo; done`

`for port in $APISERVER_PORT_1 $APISERVER_PORT_2; do echo "Destination $SINGLEZONE_CSE_NEW_IP_3:$port"; curl -k --connect-timeout 5 https://$CARRIER-3-1.private.$REGION.containers.cloud.ibm.com:$port/version --resolve $CARRIER-3-1.private.$REGION.containers.cloud.ibm.com:$port:$SINGLEZONE_CSE_NEW_IP_3 -o /dev/null -s -w "%{http_code}" || echo ": TIMEOUT"; echo; echo; done`

Ensure that these tests in step 6 return HTTP 200 codes indicating the new CSEs are working


### Update armada-secure

The next step is to add the CSE(s) to armada-secure in the following places:
1. The service-endpoint config
    - https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/<REGION>/service-endpoint-config.yaml in the `spoke-service-endpoint-map.json`
    - This allows the network microservice code to update this new CSE with CSE ACL rules that implement CBR rules or private service endpoint allowlist rules that customers add to their clusters
2. armada-info-configmap specific to this control plane cluster
    - https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/<REGION>/spokes/prod-<DATACENTER>-<CARRIER>/armada-info.yaml in the MASTER_PRIVATE_ENDPOINTS_CSE list
    - This allow Prometheus to probe and monitoring
    - Once this change is promoted to production, it still won't be picked up until the armada-ops-alert-conf job is re-run to pick changes from the MASTER_PRIVATE_ENDPOINTS_CSE list (see https://ibm-cloudplatform.slack.com/archives/C54H08JSK/p1715279628816229?thread_ts=1713917006.172549&cid=C54H08JSK for details)
3. (ONLY IF THE CONTROL PLANE CLUSTER DOES NOT HAVE ANY VPC CLUSTER MASTERS ON IT) The service-endpoint config
    - https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/<REGION>/service-endpoint-config.yaml in the `private-se-info.json`
    - This specifies which CSEs the VPE Gateway for cluster masters should route traffic to for VPC clusters
    - If there are currently no VPC cluster masters on this control plane then it is safe to change this now
    - If there are VPC cluster masters on this control plane, but none of them use CSE ACLs (either for CBR rules or private service endpoint allowlist), then it is also safe to change this now
    - If there are any VPC cluster masters on this control plane that use CBR rules or private service endpoint allowlist, then do NOT change this now
        - If you change this now, it will cause these clusters (within a few hours) to switch to use the new CSE, which might not have the same CSE ACL rules as the old CSE.
        - This could allow attackers to access the cluster master from IP addresses that are not in the customer's CBR rules or private service endpoint allowlist
        - This can be changed in a future step, once the CSE ACLs are known to be in sync and both being updated when the customer makes a rule change

A few example PRs are:
1. Change single zone region prod-sao01-carrier101 CSE to one that is in sao01: https://github.ibm.com/alchemy-containers/armada-secure/pull/8070
    - Since there were no VPC clusters on carrier101, all three changes were made in this PR
2. Change multi zone region prod-mad020-carrier1 CSEs to ones that are in Madrid: https://github.ibm.com/alchemy-containers/armada-secure/pull/8073
    - Same situation, since there were no VPC clusters on carrier101, all three changes were made in this PR


### Synchronize the CSE ACLs

It is important that the CSE ACLs for the new CSE match the ones on the old CSE BEFORE we switch over any existing clusters.  There are two types of CSE ACLs that IKS/ROKS uses on these control plane CSEs:

1. Static CSE ACLs.  These allow only specific IKS/ROKS control plane subnets to access these monitoring/alerting node ports and block all other source IPs from accessing these ports:
    - Grafana port:      30300
    - Prometheus port:   30794
    - Alertmanager port: 30903

I don't know how the control plane subnets that can access these are determined, but they seem to be mostly identical across all regions, with only a few IPs different between regions

2. CSE ACLs for individual cluster masters that are only present if the cluster owner either enabled the private service endpoint allowlist feature, or enabled CBR rules for the private network access to their cluster masters, or both.  These restrict access to the following nodeports:
    - Cluster apiserver port: Only allows traffic from the cluster worker IPs/subnets and then any IPs the customer specifies in their CBR or allowlist rules
    - Cluster Openvpn or Konnectivity server port: Only allows traffic from the cluster worker IPs/subnets
    - Cluster Oauth server port (only ROKS): Only allows traffic from the cluster worker IPs/subnets and then any IPs the customer specifies in their CBR or allowlist rules
    - Cluster Ignition server port (only ROKS VPC with CoreOS workers): Only allows traffic from the cluster worker IPs/subnets

After the armada-secure PR created for the previous step, we need to synchronize the CSE ACLs so that the new CSE has the same rules as the old CSE.  There is some automation that the SRE team has that will do this that is described here: https://ibm-argonauts.slack.com/archives/C72SBC64X/p1714582071001559?thread_ts=1707841905.182629&cid=C72SBC64X.  It looks like an issue needs to be created similar to this: https://github.ibm.com/alchemy-conductors/carrier-service-endpoints/issues/695 (maybe with the CSE ACL list copied in to this GHE manually from what is on the old CSE).  Then the addACL jenkins job needs to be run (like this: https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-CSE-operations-pipeline/1054/parameters/) which points to the GHE for the ACLs to add?

Once this automation is run and the CSE ACLs are confirmed to be the same, then they should stay in sync because any changes made to the CSE ACLs for the type 2 rules above (from CBR rule and private service endpoint allowlist changes) should be made to both the old and new CSEs.


### Update DNS

The next step is to update the DNS entries for this control plane so the private URLs point to the new CSEs.  Here are some example issues where this is done:

1. Change single zone region prod-sao01-carrier101 entries to one that is in sao01: https://github.ibm.com/alchemy-netint/firewall-requests/issues/5577
2. Change multi zone region prod-mad020-carrier1 entries to ones that are in Madrid: https://github.ibm.com/alchemy-netint/firewall-requests/issues/5573

After this, it is probably a good idea to re-run the tests from step 5 and run these tests using the `-vvv` curl option to verify that the new IPs are being used and that the new CSEs are working properly

Also, if this control plane cluster is still being used for new cluster masters, it would be good to:
1. Create a new classic cluster, preferably a private service endpoint only cluster, and see that its master is put on this control plane cluster
2. Verify the new cluster workers come up successfully, which if it is a private service endpoint only cluster will confirm that the CSE is working properly because the worker to master connection will have to go through the new CSEs


### Update armada-secure

If the first update to armada-secure did not include adding the new CSE IPs into the private-se-info.json because the control plane cluster had VPC cluster masters that were using CSE ACLs to protect the cluster master, then that armada-secure change should be made now in a separate PR. Edit the `private-se-info.json` entry in https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/<REGION>/service-endpoint-config.yaml to specify the new multi zone CSE IPs (or the only CSE IP for single zone regions like prod-sao01-carrier101).  Get this PR merged and rolled out to all production regions.

When a VPC cluster is first created, these IPs in `private-se-info.json` are put into the Ghost information for this cluster, in the VPE Extension data section.  Then a VPE Gateway is created using that VPE Extension data in Ghost for the cluster, routing traffic to these CSE IPs.  The VPC cluster workers then use this VPE Gateway to connect to the cluster master (which routes traffic to the specified CSE IPs).  When these IPs are changed in armada-secure, the VPE Gateway is not immediately updated to use the new CSE IPs.  Recently the VPE team implemented something that they say will update the routing to use these new IPs within about 12 hours of them being changed, however we have not tested this scenario since this change was made.  So it is possible this routing to the new CSE might not change just because the CSE IPs are changed in armada-secure.

Once this change is promoted to production in the region the new CSEs are in, if this control plane cluster is still being used for new cluster masters, it would be good to:
1. Create a new VPC cluster, preferably a private service endpoint only cluster, and see that its master is put on this control plane cluster
2. Once the cluster has been created, run `@xo queryGhostClusters <ACCOUNTID> cluster=<CLUSTERID> region=<REGION>` to get the Ghost data for the VPE Gateway for the cluster master
- Account ID and region can be found from `@xo cluster <CLUSTERID>` (you will need to convert the `ActualDatacenterCluster` string to the region that tugboat/carrier is in)
- Example is: `@xo queryGhostClusters bdd96d55c7f54798a6b9a1e1bedec37c cluster=cqg1plfs04uh1nlmk8r0 region=ap-south`
- Verify that the in the `"extensions": { "virtual_private_endpoints": {` part of this Ghost data that the `endpoints` list matches the new CSE IPs from armada-secure
3. Verify the new cluster workers come up successfully, which if it is a private service endpoint only cluster will confirm that the CSE is working properly because the worker to master connection will have to go through the new CSEs (via the VPE Gateway)


### Disable and Remove Old CSE

1. Work with CSE team to validate that no traffic is going through the old CSE
2. Ask the VPE team (maybe in #ibmcloud-vpe) if they can verify that no existing VPE Gateways in that region are still sending traffic to any of the old CSEs.  If any are still using the CSEs, they will need to be updated/refreshed so that they use the current data that is in Ghost.
3. Update armada-secure to remove references to the old CSE (so CSE ACLs don't get updated and we stop monitoring and alerting on it)
    - https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/<REGION>/service-endpoint-config.yaml in the `spoke-service-endpoint-map.json`
    - https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/<REGION>/spokes/prod-<DATACENTER>-<CARRIER>/armada-info.yaml in the MASTER_PRIVATE_ENDPOINTS_CSE list
4. Work with CSE team to disable and delete this CSE
