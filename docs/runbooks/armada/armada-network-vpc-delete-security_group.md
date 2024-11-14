---
layout: default
description: "[Troubleshooting] Armada - VPC Cluster's Default Security Group is Deleted"
title: "[Troubleshooting] Armada - VPC Cluster's Default Security Group is Deleted"
runbook-name: "[Troubleshooting] Armada - VPC Cluster's Default Security Group Deleted"
service: armada
tags: armada, kubernetes, security, network, vpc
link: /armada/armada-network-vpc-delete-security_group.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
Default Security Group in IKS VPC Clusters

A security group is created in the customer's account by IKS code when an IKS cluster is created in a VPC.  The security group's name is "kube-___clusterID___".  The cluster will not work properly if the security group is deleted. For example, cluster workers cannot be replaced, and new workers cannot be added to the cluster if the security group is deleted.  However, existing workers will continue to function.

A reference to the secruity group is added to each worker as it is created.  Since there is a reference to the security group, the user should not be able to delete the security group using the cloud user interface or via "ibmcloud is security-group-delete".  This is a bug in LBaaS code that is being be fixed.  Until the fix is pushed to production the user will be able to delete the security group.

## Example Alerts?
Does not apply

## Investigation and Action
Options for a Cluster with a Deleted Security Group

### 1. Replace the cluster
1. Create a new cluster to replace the cluster with the deleted security group.  A default security group will be created for the new cluster.
2. Migrate the workload to the new cluster.
3. Delete the old cluster.

### 2. Clear the Cluster, Force IKS Code to Create a New Security Group
All references to the deleted security group must be removed before it can be replaced by IKS code.  In this option we remove all references by deleting all of the workers in the cluster.

1. Use ibmcloud commands or the cloud user interface to remove all workers from the cluster.  For example, from a terminal session you can list the workers, then run the "worker rm" command for each worker in the cluster.
```bash
$ ibmcloud ks workers --cluster <clusterID>
$ ibmcloud ks worker rm --cluster <clusterID> --worker <workerID>
```

2. Clear the security group reference in the model -- once all workers are removed then the data model for the cluster must be updated since it still contains a reference to the security group.
   - Only conductors or SREs have enough authority to adjust the data model.  The user cannot change it and IKS development cannot not change it.
   - The conductor/sre will
      - access the carrier-master for the cluster
      - armada-data get Cluster -pathvar ClusterID=___clusterID___ -field IKSSecurityGroup
      - armada-data delete Cluster -pathvar ClusterID=___clusterID___ -field IKSSecurityGroup
      - armada-data get Cluster -pathvar ClusterID=___clusterID___ -field IKSSecurityGroup
3. Refresh the master which will force the IKS code to re-create the default security group.  The customer will use "ibmcloud ks cluster master refresh --cluster ___clusterID___" to refresh the master.
4. Wait at least 30 minutes for the master refresh to finish.
5. The customer can now add workers back to the cluster.  For example, "ibmcloud ks worker-pool resize" can be used to create new workers.

### 3. Create a New Security Group, Force IKS Code to Use It
The customer can create a new security group which will replace the IKS default security group.  The rules added to the new security group must match those of an IKS security group.  Once created, a refrence to the security group is added to the data model and then the workers are replaced.  This procedure results in a rolling update of the workers.  The cluster will continue to function as the workers are replaced.

Except where indicated the following instructions are run by the customer in a terminal session.  The customer's credentials must be established in the terminal session so they are able to run ibmcloud and kubectl commands.

1. Use ibmcloud commands to record the vpc identifier and cluster identifier
```bash
$ ibmcloud is vpcs
$ ibmcloud ks clusters
```

2. Create the new security group.  Inputs are the new group's name, vpc and resource group of the cluster.  Note the name used in this example follows the naming
convention of the security group that was deleted.  It is kube-___clusterID___-2.  The resource group of the cluster must be used in the command.
```bash
$ ibmcloud is security-group-create kube-<clusterID>-2 <vpcID> --resource-group-name <clusterResourceGroupID>
$ ibmcloud is sgs | grep kube-
```

3. Add rules to the security group so they are identical to those of the security group that was deleted.  Note the first command will fetch the pod subnet from the cluster.  That value is used for the "--remote" parameter of the last two commands.  An example pod subnet is "172.17.0.0/18".
```bash
ibmcloud ks cluster get --cluster <clusterID> | grep 'Pod Subnet'
ibmcloud is security-group-rule-add <securityGroupID> inbound tcp --port-min 30000 --port-max 32767
ibmcloud is security-group-rule-add <securityGroupID> inbound udp --port-min 30000 --port-max 32767
ibmcloud is security-group-rule-add <securityGroupID> outbound all --remote <podSubnetFromFirstCommand>
ibmcloud is security-group-rule-add <securityGroupID> inbound all --remote <podSubnetFromFirstCommand>
```
4. Retrieve the details of the new security group. They are needed when creating the reference that is added to the data model.  Record the security group's name, ID and CRN.  Here is an example:
```bash
ibmcloud is sg <securityGroupID>

Getting security group r134-9ccad360-211b-40ea-bfc5-a2abafb6118e under account xxxxx as user xxxxxx ...

ID               r134-9ccad360-211b-40ea-bfc5-a2abafb6118e
Name             kube-c602oj420c02vdi45af0-2
CRN              crn:v1:staging:public:is:us-south:a/45ee9c7e3eac4724b4748f5bdee9a814::security-group:r134-9ccad360-211b-40ea-bfc5-a2abafb6118e
Created          2021-11-09T15:29:25-06:00
VPC              ID                                          Name
                 r134-4b358aa1-fe13-4b75-8968-ebb6a65ee794   my-vpc-gen2

Resource group   ID                                 Name
                 f5325a5ef42145c193263ccf9dc966f8   Default


Rules
ID                                          Direction   IP version   Protocol                        Remote
r134-b3f6f5f7-246c-4728-bcc7-3f6200ee5fdd   inbound     ipv4         tcp Ports:Min=30000,Max=32767   0.0.0.0/0
r134-eeeed963-706e-4a28-9aef-38895a2f7734   inbound     ipv4         udp Ports:Min=30000,Max=32767   0.0.0.0/0
r134-bfe25499-a574-4ca3-9d76-5496b301d5e2   outbound    ipv4         all                             172.17.0.0/18
r134-bbab471b-e412-4ff2-bd59-12c1ac8527e4   inbound     ipv4         all                             172.17.0.0/18

Targets
ID   Name   Resource type   Server ID   Server type
```

5. Create the security group identifier string that is added to the data model.
```
Prototype:
   {"id":"<securityGroupID>","crn":"<crn from security group>","name":"<security-group-name>"}

Example:
   {"id":"r134-9ccad360-211b-40ea-bfc5-a2abafb6118e","crn":"crn:v1:staging:public:is:us-south:a/45ee9c7e3eac4724b4748f5bdee9a814::security-group:r134-9ccad360-211b-40ea-bfc5-a2abafb6118e","name":"kube-c602oj420c02vdi45af0-2"}
```

6. Update the security group reference in the model using the string created in the previous step.
   - Only conductors or SREs have enough authority to adjust the data model.  The user cannot change it and IKS development cannot not change it.
   - The conductor/sre will
      - access the carrier-master for the cluster
      - armada-data get Cluster -pathvar ClusterID=___clusterID___ -field IKSSecurityGroup
      - armada-data set Cluster -field IKSSecurityGroup --pathvar ClusterID=___clusterID___ -value ' ___identifierFromPreviousStep___ '
      - armada-data get Cluster -pathvar ClusterID=___clusterID___ -field IKSSecurityGroup
      - For example:
```
armada-data set Cluster -field IKSSecurityGroup --pathvar ClusterID=c602oj420c02vdi45af0 -value '{"id":"r134-9ccad360-211b-40ea-bfc5-a2abafb6118e","crn":"crn:v1:staging:public:is:us-south:a/45ee9c7e3eac4724b4748f5bdee9a814::security-group:r134-9ccad360-211b-40ea-bfc5-a2abafb6118e","name":"kube-c602oj420c02vdi45af0-2"}'
```      

7. Replace the workers of the cluster -- the customer can now replace the workers in the cluster.  When new workers are added they will use the new security group.  Workers should be added one at a time so the cluster continues to work while workers are being replaced.

8. The conductor or SRE who completed step 6 should update update GHE item https://github.ibm.com/alchemy-containers/armada-network/issues/5604 with the cluster ID.

## Escalation Policy
Does not apply

## References

- [VPC Security Groups](https://cloud.ibm.com/docs/containers?topic=containers-vpc-network-policy#security_groups)


