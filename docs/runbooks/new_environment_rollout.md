---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: New Environment rollout
service: Conductors
title: New Environment rollout
runbook-name: "New Environment rollout"
link: /new_environment_rollout.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Runbook pertains details of actions to take in Shepherds cluster order, new environment BOM, SL Provisioning app and migrating Single Zone Region (SZR) to Multi Zone Region (MZR) roll-out

## Detailed Information

### Table of content

| Order | Task |
| -- | -- |
| 1.0 | [Planning](#planning) |
| 2.0 | [ServiceEndpoint](#serviceendpoint) |
| 2.0 | [VlanInfra](#vlaninfra) |
| 2.0 | [Vlan](#vlan) |
| 3.0 | [InfraMachineOrder](#inframachineorder) |
| 4.0 | [Bootstrap](#bootstrap) |
| 5.0 | [MachineOrder](#machineorder) |
| 6.0 | [Storage](#storage) |
| 7.0 | [CseDou](#csedou) |
| 7.3 | [DnsProcurement](#dnsprocurement) |
| 7.4 | [StatusCakeSetup](#statuscakesetup) |
| 8.0 | [Haproxy](#haproxy) |
| 9.0 | [Cert](#cert) |
| 10.0 | [COS](#cos) |
| 11.0 | [LogDNA](#logdna) |
| 13.0 | MasterDeploy |
| 14.0 | WorkerDeploy |
| 14.0 | [StatusCakeEnable](#statuscakeenable) |
| 15.0 | [Bastion](#bastion) |
| 16.0 | [ImporterConfig](#importerconfig) |
| 16.1 | [VPEForIKSAPI](#vpeforiksapi)
| 17.0 | [ArmadaSecure](#armadasecure) |
| 17.0 | [Dashboard](#dashboard) |
| 17.5 | [ArmadaOps](#armadaops) |
| 17.5 | SecurityComplianceCheck |
| 20.0 | BssGhost |
| 21.0 | AuthorizeGhost |
| 23.0 | [BxCr](#bxcr) |
| 23.0 | [DarkLaunch](#darklaunch) |
| 23.1 | [LaunchDarkly](#launchdarkly) |
| 24.0 | SmokeTest |
| 25.0 | [TugboatSetup](#tugboatsetup) |
| 25.0 | DocUpdates |
| 25.0 | ArmadaUI |
| 25.0 | ArmadaEnv |
| 25.1 | [TugboatOrder](#tugboatorder) |
| 26.0 | [BackupLogDNA](#backuplogdna) |

## Detailed Procedure

**Note: In this runbook, region `ca-tor` is begin used at many place to indicate current region being worked on. Please make sure to change to correct region.**

### Planning

Usually the carrier rollout is in new data center or region. Hence SL capacity assigned to our account is limited. So we would like to give SL heads up for our upcoming requirement for all hardware and services quotas. Plan and raise SL ticket describing required resources. (Sometime SL wants us to raise a ticket per DC so be ready to breakdown the request if that happens)

1. Go to [IBM Cloud](https://cloud.ibm.com)
1. Select correct account. Example 531277 - Argonauts Production
1. Go to Support > Create a case

Put following details on the case. Replace content in `<>` with relevant information. 
```
In the coming weeks, we plan to set up an environment in <DCs> to support the IBM Cloud Kubernetes Service. We will require the following hardware:

1 VSI with 32core 64GB per zone
2 VSI with 32core 128GB per zone
27 VSI with 16core 64GB per zone
14 VSI with 8core 32GB per zone
2 VSI with 16core 128GB on <primary DC>
2 vlans
2 VIPs

2 BMs with Single Intel Xeon E-2174G (4 Cores, 3.8 GHz) or comparable and redundant power supplies where available 64 GB RAM and 2TB storage


Storage volume increase request:
• What is the use case for the additional volumes request?
  these are to be used by a new instance of IBM Cloud Kubernetes Service
• How many additional Block volumes are needed by type, size, IOPS, and location?
  0
• How many additional File volumes are needed by type, size, IOPS, and location?
  2x, Endurance, 4000GB, 10 IOPS, tor01
  1x, Endurance, 250GB, 10 IOPS, tor01
  20x, Performance, 1000GB 1000 IOPS, tor01
• Please provide an estimate of when you expect to have provisioned all of the requested volume increase?
  30 days
• Please provide a 90-day forecast of expected average capacity usage of these volumes
  100% utilized in 30 days

```

### ServiceEndpoint

Service endpoint is required to establish private endpoint communication for the customer clusters. 

Carrier service endpoint team might not have been onboard when the deployment is started. (ask in `#private-marketplace` channel) Hence to progress with carrier deployment, create new issue to deploy service endpoint in closest available region. Process will be similar for existing region.  
Once service endpoint team is onboard onto new region, finish [CseDou](#csedou) and get apikey approved, create new CSEs in new region and create [netint ticket](https://github.ibm.com/alchemy-netint/firewall-requests/issues/3707) to point to new CSEs and delete old CSEs when netint finished pointing to new CSE. 


### VlanInfra

If the infrastructure (QRadar, Sensu, etc) are being used from existing region, then comment on the netint ticket to close the issue without acting on it. 

### Vlan

Netint team will action this item

### InfraMachineOrder

If the infrastructure (QRadar, Sensu, etc) are being used from existing region, then this task is not required.

### Bootstrap

Bootstrap is required for our infrastructure machines to work and stay compliant. We need to prepare bootstrap process for new region and zones

Bootstrap changes includes two types of changes. 
1. To add new machines and environment in the bootstrap process follow [How to add an extended environment](./bootstrap_add_extended_environment.html) runbook.
1. To update bots to recognize new environment and new machines follow [How to add an new environment to bots](./bots_add_new_environment.html) runbook.

### MachineOrder

We need to order machines to deploy legacy carrier.

Order following machines using [Provisioning App](https://alchemy-dashboard.containers.cloud.ibm.com/prov/api/web/).
- 1 master node per zone with `carrier-masters-ha-ubuntu-18` template
- 4 worker nodes per zone with `carrier-workers-1000-series` template
- 2 armada services nodes per zone with `carrier-workers-8000-series` template
- 2 prometheus worker nodes in primary zone only with `prod-tok02-carrier1-worker-19` template

Order 2 HAProxy nodes per zone with following (or close) configuration from [IBM Cloud](https://cloud.ibm.com/)
```
CPU: Single Intel Xeon E-2174G (4 Cores, 3.8 GHz)
RAM: 64 GB
DISC: 2 TB
Network: Port speed = 10 Gbps, Public egress - bandwidth = 20000 GB
Power supply: redundant power supplies where available
```
Because we are ordering HAProxy nodes straight from dashboard, it won't bootstrap automatically. So bootstrap them with [alchemy-bootstrap Jenkins Job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/job/alchemy-bootstrap/)

When all servers are provisioned, [verify bootstrap and smith](./armada/armada-carrier-scale-out-existing-carriers.html) on all servers.

### Storage

File storages are necessary for persistence volume for various component on legacy carrier. 

Order storage components using [softlayer-utils jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Volumes/view/SoftLayer/job/softlayer-utils/) with following parameters.  
SL_USER: `<Your SL username>`  
SL_API_KEY: `<Your SL api key>`  
SL_DC: `<Primary DC>`  
OPERATION: create

| | etcd | prometheus | kubx |
| -- | -- | -- | -- |
| NAME | `<carrier name> etcd` | `<carrier name> prom` | `<carrier name> kubx` |
| STORAGE_TYPE | Endurance | Performance | Endurance |
| SIZE | 250 | 1000 | 4000 |
| IOPS | 10 | 10000 | 10 |

Once provisioned, go to [Cloud Storage](https://cloud.ibm.com/cloud-storage/file) to find them and add primary and portable subnet of private VLAN in primary data center.  
To find the vlan go to [Network vlans](https://cloud.ibm.com/classic/network/vlans) and filter by location and carrier

Also go to Snapshot and set up daily back up starting midnight and retain for 7 days.

### CseDou

When CSE team gets onboard to the new region, we need to be able to deploy CSE to new region. We need to obtain permission from CSE team to do so.

Account: 531277
- Create new service id. [Service IDs](https://cloud.ibm.com/iam/serviceids) -> Create. Name: `ServiceID-containers-prod-<region>-MIS`
- Create 2 new apikey. [Service IDs](https://cloud.ibm.com/iam/serviceids) -> select newly created service id (above) -> API keys. Name: `containers-prod-<region>-MIS` and `Private CSE ACL Automation`
- Store apikeys in [Thycotic](https://pimconsole.sos.ibm.com/SecretServer/app/#/folders/4250)
- Raise ticket in [IBM-Cloud-Platform-Networking/MISsupport](https://github.ibm.com/IBM-Cloud-Platform-Networking/MISsupport) with following info (make sure to update 'UPDATE_ME' lines):
  Title:
  ```
  Grant service IAM access for CSE
  ```
  Body:
  ```
  Account: 531277
  department name: IBM Cloud
  project: IBM Cloud Kubernetes
  
  ServiceID:
  <region>: found in url of newly created service id https://cloud.ibm.com/iam/serviceids/*$SERVICE_ID*?tab=groups << UPDATE_ME
  Div: 02
  Department: 461003
  Department Name: IBM Cloud
  Project: IBM Cloud
  Contact: your email << UPDATE_ME
  prod Environment.
  Business Justification: needed to rollout new IKS/ROKS env in <region>
  DOU: https://github.ibm.com/IBM-Cloud-Platform-Networking/MISsupport/files/668495/DOU_ServiceEndpoint_Template-IaaS-IKS.docx
  ```
- Receive approval from CSE team

### DnsProcurement

Netint action this task. Verify the table generated by shepherd is correct.

### StatusCakeSetup

Monitoring setup for public endpoint for legacy carrier.

Follow [Create Statuscake Alerts](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/statuscake_creation.html#create-statuscake-alerts) section of the runbook.  
This will create an entry of public endpoints in StatusCake. The entries will have `HAMasterEndpointAlertMaintenance` tag hence it won't trigger alert for primary.

### Haproxy

Netint action this task.

### Cert

Certificates are being used for https secure communication on regional public endpoint such as `ca-tor.containers.cloud.ibm.com`

1. Get environment-prod-ca-tor repository created in alchemy-1337 org. (Reach out to alchemy-1337 owner if you don't have access to create repository and ask them to create a repository for you)
1. Create following files in environment-prod-ca-tor git repository for a new region (see an existing region for this list)
   - `deploy/envrc.ca-tor`
1. Create armada_ssh key files in SecrectKeys directory
   - cmd: `ssh-keygen -m PEM -t rsa -C carrier@ca-tor`
1. Create a csr and key file in containers-api-cert directory. [Example](https://github.ibm.com/alchemy-1337/environment-prod-ap-north/tree/master/containers-api-cert)
   - create csr and key files using script provided in BOM task. Store them in https://github.ibm.com/alchemy-1337/environment-prod-ca-tor/tree/des/containers-api-cert
1. Order SSL certs for region using the csr from the previous step.
   - Using [using cert manager](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/using_certificate_manager.html) runbook, order certs mentioned in BOM task and store them into armada-secure. 

### COS

COS bucket is being used to store customer master plane backups for the region. One COS instance needs to be dedicated for the region. So we will order COS instance, create a bucket inside COS instance and we will store its config and secret in armada-secure.

1. Sign into [IBM Cloud](https://cloud.ibm.com/)
1. Select the `531277 - Argonauts Production` account
1. Go to Catalog > Services > Filter `storage` > pick `Object Storage`
1. Select Standard plan. Provide appropriate name and resource group. 
1. Create COS instance `armada-deploy-etcd-backups-prod-<region>`
1. Create bucket within COS instance using `cross-regional` resiliency and location `<region>`
1. Create a api key and obtain the value clicking `Edit Sources`
1. Store config and credential in armada-secure. [Example](https://github.ibm.com/alchemy-containers/armada-secure/pull/2842)

### LogDNA

LogDNA is being used to store micro service logs that are running inside the region. Create LogDNA, Activity Tracker and SysDig instances dedicated to new region. Store LogDNA ingestion key to armada-secure so micro services can send logs to LogDNA.

1. Create LogDNA instance and assign correct access by following [LogDNA new instance](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/logDNA_new_instance) runbook.
1. Sysdig instances
   1. Create `sysdig-prod-<region>` resource group and create following Sysdig instances under this resource group.
   1. `sysdig-IKS-<region>`
   1. `sysdig-IKS-platform-<region>` (Configure this instance to receive to receive Platform metrics)
1. LogDNA Agent Config
   1. navigating to the Observability > Monitoring menu
   1. click obtain key from LogDNA instance menu to generate a key (if this instance is new)
   1. click obtain key again  to retrieve the key value
   1. add encrypted key to [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure/tree/master/build-env-vars/logdna)

### StatusCakeEnable

To enable monitoring on the carrier public endpoint `c<carrier_number>.<region>.containers.cloud.ibm.com`. Follow [Status cake alert creation](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/statuscake_creation.html#when-ready-to-go-live) runbook. 

### Bastion

Follow [Bastion platform deployment](./bastion/bastion_platform_deployment.html) runbook and deploy bastion for the region.

### ImporterConfig

TODO: Figure out why this step is needed.

### VPEforIKSAPI

Follow [Steps to create VPE for SREs in Architecture Concept - VPE for IKS API](https://github.ibm.com/alchemy-containers/armada/blob/master/architecture/guild/concept-docs/concept-vpe-iks-api.md#steps-to-create-vpe-for-sres) to create VPE for the production environment

### ArmadaSecure

We need to add config files to armada-secure for new region so micro services can utilise those config.

Add following files for the new region. (yaml files can be copied from other region and be updated to be compatible with new region)
- secure/armada/ca-tor/hubs/prod-tor01-carrier1/armada-info.yaml
- secure/armada/ca-tor/hubs/prod-tor01-carrier1/armada-ops-config.yaml
- build-env-vars/armada-network-microservice/NETMS_IKS_CSE_API_KEY_PROD_CA_TOR.gpg
   - Get it from [Thycotic](https://pimconsole.sos.ibm.com/SecretServer/app/#/folders/9888)
- secure/armada/ca-tor/akamai-carrier-ingress.yaml
- secure/armada/ca-tor/armada-cert.yaml
- secure/armada/ca-tor/armada-info.yaml
- secure/armada/ca-tor/armada-ops-alert-conf.yaml
- secure/armada/ca-tor/armada-ops-config.yaml
- secure/armada/ca-tor/armada-ops-grafana.yaml
- secure/armada/ca-tor/service-endpoint-config.yaml
- build-file-vars/infra-kubeconfigs/PROD_TOR01_CARRIER1.gpg
- secure/armada/ca-tor/hubs/infra-kubeconfigs.yaml

### Dashboard

We need to update dashboard to pick up new carrier to monitor.

Update following repositories
1. nginx-dashboard
   - Update [Dockerfile](https://github.ibm.com/alchemy-conductors/nginx-dashboard/blob/master/Dockerfile)
      - Add new carrier worker nodes
   - Update [nginx.conf](https://github.ibm.com/alchemy-conductors/nginx-dashboard/blob/master/nginx.conf)
      - Add sensu-uptime and prometheus configuration for new carrier. [Example](https://github.ibm.com/alchemy-conductors/nginx-dashboard/pull/484/files#diff-daaf2fceca49ed034eace91c4e875653R1205-R1217)
1. alchemy-dashboard
   - Update [config/carrierConfig.json](https://github.ibm.com/alchemy-conductors/alchemy-dashboard/blob/master/app/config/carrierConfig.json) ([Example](https://github.ibm.com/alchemy-conductors/alchemy-dashboard/pull/459/files))
   - Update [scripts/routeCustom.js](https://github.ibm.com/alchemy-conductors/alchemy-dashboard/blob/master/app/scripts/routeCustom.js)
   - Update [services/alchemy-dashboard/deployment.yaml](https://github.ibm.com/alchemy-conductors/alchemy-dashboard/blob/master/services/alchemy-dashboard/deployment.yaml)
     - Add prometheus deployment ([Example](https://github.ibm.com/alchemy-conductors/alchemy-dashboard/blob/master/services/alchemy-dashboard/deployment.yaml#L559-L564))
1. Deploy alchemy-dashboard through [Razee](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/alchemy-dashboard)

### ArmadaOps

- Create sensu-uptime checks for prometheus and alertmanager (follow [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-ops-add-monitoring-checks-in-sensu-uptime.html))
- Dedicate worker prod-tor01-carrier1-worker-[19-20] for prometheus  
   Add taints to all the workers you have identified - see [Taints runbook for guidance](https://github.ibm.com/alchemy-containers/armada-ansible/blob/master/Taints.md)  
   Update `prometheus_only=true` label on worker nodes [19-20] in [armada-envs](https://github.ibm.com/alchemy-containers/armada-envs). Use this [Example](https://github.ibm.com/alchemy-containers/armada-envs/pull/1310/files)
- Add new region checks on [armada-ops-avail](https://github.ibm.com/alchemy-containers/armada-ops-avail). Use this [Example](https://github.ibm.com/alchemy-containers/armada-ops-avail/pull/89/files) for reference

### BxCr

Raise a train in `#cfs-test-prod-trains` channel for a new environment. Comment a link of successful train on the issue.  
Similarly gather successful train evidence from `#cfs-prod-trains` channel (No need to raise a special train for testing in prod. Get existing train as an evidence.)

### DarkLaunch

We need to launch the carrier (only if in new region) to be able to deploy tugboats. 

- Update [datacenters.json](https://github.ibm.com/alchemy-containers/armada-config-pusher/blob/master/json-templates/ca-tor/datacenters.json) ([Example](https://github.ibm.com/alchemy-containers/armada-config-pusher/pull/1100))
   - If the new datacenter is already used for patrols, need to ensure specified appropriately (see MEL01 in ap-south as an example)
- Redeploy armada-config-pusher  
   ** If deploying to existing region but a new carrier:
- Create a test cluster and move it to the new [carrier](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/#order-test-cluster-in-existing-zone)  
** Must do
- add to list of carriers on [alchemy-containers/armada-envs/README.md](https://github.ibm.com/alchemy-containers/armada-envs/blob/master/README.md)
- Add an entry to the [zone to region mapping list](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/armada-regions.yaml#L17) in armada-secure for global api and UI support.
- Promote armada-secure with the above change

### LaunchDarkly

To launch the region for internal use, we enable flag on Launch Darkly. 

- add the following rules to [armada-api.ca-tor](https://app.launchdarkly.com/armada-users/production/features/armada-api.ca-tor/targeting)
  - Allow all IBMers "User is in segment IBM'ers"
  - Allow sysdig and logdna "If bssAccountID is one of 4183e714347c43a79451c9b58ed0e5fd 0a724372d51549c8823583139a71dead"
- add prod-tor01-carrier1 to [armada-api.openshift.zones/targeting](https://app.launchdarkly.com/armada-cruisers/production/features/armada-api.openshift.zones/targeting)
- add all DCs to variation 2 in [armada-api.openshift.zones/variations](https://app.launchdarkly.com/armada-cruisers/production/features/armada-api.openshift.zones/variations)

### TugboatSetup

Once the carrier is live we need to be prepared for tugboats.  
_We prefer customer clusters on tugboats, rather then on legacy carriers because tugboats are easier to maintain._

Set correct perms for tugboat user.  
1. Log in to [IBM Cloud](https://cloud.ibm.com/) account 531277
1. [Create Resource Group](https://cloud.ibm.com/docs/account?topic=account-rgs#create_rgs) tugboat-ca-tor
1. Add new permissions to IKS Tugboat Automation.
   1. Select IKS Tugboat Automation from [Access Groups list](https://cloud.ibm.com/iam/groups)
   1. Click Access Policies tab, then Assign Access
   1. Add `Administrator, Editor, Operator, Writer, Manager, Reader, Viewer` access to "Kubernetes Service service in tugboat-ca-tor resource group"
   1. Add `Editor` access to "tugboat-ca-tor resource group resourceType string equals resource-group, resource string equals tugboat-ca-tor"
   1. Add `Viewer, Manager` access to "Certificate Manager service in tugboat-ca-tor resource group"
1. Add new permissions for vuln scan to one of:
   - [security-scans-prod-tugboat1](https://cloud.ibm.com/iam/serviceids/ServiceId-a078ed53-514d-407d-b61b-e5de6f150d16)  
   for regions `us-south`, `us-east`, `ca-tor`, `ap-north`, `jp-osa`
   - [security-scans-prod-tugboat](https://cloud.ibm.com/iam/serviceids/ServiceId-f166fdc8-28f6-408c-b26c-2d9666d9ddf7)  
   for regions `eu-de`, `eu-gb`, `ap-south`
   1. Click Access Policies tab, then Assign Access
   1. Add `Viewer, Reader, Operator` access to "Kubernetes Service service in tugboat-ca-tor resource group"
   1. `Viewer` access to "tugboat-ca-tor resource group resourceType string equals resource-group, resource string equals tugboat-ca-tor" will be added automatically to the right. If not, add Viewer access.

Update Jenkins Jobs  
- add secret to [jenkins credentials](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/credentials/store/folder/domain/_/newCredentials). 
   - Kind: secret-text  
   - Secret: output from command below on legacy carrier.  
      `kubectl -n kube-system get secret logdna-agent-key -o jsonpath={.data.logdna-agent-key} | base64 -d ; echo`  
   - ID: LOGDNA_INGESTION_KEY_CA_TOR  
   - Description: LOGDNA_INGESTION_KEY_CA_TOR
- add ca-tor and LOGDNA_INGESTION_KEY_CA_TOR variable to [bootstrap-minimal-tugboat](https://github.ibm.com/alchemy-containers/tugboat-cluster-update-monitor/blob/master/jjb/bootstrap-minimal-tugboat.yml)
- add prod-tor01-carrier1-master-01 to [armada-tugboat-update](https://github.ibm.com/alchemy-containers/armada-cruiser-automated-recovery/edit/master/jjb/armada-tugboat-update.yaml)
- add prod-tor01-carrier1-master-01 to [armada-tugboat-move-test-cluster](https://github.ibm.com/alchemy-containers/armada-cruiser-automated-recovery/blob/master/jjb/move-cluster-to-new-tugboat.yaml)

Update alchemy-containers/tugboat-bootstrap  
- add ca-tor to [README.MD](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/README.MD)
- add `ca-tor-prod-prometheus|grafana|alert`, to [monitoring_git/defaults/main.yml](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/ansible/roles/monitoring_git/defaults/main.yml)
- add ca-tor-prod to region_map in [monitoring_git/defaults/main.yml](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/ansible/roles/monitoring_git/defaults/main.yml)
- add ca-tor-prod to log_dna_map in [monitoring_git/defaults/main.yml](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/ansible/roles/monitoring_git/defaults/main.yml). To find the hash needed for this logging instance, go to [resources](https://cloud.ibm.com/resources) in 1185207, search ca-tor-STS. Select the instance under Services, then click "View LogDNA". Use the hash in this url to construct the new one.
- update armada-envs sub module.
- add ca-tor block in region case statement on [jenkins_entry.sh](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/jenkins_entry.sh)
- ca-tor is not available from the global api during setup. We must init it temporarily at [alchemy-containers/tugboat-bootstrap/ansible/roles/ibmcloud_login/tasks/main.yml](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/ansible/roles/ibmcloud_login/tasks/main.yml). Add below task.
```
- name: Init ca-tor host
  shell: "ibmcloud ks init --host=https://origin.ca-tor.containers.cloud.ibm.com"
  delay: "{{ delay }}"
  retries: "{{ retries }}"
  register: login
  until: login is successful
  when: '"tugboat-ca-tor" in RESOURCE_GROUP' #TODO not needed once global api is working
```

### TugboatOrder

When tugboat setup is finished, order tugboats in new environment.  
Follow steps on [tugboat-bootstrap runbook](https://github.ibm.com/alchemy-containers/tugboat-bootstrap/blob/master/README.MD) and order following tugboats
- microservice tugboat
- roks tugboat
- iks tugboat

### BackupLogDNA

1. Sign into [IBM Cloud](https://cloud.ibm.com/)
1. Select the `1185207 - Alchemy Production` account
1. From `Resource List` on the left, search for `logDNA-COS-prod` COS instance. 
1. Create following buckets under `logDNA-COS-prod` COS instance with `cross-regional` resiliency and location `<region>`
   - `1185207-logdna-activity-tracker-ca-tor` (For Activity Tracker backup)
   - `1185207-logdna-kubx-master-microservices-ca-tor` (For LogDNA backup)  
   _If region is not available on UI, it might be enable for CLI only. Follow below steps to create buckets using CLI_
   1. Configure `ca-tor` endpoint for cos
      `ibmcloud cos config endpoint-url --url s3.ca-tor.cloud-object-storage.appdomain.cloud`
   1. Get the id of `logDNA-COS-prod`  
      `ibmcloud resource service-instance logDNA-COS-prod --id`  
      _Copy only part after `::`_ as described in [this document](https://cloud.ibm.com/docs/cloud-object-storage-cli-plugin?topic=cloud-object-storage-cli-plugin-ic-cos-cli#ic-create-bucket)
   1. Configure crn  
      `ibmcloud cos config crn --crn <previously copied id>`
   1. Create activity tracker COS bucket in `ca-tor` region
      `ibmcloud cos bucket-create --bucket 1185207-logdna-activity-tracker-ca-tor --class Smart --region ca-tor`
   1. Create kubx-masters COS bucket in `ca-tor` region
      `ibmcloud cos bucket-create --bucket 1185207-logdna-kubx-master-microservices-ca-tor --class Smart --region ca-tor`
1. Configure COS bucket for Activity Tracker backup (`1185207-logdna-activity-tracker-ca-tor`) for event tracking
   1. Get IAM token with following command and store in `IAM_TOKEN` variable  
      `ibmcloud iam oauth-tokens`
   1. Get CRN of activity tracker instance and store in `AT_CRN` variable  
      `ibmcloud resource service-instance kubx-master-microservices-ca-tor-ATS`
   1. Run following curl command to update cos bucket for event tracking to Activity Tracker  
      ```
      curl -X PATCH https://config.cloud-object-storage.cloud.ibm.com/v1/b/<bucket> -H "authorization: $IAM_TOKEN" -d "{\"activity_tracking\": { \"activity_tracker_crn\": \"$AT_CRN\", \"read_data_events\": true, \"write_data_events\": true}}"
      ```
1. Go to `Service credentials` on `logDNA-COS-prod` COS instance and create two new credentials.
   - `COS-prod-ca-tor-credential` (For `1185207-logdna-kubx-master-microservices-ca-tor`)
   - `COS-prod-AT-ca-tor-credential` (For `1185207-logdna-activity-tracker-ca-tor`)
1. Go to [Observability](https://cloud.ibm.com/observe) on a new tab.
1. Find out LogDNA instance `kubx-master-microservices-ca-tor-STS` under `Logging` and configure it with credentials in `COS-prod-ca-tor-credential` for archival as described in this [runbook](./activity_tracker_backup.html)
1. Find out Activity Tracker instance `kubx-master-microservices-ca-tor-ATS` under `Activity Tracker` and configure it with credentials in `COS-prod-AT-ca-tor-credential` for archival as described in this [runbook](./activity_tracker_backup.html)
1. Go to `Service IDs` from `Manage > Access (IAM) > Service IDs`
1. Click on `COS-prod-ca-tor-credential` and add following access policy
   - `Writer, Viewer` access to `Cloud Object Storage` service with 
      - serviceInstance string equals logDNA-COS-prod
      - resourceType string equals bucket
      - resource string equals 1185207-logdna-kubx-master-microservices-ca-tor
1. Click on `COS-prod-AT-ca-tor-credential` and add following access policy
   - `Writer` access to `Cloud Object Storage` service with 
      - serviceInstance string equals logDNA-COS-prod
      - resourceType string equals bucket
      - resource string equals 1185207-logdna-activity-tracker-ca-tor

### Troubleshooting

TODO: Add troubleshooting/Gotcha information 
