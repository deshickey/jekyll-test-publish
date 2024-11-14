---
layout: default
title: "AI Assistant Networking Overview"
runbook-name: "AI Assistant Networking Overview"
description: "AI Assistant Networking Overview"
service: "AI Assistant"
tags: ai-assistant
link: /ai-assistant/operations/overview/networking.html
type: Informational
parent: AI Assistant
grand_parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document provides Istio and VPC information about the cluster configuration and Istio Egress / Ingress

## Detailed Information

### VPC Layout

The following information is a summary of the clusters supporting the AI Assistant service. All ingress and egress
traffic will flow through the edge and public gateways identified.

This information can be used to track calls through CIS and/or Akamai in the case of networking issues.

#### Development [ dn-dev-d-context-help ]

| VPC Region | VPC Name                   | Cluster                        | Subnet                               | Public Gateway  |
|------------|----------------------------|--------------------------------|--------------------------------------|-----------------|
| London     | context-help-dev-lon01-vpc | context-help-dev-lon01-cluster | context-help-dev-lon01-edge-subnet-1 | 158.175.185.6   |
| London     | context-help-dev-lon02-vpc | context-help-dev-lon02-cluster | context-help-dev-lon02-edge-subnet-1 | 158.175.177.169 |

#### Staging [ dn-stage-s-cpapi-extended ]

| VPC Region | VPC Name             | Cluster                          | Subnet                         | Public Gateway  |
|------------|----------------------|----------------------------------|--------------------------------|-----------------|
| Frankfurt  | cpapi-ext-eu-de-vpc  | cpapi-ext-stage-fra-1-01-cluster | cpapi-ext-eu-de-edge-subnet-1  | 149.81.3.155    |
| Sydney     | cpapi-ext-au-syd-vpc | cpapi-ext-stage-syd-1-01-cluster | cpapi-ext-au-syd-edge-subnet-1 | 159.23.90.86    |
| London     | cpapi-ext-eu-gb-vpc  | cpapi-ext-stage-lon-1-01-cluster | cpapi-ext-eu-gb-edge-subnet-1  | 161.156.196.172 |

#### Production [ dn-prod-s-cpapi-extended ]

| VPC Region | VPC Name          | Cluster                          | Subnet                      | Public Gateway |
|------------|-------------------|----------------------------------|-----------------------------|----------------|
| Frankfurt  | cpapi-eu-de-vpc   | cpapi-eu-de-fra02-0001-cluster   | cpapi-eu-de-edge-subnet-1   | 149.81.3.134   |
| Sydney     | cpapi-au-syd-vpc  | cpapi-au-syd-syd01-0001-cluster  | cpapi-au-syd-edge-subnet-1  | 159.23.93.208  |
| Washington | cpapi-us-east-vpc | cpapi-us-east-wdc04-0001-cluster | cpapi-us-east-edge-subnet-1 | 150.239.85.112 |

### Istio Mesh

The mesh needs to be updated any time

- A new IBM Cloud instance needs to be accessible from a microservice ( i.e. ICD database )
- A host needs to be added to the egress so it is available
- New endpoints are needed in the ingress

Istio configurations are deployed via the standard CICD process

#### Hosts in Egress

Hosts used in egress should not contain paths to any specific resource. Wildcards should not be used.

The following external hosts are accessible to the AI Assistant services

| Host                                                                                                        |   Dev   |  Stage  |  Prod   | Associated Service(s)                                                                                                                         |
|-------------------------------------------------------------------------------------------------------------|:-------:|:-------:|:-------:|-----------------------------------------------------------------------------------------------------------------------------------------------|
| slack.com                                                                                                   | Allowed | Allowed | Allowed | slack-notifier-service                                                                                                                        |
| hooks.slack.com                                                                                             | Allowed | Allowed | Allowed | slack-notifier-service                                                                                                                        |
| iam.cloud.ibm.com                                                                                           | REMOVE  | REMOVE  | Allowed | ai-assistant-component, contextual-search,  data-filter, query-classifier, query-processor, slack-notifier-service,agentic-assistant-service  |
| iam.test.cloud.ibm.com                                                                                      | Allowed | Allowed | REMOVE  | ai-assistant-component, contextual-search,  data-filter, query-classifier, query-processor, slack-notifier-service, agentic-assistant-service |
| test.cloud.ibm.com                                                                                          | Allowed | Allowed | REMOVE  | ai-assistant-component                                                                                                                        |
| api.eu-gb.natural-language-understanding.watson.cloud.ibm.com                                               | Allowed | Allowed | Allowed | data-filter, query-classifier                                                                                                                 |
| google.com                                                                                                  | Allowed | Allowed | Allowed | Python package                                                                                                                                |
| huggingface.co                                                                                              | Allowed | Allowed | Allowed | Python package                                                                                                                                |
| login.w3.ibm.com                                                                                            | Blocked | Blocked | Allowed | question-response-analyzer                                                                                                                    |
| preprod.login.w3.ibm.com                                                                                    | Allowed | Allowed | REMOVE  | question-response-analyzer                                                                                                                    |
| api.eu-gb.language-translator.watson.cloud.ibm.com                                                          | REMOVE  | Allowed | REMOVE  | query-processor                                                                                                                               |
| api.eu-de.language-translator.watson.cloud.ibm.com                                                          | Blocked | Blocked | Allowed | query-processor                                                                                                                               |
| eu-gb.monitoring.cloud.ibm.com                                                                              | Allowed | Allowed | Blocked | query-processor                                                                                                                               |
| mt-api.straker.global                                                                                       | Allowed | REMOVE  | REMOVE  | query-processor, agentic-assistant-service                                                                                                    |
| us-south.appid.cloud.ibm.com                                                                                | Allowed | REMOVE  | REMOVE  | query-processor                                                                                                                               |
| github.ibm.com                                                                                              | Allowed | Allowed | Allowed | question-response-analyzer                                                                                                                    |
| eu-de.monitoring.cloud.ibm.com                                                                              | Blocked | Allowed | Allowed | query-processor                                                                                                                               |
| au-syd.monitoring.cloud.ibm.com                                                                             | Blocked | Allowed | Allowed | query-processor                                                                                                                               |
| us-east.monitoring.cloud.ibm.com                                                                            | Blocked | Blocked | Allowed | query-processor                                                                                                                               |
| cloud.ibm.com                                                                                               | Blocked | Blocked | Allowed | ai-assistant-component                                                                                                                        |
| ai-assistant.cloud.ibm.com                                                                                  | Blocked | Blocked | Allowed | NO SERVICE                                                                                                                                    |
| us-south.ml.cloud.ibm.com                                                                                   | Allowed | Allowed | Allowed | agentic-assistant-service                                                                                                                     |
| eu-gb.ml.cloud.ibm.com                                                                                      | Allowed | Allowed | Allowed | agentic-assistant-service                                                                                                                     |
| docs-search.global-search-tagging.cloud.ibm.com                                                             | Allowed | Allowed | Allowed | contextual-search                                                                                                                             |
| www-api.ibm.com                                                                                             | Allowed | Allowed | Allowed | NO SERVICE                                                                                                                                    |
| ibmdocs-proxy.unified-search-kube-7ca05a4d8f79f63aa92c53f018863c50-0000.us-south.containers.appdomain.cloud | Allowed | Allowed | Allowed | NO SERVICE                                                                                                                                    |
| ai-assistant.dev.cloud.ibm.com                                                                              | Allowed | Blocked | Blocked | question-response-analyzer                                                                                                                    |
| api.eu-de.natural-language-understanding.watson.cloud.ibm.com                                               | Blocked | Blocked | Allowed | NO SERVICE                                                                                                                                    |
| ai-assistant.test.cloud.ibm.com                                                                             | Blocked | Allowed | Blocked | NO SERVICE                                                                                                                                    |
| api.us-south.language-translator.watson.cloud.ibm.com                                                       | Allowed | Allowed | Allowed | NO SERVICE                                                                                                                                    |
| api.dataplatform.cloud.ibm.com                                                                              | Allowed | Allowed | Allowed | NO SERVICE                                                                                                                                    |
| api.us-south.natural-language-understanding.watson.cloud.ibm.com                                            | Allowed | Allowed | Allowed | NO SERVICE                                                                                                                                    |

#### Routes in Ingress

The ports specified in the ingress needs to match the value for the **Service.ports.protocol: TCP** value in the helm
chart for the service

| Route                       | Target Service                                               | Port | Specified in                    |
|-----------------------------|--------------------------------------------------------------|------|---------------------------------|
| /question-response-analyzer | question-response-analyzer-service.filters.svc.cluster.local | 3001 | service.yaml                    |
| /ai-contextual-help         | query-processor-service.filters.svc.cluster.local            | 3002 | service.yaml                    |
| /contextual-ui/ai-help      | ai-assistant-component-service.filters.svc.cluster.local     | 3004 | values.yaml:  HttpContainerPort |

## Further Information

Istio configuration files: <https://github.ibm.com/ai-content/istio-config>
