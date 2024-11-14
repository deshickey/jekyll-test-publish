---
layout: default
title: Bluegroup Data
type: Informational
grand_parent: Policies & Processess
parent: Accessgroup Mapping
---

Informational
{: .label }


# Bluegroup accounts

## Table of contents
* [Account access by role](#account-access-by-role)
* [Roles with access to each account](#Roles-with-access-to-each-account)

## Account access by role

| Role | Account | Access Groups |
| :---: | :-- | :-- |
| ROLE_ICCR_AUTOMATION-NON-PRODUCTION | IKS Bluegroups | alchemy-containers-jenkins-armada-microservices, alchemy-testing-jenkins-containers-build, alchemy-testing-jenkins-containers-registry |
| ROLE_ICCR_DEVELOPER | IKS Bluegroups | Alchemy%20-%20Dashboard%20users, alchemy-containers-jenkins-containers-build, alchemy-containers-jenkins-containers-registry, alchemy-containers-jenkins-vulnerability-advisor, alchemy-testing-jenkins-containers-build, alchemy-testing-jenkins-containers-registry |
| ROLE_IKS_AUTOMATION-ACCESSHUB | IKS Bluegroups | containers-launchdarkly |
| ROLE_IKS_AUTOMATION-BUILD | IKS Bluegroups | alchemy-containers-jenkins-armada-performance |
| ROLE_IKS_AUTOMATION-COMPLIANCE | IKS Bluegroups | Alchemy%20-%20Security%20Compliance, Containers%20Cluster%20Squad, alchemy-conductors-jenkins-conductors, containers-launchdarkly |
| ROLE_IKS_AUTOMATION-PERFORMANCE | IKS Bluegroups | alchemy-containers-jenkins-armada-performance, alchemy-testing-jenkins-armada-performance |
|  | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_IKS_AUTOMATION-SRE-BOT | IKS Bluegroups | alchemy-testing-jenkins-vpn |
| ROLE_IKS_DASHBOARD | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_IKS_DEVELOPER | IKS Bluegroups | Alchemy%20-%20Dashboard%20users, Alchemy-Containers-A, alchemy-testing-jenkins-armada-continuous-pvg |
| ROLE_IKS_DEVELOPER-BOOTSTRAP | IKS Bluegroups | alchemy-containers-jenkins-armada-microservices |
| ROLE_IKS_DEVELOPER-CARRIERRUNTIME | IKS Bluegroups | alchemy-containers-jenkins-armada-microservices, alchemy-testing-jenkins-containers-runtime |
| ROLE_IKS_DEVELOPER-CLUSTER | IKS Bluegroups | Containers%20Cluster%20Squad, alchemy-containers-jenkins-armada-microservices |
| ROLE_IKS_DEVELOPER-DEPLOY | IKS Bluegroups | alchemy-containers-jenkins-armada-microservices, alchemy-containers-jenkins-containers-jjb, alchemy-containers-jenkins-containers-runtime |
| ROLE_IKS_DEVELOPER-DEVOPS | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_IKS_DEVELOPER-DOCUMENTATION | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_IKS_DEVELOPER-INGRESS | IKS Bluegroups | alchemy-containers-jenkins-frontdoor |
| ROLE_IKS_DEVELOPER-IRONSIDES | IKS Bluegroups | alchemy-containers-jenkins-harbourmaster |
| ROLE_IKS_DEVELOPER-ISTIO-OPENSOURCE | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_IKS_DEVELOPER-MANAGERS | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_IKS_DEVELOPER-PERFORMANCE | IKS Bluegroups | alchemy-containers-jenkins-armada-performance, alchemy-testing-jenkins-armada-performance |
| ROLE_IKS_DEVELOPER-STORAGE | IKS Bluegroups | alchemy-containers-jenkins-armada-microservices, alchemy-containers-jenkins-containers-volumes, alchemy-containers-jenkins-osinnovationb, alchemy-containers_networking_storage |
| ROLE_IKS_DEVELOPER-UPDATE | IKS Bluegroups | alchemy-containers-jenkins-armada-microservices, alchemy-containers-jenkins-containers-jjb |
| ROLE_IKS_OPS-PRODUCTION-WATSON | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_IKS_SECURITY | IKS Bluegroups | Alchemy%20-%20Dashboard%20users, Alchemy%20-%20Security%20Compliance |
| ROLE_IKS_SRE-AU | IKS Bluegroups | Alchemy%20-%20Conductors%20Squad, Alchemy%20-%20Dashboard%20users, afaas-wcp-alchemy-team-ar-read, alchemy-conductors-jenkins-conductors, alchemy-testing-jenkins-containers-runtime, alchemy-testing-jenkins-vpn, containers-launchdarkly |
| ROLE_IKS_SRE-BNPP | IKS Bluegroups | Alchemy%20-%20Conductors%20Squad, Alchemy%20-%20Dashboard%20users, alchemy-conductors-jenkins-conductors, jaas-wcp-bnpp-iks-sre-team-admin, jaas-wcp-bnpp-iks-sre-team-admin |
|  | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_IKS_SRE-CN | IKS Bluegroups | Alchemy%20-%20Conductors%20Squad, Alchemy%20-%20Dashboard%20users, afaas-wcp-alchemy-team-ar-read, alchemy-conductors-jenkins-conductors, alchemy-testing-jenkins-containers-runtime, alchemy-testing-jenkins-vpn, containers-launchdarkly |
| ROLE_IKS_SRE-DE | IKS Bluegroups | Alchemy%20-%20Conductors%20Squad, Alchemy%20-%20Dashboard%20users, afaas-wcp-alchemy-team-ar-read, alchemy-conductors-jenkins-conductors, alchemy-testing-jenkins-containers-runtime, alchemy-testing-jenkins-vpn, containers-launchdarkly |
| ROLE_IKS_SRE-GB | IKS Bluegroups | Alchemy%20-%20Conductors%20Squad, Alchemy%20-%20Dashboard%20users, afaas-wcp-alchemy-team-ar-read, alchemy-conductors-jenkins-conductors, alchemy-testing-jenkins-containers-runtime, alchemy-testing-jenkins-vpn, containers-launchdarkly |
| ROLE_IKS_SRE-IE | IKS Bluegroups | Alchemy%20-%20Conductors%20Squad, Alchemy%20-%20Dashboard%20users, afaas-wcp-alchemy-team-ar-read, alchemy-conductors-jenkins-conductors, alchemy-testing-jenkins-containers-runtime, alchemy-testing-jenkins-vpn, containers-launchdarkly |
| ROLE_IKS_SRE-IN | IKS Bluegroups | Alchemy%20-%20Conductors%20Squad, Alchemy%20-%20Dashboard%20users, afaas-wcp-alchemy-team-ar-read, alchemy-conductors-jenkins-conductors, alchemy-testing-jenkins-containers-runtime, alchemy-testing-jenkins-vpn, containers-launchdarkly |
| ROLE_IKS_SRE-LEADS-AU | IKS Bluegroups | afaas-wcp-alchemy-team-ar-write |
| ROLE_IKS_SRE-LEADS-CN | IKS Bluegroups | afaas-wcp-alchemy-team-ar-write |
| ROLE_IKS_SRE-LEADS-DE | IKS Bluegroups | afaas-wcp-alchemy-team-ar-write |
| ROLE_IKS_SRE-LEADS-GB | IKS Bluegroups | afaas-wcp-alchemy-team-ar-write |
| ROLE_IKS_SRE-LEADS-IE | IKS Bluegroups | afaas-wcp-alchemy-team-ar-write |
| ROLE_IKS_SRE-LEADS-IN | IKS Bluegroups | afaas-wcp-alchemy-team-ar-write |
| ROLE_IKS_SRE-LEADS-US | IKS Bluegroups | afaas-wcp-alchemy-team-ar-write |
| ROLE_IKS_SRE-NETINT | IKS Bluegroups | Alchemy%20-%20Dashboard%20users, alchemy-conductors-jenkins-conductors, alchemy-containers-jenkins-armada-microservices, alchemy-containers-jenkins-network-intelligence |
| ROLE_IKS_SRE-NETINT-AUTOMATION | IKS Bluegroups | alchemy-conductors-jenkins-conductors, alchemy-containers-jenkins-armada-microservices, alchemy-containers-jenkins-network-intelligence |
| ROLE_IKS_SRE-SUPERADMIN | IKS Bluegroups | containers-launchdarkly |
| ROLE_IKS_SRE-US | IKS Bluegroups | Alchemy%20-%20Conductors%20Squad, Alchemy%20-%20Dashboard%20users, afaas-wcp-alchemy-team-ar-read, alchemy-conductors-jenkins-conductors, alchemy-testing-jenkins-containers-runtime, alchemy-testing-jenkins-vpn, containers-launchdarkly |
| ROLE_LAUNCHDARKLY_CF-ADMIN | IKS Bluegroups | containers-launchdarkly |
| ROLE_LAUNCHDARKLY_CF-READER | IKS Bluegroups | containers-launchdarkly |
| ROLE_LAUNCHDARKLY_CF-WRITER | IKS Bluegroups | containers-launchdarkly |
| ROLE_LAUNCHDARKLY_IKS-ADMIN | IKS Bluegroups | containers-launchdarkly |
| ROLE_LAUNCHDARKLY_IKS-READER | IKS Bluegroups | containers-launchdarkly |
| ROLE_LAUNCHDARKLY_IKS-WRITER | IKS Bluegroups | containers-launchdarkly |
| ROLE_RAZEE_DEVELOPER | IKS Bluegroups | Alchemy%20-%20Dashboard%20users, satellite-config |
| ROLE_SAT_DEVELOPER-LINK | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_SAT_LINK-SRE-CA | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_SAT_LINK-SRE-DE | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_SAT_LINK-SRE-GB | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_SAT_LINK-SRE-IT | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |
| ROLE_SAT_LINK-SRE-US | IKS Bluegroups | Alchemy%20-%20Dashboard%20users |

## Roles with access to each account

| Account | AccessGroup | Roles |
| :---: | :-- | :-- |
| IKS Bluegroups | Alchemy%20-%20Conductors%20Squad | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP |
|  | Alchemy%20-%20Dashboard%20users | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-BNPP, ROLE_IKS_DASHBOARD, ROLE_IKS_DEVELOPER-MANAGERS, ROLE_SAT_DEVELOPER-LINK, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US, ROLE_SAT_LINK-SRE-CA, ROLE_IKS_DEVELOPER-ISTIO-OPENSOURCE, ROLE_IKS_OPS-PRODUCTION-WATSON, ROLE_IKS_DEVELOPER-DEVOPS, ROLE_IKS_SRE-BNPP, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_DEVELOPER-DOCUMENTATION |
|  | Alchemy%20-%20Security%20Compliance | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_SECURITY |
|  | Alchemy-Containers-A | ROLE_IKS_DEVELOPER |
|  | Containers%20Cluster%20Squad | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_DEVELOPER-CLUSTER |
|  | afaas-wcp-alchemy-team-ar-read | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | afaas-wcp-alchemy-team-ar-write | ROLE_IKS_SRE-LEADS-AU, ROLE_IKS_SRE-LEADS-CN, ROLE_IKS_SRE-LEADS-IN, ROLE_IKS_SRE-LEADS-DE, ROLE_IKS_SRE-LEADS-IE, ROLE_IKS_SRE-LEADS-GB, ROLE_IKS_SRE-LEADS-US |
|  | alchemy-conductors-jenkins-conductors | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-BNPP |
|  | alchemy-containers-jenkins-armada-microservices | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_IKS_DEVELOPER-CARRIERRUNTIME, ROLE_IKS_DEVELOPER-CLUSTER, ROLE_IKS_DEVELOPER-DEPLOY, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_DEVELOPER-STORAGE, ROLE_IKS_DEVELOPER-UPDATE, ROLE_IKS_DEVELOPER-BOOTSTRAP |
|  | alchemy-containers-jenkins-armada-performance | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_DEVELOPER-PERFORMANCE |
|  | alchemy-containers-jenkins-containers-build | ROLE_ICCR_DEVELOPER |
|  | alchemy-containers-jenkins-containers-jjb | ROLE_IKS_DEVELOPER-DEPLOY, ROLE_IKS_DEVELOPER-UPDATE |
|  | alchemy-containers-jenkins-containers-registry | ROLE_ICCR_DEVELOPER |
|  | alchemy-containers-jenkins-containers-runtime | ROLE_IKS_DEVELOPER-DEPLOY |
|  | alchemy-containers-jenkins-containers-volumes | ROLE_IKS_DEVELOPER-STORAGE |
|  | alchemy-containers-jenkins-frontdoor | ROLE_IKS_DEVELOPER-INGRESS |
|  | alchemy-containers-jenkins-harbourmaster | ROLE_IKS_DEVELOPER-IRONSIDES |
|  | alchemy-containers-jenkins-network-intelligence | ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | alchemy-containers-jenkins-osinnovationb | ROLE_IKS_DEVELOPER-STORAGE |
|  | alchemy-containers-jenkins-vulnerability-advisor | ROLE_ICCR_DEVELOPER |
|  | alchemy-containers_networking_storage | ROLE_IKS_DEVELOPER-STORAGE |
|  | alchemy-testing-jenkins-armada-continuous-pvg | ROLE_IKS_DEVELOPER |
|  | alchemy-testing-jenkins-armada-performance | ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_DEVELOPER-PERFORMANCE |
|  | alchemy-testing-jenkins-containers-build | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER |
|  | alchemy-testing-jenkins-containers-registry | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER |
|  | alchemy-testing-jenkins-containers-runtime | ROLE_IKS_DEVELOPER-CARRIERRUNTIME, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | alchemy-testing-jenkins-vpn | ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | containers-launchdarkly | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_LAUNCHDARKLY_IKS-READER, ROLE_LAUNCHDARKLY_IKS-ADMIN, ROLE_LAUNCHDARKLY_IKS-WRITER, ROLE_LAUNCHDARKLY_CF-READER, ROLE_LAUNCHDARKLY_CF-WRITER, ROLE_LAUNCHDARKLY_CF-ADMIN, ROLE_IKS_SRE-SUPERADMIN |
|  | jaas-wcp-bnpp-iks-sre-team-admin | ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-BNPP |
|  | satellite-config | ROLE_RAZEE_DEVELOPER |
