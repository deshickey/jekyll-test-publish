---
layout: default
description: How to troubleshoot armada-ops-prometheus HA 
title: armada-ops - How to troubleshoot armada-ops-prometheus HA 
service: armada
runbook-name: "armada-ops - How to troubelshoot armada-ops-prometheus HA" 
tags: alchemy, armada, node, down, prometheus, HA, statefulset
link: /armada/armada-ops-prometheus-ha-troubleshooting.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to trouleshoot with issues for armada-ops-prometheus HA StatefulSet. Prometheus HA (High Availability) is using the StatefulSet instead of Deployment to acquire PVC per each prometheus worker node to bring prometheus instances up. 


## Investigation and Action

### Prometheus pod is not able to be scheduled
---

armada-ops-prometheus HA deployed in MZR (most tugboats) should have 3 dedicated worker nodes under `prometheus` label. Each worker node IP can be found using kubectl command. 

```
[prod-dal10-carrier105] chaseo@prod-dal10-carrier2-worker-1002:~$ kubectl get node --show-labels | grep prometheus
10.220.9.169    Ready                      <none>   453d     v1.22.12+IKS   arch=amd64,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=b3c.32x128.encrypted,beta.kubernetes.io/os=linux,dedicated=prometheus,failure-domain.beta.kubernetes.io/region=us-south,failure-domain.beta.kubernetes.io/zone=dal13,ibm-cloud.kubernetes.io/encrypted-docker-data=true,ibm-cloud.kubernetes.io/external-ip=169.62.175.14,ibm-cloud.kubernetes.io/ha-worker=true,ibm-cloud.kubernetes.io/iaas-provider=softlayer,ibm-cloud.kubernetes.io/internal-ip=10.220.9.169,ibm-cloud.kubernetes.io/machine-type=b3c.32x128.encrypted,ibm-cloud.kubernetes.io/node-local-dns-enabled=true,ibm-cloud.kubernetes.io/os=REDHAT_7_64,ibm-cloud.kubernetes.io/region=us-south,ibm-cloud.kubernetes.io/sgx-enabled=false,ibm-cloud.kubernetes.io/worker-id=kube-bn08l8td0bfjd8d8kqkg-produssouth-dedicat-00006331,ibm-cloud.kubernetes.io/worker-pool-id=bn08l8td0bfjd8d8kqkg-d4b4c06,ibm-cloud.kubernetes.io/worker-pool-name=dedicated-prometheus,ibm-cloud.kubernetes.io/worker-version=1.22.12_1566,ibm-cloud.kubernetes.io/zone=dal13,kubernetes.io/arch=amd64,kubernetes.io/hostname=10.220.9.169,kubernetes.io/os=linux,node.kubernetes.io/instance-type=b3c.32x128.encrypted,privateVLAN=2727220,publicVLAN=2727222,topology.kubernetes.io/region=us-south,topology.kubernetes.io/zone=dal13
10.221.35.107   Ready                      <none>   453d     v1.22.12+IKS   arch=amd64,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=b3c.32x128.encrypted,beta.kubernetes.io/os=linux,dedicated=prometheus,failure-domain.beta.kubernetes.io/region=us-south,failure-domain.beta.kubernetes.io/zone=dal10,ibm-cloud.kubernetes.io/encrypted-docker-data=true,ibm-cloud.kubernetes.io/external-ip=150.238.229.156,ibm-cloud.kubernetes.io/ha-worker=true,ibm-cloud.kubernetes.io/iaas-provider=softlayer,ibm-cloud.kubernetes.io/internal-ip=10.221.35.107,ibm-cloud.kubernetes.io/machine-type=b3c.32x128.encrypted,ibm-cloud.kubernetes.io/node-local-dns-enabled=true,ibm-cloud.kubernetes.io/os=REDHAT_7_64,ibm-cloud.kubernetes.io/region=us-south,ibm-cloud.kubernetes.io/sgx-enabled=false,ibm-cloud.kubernetes.io/worker-id=kube-bn08l8td0bfjd8d8kqkg-produssouth-dedicat-0000614a,ibm-cloud.kubernetes.io/worker-pool-id=bn08l8td0bfjd8d8kqkg-d4b4c06,ibm-cloud.kubernetes.io/worker-pool-name=dedicated-prometheus,ibm-cloud.kubernetes.io/worker-version=1.22.12_1566,ibm-cloud.kubernetes.io/zone=dal10,kubernetes.io/arch=amd64,kubernetes.io/hostname=10.221.35.107,kubernetes.io/os=linux,node.kubernetes.io/instance-type=b3c.32x128.encrypted,privateVLAN=2727214,publicVLAN=2727212,topology.kubernetes.io/region=us-south,topology.kubernetes.io/zone=dal10
10.74.177.117   Ready                      <none>   453d     v1.22.12+IKS   arch=amd64,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=b3c.32x128.encrypted,beta.kubernetes.io/os=linux,dedicated=prometheus,failure-domain.beta.kubernetes.io/region=us-south,failure-domain.beta.kubernetes.io/zone=dal12,ibm-cloud.kubernetes.io/encrypted-docker-data=true,ibm-cloud.kubernetes.io/external-ip=169.59.222.216,ibm-cloud.kubernetes.io/ha-worker=true,ibm-cloud.kubernetes.io/iaas-provider=softlayer,ibm-cloud.kubernetes.io/internal-ip=10.74.177.117,ibm-cloud.kubernetes.io/machine-type=b3c.32x128.encrypted,ibm-cloud.kubernetes.io/node-local-dns-enabled=true,ibm-cloud.kubernetes.io/os=REDHAT_7_64,ibm-cloud.kubernetes.io/region=us-south,ibm-cloud.kubernetes.io/sgx-enabled=false,ibm-cloud.kubernetes.io/worker-id=kube-bn08l8td0bfjd8d8kqkg-produssouth-dedicat-000062eb,ibm-cloud.kubernetes.io/worker-pool-id=bn08l8td0bfjd8d8kqkg-d4b4c06,ibm-cloud.kubernetes.io/worker-pool-name=dedicated-prometheus,ibm-cloud.kubernetes.io/worker-version=1.22.12_1566,ibm-cloud.kubernetes.io/zone=dal12,kubernetes.io/arch=amd64,kubernetes.io/hostname=10.74.177.117,kubernetes.io/os=linux,node.kubernetes.io/instance-type=b3c.32x128.encrypted,privateVLAN=2727216,publicVLAN=2727218,topology.kubernetes.io/region=us-south,topology.kubernetes.io/zone=dal12
```

PVC should be provisioined in each worker node

```
[prod-dal10-carrier105] chaseo@prod-dal10-carrier2-worker-1002:~$ kubectl get pvc -n monitoring
NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS               AGE
data-volume-armada-ops-prometheus-0   Bound    pvc-1f836228-92cd-4e63-bd58-1b2188648410   1000Gi     RWX            prometheus-storage-class   4d1h
data-volume-armada-ops-prometheus-1   Bound    pvc-49e715f4-df88-41ac-91ae-70d8d59892f3   1000Gi     RWX            prometheus-storage-class   4d1h
data-volume-armada-ops-prometheus-2   Bound    pvc-c46eb191-67ed-4230-8c4f-5c17c9a375b5   1000Gi     RWX            prometheus-storage-class   4d1h
monitoring-prom2-data-nfs-claim       Bound    pvc-a5beb3f2-055f-11ea-9f1f-22575441027d   1000Gi     RWX            ibmc-file-retain-custom    2y291d
[prod-dal10-carrier105] chaseo@prod-dal10-carrier2-worker-1002:~$ kubectl describe pvc data-volume-armada-ops-prometheus-0 -n monitoring
Name:          data-volume-armada-ops-prometheus-0
Namespace:     monitoring
StorageClass:  prometheus-storage-class
Status:        Bound
Volume:        pvc-1f836228-92cd-4e63-bd58-1b2188648410
Labels:        app=armada-ops-prometheus
Annotations:   ibm.io/provisioning-status:
                 {"status":"complete","time":"2022-08-26T01:23:37Z","attempt":1,"retry":false,"pluginid":"ibm-file-plugin-1661476900","pvcid":"1f836228-92c...
               pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
               volume.beta.kubernetes.io/storage-provisioner: ibm.io/ibmc-file
               volume.kubernetes.io/selected-node: 10.220.9.169
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      1000Gi
Access Modes:  RWX
VolumeMode:    Filesystem
Used By:       armada-ops-prometheus-0
Events:        <none>
```

If a PVC provisioning is blocked by an issue, you should see 'Pending'. `kubectl describe pvc` displays detailed error logs to identify the issue why PVC is not able to be provisioned.

```
NAME                                  STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS               AGE
data-volume-armada-ops-prometheus-0   Pending                                                                        prometheus-storage-class   2d23h
```

In case of the issue caused by the infrastructure level or other miscellaneous issues, then you can re-create PVC by following steps.

1. Delete the pending PVC - `kubectl delete pvc data-volume-armada-ops-prometheus-0 -n monitoring`
2. Once PVC is deleted, you can reprovision new PVC by restarting the associated prometheus pod - `kubectl delete pod armada-ops-prometheus-0 -n monitoring`
3. It takes several minutes to complete the provisioning of PVC. Once PVC is created and `Bound` status, then the prometheus pod should be able to be scheduled. 


### PVC is not able to be provisioned
---
armada-ops-prometheus HA is using a custom storage class `prometheus-storage-class`. Each carrier & tugboat should have the storage class in place but in case you cannot find the storage class, you need to manually create. 

```
[prod-dal10-carrier105] chaseo@prod-dal10-carrier2-worker-1002:~$ kubectl get storageclass
NAME                         PROVISIONER        RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
default                      ibm.io/ibmc-file   Delete          Immediate              false                  32d
ibmc-file-bronze (default)   ibm.io/ibmc-file   Delete          Immediate              false                  32d
ibmc-file-bronze-gid         ibm.io/ibmc-file   Delete          Immediate              false                  32d
ibmc-file-custom             ibm.io/ibmc-file   Delete          Immediate              false                  32d
ibmc-file-gold               ibm.io/ibmc-file   Delete          Immediate              false                  32d
ibmc-file-gold-gid           ibm.io/ibmc-file   Delete          Immediate              false                  32d
ibmc-file-retain-bronze      ibm.io/ibmc-file   Retain          Immediate              false                  32d
ibmc-file-retain-custom      ibm.io/ibmc-file   Retain          Immediate              false                  32d
ibmc-file-retain-gold        ibm.io/ibmc-file   Retain          Immediate              false                  32d
ibmc-file-retain-silver      ibm.io/ibmc-file   Retain          Immediate              false                  32d
ibmc-file-silver             ibm.io/ibmc-file   Delete          Immediate              false                  32d
ibmc-file-silver-gid         ibm.io/ibmc-file   Delete          Immediate              false                  32d
prometheus-storage-class     ibm.io/ibmc-file   Retain          WaitForFirstConsumer   false                  4d19h
```

The `promtheus-storage-class` is defined in [https://github.ibm.com/alchemy-conductors/prom-ha-enablement/blob/master/prometheus-storage-class.yaml](https://github.ibm.com/alchemy-conductors/prom-ha-enablement/blob/master/prometheus-storage-class.yaml). You can also use a Jenkins job [https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/tugboat/job/prom-storage-class/](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/tugboat/job/prom-storage-class/) to create one. More instruction can be found - [https://github.ibm.com/alchemy-conductors/prom-ha-enablement](https://github.ibm.com/alchemy-conductors/prom-ha-enablement)


If a PVC provision failed due to storage limit configured in the zone, you need to open a customer support ticket via IBM Cloud account 531277 Argonauts Production. Example, [https://cloud.ibm.com/unifiedsupport/cases?accountId=e223e119c9be31669e5688bb376411f7&number=CS2916699](https://cloud.ibm.com/unifiedsupport/cases?accountId=e223e119c9be31669e5688bb376411f7&number=CS2916699)

```
Warning  ProvisioningFailed    3m52s (x8 over 31m)  ibm.io/ibmc-file_ibm-file-plugin-8548586f5d-sg8tb_d13868f0-a5b3-44b8-8efb-6a3da83f96e9  failed to provision volume with StorageClass "prometheus-storage-class": pvc already has a failed provision status [ibm.io/provisioning-status:{"status":"failed","error":"storage creation failed with error: {Code:E0003, Description:Failed to place storage order with the storage provider [Backend Error:Your order will exceed the maximum number of storage volumes allowed. Please contact Sales.], Type:StorageOrderFailed, RC:500, Recommended Action(s):Wait a few minutes, then try re-creating your PVC. If the problem persists, open an IBM Cloud support case.}","time":"2022-07-14T04:48:49Z","attempt":1,"retry":false,"pluginid":"ibm-file-plugin-1657650058","pvcid":"9fd4a3ba-df87-454e-986d-0c987d8b9f3b"}].Retry wont happen. kindly delete and re-create pvc
  Normal   ExternalProvisioning  63s (x124 over 31m)  persistentvolume-controller                                                             waiting for a volume to be created, either by external provisioner "ibm.io/ibmc-file" or manually created by system administrator
```


## Escalation Policy

Involve the `armada-ops` squad via the [{{ site.data.teams.armada-ops.escalate.name }}]({{ site.data.teams.armada-ops.escalate.link }})

Discussion for general prometheus problems is best handled in the [Slack Channel #armada-ops](https://ibm-argonauts.slack.com/messages/C534XTE49/)
