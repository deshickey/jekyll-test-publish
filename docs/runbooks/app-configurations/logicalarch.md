---
layout: default
title: IBM Cloud App Configuration Logical Architecture
type: Informational
runbook-name: "IBM Cloud App Configuration Logical Architecture"
description: "IBM Cloud App Configuration Logical Architecture"
service: App Configuration
tags: app-configurations
link: /app-configurations/logicalarch.html
parent: App Configs
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
# Logical Architecture

IBM Cloud App Configuration service is a regional service deployed and managed regionally.  All below mentioned components of the service exist in each regions.

The diagram below shows how the functional components and micro services are layered.  This diagram shows the runtime dependencies.  For the full list of dependencies refer [here](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/dependencies.html)

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/logicalarch.png" width="640" />

## Detailed Information
## Service Components 

- [Logical Architecture](#logical-architecture)
  - [Service Components](#service-components)
    - [Service Runtime](#service-runtime)
      - [Service Gateway](#service-gateway)
      - [Config Server](#config-server)
      - [Events Server](#events-server)
      - [Data Encryption Handler](#data-encryption-handler)
      - [Webhook Handler](#webhook-handler)
    - [Service Broker](#service-broker)
    - [Service Dashboard](#service-dashboard)
    - [pgbouncer](#pgbouncer)
    - [SDKs](#sdks)

**Design Concepts**

* Service Runtime contains Gateway component and this is the single point of entry in to the service functionalities.  
* Gateway component is responsible for routing, authentication and service health consolidation.
* Whenever a new service instance is provisioned, a set of resources uniquely associated with the service instance are created and associated with the service Guid. Every call to the Service will include the guid to resolve to the right resources
* Every microservice in the architecture can be horizontally scaled to serve increasing load
* PostgreSQL used as the primary data store to store configuration and client registration / handling data
* All these components connect to the postgresql via Pgbouncer.  All components are configured to connect to pgbouncer and pgbouncer connects to the database.
* Redis is used as the temporary cache to store transient data


### Service Runtime

The Service Runtime follows Microservices architecture style - composed of several services. 

* Service Gateway Component
* Feature Server
* Events Server
* Data Encryption Handler
* Webhook Handler
  
The architecture of each of the above individual microservices is discussed below.

#### Service Gateway

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/components-gateway.png" width="640" />

* Single point of entry to the service
* Authorization (IAM Based)
* Health checking end point that reports health of the Service runtime (includes all the dependencies and other microservices)
* Serviceability using LogDNA
  
**Stack**

* GoLang
  * go-lua
* nginx configuration
* Postgresql Client
* Redis Client

#### Config Server

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/components-feature.png" width="640" />

* Handle Collections, Environments, Features & Segmentation.
* Expose REST APIs
* Exposes Websocket and SSE endpoint for the SDKs
* Expose Health end point for Config server
* Store persistent storage to Postgresql database
* Serviceability using LogDNA

**Stack**

* IBM Java 8
* Maven 3.5.8
  * Postgresql Client
  * Other approved maven library packages
  

#### Events Server

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/components-events.png" width="640" />

* Handle all asynchronous actions for the service.
* Handles billing for the service consumption.
* Expose REST APIs to post feature evaluation from SDK
* Expose Health end-point for Events server
* Store persistent Evaluation Insights to Postgresql database.
* Serviceability using LogDNA.
  
**Stack**

* IBM Java 8
* Maven 3.5.8
  * Postgresql Client
  * Redis Client
  * Other approved maven library packages

#### Data Encryption Handler 

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/components-dataencryptionhandler.png" width="640" />

* Handle the data encryption related operations.
* Interact with kms services (key protect, hpcs) to achieve BYOK.
* Expose webhook endpoint to receive hyperwarp events from kms services.
* Expose Health endpoint for Data Encryption handler.
* Logging using LogDNA

**Stack**

* GoLang
* Postgresql Client
* Redis Client

#### Webhook Handler 

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/components-webhookhandler.png" width="640" />

* Handles the event callback from ServiceNow for Approval Workflow functionality.
* Updates the feature flag state upon approval of Change Requests (CR) in ServiceNow.
* Expose webhook endpoint to receive callback from ServiceNow.
* Expose Health endpoint for Webhook handler.
* Logging using LogDNA

**Stack**

* GoLang
* Postgresql Client


### Service Broker

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/components-broker.png" width="640" />

* Provisioning layer that manages the lifecycle of Service instances. Service broker supports only the Resource Controller (RC) compliant model.
* Service broker is a provision-through resources: [OSB compliant](http://openservicebrokerapi.org)
* Refer [IBM Cloud Resource Broker API](https://cloud.ibm.com/apidocs/ibm-cloud-osb-api) for further details.

**Stack**

* Node 
* NPM

### Service Dashboard

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/components-dashboard.png" width="640" />

* An user interface for all service operations.
* Secure access
* Integrates into IBM Cloud console
* Global console compliant.  Based on Carbon components.  

**Stack**

* Node
* NPM


### pgbouncer

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/components-pgbouncer.png" width="640" />

* Front ends all communication to Postgresql
* Open Source component
* Serviceability using LogDNA.

### SDKs

<img src="https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/app-configurations/assets/components-sdk.png" width="640" />

* Platform specific SDKs for Feature
* Communication layer to work with the Service runtime
* User friendly APIs
* Controlled requests to Service runtime in order to not fall into enforced rate limits
* Get updates from Config server using websocket protocol.
* Browser SDKs for JavaScript and React use SSE protocol to recieve real-time config update.