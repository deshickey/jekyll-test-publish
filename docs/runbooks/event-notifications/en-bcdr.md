---
layout: default
title: "IBM Cloud Event Notifications IT DR Plan"
runbook-name: "IBM Cloud Event Notifications IT DR Plans"
description: "IBM Cloud Event Notifications IT DR Plan"
category: Event Notifications
service: Event Notifications
tags: event-notifications
link: /event-notifications/en-bcdr.html
type: Informational
grand_parent: Armada Runbooks
parent: Event Notifications
---

Informational
{: .label }

# IBM Cloud Event Notifications IT DR Plan
## Overview
--- 
## Approval Information
* Approved By: Neeta Stanley (Development Manager)
* Approved On: 22 May 2024
* Evidence : https://github.ibm.com/Notification-Hub/planning/issues?q=is%3Aissue+is%3Aclosed+BCDR+label%3Aenhancement
* Slack Channel for BCDR Test Activity: #event-notifications-bcdr
* Last updated On: 22 May 2024
--- 
## Roles
* BU BC/DR Leader
* BC-DR Focal
* BCP Squad Focal
* Team Lead/Service Architect
* BCP Approver
* Content Owner
* Technical Recovery Team
--- 
## Detailed Information
The IBM Cloud Event Notifications is a multi-tenant regional service implemented using a micro-service architecture [Service Architecture](https://pages.github.ibm.com/Notification-Hub/planning/architecture/architecture.html)..
All apps within the micro-services are developed in Golang or Node.js and are built as Docker container images. The Docker images are then deployed and managed in IBM Kubernetes Clusters created using the IBM Kubernetes Service (IKS). The Kubernetes clusters reside in various IBM Cloud regions. Each region is deployed with 8 nodes located across 3 different data centres (Availability Zones), with 2 worker nodes in each zone.

## Prerequisites
--- 
### Dependencies
--- 
The IBM Event Notifications service depends on the following external services (which may or may not be housed in the same data centre):
 - IBM Cloud Databases for PostgreSQL
 - IBM Cloud Databases for Redis
 - IBM Cloud Databases for Event Streams
 - IBM Cloud® App Configuration
 - IBM Cloud Object Storage
 
 * Note: 
     - If Event Streams is down, the Event Notifications service will continue to function using the Circuit Breaker pattern. 
     - Redis is used for caching and if it is down, service will still continue to work. 
     - Redis is also required for IBM Cloud Console dashboard, for session maintenance.
     - If App Configuration service is down, service will still continue to work with the last working configuration.

### Other Dependencies on IBM Cloud
--- 
Both the IBM Cloud Event Notifications service and its customers are intimate tenants of IBM Cloud. If IBM Cloud is down, then both the service and our customers require a full recovery of IBM Cloud prior to recovery of the service.
IBM Cloud Event Notifications service’s users are tenants of IBM Cloud, and require the following to be working:
 - IBM Cloud login service
 - IBM Cloud clusters (Kubernetes classic and vpc-gen2)
 - IBM Cloud Console
 - Resource controller
 - IAM
 - IBM Key Protect
 - Messaging API

## Close/Shutdown Procedure:
---  
This section contains the procedure to gracefully shutdown the service in case of emergencies that require an ordered shutdown.
Event Notifications Service’s primary test executor is responsible for all of these actions:

 - Take backup of all the kubernetes resources for all microservices locally. 
 - Take backup of vault secrets locally. 
 - Take backup of istio yaml(virtual service) locally. 
 - Delete all kubernetes resources deployment, configmap, service, network etc for each microservice deployed in the cluster respectively. 
 - Delete istio (virtual service). 
 - Delete vault secrets from the clusters. 
 - Change credentials for dependent services Postgres, Redis , Event Streams etc. 
 - Disable Tekton pipeline from deploying any further services to the cluster. 

## Restart/Restore Procedure:
--- 
Event Notifications Service’s primary test executor is responsible for all of these actions:

 - Change credentials for dependent services like Postgres, Redis , Event Streams and update the new updated secrets in the vault. 
 - Enable Tekton pipeline and deploy microservices, if Tekton is down create all resources (deployment, service, network, configmap) from the yaml’s backup saved in local machine. 
 - Create secrets with update credentials for the dependent services using the yaml’s backup saved in local machine. 
 - Create istio service from the yaml’s backup saved in local machine. 
 - Perform end to end functional test to make sure all functionality with dependent services works as expected. 

## Disaster Recovery Plan
---
### IBM Cloud Recovery
--- 
IBM Cloud follows its BCP Recovery plan and is fully restored in the region. (See Above)
### External Service Recovery (with no data loss)
--- 
The external services may or may not be affected. If they are affected then each of the affected services must follow their BCP Recovery plan.
If the IBM Cloud Recovery plan provides additional instructions, follow those instructions.
### External Service Recovery of Event Notifications data
--- 
The following services hold IBM Cloud Event Notifications service owned data. For some of the services, IBM Cloud Event Notifications Service also maintains additional backup data beyond the inherent resiliency provided by the dependent services.
#### IBM Databases for PostgreSQL
--- 
is used to store all IBM Clous Event Notifications service’s persistent data for Dallas Region. The ICD for PostgreSQL service has automatic backup and HA capabilities provided as part of service. Data is backed-up automatically once, every day.
 - Backups are retained and available for restoration for 30 days.
 - Backups are cross-regionally durable. Backups are stored across multiple regions, and can be restored to a different region.
More information on ICD for PostgreSQL’s backup mechanism is available [here](https://cloud.ibm.com/docs/databases-for-postgresql?topic=databases-for-postgresql-getting-started&interface=ui).
ICD for Postgres also supports high availability as detailed [here](https://cloud.ibm.com/docs/databases-for-postgresql?topic=databases-for-postgresql-getting-started&interface=ui).

### Recovery Time Objective (RTO)
--- 
| Task | Duration | Notes
| :--- |:---|:---|
| Incident Declared by Incident Commander |||		
| Analysis | 30 minutes | In the event of a significant incident, Impact Analysis to determine if declaration of disaster and execution of offering recovery plan is required is to be carried out by technical recovery team.| 
| MAO (Maximum Acceptable Outage) and RTO (Recovery Time Objective) | 9 hours||		
| Cluster Redeployed | 120 Minutes (2 Hours) | Identify the region/zone for alternate site choice and deploy infrastructure.
| Event Notifications Database Rerouting | 1 hour | For PostgreSQL the technical recovery team will contact the PostgreSQL service team to restore the backup into new instance on alternate site. Restoration steps are. provided in the link [here](https://cloud.ibm.com/docs/databases-for-postgresql?topic=databases-for-postgresql-getting-started&interface=ui)|
| Software Deployment | 200 Minutes (3.2 Hours) | Deploy containers on provisioned infrastructure on alternate sites. This involves deployment of 26 microservices in the new classic cluster and 2 statefulsets and 1 HAProxy in VPC cluster.
| Validation | 60 minutes (1 Hours) | Ensure the service is functional| 
| MTD (including analysis) | 540 Minutes (9 hours) | | 


### Recovery Point Objective (RPO):
--- 
 The maximum recovery point objective for Event notifications is 1 day. We create a daily backup of customer and configuration at 9 AM IST.

### Cross-Region Disaster Recovery 
--- 
Complete cross region disaster recovery involves actions on IBM Cloud Event Notifications team. The IBM Cloud Event Notifications service’s technical recovery team members are responsible for the recovery of the service meta data - the control plan.
Please follow the below steps to recover the control-plane microservices from the region where the incident has occurred. The below steps are required for internal Event Notifications service’s technical recovery team members, the BCP Squad is the in-charge of executing them.
 - As soon as the incident related to the disaster is declared and as part of the initial analysis, identify the region for alternate site choice. Create a new IKS cluster in that region using the IBM Cloud catalog. (Event Notifications Primary Test Executor is responsible for this)
 - Create new instances of ICD for Redis and ICD for Event Streams on the identified recovery region.
 - Since all the microservices need to be deployed in the newly provisioned cluster, source code for all the components needs to be rebuilt. Clone the source code from IBM GitHub repositories in case the primary source code repositories (github.ibm.com) are available. Otherwise, get the source code from the backup machines where source code is regularly updated. (Event Notifications Primary Test executor is responsible for this)
 - The alternate container registry has also setup in another region to maintain the latest microservice images in case of primary container registry is down. The secondary backup is under **Push Notifications Prod Account(1424241)** account and third site backup is under  **Push Notifications - DevStage** account.
 - Docker images for all the components need to be generated in case the container registry is affected by the disaster. (Event Notifications Technical Recovery Team members are responsible for executing)
 - PostgreSQL: Restoration steps are provided in the link [here](https://cloud.ibm.com/docs/databases-for-postgresql?topic=databases-for-postgresql-getting-started&interface=ui).
 - Manually modify the environment variables to point the images to the newly identified region (Alternate site choice for the affected region).
  - PostgreSQL url is modified to the back-up database. (Event Notifications Technical Recovery Team members are responsible for executing )
  - Update Configuration with the new values for ICD Redis as well as Event Streams (Event Notifications Technical Recovery Team members are responsible for executing )
 - Deploy all the images to the Kubernetes cluster and create other resources including deployments, services, secrets, config-maps, network policies, istio (Virtual Service) and vault secrets. Ensure all the required pods are up and running. (Event Notifications Technical Recovery Team members are responsible for executing)
  - The Deployment, Service and Network Policy yaml files are available in the respective Git repos
  - Istio (Virtual Service) yaml which is applicable for the Cluster itself, is also available in the Git repo.
  - We are using Secret Manager to store the certificates. If the SM is down in particular region we will provision the new SM instance in different region and we will request the new certificate from the Secret Manager and connect it to CIS. This will suffice the backup and restore of the SM which contains the certificates.
 - After deployment, ensure all pods for each microservice are up and running and do a health check for each microservice, ICD PostgreSQL, ICD Redis, Event Streams. (Event Notifications Technical Recovery Team is responsible for this)
 - Update the global catalog entry for the affected region to point the service dashboard of the affected region to the new cluster’s Overview dashboard. This will ensure the dashboard (multi-tenant console) will be picked up by the service deployed in the new alternate cluster. (Event Notifications Primary Test Executor is responsible for this)
 - Update the resource management console to point to the service broker deployed in the new region. (Event Notifications Primary Test Executor is responsible for this)

 #### Recovery Procedure steps for custom-domain Email

 - Setup the VPC in the alternate region using the IBM Catalog. Refer the documentation here: https://cloud.ibm.com/docs/vpc?topic=vpc-getting-started
 - Setup the VPC cluster in alternate region using the IBM Cloud catalog.
 - Create new instances of ICD for Redis
 - Istio (Virtual Service) yaml which is applicable for the Cluster itself, is also available in the Git repo.
 - Create resources including deployments, services, secrets, config-maps, network policies in the newly provisioned cluster.
 - The alternate container registry has also setup in another region to maintain the latest microservice images in case of primary container registry is down. Apply the latest image in the microservice
 - Update the configmap event-notifications-custom-email-transformer-configmap and event-notifications-config-engine-configmap in classic cluster to newly set VPC cluster ingress endpoint.
 - After deployment, ensure all pods for each microservice are up and running.

 #### Recovery Procedure steps for SMTP Configuration

 **Create SMTP Namespace and Install COS Plugin**: Install the COS plugin as documented in [link: https://cloud.ibm.com/docs/containers?topic=containers-storage_cos_install]. Verify that the plugin is installed correctly and the plugin pods are running in the default namespace.  
  
 **Setup PVC and Connect COS Instance**: Create a Persistent Volume Claim (PVC) in the SMTP namespace and connect it to a Cloud Object Storage (COS) instance. Provide the bucket name, endpoint, and COS secret in the PVC.

 **Setup HAProxy:** Set up HAproxy in the SMTP namespace, following the instructions in [link: https://github.ibm.com/Notification-Hub/haproxy/tree/master].

 **Setup SMTP-Relay Statefulset Pods**: Set up the smtp-relay statefulset pods and connect them to the already created PVC.

 **Register ALB in Origin Pools**: Register the Application Load Balancer (ALB) in the origin pools under the Global Load Balancer setup.

 **Update DNS**: Update the DNS with the new ALB.

 **Create Resources:** Create resources, including deployments, services, secrets, config-maps, and network policies, in the newly provisioned cluster.

 **Alternate Container Registry Setup:** Set up an alternate container registry in another region to maintain the latest microservice images in case the primary container registry is down. Apply the latest image to each microservice.

 **Verify Pod Deployment:** After deployment, ensure that all pods for each microservice are up and running.


### Recovery Procedure to restore back to Primary site
--- 
This section contains the procedure to restore processing back to the primary site, once the primary is fully recovered.
Once primary site hosting the IBM Event Notifications recovers fully, following steps needs to be performed by IBM Event Notifications’ technical recovery team .
Please follow the below steps to move back to  the microservices of the region which fully recovered after the incident occurred. The below steps are required to be performed by the IBM Event Notifications service’s technical recovery team.
 - Identify if existing  Kubernetes IKS cluster is up and running and if not create a new Kubernetes IKS cluster in that region using the IBM Cloud catalog. (Event Notifications Technical Recovery Team is responsible for this).
 - PostgreSQL: Restoration  steps provided in the link [here](https://cloud.ibm.com/docs/databases-for-postgresql?topic=databases-for-postgresql-getting-started&interface=ui)
 - Manually modify the environment variables to point the images to the newly identified region (Alternate site choice for the affected region).
  - PostgreSQL url is modified to the back-up database. (Event Notifications Technical Recovery Team members are responsible for executing)
  - Update Configuration with the new values for ICD Redis as well as Event Streams (Event Notifications Technical Recovery Team members are responsible for executing)
 - After deployment ensure all pods for each microservice are up and running and do a health check for each microservice, ICD PostgreSQL, ICD Redis, Event Streams. (Event Notifications Technical Recovery Team is responsible for this)
 - Update the Global Catalog entry for the region to point it back from the recovery region cluster service dashboard to the original region dashboard. This will ensure the dashboard (multi-tenant console) of the original region will be picked up by the service. (Event Notifications Technical Recovery Team is responsible)
 - Update the resource management console to point to the service broker deployed in the original region. (Event Notifications Technical Recovery Team is responsible for this)

### Restoring accidental deletion:
--- 
This section contains the restoring process for accidental deletion of customer data for Event Notifications.

### ICD for PostgreSQL :
--- 
IBM® Cloud Databases for PostgreSQL offers Point-In-Time Recovery (PITR) for any time in the last 7 days. The deployment performs continuous incremental backups and can replay transactions to bring a new deployment that is restored from a backup to any point in that 7-day window, as needed.

The Backups tab of the deployment's UI keeps all the PITR information under Point-in-Time here.

Recovery
 - Identify the Point-In-Time for PostgreSQL for which data needs to be recovered.
 - Initiate a PITR (Point In Time Recovery), enter the time that you want to
   restore back to in UTC. Clicking Restore brings up the options for your
   recovery. Enter a name, select the version, region, and allocated resources
   for the new deployment. Click Recover to start the process here.              
 - The above process recover data into a new deployment.
 - After restoration of database complete in new deployment, export the 
   deleted data from the new deployment and import it into existing. The latest
   version of “pgAdmin” tool can be used for export and import.  (All steps stated here should be performed by the IBM Event Notifications service’s Technical
   Recovery Team)

### Cross-Region service recovery when dependent services down:
--- 
This section contains the procedure to bring up the service when dependent services in a region are down.

Following steps needs to be performed by IBM Event Notifications Service’s Technical Recovery Team, BCP squad.
 - As soon as the incident related to the disaster is declared and as part of the
      initial analysis, identify the region. (Event Notifications Technical Recovery
      Team is responsible.)            
 - For persistent dependencies like PostgreSQL identify the
      backed up databases. Create new instance for non-persistent dependencies
      like ICD Redis and Event Streams. (Event Notifications Technical  
      Recovery Team is responsible for this)     

 - Redeploy all microservices in the cluster from the pipeline for that region so
      that all images point to the environment variables and dependencies like
      ICD Redis and Event Streams of that region (Event
      Notifications Technical Recovery Team is responsible for this) 
 - After deployment ensure all pods for each microservice are up and running 
      and do a health check for each microservice. (Event Notifications Technical 
      Recovery Team is responsible for this)

### Cross-Region failover and client data recovery in such scenario:
--- 
IBM Event Notifications Service is a regional service. It does not provide automated cross-regional failover or cross-regional disaster recovery. If a regional disaster occurs, all data might not be recovered. However, a location recovery is possible and all data can be restored. If there is a need for regional disaster recovery, it is recommended that you create and maintain backup instances in other regions. To synchronize a service instance in one region with an instance in a different region, you can use the [APIs](https://cloud.ibm.com/apidocs/event-notifications/event-notifications) 
Review the API documentation to consider the important data that you want to backup and restore.
For example, you may start with the following to be backed up:
 - sources :  /v1/instances/{instance_id}/sources - Your platform sources
 - topics: /v1/instances/{instance_id}/topics -  All registered topics
 - rules: /v1/instances/{instance_id}/rules – All rules created on topics
 - destinations: /v1/instances/{instance_id}/destinations – All registered channels
 - subscriptions: /v1/instances/{instance_id}/subscriptions - All the subscriptions
 - integrations: /v1/instances/{instance_id}/integrations - All the integrations
 - templates: /v1/instances/{instance_id}/templates - All the templates
 - smtp configurations: /v1/instances/{instance_id}/smtp/config - All the SMTP Configurations
For each of the data set that you need to back up and restore, use the GET calls to get a copy of the data, and use corresponding the PUT / POST API to populate the new instance on a different region

### Clusters High Availability
--- 
The IBM Event Notifications service is available, in each IBM Cloud region, in a High Availability mode. i.e with 6 nodes deployed across three datacentre with 2 nodes per data centre. Refer [Network Topology](https://pages.github.ibm.com/Notification-Hub/planning/architecture/physical/network.html)
### Data centre Availability
--- 
If a data centre is unavailable, other data centre which is part of a cluster continue to serve our customers, without any disruption. To serve the capacity required, a new node in an available data centre would be created. This does not require any new deployment and the number replicas defined as part of the deployment would address this. Event Notifications Technical Recovery Team is responsible for this activity.

### Backup ICD Database To COS Bucket:
--- 
To reduce the risk that an attacker gets access to the services primary cloud account and deletes or corrupts all database instances, additional COS instances has been created with a write only API key in a separate functional accounts, which has limited access. The access control to the Cloud account and the COS instance/buckets is managed via Access Hub. The two functional accounts are referred as second and third site for data recovery.

The secondary backup is kept under **Push Notifications Prod Account(1424241)** account to keep the backup of the customer data (PSQL data). We have provisioned a cos instance named **Event-Notifications-postgres-cos-backups** under this account and below are the details about the bucket and the regions.


| Region | Bucket Name | Backup Region |
| :--- | :--- | :--- |
|  Dallas(us-south) | endallasproductionpostgres , enpushdallasproductionpostgres                    | WDC(us-east)            | 
|  London(eu-gb)    | enlondonproductionpostgres , enpushlondonproductionpostgres                    | Dallas(us-south)        |
|  Sydney(au-syd)   | ensydneyproductionpostgres , enpushsydneyproductionpostgres                    | London(eu-gb)           |
|  Frankfurt(eu-de) | eenfrankfurtproductionpostgresbackup , enpushfrankfurtproductionpostgresbackup | Madrid(eu-es)           | 
|  Madrid(eu-es)    | enmadridproductionpostgres , enpushmadridproductionpostgres                    | Frankfurt(eu-de)        |
|  BNPP(eu-fr2)     | en-bnpp-productionpostgres , enpush-bnpp-productionpostgres                    | France(eu-fr2)          |

The third backup is kept under **Push Notifications - DevStage** account to keep the backup of the customer data (PSQL data). We have provisioned a cos instance named **Event-Notifications-postgres-cos-backups-BCDR** under this account and below are the details about the bucket and the regions.


| Region | Bucket Name | Backup Region |
| :--- | :--- | :--- |
|  Dallas(us-south) | endallasproductionpostgres-bcdr , enpushdallasproductionpostgres-bcdr         | WDC(us-east)     | 
|  London(eu-gb)    | enlondonproductionpostgres-bcdr , enpushlondonproductionpostgres-bcdr         | Dallas(us-south) |
|  Sydney(au-syd)   | ensydneyproductionpostgres-bcdr , enpushsydneyproductionpostgres-bcdr         | London(eu-gb)    |
|  Frankfurt(eu-de) | en-frankfurtproductionpostgres-bcdr , en-pushfrankfurtproductionpostgres-bcdr | Madrid(eu-es)    |
|  Madrid(eu-es)    | enmadridproductionpostgres-bcdr  , enpushmadridproductionpostgres-bcdr        | Frankfurt(eu-de) |
|  BNPP(eu-fr2)     | enbnppproductionpostgres-bcdr, enpushbnppproductionpostgres-bcdr              | France(eu-fr2)   |

A scheduled Tekton pipeline job is created which creates dump of the PostgreSQL database for each region and uploads the dump to the COS bucket with the API key.

Since IBM Cloud Event Notifications service is a regional service and has presence in Dallas (us-south), London (eu-gb), Sydney (au-syd) and Frankfurt (eu-de), each of Dallas, London, Sydney and Frankfurt have PostgreSQL database instances respectively and each instances dump get uploaded in COS buckets created across different regions for recovery purposes.

Postgres database is fully backed up on the COS instance daily and the backups are  retained for 30 days

Note: By default COS applies encryption to all the objects stored in the buckets

### Daily Monitoring Job for PostgreSQL point in time backup:
--- 
A daily automated monitoring job for PostgreSQL point-in-time backup has been created to track the status of backups and alert in slack channel #event-notifications-monitoring, both in case of a failure or success. In case of a failure, a PagerDuty alert is also triggered to the on-call operations personnel for Event Notifications Service.

Since point-in-time backup is out of the box feature of PostgreSQL databases and hence in case of failure we create a ticket to the PostgreSQL databases support team.


### Daily Monitoring Job for PostgreSQL database backup in COS buckets:
--- 
A daily automated monitoring job is set up to backup PostgreSQL database every day and upload it to the COS bucket.

The job also tracks the status and alert in slack channel #event-notifications-monitoring in case of a failure or success.
### Tekton
--- 
The Tekton master instance is managed and backed-up by the IBM TAAS team. In case the instance breaks, a backup can be restored.
The slave instances do not hold critical data and are backed up locally.

### Backup COS Bucket Data to Another COS Bucket:

Data High Availability and Disaster Recovery

To ensure data high availability, we implement a backup strategy by copying data from one Cloud Object Storage (COS) instance to another COS instance.

Disaster Recovery Process

In the event of a disaster, we can recover the data by connecting the backed-up COS instance to the cluster. To do this, we:

- Update the credentials of the COS instance in the cluster secrets.
- Update the bucket details in the Persistent Volume Claim (PVC) and StatefulSet in the cluster.

## Vendor Contact list:
--- 
Additional Information: Vendor Contact list: https://ibm.box.com/s/nv5n325x5dzqu074r7003k59fl9q6gd3
The link contains two documents:
 - Spreadsheet with list of vendors and contact methods
 - Doc file with additional information about the spreadsheet, if needed

## Tests
--- 
### Expected Test Timeframe
--- 
Estimated time taken to execute the tests may be between 6 hours to 1 day.
### Containers restoration
--- 
After a disaster, first steps will require creating new clusters.
Technical recovery team will follow these steps for deployment of additional clusters in Dallas, and will write down the results, the duration of each step and the overall duration.
Deployment to a cluster can be via the pipeline or manually. Pipeline deployment is preferred way to deploy the service code. If pipeline is not available, deployment can be done manually.
### Backup restoration ICD PostgreSQL
--- 
PostgreSQL backup restoration test will involve the following mentioned:
 - For ICD PostgreSQL backup restored into new deployment.
 - Technical recovery team will restore the backup into new deployment by following backup restoration mechanism mentioned [here](https://cloud.ibm.com/docs/databases-for-postgresql?topic=databases-for-postgresql-getting-started&interface=ui)
 - Technical recovery team will check and verify the backup database manually.
•	Above process will be used for the restoration on production too.
Tests results will be documented on Github - recording the tests flow, results (actual vs expected), duration and any action items that might result from the tests.

## Communication route for BCDR notifications
In the event of service down or disaster scenario in any region, we raise a confirmed CIE incident using ciebot @ciebot. Once the CIE incident is opened an AVM is assigned to IBM Event Notifications who has the responsibility to send notifications to IBM Event Notifications service customers

Once the issue is resolved, IBM Event Notifications disaster recovery team provides the RCA. AVM attach the RCA with the PRB record and send notifications to the customer stating IBM Event Notifications service is up and running and they can start with there activities as usual.

