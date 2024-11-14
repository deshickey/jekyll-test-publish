---
layout: default
description: General troubleshooting info for RHCOS (CoreOS) on VPC
title: General debugging info for RHCOS (CoreOS) on VPC
service: hypershift
runbook-name: "General debugging info for RHCOS (CoreOS) on VPC"
tags:  hypershift, troubleshoot, debug, debugging, general, rhcos, coreos
link: /hypershift/rhcos-troubleshooting.html
type: Informational
grand_parent: Armada Runbooks
parent: Hypershift
---

Informational
{: .label }

## Overview
This runbook can be used to troubleshoot common issues for RHCOS (CoreOS) on VPC hosts. Since we support RHCOS with VPC and Hypershift, we will also reference Hypershift and VPC concepts.

## Detailed Information

### General RHCOS information

[Red Hat Enterprise Linux CoreOS](https://docs.openshift.com/container-platform/4.13/architecture/architecture-rhcos.html) (RHCOS) is a focused operating system for the Openshift Container Platform. Developed by Red Hat after acquiring [CoreOS](https://www.redhat.com/en/technologies/cloud-computing/openshift/what-was-coreos)

Key Features include:
- Based on RHEL: The underlying operating system consists primarily of RHEL components. The same quality, security, and control measures that support RHEL also support RHCOS. 
- Controlled immutability: Although it contains RHEL components, RHCOS is designed to be managed more tightly than a default RHEL installation.
- etc.


### Bootup process
[Ignition](https://docs.openshift.com/container-platform/4.13/architecture/architecture-rhcos.html#rhcos-about-ignition_architecture-rhcos) is the utility that is used by RHCOS to manipulate disks during initial configuration. 


### ROKS/Satellite
We currently support RHCOS in Satellite CoreOS enabled locations and in 4.15+ ROKS VPC clusters.

If this is a non-satellite cluster, you can check taht the cluster is hypershift via `@xo master <masterID> show=all` and looking for `HypershiftEnabled`.

For Satellite, the RHCOS ignition file can be generated with the IBMCloud CLI

```
ibmcloud sat host attach --location ${LOCATION_ID} --operating-system RHCOS
```

For ROKS, hosts are provisioned with an ignition file by armada microservices (cluster/riaas) The ignition file is generated from a Hypershift managed secret created in the `master-<clusterID>` namespace. A secret is created per `InstanceGroup` / Hypershift NodePool. 

e.g. 
```
❯ kubectl -n master-$CLUSTER get secret | grep user-data
user-data-cj8l4v110hgbfu8rp840-bf15b94-11bade3-331eedb7   Opaque                                2      5d17h
user-data-cj8l4v110hgbfu8rp840-bf15b94-6ce9a7c-331eedb7   Opaque                                2      5m46s
```

The RHCOS image used during provisioning is stored in a configmap per cluster in the `master` namespace

e.g

```
❯ kubectl -n master get cm | grep metadata-info
nodepool-metadata-info-cj8l4v110hgbfu8rp840                           4      8d
nodepool-metadata-info-cjec1eq10r9c51uckg4g                           4      25h
nodepool-metadata-info-cjec66g100sl9a4l52u0                           4      25h

❯ kubectl -n master get cm nodepool-metadata-info-cj8l4v110hgbfu8rp840 -o yaml | grep " os_image_id:"
  os_image_id: rhcos-413-92-202306140611-0-ibmcloud-x86-64
```

### Accessing Hosts

An ssh key can be supplied in the ignition file in a `passwd` section:

```
  "passwd": {
    "users": [
      {
        "name": "core",
        "sshAuthorizedKeys": [ "" ]
      }
    ]
  },
```

**NOTE:** Use the `core` user since this is a privileged user by default

The above method can be used in Satellite. If using IBM Cloud VPC for hosts, a public floating IP can be [attached](https://cloud.ibm.com/docs/vpc?topic=vpc-fip-working) to an instance in order to reach it publicly.

Another method for adding an ssh key is by adding a Kubernetes secret containing your ssh key and adding it to the `HostedCluster` resource in the `master` namespace

e.g.

```
❯ kubectl create secret generic <keyname> -n master --from-file=id_rsa.pub=<pathToPublicSSHKey>

❯ kubectl -n master explain hostedcluster.spec.sshKey
KIND:     HostedCluster
VERSION:  hypershift.openshift.io/v1beta1

RESOURCE: sshKey <Object>

DESCRIPTION:
     SSHKey references an SSH key to be injected into all cluster node sshd
     servers. The secret must have a single key "id_rsa.pub" whose value is the
     public part of an SSH key.

FIELDS:
   name	<string>
     Name of the referent. More info:
     https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
```

**NOTE:**: At certain points during ignition, the above keys may be removed. Once a node joins the cluster and is in `Ready` state, `oc debug node/<NodeName>` can be used to access the node.

Nodes created for Hypershift ROKS VPC clusters by armada-microservices live in the [IBM Cloud service accounts](https://github.ibm.com/alchemy-containers/armada-secure/search?q=G2_WORKER_SERVICE_ACCOUNT_ID) Access is needed to those accounts in order to view the hosts in VPC infrastructure.

### Common Node issues

#### Control Plane Operators

The general flow and pre-requisites for a node joining a cluster is as follows:

The top level Hypershift operator pods must be running, not logging errors for the hosted cluster, and successfully reconciling `HostedClusters` and `NodePools` in the `master` namespace (`"successfully reconciled"` messages in logs). This operator is in charge of reconciling `user-data-*` secrets necessary for generating igntion files and manages the `control-plane-operator`

```
❯ kubectl -n hypershift get po
NAME                        READY   STATUS    RESTARTS   AGE
operator-646f794c9b-9x67f   1/1     Running   0          5d18h
operator-646f794c9b-lgvmz   1/1     Running   0          5h11m
operator-646f794c9b-p7j8f   1/1     Running   0          5d18h
```

The `control-plane-operator` pod must be running, not logging errors, and successfully reconciling the `HostedControlPlane` resource (`"Successfully reconciled"` messages in logs). This operator manages the `ignition-server` (for 4.9 and 4.10 openshift clusters, the top level hypershift operator also manages the `ignition-server`)

```
❯ kubectl  -n master-$CLUSTER get po -l app=control-plane-operator
NAME                                      READY   STATUS    RESTARTS   AGE
control-plane-operator-6f956564b9-792hm   1/1     Running   0          15m
```

#### NodePool configuration

There must be a `NodePool` resource in the `master` namespace for each IBM Cloud `InstanceGroup`

```
❯ kubectl -n master get np -l clusterid=$CLUSTER --show-labels
NAME                                   CLUSTER                DESIRED NODES   CURRENT NODES   AUTOSCALING   AUTOREPAIR   VERSION   UPDATINGVERSION   UPDATINGCONFIG   MESSAGE   LABELS
cj8l4v110hgbfu8rp840-bf15b94-11bade3   cj8l4v110hgbfu8rp840                                   False                      4.13.5                                                 clusterid=cj8l4v110hgbfu8rp840,instancegroupid=cj8l4v110hgbfu8rp840-bf15b94-11bade3,workerpoolid=cj8l4v110hgbfu8rp840-bf15b94
cj8l4v110hgbfu8rp840-bf15b94-6ce9a7c   cj8l4v110hgbfu8rp840                                   False                      4.13.5                                                 clusterid=cj8l4v110hgbfu8rp840,instancegroupid=cj8l4v110hgbfu8rp840-bf15b94-6ce9a7c,workerpoolid=cj8l4v110hgbfu8rp840-bf15b94
```

This `NodePool` resource must contain the necessary spec configs that list configmap names
```
❯ kubectl -n master explain nodepool.spec.config
KIND:     NodePool
VERSION:  hypershift.openshift.io/v1beta1

RESOURCE: config <[]Object>

DESCRIPTION:
     Config is a list of references to ConfigMaps containing serialized
     MachineConfig resources to be injected into the ignition configurations of
     nodes in the NodePool. The MachineConfig API schema is defined here:
     https://github.com/openshift/machine-config-operator/blob/18963e4f8fe66e8c513ca4b131620760a414997f/pkg/apis/machineconfiguration.openshift.io/v1/types.go#L185
     Each ConfigMap must have a single key named "config" whose value is the
     JSON or YAML of a serialized Resource for
     machineconfiguration.openshift.io: KubeletConfig ContainerRuntimeConfig
     MachineConfig or ImageContentSourcePolicy

     LocalObjectReference contains enough information to let you locate the
     referenced object inside the same namespace.

FIELDS:
   name	<string>
     Name of the referent. More info:
     https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
```

All nodepools must contain 
```
    - name: ignition-config-97-ibm-master-endpoints-<clusterID>
    - name: ignition-config-97-ibm-machineconfig-base-<clusterID>
```

Satellite additionally needs 
```
    - name: ignition-config-98-ibm-machineconfig-satellite-<clusterID>
```

Roks additionally needs 
```
    - name: ignition-config-98-ibm-machineconfig-roks-<clusterID>
    - name: ignition-config-98-ibm-machineconfig-chrony-<clusterID>
    - name: ignition-config-98-ibm-machineconfig-private-<clusterID>
```

If these spec requirements do not exist, verify that the nodepool reconciler pods have not failed:
```
❯ kubectl -n master get po
NAME                                                  READY   STATUS      RESTARTS   AGE
ibm-nodepool-reconcile-<clusterID>-*     0/1     Completed   0          178m
```

In addition to these spec requirements, the mentioned configmaps must exist in the `master` namespace
```
❯ kubectl -n master get cm -l clusterid=$CLUSTER
NAME                                                                  DATA   AGE
ignition-config-97-ibm-machineconfig-base-<clusterID>        1      9d
ignition-config-97-ibm-master-endpoints-<clusterID>          1      9d
ignition-config-98-ibm-machineconfig-chrony-<clusterID>      1      9d
ignition-config-98-ibm-machineconfig-private-<clusterID>     1      9d
ignition-config-98-ibm-machineconfig-roks-<clusterID>        1      9d
ignition-config-98-ibm-machineconfig-satellite-<clusterID>   1      7d21h
nodepool-metadata-info-<clusterID>                           4      9d
```

Once a `NodePool` resource exists, the top level hypershift operator pods generate the `user-data-*` secrets in the `master-<clusterID>` namespace (where a secret exists per `InstanceGroup`)
```
❯ kubectl -n master-$CLUSTER get secret | grep user-data
user-data-<clusterID>-bf15b94-11bade3-8d0f497a   Opaque                                2      103m
user-data-<clusterID>-bf15b94-6ce9a7c-8d0f497a   Opaque                                2      103m
```

#### Ignition Server

The `ignition-server` pods must be running, not logging errors, and succesfully generating/caching/serving host payloads. 

e.g.

```
"Payload generated successfully" // for new payloads
"IgnitionProvider generated payload" // for new payloads
"Payload found in cache" // for cached payloads
```


This deployment serves the required payload to a worker node during provisioning

```
❯ kubectl -n master-$CLUSTER get po -l app=ignition-server
NAME                              READY   STATUS    RESTARTS   AGE
ignition-server-75547d787-jtk4m   1/1     Running   0          10m
ignition-server-75547d787-mj4kt   1/1     Running   0          10m
ignition-server-75547d787-x85zv   1/1     Running   0          10m
```

Additional verification steps for the ignition server include using the `user-data-*` secret to `curl` the ignition-server and retrieve the payload that an rhcos worker would use at bootup

e.g.

```
❯ kubectl -n master-$CLUSTER get secret user-data-cj8l4v110hgbfu8rp840-bf15b94-11bade3-8d0f497a -o jsonpath='{.data.value}'  | base64 -d
{"ignition":{"config":{"merge":[{"httpHeaders":[{"name":"Authorization","value":"Bearer <bearerTokenValue>"},{"name":"NodePool","value":"master/cj8l4v110hgbfu8rp840-bf15b94-11bade3"},{"name":"TargetConfigVersionHash","value":"8d0f497a"}],"source":"https://c100-e.containers.pretest.cloud.ibm.com:30461/ignition","verification":{}}],"replace":{"verification":{}}},"proxy":{},"security":{"tls":{"certificateAuthorities":[{"source":"data:text/plain;base64,<certData>=","verification":{}}]}},"timeouts":{},"version":"3.2.0"},"passwd":{},"storage":{},"systemd":{}}%


curl -vk -w "%{http_code}" -H "Authorization: Bearer <bearerTokenValue>" https://c100-e.containers.pretest.cloud.ibm.com:30461/ignition 
```

The curl should return a `200` http code and contents of the ignition payload.

#### Issues running ignition on node

If everything on the control plane looks good, [accessing the node](#accessing-hosts) and viewing `systemd` units with `journalctl -xe` should provide info into any failing `IBM` provided units (delivered in ignition payload)

A few of these services include 
```
          name: ibm-ext4-format.service
          name: ibm-locate-secondary-storage.service
          name: ibm-luks-encryption.service
          name: ibm-metadata-gatherer.service
          name: ibm-report-bootid.service
          name: ibm-at-init.service
          name: ibm-at-selinux-reconcile.service
```

The ignition file used at startup can also be found at `/etc/ignition-machine-config-encapsulated.json.bak` in order to verify the expected ignition config was utilized.

#### Issues with armada-microservices

Accessing [IBM Cloud Logs](https://cloud.ibm.com/observability/logging) and searching for the failing workerID or clusterID can provide useful information if there are issues with armada-microservices around provisioning VPC RHCOS hosts.
