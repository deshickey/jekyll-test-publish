---
layout: default
title: GitHub Data
type: Informational
grand_parent: Policies & Processess
parent: Accessgroup Mapping
---

Informational
{: .label }

# Github accounts

## Table of contents
* [Account access by role](#account-access-by-role)
* [Roles with access to each account](#Roles-with-access-to-each-account)
	
## Account access by role

| Role | Account | Teams |
| :---: | :-- | :-- |
| ROLE_CF_IKS-ADMIN | alchemy-containers | Cloudflare-Admin |
| ROLE_CF_IKS-READER | alchemy-containers | Cloudflare-Reader |
| ROLE_CF_SAT-READER | alchemy-containers | Cloudflare-Reader |
| ROLE_ICCR_AUTOMATION-NON-PRODUCTION | alchemy-registry | registry |
|  | alchemy-va | Registry dev squad |
| ROLE_ICCR_DEVELOPER | alchemy-containers |  |
| ROLE_ICCR_DEVELOPER-LEAD | alchemy-va | Project Management |
| ROLE_ICCR_DEVELOPER-REGISTRY | alchemy-containers | registry |
|  | alchemy-registry | registry |
|  | alchemy-va | Registry dev squad |
| ROLE_ICCR_DEVELOPER-VA | alchemy-containers | VA, va-cli |
|  | alchemy-registry | va |
|  | alchemy-va | VA dev squad |
| ROLE_ICCR_DOCUMENTATION | alchemy-registry | docs |
|  | alchemy-va | Docs, Docs Admin |
| ROLE_ICCR_SECURITY | alchemy-registry | Security Squad |
|  | alchemy-va | Security squad |
| ROLE_ICCR_SECURITY-BISO | alchemy-registry | Auditree BISO Monitoring |
|  | alchemy-va | Auditree BISO Monitoring Team |
| ROLE_ICCR_SRE-AU | alchemy-registry |  |
|  | alchemy-va |  |
| ROLE_ICCR_SRE-DE | alchemy-registry |  |
|  | alchemy-va |  |
| ROLE_ICCR_SRE-GB | alchemy-registry |  |
|  | alchemy-va |  |
| ROLE_ICCR_SRE-IE | alchemy-registry |  |
|  | alchemy-va |  |
| ROLE_ICCR_SRE-IN | alchemy-registry |  |
|  | alchemy-va |  |
| ROLE_ICCR_SRE-US | alchemy-registry |  |
|  | alchemy-va |  |
| ROLE_IKS_AUTOMATION-ACCESSHUB | alchemy-auditree |  |
|  | alchemy-conductors |  |
|  | alchemy-containers |  |
|  | alchemy-netint |  |
|  | alchemy-registry |  |
|  | alchemy-va |  |
| ROLE_IKS_AUTOMATION-ALCHEMYTESTSQUAD | alchemy-containers |  |
| ROLE_IKS_AUTOMATION-BUILD | alchemy-conductors | approvers, conductors |
|  | alchemy-containers | Security squad, armada-ops, conductors |
|  | alchemy-netint | netint |
|  | alchemy-registry | registry |
|  | alchemy-va |  |
| ROLE_IKS_AUTOMATION-COMPLIANCE | alchemy-auditree |  |
|  | alchemy-containers | armada-bootstrap-squad |
|  | alchemy-netint | netint |
| ROLE_IKS_AUTOMATION-CONTAINERBOT | alchemy-containers | fr8r-maintainers, fr8r-writers |
| ROLE_IKS_AUTOMATION-ICDEVOPS | alchemy-containers | conductors |
| ROLE_IKS_AUTOMATION-INGRESS | alchemy-containers | Cloudflare-Admin |
| ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY | alchemy-containers | runtime |
| ROLE_IKS_AUTOMATION-SERVICENOW-DEV | alchemy-containers | snowdev |
| ROLE_IKS_BNPP-AUTOMATION-PRODUCTION | alchemy-conductors | conductors, dublin-sre |
|  | alchemy-containers | conductors, dublin-sre, update-squad |
| ROLE_IKS_BNPP-AUTOMATION-PRODUCTION-TESTING | alchemy-containers | armada-deploy-squad |
| ROLE_IKS_COMPLIANCE-MEDIA-CUSTODIAN | alchemy-conductors | media-custodians |
| ROLE_IKS_DEVELOPER | alchemy-auditree | IKS Vulnerability Review |
|  | alchemy-containers | IKS Vulnerability Notifications, Stalker Mergers |
| ROLE_IKS_DEVELOPER-API | alchemy-containers | api, api-approvers, cli-approvers, ironsides, runtime |
| ROLE_IKS_DEVELOPER-ARMADADATA | alchemy-containers | ballast |
| ROLE_IKS_DEVELOPER-AUTOSCALE | alchemy-containers | Autoscaling |
| ROLE_IKS_DEVELOPER-BOOTSTRAP | alchemy-containers | armada-bootstrap-squad |
| ROLE_IKS_DEVELOPER-CARRIERRUNTIME | alchemy-conductors | carrier-runtime |
|  | alchemy-containers | armada-carrier |
| ROLE_IKS_DEVELOPER-CLUSTER | alchemy-conductors | cluster-squad |
|  | alchemy-containers | cluster-squad |
| ROLE_IKS_DEVELOPER-CLUSTER-ADMIN | alchemy-containers | cluster-squad-admins |
| ROLE_IKS_DEVELOPER-DEPLOY | alchemy-containers | armada-deploy-squad, fr8r-admins, fr8r-maintainers, fr8r-writers, k8s-squad, runtime, runtime-mergers |
| ROLE_IKS_DEVELOPER-DESIGN | alchemy-containers | Design |
| ROLE_IKS_DEVELOPER-DEVOPS | alchemy-containers | Devops-thoughtlords |
| ROLE_IKS_DEVELOPER-DOCKER | alchemy-containers | docker-infra-owner, os-innovation-b |
| ROLE_IKS_DEVELOPER-DOCUMENTATION | alchemy-containers | docs |
|  | alchemy-va | Docs, Docs Admin |
| ROLE_IKS_DEVELOPER-EXTENDED-UI | alchemy-containers | ui-squad-extended-india |
| ROLE_IKS_DEVELOPER-HYBRID | alchemy-containers | armada-hybrid |
| ROLE_IKS_DEVELOPER-ICE | alchemy-containers | ICE |
| ROLE_IKS_DEVELOPER-INGRESS | alchemy-conductors | ingress-squad |
|  | alchemy-containers | FrontDoor, armada-ingress |
| ROLE_IKS_DEVELOPER-ISTIO | alchemy-containers | armada-istio |
| ROLE_IKS_DEVELOPER-ISTIO-OPENSOURCE | alchemy-containers | istio-contributors |
| ROLE_IKS_DEVELOPER-KEDGE | alchemy-containers | kedge |
| ROLE_IKS_DEVELOPER-MANAGERS | alchemy-containers | management |
| ROLE_IKS_DEVELOPER-MULTIARCH | alchemy-containers | multiarch-team, system-z |
| ROLE_IKS_DEVELOPER-NETWORK | alchemy-containers | armada-network-squad, networking |
| ROLE_IKS_DEVELOPER-OFFERING | alchemy-containers | Offering Management |
| ROLE_IKS_DEVELOPER-PERFORMANCE | alchemy-containers | performance |
| ROLE_IKS_DEVELOPER-PIPELINE | alchemy-containers | dove |
| ROLE_IKS_DEVELOPER-SANDBOX | alchemy-containers | armada-sandbox |
| ROLE_IKS_DEVELOPER-SIGEX | alchemy-containers | signature-experience |
| ROLE_IKS_DEVELOPER-STORAGE | alchemy-containers | storage |
| ROLE_IKS_DEVELOPER-UI | alchemy-containers | Design, UI, mks-ui |
| ROLE_IKS_DEVELOPER-UI-ADMIN | alchemy-containers | ui-approvers |
| ROLE_IKS_DEVELOPER-UPDATE | alchemy-containers | update-squad |
| ROLE_IKS_SECURE_APPROVERS | alchemy-containers | razee-prod-approvers |
| ROLE_IKS_SECURE_SECRET_APPROVER | alchemy-containers | secure-secret-approvers |
| ROLE_IKS_SECURITY | alchemy-auditree | IKS SRE |
|  | alchemy-conductors | security |
|  | alchemy-containers | Security squad |
|  | alchemy-netint | Security squad |
| ROLE_IKS_SECURITY-AUDIT | alchemy-auditree | Security Audit Team |
|  | alchemy-containers | Security Audit Team |
| ROLE_IKS_SECURITY-AUDITREE | alchemy-auditree | Auditree BISO Monitoring Team - public_cloud_biso |
| ROLE_IKS_SRE | alchemy-conductors | conductors |
|  | alchemy-containers | armada-ops, conductors |
| ROLE_IKS_SRE-AU | alchemy-auditree | IKS SRE, IKS Vulnerability Review |
|  | alchemy-conductors | conductors |
|  | alchemy-containers | Cloudflare-Reader, IKS Vulnerability Notifications, armada-ops, conductors |
| ROLE_IKS_SRE-BNPP | alchemy-conductors | conductors, dublin-sre |
|  | alchemy-containers | armada-ops, conductors, dublin-sre |
| ROLE_IKS_SRE-CN | alchemy-auditree | IKS SRE |
|  | alchemy-conductors | conductors |
|  | alchemy-containers | Cloudflare-Reader, armada-ops, conductors |
| ROLE_IKS_SRE-DE | alchemy-auditree | IKS SRE |
|  | alchemy-conductors | conductors |
|  | alchemy-containers | Cloudflare-Reader, armada-ops, conductors |
| ROLE_IKS_SRE-DEDICATED | alchemy-containers | Dedicated |
| ROLE_IKS_SRE-GB | alchemy-auditree | IKS SRE, IKS Vulnerability Review |
|  | alchemy-conductors | conductors |
|  | alchemy-containers | Cloudflare-Reader, IKS Vulnerability Notifications, armada-ops, conductors |
| ROLE_IKS_SRE-IE | alchemy-auditree | IKS SRE, IKS Vulnerability Review |
|  | alchemy-conductors | conductors |
|  | alchemy-containers | Cloudflare-Reader, IKS Vulnerability Notifications, armada-ops, conductors |
| ROLE_IKS_SRE-IN | alchemy-auditree | IKS SRE, IKS Vulnerability Review |
|  | alchemy-conductors | conductors |
|  | alchemy-containers | Cloudflare-Reader, IKS Vulnerability Notifications, armada-ops, conductors |
| ROLE_IKS_SRE-LEAD-AU | alchemy-netint |  |
| ROLE_IKS_SRE-LEAD-CN | alchemy-netint |  |
| ROLE_IKS_SRE-LEAD-DE | alchemy-netint |  |
| ROLE_IKS_SRE-LEAD-GB | alchemy-netint |  |
| ROLE_IKS_SRE-LEAD-IE | alchemy-netint |  |
| ROLE_IKS_SRE-LEAD-IN | alchemy-netint |  |
| ROLE_IKS_SRE-LEAD-US | alchemy-netint |  |
| ROLE_IKS_SRE-LEADS-AU | alchemy-conductors | approvers, local_users_non-eu |
|  | alchemy-containers | Cloudflare-Superadmin, conductors-admin |
| ROLE_IKS_SRE-LEADS-CN | alchemy-conductors | approvers |
|  | alchemy-containers | Cloudflare-Superadmin, conductors-admin |
| ROLE_IKS_SRE-LEADS-DE | alchemy-conductors | approvers, local_users_eu, local_users_non-eu |
|  | alchemy-containers | Cloudflare-Superadmin, conductors-admin |
| ROLE_IKS_SRE-LEADS-GB | alchemy-conductors | approvers, local_users_non-eu |
|  | alchemy-containers | Cloudflare-Superadmin, conductors-admin |
| ROLE_IKS_SRE-LEADS-IE | alchemy-conductors | approvers, local_users_eu, local_users_non-eu |
|  | alchemy-containers | Cloudflare-Superadmin, conductors-admin |
| ROLE_IKS_SRE-LEADS-IN | alchemy-conductors | approvers, local_users_non-eu |
|  | alchemy-containers | Cloudflare-Superadmin, conductors-admin |
| ROLE_IKS_SRE-LEADS-US | alchemy-conductors | approvers, local_users_non-eu |
|  | alchemy-containers | Cloudflare-Superadmin, conductors-admin |
| ROLE_IKS_SRE-NETINT | alchemy-auditree | IKS Vulnerability Review |
|  | alchemy-conductors |  |
|  | alchemy-containers | Cloudflare-Admin, IKS Vulnerability Notifications, netint |
|  | alchemy-netint | netint |
| ROLE_IKS_SRE-NETINT-AUTOMATION | alchemy-conductors | conductors, dublin-sre |
|  | alchemy-netint | netint |
| ROLE_IKS_SRE-US | alchemy-auditree | IKS SRE, IKS Vulnerability Review |
|  | alchemy-conductors | conductors |
|  | alchemy-containers | Cloudflare-Reader, IKS Vulnerability Notifications, armada-ops, conductors |
| ROLE_IKS_SUPPORT-ACS | alchemy-containers | Support-ACS |
| ROLE_RAZEE_DEVELOPER | alchemy-auditree | Satellite Vulnerability Review |
|  | alchemy-containers | Satellite Config, Satellite Vulnerability Notifications, dove, razee |
| ROLE_SAT_DEVELOPER-LINK | alchemy-auditree | Satellite Vulnerability Review |
|  | alchemy-containers | Satellite Vulnerability Notifications, Satellite-Link, Satellite-Mesh |
| ROLE_SAT_LINK-SRE-CA | alchemy-containers | Cloudflare-Reader |
| ROLE_SAT_LINK-SRE-DE | alchemy-containers | Cloudflare-Reader |
| ROLE_SAT_LINK-SRE-GB | alchemy-containers | Cloudflare-Reader |
| ROLE_SAT_LINK-SRE-IT | alchemy-containers | Cloudflare-Reader |
| ROLE_SAT_LINK-SRE-US | alchemy-containers | Cloudflare-Reader |

## Roles with access to each account

| Account | Teams | Roles |
| :---: | :-- | :-- |
| alchemy-auditree | Auditree BISO Monitoring Team - public_cloud_biso | ROLE_IKS_SECURITY-AUDITREE |
|  | IKS SRE | ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | IKS Vulnerability Review | ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | Satellite Vulnerability Review | ROLE_RAZEE_DEVELOPER, ROLE_SAT_DEVELOPER-LINK |
|  | Security Audit Team | ROLE_IKS_SECURITY-AUDIT |
| alchemy-conductors | approvers | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-LEADS-AU, ROLE_IKS_SRE-LEADS-CN, ROLE_IKS_SRE-LEADS-DE, ROLE_IKS_SRE-LEADS-IE, ROLE_IKS_SRE-LEADS-IN, ROLE_IKS_SRE-LEADS-GB, ROLE_IKS_SRE-LEADS-US |
|  | carrier-runtime | ROLE_IKS_DEVELOPER-CARRIERRUNTIME |
|  | cluster-squad | ROLE_IKS_DEVELOPER-CLUSTER |
|  | conductors | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION |
|  | dublin-sre | ROLE_IKS_BNPP-AUTOMATION-PRODUCTION, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | ingress-squad | ROLE_IKS_DEVELOPER-INGRESS |
|  | local_users_eu | ROLE_IKS_SRE-LEADS-DE, ROLE_IKS_SRE-LEADS-IE |
|  | local_users_non-eu | ROLE_IKS_SRE-LEADS-AU, ROLE_IKS_SRE-LEADS-DE, ROLE_IKS_SRE-LEADS-IE, ROLE_IKS_SRE-LEADS-IN, ROLE_IKS_SRE-LEADS-GB, ROLE_IKS_SRE-LEADS-US |
|  | media-custodians | ROLE_IKS_COMPLIANCE-MEDIA-CUSTODIAN |
|  | security | ROLE_IKS_SECURITY |
| alchemy-containers | Autoscaling | ROLE_IKS_DEVELOPER-AUTOSCALE |
|  | Cloudflare-Admin | ROLE_CF_IKS-ADMIN, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-INGRESS |
|  | Cloudflare-Reader | ROLE_CF_IKS-READER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-US, ROLE_CF_SAT-READER |
|  | Cloudflare-Superadmin | ROLE_IKS_SRE-LEADS-AU, ROLE_IKS_SRE-LEADS-CN, ROLE_IKS_SRE-LEADS-DE, ROLE_IKS_SRE-LEADS-IN, ROLE_IKS_SRE-LEADS-IE, ROLE_IKS_SRE-LEADS-GB, ROLE_IKS_SRE-LEADS-US |
|  | Dedicated | ROLE_IKS_SRE-DEDICATED |
|  | Design | ROLE_IKS_DEVELOPER-DESIGN, ROLE_IKS_DEVELOPER-UI |
|  | Devops-thoughtlords | ROLE_IKS_DEVELOPER-DEVOPS |
|  | FrontDoor | ROLE_IKS_DEVELOPER-INGRESS |
|  | ICE | ROLE_IKS_DEVELOPER-ICE |
|  | IKS Vulnerability Notifications | ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | Offering Management | ROLE_IKS_DEVELOPER-OFFERING |
|  | Satellite Config | ROLE_RAZEE_DEVELOPER |
|  | Satellite Vulnerability Notifications | ROLE_RAZEE_DEVELOPER, ROLE_SAT_DEVELOPER-LINK |
|  | Satellite-Link | ROLE_SAT_DEVELOPER-LINK |
|  | Satellite-Mesh | ROLE_SAT_DEVELOPER-LINK |
|  | Security Audit Team | ROLE_IKS_SECURITY-AUDIT |
|  | Security squad | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SECURITY |
|  | Stalker Mergers | ROLE_IKS_DEVELOPER |
|  | Support-ACS | ROLE_IKS_SUPPORT-ACS |
|  | UI | ROLE_IKS_DEVELOPER-UI |
|  | VA | ROLE_ICCR_DEVELOPER-VA |
|  | api | ROLE_IKS_DEVELOPER-API |
|  | api-approvers | ROLE_IKS_DEVELOPER-API |
|  | armada-bootstrap-squad | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_DEVELOPER-BOOTSTRAP |
|  | armada-carrier | ROLE_IKS_DEVELOPER-CARRIERRUNTIME |
|  | armada-deploy-squad | ROLE_IKS_BNPP-AUTOMATION-PRODUCTION-TESTING, ROLE_IKS_DEVELOPER-DEPLOY |
|  | armada-hybrid | ROLE_IKS_DEVELOPER-HYBRID |
|  | armada-ingress | ROLE_IKS_DEVELOPER-INGRESS |
|  | armada-istio | ROLE_IKS_DEVELOPER-ISTIO |
|  | armada-network-squad | ROLE_IKS_DEVELOPER-NETWORK |
|  | armada-ops | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP |
|  | armada-sandbox | ROLE_IKS_DEVELOPER-SANDBOX |
|  | ballast | ROLE_IKS_DEVELOPER-ARMADADATA |
|  | cli-approvers | ROLE_IKS_DEVELOPER-API |
|  | cluster-squad | ROLE_IKS_DEVELOPER-CLUSTER |
|  | cluster-squad-admins | ROLE_IKS_DEVELOPER-CLUSTER-ADMIN |
|  | conductors | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION, ROLE_IKS_AUTOMATION-ICDEVOPS |
|  | conductors-admin | ROLE_IKS_SRE-LEADS-AU, ROLE_IKS_SRE-LEADS-CN, ROLE_IKS_SRE-LEADS-DE, ROLE_IKS_SRE-LEADS-IN, ROLE_IKS_SRE-LEADS-IE, ROLE_IKS_SRE-LEADS-GB, ROLE_IKS_SRE-LEADS-US |
|  | docker-infra-owner | ROLE_IKS_DEVELOPER-DOCKER |
|  | docs | ROLE_IKS_DEVELOPER-DOCUMENTATION |
|  | dove | ROLE_IKS_DEVELOPER-PIPELINE, ROLE_RAZEE_DEVELOPER |
|  | dublin-sre | ROLE_IKS_BNPP-AUTOMATION-PRODUCTION, ROLE_IKS_SRE-BNPP |
|  | fr8r-admins | ROLE_IKS_DEVELOPER-DEPLOY |
|  | fr8r-maintainers | ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_DEVELOPER-DEPLOY |
|  | fr8r-writers | ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_DEVELOPER-DEPLOY |
|  | ironsides | ROLE_IKS_DEVELOPER-API |
|  | istio-contributors | ROLE_IKS_DEVELOPER-ISTIO-OPENSOURCE |
|  | k8s-squad | ROLE_IKS_DEVELOPER-DEPLOY |
|  | kedge | ROLE_IKS_DEVELOPER-KEDGE |
|  | management | ROLE_IKS_DEVELOPER-MANAGERS |
|  | mks-ui | ROLE_IKS_DEVELOPER-UI |
|  | multiarch-team | ROLE_IKS_DEVELOPER-MULTIARCH |
|  | netint | ROLE_IKS_SRE-NETINT |
|  | networking | ROLE_IKS_DEVELOPER-NETWORK |
|  | os-innovation-b | ROLE_IKS_DEVELOPER-DOCKER |
|  | performance | ROLE_IKS_DEVELOPER-PERFORMANCE |
|  | razee | ROLE_RAZEE_DEVELOPER |
|  | razee-prod-approvers | ROLE_IKS_SECURE_APPROVERS |
|  | registry | ROLE_ICCR_DEVELOPER-REGISTRY |
|  | runtime | ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY, ROLE_IKS_DEVELOPER-DEPLOY, ROLE_IKS_DEVELOPER-API |
|  | runtime-mergers | ROLE_IKS_DEVELOPER-DEPLOY |
|  | secure-secret-approvers | ROLE_IKS_SECURE_SECRET_APPROVER |
|  | signature-experience | ROLE_IKS_DEVELOPER-SIGEX |
|  | snowdev | ROLE_IKS_AUTOMATION-SERVICENOW-DEV |
|  | storage | ROLE_IKS_DEVELOPER-STORAGE |
|  | system-z | ROLE_IKS_DEVELOPER-MULTIARCH |
|  | ui-approvers | ROLE_IKS_DEVELOPER-UI-ADMIN |
|  | ui-squad-extended-india | ROLE_IKS_DEVELOPER-EXTENDED-UI |
|  | update-squad | ROLE_IKS_BNPP-AUTOMATION-PRODUCTION, ROLE_IKS_DEVELOPER-UPDATE |
|  | va-cli | ROLE_ICCR_DEVELOPER-VA |
| alchemy-netint | Security squad | ROLE_IKS_SECURITY |
|  | netint | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-NETINT |
| alchemy-registry | Auditree BISO Monitoring | ROLE_ICCR_SECURITY-BISO |
|  | Security Squad | ROLE_ICCR_SECURITY |
|  | docs | ROLE_ICCR_DOCUMENTATION |
|  | registry | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_IKS_AUTOMATION-BUILD, ROLE_ICCR_DEVELOPER-REGISTRY |
|  | va | ROLE_ICCR_DEVELOPER-VA |
| alchemy-va | Auditree BISO Monitoring Team | ROLE_ICCR_SECURITY-BISO |
|  | Docs | ROLE_ICCR_DOCUMENTATION, ROLE_IKS_DEVELOPER-DOCUMENTATION |
|  | Docs Admin | ROLE_ICCR_DOCUMENTATION, ROLE_IKS_DEVELOPER-DOCUMENTATION |
|  | Project Management | ROLE_ICCR_DEVELOPER-LEAD |
|  | Registry dev squad | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY |
|  | Security squad | ROLE_ICCR_SECURITY |
|  | VA dev squad | ROLE_ICCR_DEVELOPER-VA |
