---
layout: default
title: armada-network - How to Block Cluster APIServer Completely
type: Troubleshooting
runbook-name: "armada-network - How to Block Cluster APIServer Completely"
description: "armada-network - How to Block Cluster APIServer Completely"
service: armada
link: /armada/armada-network-block-apiserver.html
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

We have seen a few customer cases where a cluster APIserver is being completely overwhelmed by calls to get large numbers of objects, and is crashing due to memory or CPU usage limits before any kubectl calls can even be made to reduce the number of objects.  In these cases, the best solution might be to lock the Calico datastore (if it is Calico traffic/requests causing the problem).  If that doesn't work, or if it isn't Calico traffic that is the problem, then we should try to temporarily block all network traffic to the cluster APIserver's public and private SE (if the cluster has both).

Once we have done one or both of those things, we can attempt to clean up the large number of objects or otherwise fix the cluster by running kubectl (or kubx-kubectl) commands from our control plane, and target one of the control plane cluster workers directly using the worker's private 10.x.x.x IP and the apiserver nodeport.  This runbook explains how to do that.

## Example Alerts

N/A

## Investigation and Action

If this is going to be done on a production tugboat or carrier, the first step is to create a prod train and get it approved.  Here is a sample prod train request:

```
Squad: <Squad that is performing this work>
Title: Temporarily block traffic to cluster <CLUSTERID>
Environment: <ENV>
Details: |
  In order to recover cluster <CLUSTERID>, we need to lock the Calico
  datastore, and if that doesn't work, we need to temporarily block
  all traffic to this cluster's apiserver.  We will do this using the
  instructions in the "How to Block Cluster APIServer Completely"
  runbook
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 8h
Ops: true
BackoutPlan: Unlock datastore and/or delete Calico policy that was created
```

For production, wait for the train to be approved, then start the train.

The next step is to try locking the calico datastore

### Lock the Calico Datastore

This can be done via this jenkins job: https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-calico-ipam-cleanup/

Run the jenkins job, passing in:
1. The cluster ID in the "Cluster" field
2. Choose the region the cluster is in from the dropdown
3. If this is a production cluster, put the prod train you created earlier in the PROD_TRAIN_REQUEST_ID field
4. Check the "SAFETY_OFF" box (just means you know you are running a command that modifies the cluster)
5. In the CUSTOM_CRUISER_OR_TUGBOAT_CALICOCTL_CMD field enter: datastore migrate lock

Here is an example job: https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-network-calico-ipam-cleanup/1373/parameters/

Once the job completes successfully, the calico datastore will be locked, which will mean no pod-networking pods will be allowed to start.  If this doesn't reduce the load on the apiserver to a manageable level, then you might as well unlock the calico datastore with that same job.  The easiest way is to choose to "Rebuild" the job you just ran, but change the CUSTOM_CRUISER_OR_TUGBOAT_CALICOCTL_CMD field to: datastore migrate unlock

If locking the datastore didn't reduce the load, the next step is to apply a Calico policy to the control plane cluster (tugboat or carrier) that the cluster master is on.

### Calico GlobalNetworkPolicy To Block All Traffic To a Cluster's Public and Private Service Endpoint:

This policy will be needed in the next steps below for both the carrier and tugboat managed cluster masters

```
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: block-all-to-<CLUSTERID> # replace with cluster's CLUSTERID
spec:
  applyOnForward: true
  ingress:
  - action: Deny
    destination:
      ports:
      - <APISERVER_NODEPORT> # replace with cluster apiserver nodeport
    protocol: TCP
  - action: Deny
    destination:
      ports:
      - <APISERVER_NODEPORT> # replace with cluster apiserver nodeport
    protocol: UDP
  preDNAT: true
  selector: ibm.role in { 'worker_public', 'worker_private' }
  order: 100
  types:
  - Ingress
```

You will also need the cluster's apiserver nodeport.  This can be found by running: `@xo cluster <CLUSTER_ID>`.  The apiserver nodeport is the 5 digit number at the end of the `ServerURL` entry.

### If the Cluster Master is Hosted on a Carrier

1. SSH to the carrier master node of the carrier that is hosting the cluster.
2. Create a text file called `block-all-to-<CLUSTERID>-policy.yaml` and copy the GlobalNetworkPolicy above into it (substituting `<CLUSTERID>` and `<APISERVER_NODEPORT>`)
3. Run: `/tmp/calicoctl apply -f block-all-to-<CLUSTERID>-policy.yaml` to apply the policy
4. Wait 60 seconds for the policy to be applied to all the worker nodes, then run: `kubx-kubectl <CLUSTERID> version`.  If the policy applied correctly, this will hang because the policy will block it
5. The policy will only prevent new connections. If you want to ensure that any existing connections to the apiserver are also disconnected, either delete the three apiserver pods for this cluster, or have the customer run a cluster master refresh (which will recycle the apiserver pods).
6. Run `kubx-kubectl <CLUSTERID> --get-kubeconfig > c.cfg` to get the cluster's admin kubeconfig
7. Edit that c.cfg file's "server:..." line by replacing whatever hostname is in that URL with `127.0.0.1`.  So the line will look like: `server: https://127.0.0.1:20504` (if 20504 is the apiserver nodeport)
8. Run `kubectl version --kubeconfig c.cfg` to verify that this new config file will work.  It should work because it is targeting the apiserver nodeport using the localhost interface and not the public or private network interface that is being blocked by the policy
9. When you are done using this c.cfg file MAKE SURE TO DELETE IT, since it contains the customer's admin cluster credentials.  See further cleanup steps below.


### If the Cluster Master is Hosted on a Tugboat

1. SSH to a carrier worker node on the carrier that is hosting the tugboat
2. Create a text file called `block-all-to-<CLUSTERID>-policy.yaml` and copy the GlobalNetworkPolicy above into it (substituting `<CLUSTERID>` and `<APISERVER_NODEPORT>`)
3. Run: `kubx-calicoctl <TUGBOAT_CLUSTERID> apply -f block-all-to-<CLUSTERID>-policy.yaml` to apply the policy.  You can get the tugboat's clusterid from armada-envs, for instance here: https://github.ibm.com/alchemy-containers/armada-envs/blob/master/prestage-dal10/carrier100.yml#L12
4. Wait 60 seconds for the policy to be applied to all the worker nodes
5. Run `invoke-tugboat <TUGBOAT_NAME>` (In some cases you might need to ssh into a different carrier worker to get invoke-tugboat to work, for instance for pre-production tugboats)
6. Run: `kubx-kubectl <CLUSTERID> version`.  If the policy applied correctly, this will hang because the policy will block it
7. The policy will only prevent new connections. If you want to ensure that any existing connections to the apiserver are also disconnected, either delete the three apiserver pods for this cluster, or have the customer run a cluster master refresh (which will recycle the apiserver pods).
8. Run `kubx-kubectl <CLUSTERID> --get-kubeconfig > c.cfg` to get the cluster's admin kubeconfig
9. Run `kubectl get nodes` to get a list of tugboat nodes, and pick one of the 10.x.x.x IPs (node names) to use to access the cluster's apiserver directly
10. Edit that c.cfg file's "server:..." line by replacing whatever hostname is in that URL with the 10.x.x.x IP of one of the tugboat's worker nodes.  So the line will look like: `server: https://10.200.200.200:20504` (if 20504 is the apiserver nodeport for the cluster, and 10.200.200.200 is the node you picked from the step above)
11. Run `ip a s eth0` on the carrier worker node you are on, and note the 10.x.x.x IP of the node (for instance, 10.140.28.143).  We will now need to create a Calico policy to allow traffic to the cluster's apiserver from that IP.
12. Exit from the `invoke-tugboat` shell (or go back to the other worker that you used in step 3 to apply the Calico policy to the tugboat).
13. Create the new Calico policy in a text file called: `allow-worker-to-<CLUSTERID>-policy.yaml` and put the following in it:

```
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: allow-worker-to-<CLUSTERID> # replace with cluster's CLUSTERID
spec:
  applyOnForward: true
  ingress:
  - action: Allow
    destination:
      ports:
      - <APISERVER_NODEPORT> # replace with cluster apiserver nodeport
    source:
      nets:
      - <10.x.x.x_carrier_worker_IP>/32 # replace with carrier worker IP from step above (must be appended with /32)
    protocol: TCP
  preDNAT: true
  selector: ibm.role == 'worker_private'
  order: 50
  types:
  - Ingress
```

14. Run: `kubx-calicoctl <TUGBOAT_CLUSTERID> apply -f allow-worker-to-<CLUSTERID>-policy.yaml` to apply the policy.
15. Back on the carrier worker that has the IP you got from `ip a s eth0` that you put into the `allow-worker-to-<CLUSTERID>` policy, run `kubectl --kubeconfig c.cfg --insecure-skip-tls-verify version` to verify that this edited config file will work now that the policy should allow traffic from the carrier worker node you are on.  Note that you will need to use the `--insecure-skip-tls-verify` flag on all the kubectl calls using this config file since it targets an IP address that is not in the server certificate
16. When you are done using this c.cfg file MAKE SURE TO DELETE IT, since it contains the customer's admin cluster credentials.  See further cleanup steps below.

### Cleanup Steps

When you are finished fixing up the cluster, make sure to do the following:

1. If you locked the calico datastore for the cluster, unlock it by choosing to "Rebuild" the jenkins job you ran to lock it, but change the CUSTOM_CRUISER_OR_TUGBOAT_CALICOCTL_CMD field to: datastore migrate unlock
2. Delete the c.cfg file (since it contains the admin credentials for the cluster
3. Delete any Calico policies you created above, using the same carrier worker and same `/tmp/calicoctl` or `kubx-calicoctl <CLUSTERID>` commands, except instead of using `apply -f <filename>` use `delete -f <filename>`
4. Complete the train request if this was done in production
5. If this is being done often, we should consider creating automation (jenkins job or similar) to do this.  These instructions are meant to be needed very rarely, just in extrordinary cases.

## Escalation Policy

N/A

## References

  * [Armada Architecture](https://github.ibm.com/alchemy-containers/armada/tree/master/architecture)
  * [kubectl](https://kubernetes.io/docs/user-guide/kubectl/)
