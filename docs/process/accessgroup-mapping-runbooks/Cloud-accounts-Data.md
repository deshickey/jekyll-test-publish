---
layout: default
title: Cloud Accounts Data
type: Informational
grand_parent: Policies & Processess
parent: Accessgroup Mapping
---

Informational
{: .label }

# IBM Cloud accounts

## Table of contents
* [Account access by role](#account-access-by-role)
* [Roles with access to each account](#Roles-with-access-to-each-account)
	
## Account access by role

| Role | Account | Access Groups |
| :---: | :-- | :-- |
| ROLE_ICCR_AUTOMATION-NON-PRODUCTION | registry-dev | Add cases and view orders, Edit cases, Retrieve users, SQUAD_FCTID, View account summary, View cases |
|  | registry-stage | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, LogDNA Readers, One-time payments, Retrieve users, SQUAD_FCTID, Update payment details, View account summary, View cases |
| ROLE_ICCR_AUTOMATION-PRODUCTION | IKS Registry Production EU-FR2 | container-registry_global_all-automation_admin |
|  | registry-prod | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, One-time payments, Retrieve users, Update payment details, View account summary, View cases, container-registry_global_all-automation_admin |
| ROLE_ICCR_DEVELOPER | Alchemy Production's Account | containers-kubernetes_au-syd_logs-metrics_viewer, containers-kubernetes_br-sao_logs-metrics_viewer, containers-kubernetes_ca-tor_logs-metrics_viewer, containers-kubernetes_eu-de_logs-metrics_viewer, containers-kubernetes_eu-gb_logs-metrics_viewer, containers-kubernetes_in-che_logs-metrics_viewer, containers-kubernetes_jp-osa_logs-metrics_viewer, containers-kubernetes_jp-tok_logs-metrics_viewer, containers-kubernetes_kr-seo_logs-metrics_viewer, containers-kubernetes_us-east_logs-metrics_viewer, containers-kubernetes_us-south_logs-metrics_viewer |
|  | Alchemy Staging's Account | ActivityTracker Readers, LogDNA Readers, SysDig Readers, global_iks_kubernetes_admin |
|  | Alchemy Support | bot-ap-north-base, bot-ap-south-base, bot-base, bot-dev-full, bot-eu-central-base, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-base, bot-us-east-base, bot-us-south-base, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator |
|  | Argo Staging | ActivityTracker Readers, LogDNA Readers, SysDig Readers |
|  | Argonauts Dev 659437 | IKS View Only, armada-log-collector |
|  | Dev Containers | ActivityTracker Readers, LogDNA Readers, SysDigViewer |
|  | IKS BNPP Prod | LogDNA-eu-fr2-access, SysDig Access Reader |
| ROLE_ICCR_DEVELOPER-LEAD | IKS Registry Production EU-FR2 | container-registry_au-syd_all_viewer, container-registry_au-syd_catalog_admin, container-registry_br-sao_all_viewer, container-registry_br-sao_catalog_admin, container-registry_ca-tor_all_viewer, container-registry_ca-tor_catalog_admin, container-registry_eu-de_all_viewer, container-registry_eu-de_catalog_admin, container-registry_eu-fr2_all_viewer, container-registry_eu-fr2_catalog_admin, container-registry_eu-gb_all_viewer, container-registry_eu-gb_catalog_admin, container-registry_in-che_all_viewer, container-registry_in-che_catalog_admin, container-registry_jp-osa_all_viewer, container-registry_jp-osa_catalog_admin, container-registry_jp-tok_all_viewer, container-registry_jp-tok_catalog_admin, container-registry_kr-seo_all_viewer, container-registry_kr-seo_catalog_admin, container-registry_us-east_all_viewer, container-registry_us-east_catalog_admin, container-registry_us-south_all_viewer, container-registry_us-south_catalog_admin |
|  | registry-prod | container-registry_au-syd_all_auditor, container-registry_au-syd_globalcatalog_viewer, container-registry_br-sao_all_auditor, container-registry_br-sao_globalcatalog_viewer, container-registry_ca-tor_all_auditor, container-registry_ca-tor_globalcatalog_viewer, container-registry_eu-de_all_auditor, container-registry_eu-de_globalcatalog_viewer, container-registry_eu-gb_all_auditor, container-registry_eu-gb_globalcatalog_viewer, container-registry_in-che_all_auditor, container-registry_in-che_globalcatalog_viewer, container-registry_jp-osa_all_auditor, container-registry_jp-osa_globalcatalog_viewer, container-registry_jp-tok_all_auditor, container-registry_jp-tok_globalcatalog_viewer, container-registry_kr-seo_all_auditor, container-registry_kr-seo_globalcatalog_viewer, container-registry_us-east_all_auditor, container-registry_us-east_globalcatalog_viewer, container-registry_us-south_all_auditor, container-registry_us-south_globalcatalog_viewer |
|  | registry-stage | AUDITOR, SQUAD_LEADS |
|  | registry-stage | SQUAD_LEADS |
| ROLE_ICCR_DEVELOPER-REGISTRY | IKS Registry Production EU-FR2 | container-registry_au-syd_all-squad_viewer, container-registry_au-syd_logs-metrics_editor, container-registry_br-sao_all-squad_viewer, container-registry_br-sao_logs-metrics_editor, container-registry_ca-tor_all-squad_viewer, container-registry_ca-tor_logs-metrics_editor, container-registry_eu-de_all-squad_viewer, container-registry_eu-de_logs-metrics_editor, container-registry_eu-fr2_all-squad_viewer, container-registry_eu-fr2_logs-metrics_editor, container-registry_eu-gb_all-squad_viewer, container-registry_eu-gb_logs-metrics_editor, container-registry_in-che_all-squad_viewer, container-registry_in-che_logs-metrics_editor, container-registry_jp-osa_all-squad_viewer, container-registry_jp-osa_logs-metrics_editor, container-registry_jp-tok_all-squad_viewer, container-registry_jp-tok_logs-metrics_editor, container-registry_kr-seo_all-squad_viewer, container-registry_kr-seo_logs-metrics_editor, container-registry_us-east_all-squad_viewer, container-registry_us-east_logs-metrics_editor, container-registry_us-south_all-squad_viewer, container-registry_us-south_logs-metrics_editor |
|  | registry-dev | Add cases and view orders, Edit cases, Retrieve users, SQUAD, Sysdig writers, View account summary, View cases |
|  | registry-prod | Add cases and view orders, Edit cases, Retrieve users, View account summary, View cases, container-registry_au-syd_all-squad_viewer, container-registry_au-syd_logs-metrics_viewer, container-registry_br-sao_all-squad_viewer, container-registry_br-sao_logs-metrics_viewer, container-registry_ca-tor_all-squad_viewer, container-registry_ca-tor_logs-metrics_viewer, container-registry_eu-de_all-squad_viewer, container-registry_eu-de_logs-metrics_viewer, container-registry_eu-gb_all-squad_viewer, container-registry_eu-gb_logs-metrics_viewer, container-registry_in-che_all-squad_viewer, container-registry_in-che_logs-metrics_viewer, container-registry_jp-osa_all-squad_viewer, container-registry_jp-osa_logs-metrics_viewer, container-registry_jp-tok_all-squad_viewer, container-registry_jp-tok_logs-metrics_viewer, container-registry_kr-seo_all-squad_viewer, container-registry_kr-seo_logs-metrics_viewer, container-registry_us-east_all-squad_viewer, container-registry_us-east_logs-metrics_viewer, container-registry_us-south_all-squad_viewer, container-registry_us-south_logs-metrics_viewer |
|  | registry-stage | Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SQUAD, SQUAD_EU, View account summary, View cases |
| ROLE_ICCR_DEVELOPER-VA | IKS Registry Production EU-FR2 | container-registry_au-syd_all-squad_viewer, container-registry_au-syd_logs-metrics_editor, container-registry_br-sao_all-squad_viewer, container-registry_br-sao_logs-metrics_editor, container-registry_ca-tor_all-squad_viewer, container-registry_ca-tor_logs-metrics_editor, container-registry_eu-de_all-squad_viewer, container-registry_eu-de_logs-metrics_editor, container-registry_eu-fr2_all-squad_viewer, container-registry_eu-fr2_logs-metrics_editor, container-registry_eu-gb_all-squad_viewer, container-registry_eu-gb_logs-metrics_editor, container-registry_in-che_all-squad_viewer, container-registry_in-che_logs-metrics_editor, container-registry_jp-osa_all-squad_viewer, container-registry_jp-osa_logs-metrics_editor, container-registry_jp-tok_all-squad_viewer, container-registry_jp-tok_logs-metrics_editor, container-registry_kr-seo_logs-metrics_editor, container-registry_us-east_all-squad_viewer, container-registry_us-east_logs-metrics_editor, container-registry_us-south_all-squad_viewer, container-registry_us-south_logs-metrics_editor |
|  | registry-dev | Add cases and view orders, Edit cases, Retrieve users, SQUAD, Sysdig writers, View account summary, View cases |
|  | registry-prod | Add cases and view orders, Edit cases, Retrieve users, View account summary, View cases, container-registry_au-syd_all-squad_viewer, container-registry_au-syd_logs-metrics_viewer, container-registry_br-sao_all-squad_viewer, container-registry_br-sao_logs-metrics_viewer, container-registry_ca-tor_all-squad_viewer, container-registry_ca-tor_logs-metrics_viewer, container-registry_eu-de_all-squad_viewer, container-registry_eu-de_logs-metrics_viewer, container-registry_eu-gb_all-squad_viewer, container-registry_eu-gb_logs-metrics_viewer, container-registry_in-che_all-squad_viewer, container-registry_in-che_logs-metrics_viewer, container-registry_jp-osa_all-squad_viewer, container-registry_jp-osa_logs-metrics_viewer, container-registry_jp-tok_all-squad_viewer, container-registry_jp-tok_logs-metrics_viewer, container-registry_kr-seo_all-squad_viewer, container-registry_kr-seo_logs-metrics_viewer, container-registry_us-east_all-squad_viewer, container-registry_us-east_logs-metrics_viewer, container-registry_us-south_all-squad_viewer, container-registry_us-south_logs-metrics_viewer |
|  | registry-stage | Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SQUAD, SQUAD_EU, View account summary, View cases |
| ROLE_ICCR_SRE-AU | IKS Registry Production EU-FR2 | container-registry_au-syd_all-sre_admin, container-registry_br-sao_all-sre_admin, container-registry_ca-tor_all-sre_admin, container-registry_eu-gb_all-sre_admin, container-registry_in-che_all-sre_admin, container-registry_jp-osa_all-sre_admin, container-registry_jp-tok_all-sre_admin, container-registry_kr-seo_all-sre_admin, container-registry_us-east_all-sre_admin, container-registry_us-south_all-sre_admin |
|  | registry-dev | SRE, Sysdig writers |
|  | registry-prod | container-registry_au-syd_all-sre_admin, container-registry_au-syd_logs-metrics_viewer, container-registry_br-sao_all-sre_admin, container-registry_br-sao_logs-metrics_viewer, container-registry_ca-tor_all-sre_admin, container-registry_ca-tor_logs-metrics_viewer, container-registry_eu-gb_all-sre_admin, container-registry_eu-gb_logs-metrics_viewer, container-registry_in-che_all-sre_admin, container-registry_in-che_logs-metrics_viewer, container-registry_jp-osa_all-sre_admin, container-registry_jp-osa_logs-metrics_viewer, container-registry_jp-tok_all-sre_admin, container-registry_jp-tok_logs-metrics_viewer, container-registry_kr-seo_all-sre_admin, container-registry_kr-seo_logs-metrics_viewer, container-registry_us-east_all-sre_admin, container-registry_us-east_logs-metrics_viewer, container-registry_us-south_all-sre_admin, container-registry_us-south_logs-metrics_viewer |
|  | registry-stage | LogDNA Readers, SRE |
| ROLE_ICCR_SRE-CN | registry-dev | SRE, Sysdig writers |
|  | registry-stage | LogDNA Readers, SRE |
| ROLE_ICCR_SRE-DE | IKS Registry Production EU-FR2 | container-registry_au-syd_all-sre_admin, container-registry_br-sao_all-sre_admin, container-registry_ca-tor_all-sre_admin, container-registry_eu-de_all-sre_admin, container-registry_eu-fr2_all-sre_admin, container-registry_eu-gb_all-sre_admin, container-registry_in-che_all-sre_admin, container-registry_jp-osa_all-sre_admin, container-registry_jp-tok_all-sre_admin, container-registry_kr-seo_all-sre_admin, container-registry_us-east_all-sre_admin, container-registry_us-south_all-sre_admin |
|  | registry-dev | SRE, SRE_EU, Sysdig writers |
|  | registry-prod | container-registry_au-syd_all-sre_admin, container-registry_au-syd_logs-metrics_viewer, container-registry_br-sao_all-sre_admin, container-registry_br-sao_logs-metrics_viewer, container-registry_ca-tor_all-sre_admin, container-registry_ca-tor_logs-metrics_viewer, container-registry_eu-de_all-sre_admin, container-registry_eu-de_logs-metrics_viewer, container-registry_eu-fr2_all-sre_admin, container-registry_eu-fr2_logs-metrics_viewer, container-registry_eu-gb_all-sre_admin, container-registry_eu-gb_logs-metrics_viewer, container-registry_in-che_all-sre_admin, container-registry_in-che_logs-metrics_viewer, container-registry_jp-osa_all-sre_admin, container-registry_jp-osa_logs-metrics_viewer, container-registry_jp-tok_all-sre_admin, container-registry_jp-tok_logs-metrics_viewer, container-registry_kr-seo_all-sre_admin, container-registry_kr-seo_logs-metrics_viewer, container-registry_us-east_all-sre_admin, container-registry_us-east_logs-metrics_viewer, container-registry_us-south_all-sre_admin, container-registry_us-south_logs-metrics_viewer |
|  | registry-stage | LogDNA Readers, SRE, SRE_EU |
| ROLE_ICCR_SRE-GB | IKS Registry Production EU-FR2 | container-registry_au-syd_all-sre_admin, container-registry_br-sao_all-sre_admin, container-registry_ca-tor_all-sre_admin, container-registry_eu-gb_all-sre_admin, container-registry_in-che_all-sre_admin, container-registry_jp-osa_all-sre_admin, container-registry_jp-tok_all-sre_admin, container-registry_kr-seo_all-sre_admin, container-registry_us-east_all-sre_admin, container-registry_us-south_all-sre_admin |
|  | registry-dev | SRE, Sysdig writers |
|  | registry-prod | container-registry_au-syd_all-sre_admin, container-registry_au-syd_logs-metrics_viewer, container-registry_br-sao_all-sre_admin, container-registry_br-sao_logs-metrics_viewer, container-registry_ca-tor_all-sre_admin, container-registry_ca-tor_logs-metrics_viewer, container-registry_eu-gb_all-sre_admin, container-registry_eu-gb_logs-metrics_viewer, container-registry_in-che_all-sre_admin, container-registry_in-che_logs-metrics_viewer, container-registry_jp-osa_all-sre_admin, container-registry_jp-osa_logs-metrics_viewer, container-registry_jp-tok_all-sre_admin, container-registry_jp-tok_logs-metrics_viewer, container-registry_kr-seo_all-sre_admin, container-registry_kr-seo_logs-metrics_viewer, container-registry_us-east_all-sre_admin, container-registry_us-east_logs-metrics_viewer, container-registry_us-south_all-sre_admin, container-registry_us-south_logs-metrics_viewer |
|  | registry-stage | LogDNA Readers, SRE |
| ROLE_ICCR_SRE-IE | IKS Registry Production EU-FR2 | container-registry_au-syd_all-sre_admin, container-registry_br-sao_all-sre_admin, container-registry_ca-tor_all-sre_admin, container-registry_eu-de_all-sre_admin, container-registry_eu-fr2_all-sre_admin, container-registry_eu-gb_all-sre_admin, container-registry_in-che_all-sre_admin, container-registry_jp-osa_all-sre_admin, container-registry_jp-tok_all-sre_admin, container-registry_kr-seo_all-sre_admin, container-registry_us-east_all-sre_admin, container-registry_us-south_all-sre_admin |
|  | registry-dev | SRE, SRE_EU, Sysdig writers |
|  | registry-prod | container-registry_au-syd_all-sre_admin, container-registry_au-syd_logs-metrics_viewer, container-registry_br-sao_all-sre_admin, container-registry_br-sao_logs-metrics_viewer, container-registry_ca-tor_all-sre_admin, container-registry_ca-tor_logs-metrics_viewer, container-registry_eu-de_all-sre_admin, container-registry_eu-de_logs-metrics_viewer, container-registry_eu-fr2_all-sre_admin, container-registry_eu-fr2_logs-metrics_viewer, container-registry_eu-gb_all-sre_admin, container-registry_eu-gb_logs-metrics_viewer, container-registry_in-che_all-sre_admin, container-registry_in-che_logs-metrics_viewer, container-registry_jp-osa_all-sre_admin, container-registry_jp-osa_logs-metrics_viewer, container-registry_jp-tok_all-sre_admin, container-registry_jp-tok_logs-metrics_viewer, container-registry_kr-seo_all-sre_admin, container-registry_kr-seo_logs-metrics_viewer, container-registry_us-east_all-sre_admin, container-registry_us-east_logs-metrics_viewer, container-registry_us-south_all-sre_admin, container-registry_us-south_logs-metrics_viewer |
|  | registry-stage | LogDNA Readers, SRE, SRE_EU |
| ROLE_ICCR_SRE-IN | IKS Registry Production EU-FR2 | container-registry_au-syd_all-sre_admin, container-registry_br-sao_all-sre_admin, container-registry_ca-tor_all-sre_admin, container-registry_eu-gb_all-sre_admin, container-registry_in-che_all-sre_admin, container-registry_jp-osa_all-sre_admin, container-registry_jp-tok_all-sre_admin, container-registry_kr-seo_all-sre_admin, container-registry_us-east_all-sre_admin, container-registry_us-south_all-sre_admin |
|  | registry-dev | SRE, Sysdig writers |
|  | registry-prod | container-registry_au-syd_all-sre_admin, container-registry_au-syd_logs-metrics_viewer, container-registry_br-sao_all-sre_admin, container-registry_br-sao_logs-metrics_viewer, container-registry_ca-tor_all-sre_admin, container-registry_ca-tor_logs-metrics_viewer, container-registry_eu-gb_all-sre_admin, container-registry_eu-gb_logs-metrics_viewer, container-registry_in-che_all-sre_admin, container-registry_in-che_logs-metrics_viewer, container-registry_jp-osa_all-sre_admin, container-registry_jp-osa_logs-metrics_viewer, container-registry_jp-tok_all-sre_admin, container-registry_jp-tok_logs-metrics_viewer, container-registry_kr-seo_all-sre_admin, container-registry_kr-seo_logs-metrics_viewer, container-registry_us-east_all-sre_admin, container-registry_us-east_logs-metrics_viewer, container-registry_us-south_all-sre_admin, container-registry_us-south_logs-metrics_viewer |
|  | registry-stage | LogDNA Readers, SRE |
| ROLE_ICCR_SRE-US | IKS Registry Production EU-FR2 | container-registry_au-syd_all-sre_admin, container-registry_br-sao_all-sre_admin, container-registry_ca-tor_all-sre_admin, container-registry_eu-gb_all-sre_admin, container-registry_in-che_all-sre_admin, container-registry_jp-osa_all-sre_admin, container-registry_jp-tok_all-sre_admin, container-registry_kr-seo_all-sre_admin, container-registry_us-east_all-sre_admin, container-registry_us-south_all-sre_admin |
|  | registry-dev | SRE, Sysdig writers |
|  | registry-prod | container-registry_au-syd_all-sre_admin, container-registry_au-syd_logs-metrics_viewer, container-registry_br-sao_all-sre_admin, container-registry_br-sao_logs-metrics_viewer, container-registry_ca-tor_all-sre_admin, container-registry_ca-tor_logs-metrics_viewer, container-registry_eu-gb_all-sre_admin, container-registry_eu-gb_logs-metrics_viewer, container-registry_in-che_all-sre_admin, container-registry_in-che_logs-metrics_viewer, container-registry_jp-osa_all-sre_admin, container-registry_jp-osa_logs-metrics_viewer, container-registry_jp-tok_all-sre_admin, container-registry_jp-tok_logs-metrics_viewer, container-registry_kr-seo_all-sre_admin, container-registry_kr-seo_logs-metrics_viewer, container-registry_us-east_all-sre_admin, container-registry_us-east_logs-metrics_viewer, container-registry_us-south_all-sre_admin, container-registry_us-south_logs-metrics_viewer |
|  | registry-stage | LogDNA Readers, SRE |
| ROLE_IKS_AUTOMATION-ACCESSHUB | Alch Dev - test | global_accesshub_automation |
|  | Alchemy Production's Account | global_accesshub_automation |
|  | Alchemy Staging's Account | global_accesshub_automation |
|  | Alchemy Support | global_accesshub_automation |
|  | Argo Staging | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, One-time payments, Search cases, Update payment details, View account summary, View cases, global_accesshub_automation |
|  | Argonauts Dev 659437 | global_accesshub_automation |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, global_accesshub_automation |
|  | Dev Containers | global_accesshub_automation |
|  | IKS BNPP Prod | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, Limit EU case restriction, One-time payments, Search cases, Update payment details, View account summary, View cases, global_accesshub_automation |
|  | IKS Registry Production EU-FR2 | global_accesshub_automation |
|  | Razee Dev | global_accesshub_automation |
|  | Razee Stage | global_accesshub_automation |
|  | Satellite Production | global_accesshub_automation |
|  | Satellite Stage | global_accesshub_automation |
|  | Satellite Stage TEST | global_accesshub_automation |
|  | registry-dev | global_accesshub_automation |
|  | registry-prod | global_accesshub_automation |
|  | registry-stage | global_accesshub_automation |
| ROLE_IKS_AUTOMATION-BUILD | Alchemy Support | container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-de_logdna_operator, container-kubernetes_prod_eu-fr2_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, containers-kubernetes_prod_au-syd_all_admin, containers-kubernetes_prod_br-sao_all_admin, containers-kubernetes_prod_ca-tor_all_admin, containers-kubernetes_prod_eu-de_all_admin, containers-kubernetes_prod_eu-fr2_all_admin, containers-kubernetes_prod_eu-gb_all_admin, containers-kubernetes_prod_in-che_all_admin, containers-kubernetes_prod_jp-osa_all_admin, containers-kubernetes_prod_jp-tok_all_admin, containers-kubernetes_prod_kr-seo_all_admin, containers-kubernetes_prod_us-east_all_admin, containers-kubernetes_prod_us-south_all_admin |
| ROLE_IKS_AUTOMATION-COMPLIANCE | Alchemy Production's Account | Add cases and view orders, View account summary, View cases, containers-kubernetes_global_registry_admin |
|  | Alchemy Support | global_sre_automation |
|  | Argo Staging | IKS View Only |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, View account summary |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Search cases, View account summary, View cases, iks_global_sre_automation_nothing |
|  | Dev Containers | Add cases and view orders, Containers-Test-Automation, Edit cases, Retrieve users, View account summary, View cases, global_iks_kubernetes_admin |
|  | IKS Registry Production EU-FR2 | container-registry_au-syd_all-sre_admin, container-registry_au-syd_all_viewer, container-registry_br-sao_all-sre_admin, container-registry_br-sao_all_viewer, container-registry_ca-tor_all-sre_admin, container-registry_ca-tor_all_viewer, container-registry_eu-de_all-sre_admin, container-registry_eu-de_all_viewer, container-registry_eu-fr2_all-sre_admin, container-registry_eu-fr2_all_viewer, container-registry_eu-gb_all-sre_admin, container-registry_eu-gb_all_viewer, container-registry_in-che_all-sre_admin, container-registry_in-che_all_viewer, container-registry_jp-osa_all-sre_admin, container-registry_jp-osa_all_viewer, container-registry_jp-tok_all-sre_admin, container-registry_jp-tok_all_viewer, container-registry_kr-seo_all-sre_admin, container-registry_kr-seo_all_viewer, container-registry_us-east_all-sre_admin, container-registry_us-east_all_viewer, container-registry_us-south_all-sre_admin, container-registry_us-south_all_viewer |
|  | Razee Dev |  |
|  | Razee Stage |  |
|  | Satellite Stage | global_sre_automation |
|  | registry-dev | SRE_Automation |
|  | registry-prod | container-registry_au-syd_all-sre_admin, container-registry_au-syd_all_auditor, container-registry_br-sao_all-sre_admin, container-registry_br-sao_all_auditor, container-registry_ca-tor_all-sre_admin, container-registry_ca-tor_all_auditor, container-registry_eu-de_all-sre_admin, container-registry_eu-de_all_auditor, container-registry_eu-fr2_all-sre_admin, container-registry_eu-fr2_all_auditor, container-registry_eu-gb_all-sre_admin, container-registry_eu-gb_all_auditor, container-registry_in-che_all-sre_admin, container-registry_in-che_all_auditor, container-registry_jp-osa_all-sre_admin, container-registry_jp-osa_all_auditor, container-registry_jp-tok_all-sre_admin, container-registry_jp-tok_all_auditor, container-registry_kr-seo_all-sre_admin, container-registry_kr-seo_all_auditor, container-registry_us-east_all-sre_admin, container-registry_us-east_all_auditor, container-registry_us-south_all-sre_admin, container-registry_us-south_all_auditor |
|  | registry-stage |  |
| ROLE_IKS_AUTOMATION-CONTAINERBOT | Alchemy Production's Account | containers-kubernetes_global_kubernetes_admin |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, View account summary |
|  | Dev Containers | Add cases and view orders, Edit cases, Retrieve users, View account summary |
| ROLE_IKS_AUTOMATION-ICDEVOPS | Alchemy Support | containers-kubernetes_global_kubernetes_admin |
| ROLE_IKS_AUTOMATION-NON-PRODUCTION | Alchemy Staging's Account | Containers-Test-Automation, global_iks_kubernetes_admin |
|  | Argo Staging | Add cases and view orders, Edit cases, IKS tugboat automation, Search cases, View account summary, View cases |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, IKS Tugboat Automation, Retrieve users, Search cases, View account summary, View cases, armada-log-collector |
|  | Dev Containers | Add cases and view orders, Containers-Test-Automation, Edit cases, Retrieve users, Search cases, View account summary, View cases, global_iks_kubernetes_admin |
| ROLE_IKS_AUTOMATION-NON-PRODUCTION-TUGBOAT | Argonauts Dev 659437 | IKS Tugboat Automation |
|  | Satellite Stage | global_tugboat_automation |
|  | Satellite Stage TEST | global_tugboat_automation |
| ROLE_IKS_AUTOMATION-PERFORMANCE | Argo Staging | Add cases and view orders, Edit cases, LogDNA Readers, Search cases, SysDig Readers, View account summary, View cases |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases |
|  | Dev Containers | Add cases and view orders, Containers-Test-Automation, Edit cases, Retrieve users, Search cases, View account summary, View cases, global_iks_kubernetes_admin |
|  | registry-dev | SQUAD |
| ROLE_IKS_AUTOMATION-PRODUCTION | Alchemy Production's Account | Add cases and view orders, Edit cases, Search cases, View cases, containers-kubernetes_global_kubernetes_admin, containers-kubernetes_global_registry_admin |
|  | Argonauts Production 531277 | global_tugboat_automation |
|  | Satellite Production | global_sre_automation |
|  | Satellite Stage | global_sre_automation |
|  | Satellite Stage TEST | global_sre_automation |
|  | registry-dev | SRE_Automation |
| ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY | Alchemy Production's Account | Add cases and view orders, Edit cases, View cases |
|  | Argonauts Dev 659437 | IKS Tugboat Automation, IKS View Only, Search cases, View cases, armada-log-collector |
|  | Dev Containers | SysDigViewer |
| ROLE_IKS_AUTOMATION-PRODUCTION-ARGONAUTS | Argonauts Production 531277 | iks_global_sre_automation_nothing |
| ROLE_IKS_AUTOMATION-PRODUCTION-BLUEFRINGE | Alchemy Support | View account summary, View cases |
| ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP | Alchemy Production's Account | Add cases and view orders, Edit cases, Search cases, View account summary, View cases |
|  | Alchemy Support | bot-ap-north-base, bot-ap-south-base, bot-base, bot-dev-full, bot-eu-central-base, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-base, bot-us-east-base, bot-us-south-base |
|  | Argo Staging | LogDNA Readers |
|  | Argonauts Production 531277 | iks_global_sre_automation_nothing |
| ROLE_IKS_AUTOMATION-PRODUCTION-BUILD | Alchemy Production's Account |  |
| ROLE_IKS_AUTOMATION-PRODUCTION-CLUSTER | Alchemy Production's Account | Add cases and view orders, Edit cases, Search cases, View cases |
|  | Argonauts Production 531277 | iks_global_sre_automation_nothing |
| ROLE_IKS_AUTOMATION-PRODUCTION-COMPLIANCE | Satellite Production | global_sre_automation |
| ROLE_IKS_AUTOMATION-PRODUCTION-SUPPORT | Alchemy Support |  |
| ROLE_IKS_AUTOMATION-PRODUCTION-TUGBOAT | Alchemy Production's Account | containers-kubernetes_global_registry_admin |
|  | Argonauts Production 531277 | global_tugboat_automation |
|  | Dev Containers | Containers-Test-Automation |
|  | Satellite Production | global_tugboat_automation |
| ROLE_IKS_AUTOMATION-SCORECARD | Argonauts Production 531277 | cto-security_global_certmanager_viewer |
|  | IKS Registry Production EU-FR2 |  |
|  | Satellite Production | global_certificate_automation |
|  | Satellite Stage | global_certificate_automation |
|  | Satellite Stage TEST | global_certificate_automation |
|  | registry-prod | container-registry_au-syd_all_auditor, container-registry_br-sao_all_auditor, container-registry_ca-tor_all_auditor, container-registry_eu-de_all_auditor, container-registry_eu-fr2_all_auditor, container-registry_eu-gb_all_auditor, container-registry_in-che_all_auditor, container-registry_jp-osa_all_auditor, container-registry_jp-tok_all_auditor, container-registry_kr-seo_all_auditor, container-registry_us-east_all_auditor, container-registry_us-south_all_auditor |
| ROLE_IKS_AUTOMATION-SRE-BOT | Alchemy Support | containers-kubernetes_global_iam_viewer |
|  | Argo Staging | Add cases and view orders, Edit cases, LogDNA Readers, SRE, Search cases, View account summary, View cases |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, SRE, Search cases, View account summary, View cases |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Search cases, View account summary, View cases, iks_global_sre_automation_nothing |
|  | Satellite Production | global_sre_automation, global_tugboat_automation |
|  | Satellite Stage | global_sre_automation, global_tugboat_automation |
| ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR | Alchemy Production's Account | containers-kubernetes_global_kubernetes_admin, containers-kubernetes_global_postgresDB_viewer |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, View account summary, View cases |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Search cases, View account summary, View cases, iks_global_sre_automation_nothing |
| ROLE_IKS_BNPP-AUTOMATION-PRODUCTION | IKS BNPP Prod | Add cases and view orders, Edit cases, ProductionAutomation, Search cases, View account summary, View cases |
| ROLE_IKS_BNPP-AUTOMATION-PRODUCTION-TESTING | IKS BNPP Prod | Add cases and view orders, Edit cases, ProductionAutomationTesting, Search cases, View account summary, View cases |
| ROLE_IKS_BNPP-TELEPORT-ADMIN | IKS BNPP Prod | Teleport Admins |
| ROLE_IKS_DEVELOPER | Alchemy Production's Account | containers-kubernetes_au-syd_logs-metrics_viewer, containers-kubernetes_br-sao_logs-metrics_viewer, containers-kubernetes_ca-tor_logs-metrics_viewer, containers-kubernetes_eu-de_logs-metrics_viewer, containers-kubernetes_eu-gb_logs-metrics_viewer, containers-kubernetes_global_xo-cos_viewer, containers-kubernetes_in-che_logs-metrics_viewer, containers-kubernetes_jp-osa_logs-metrics_viewer, containers-kubernetes_jp-tok_logs-metrics_viewer, containers-kubernetes_kr-seo_logs-metrics_viewer, containers-kubernetes_us-east_logs-metrics_viewer, containers-kubernetes_us-south_logs-metrics_viewer |
|  | Alchemy Staging's Account | ActivityTracker Readers, IKS Development, IKS View Only, LogDNA Readers, SysDig Readers, global_iks_kubernetes_admin, icd-stage-reader |
|  | Alchemy Support | bot-ap-north-base, bot-ap-south-base, bot-base, bot-dev-full, bot-eu-central-base, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-base, bot-us-east-base, bot-us-south-base, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator |
|  | Argo Staging | ActivityTracker Readers, Add cases and view orders, Edit cases, IKS Development, IKS View Only, LogDNA Readers, Search cases, SysDig Readers, View account summary, View cases, icd-stage-reader |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, IKS View Only, Retrieve users, Search cases, View account summary, View cases, armada-log-collector |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, Search cases, SysDigViewer, View account summary, View cases, global_iks_kubernetes_admin |
|  | IKS BNPP Prod | LogDNA-eu-fr2-access, LogDNA-eu-fr2-editors, SysDig Access Reader, View cases |
| ROLE_IKS_DEVELOPER-BILLING | Alchemy Production's Account | containers-kubernetes_global_billing_viewer |
|  | Alchemy Staging's Account | containers-kubernetes_global_billing_viewer |
|  | Satellite Production | containers-kubernetes_global_billing_viewer |
|  | Satellite Stage TEST | containers-kubernetes_global_billing_viewer |
| ROLE_IKS_DEVELOPER-BOOTSTRAP | Alch Dev - test | iks_multishift_dev_squad |
|  | Satellite Stage TEST | satellite-location_us-south_all_viewer, satellite-location_us-south_kubernetes_admin |
| ROLE_IKS_DEVELOPER-CARRIERRUNTIME | Alchemy Support | container-kubernetes_stage_global_dashboardclusters_admin |
|  | Argo Staging | ActivityTracker Readers, LogDNA Readers, SysDig Readers |
| ROLE_IKS_DEVELOPER-CLUSTER | Alchemy Staging's Account | iks_global_billing_viewer |
| ROLE_IKS_DEVELOPER-CLUSTER-ADMIN | Alchemy Staging's Account | iks_global_billing_viewer |
| ROLE_IKS_DEVELOPER-DOCUMENTATION | Argonauts Dev 659437 | armada-log-collector |
| ROLE_IKS_DEVELOPER-HYBRID | Satellite Production | satellite_au-syd_metrics-logs_viewer, satellite_br-sao_metrics-logs_viewer, satellite_ca-tor_metrics-logs_viewer, satellite_eu-de_metrics-logs_viewer, satellite_eu-gb_metrics-logs_viewer, satellite_in-che_metrics-logs_viewer, satellite_jp-osa_metrics-logs_viewer, satellite_jp-tok_metrics-logs_viewer, satellite_kr-seo_metrics-logs_viewer, satellite_us-east_metrics-logs_viewer, satellite_us-south_metrics-logs_viewer |
|  | Satellite Stage | satellite-config_us-south_metrics-logs_viewer, satellite-link_us-south_metrics-logs_viewer, satellite-location_us-south_metrics-logs_viewer |
| ROLE_IKS_DEVELOPER-MANAGERS | Argonauts Dev 659437 |  |
|  | IKS BNPP Prod | LogDNA-eu-fr2-access, SysDig Access Reader |
| ROLE_IKS_DEVELOPER-OFFERING | Alchemy Production's Account | containers-kubernetes_global_xo-cos_viewer |
| ROLE_IKS_DEVELOPER-OFFERING-ADMIN | Alchemy Production's Account | containers-kubernetes_global_catalog_admin |
|  | Alchemy Staging's Account | global_catalog_admin |
| ROLE_IKS_DEVELOPER-PERFORMANCE | registry-dev | Sysdig writers, performance_global_kubernetes_admin |
| ROLE_IKS_DEVELOPER-STORAGE | Argonauts Dev 659437 | IKS View Only, armada-log-collector |
| ROLE_IKS_OPS-PRODUCTION-WATSON | Alchemy Production's Account | watson_us-south_logs-metrics_viewer |
| ROLE_IKS_PRODUCTION-OPS | Alchemy Production's Account | containers-kubernetes_global_cos_viewer |
| ROLE_IKS_PRODUCTION-OPS-SOS | Argonauts Production 531277 |  |
| ROLE_IKS_SECURITY | Alchemy Production's Account | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, containers-kubernetes_au-syd_logs-metrics_viewer, containers-kubernetes_br-sao_logs-metrics_viewer, containers-kubernetes_ca-tor_logs-metrics_viewer, containers-kubernetes_eu-de_logs-metrics_viewer, containers-kubernetes_eu-gb_logs-metrics_viewer, containers-kubernetes_in-che_logs-metrics_viewer, containers-kubernetes_jp-osa_logs-metrics_viewer, containers-kubernetes_jp-tok_logs-metrics_viewer, containers-kubernetes_kr-seo_logs-metrics_viewer, containers-kubernetes_us-east_logs-metrics_viewer, containers-kubernetes_us-south_logs-metrics_viewer |
|  | Alchemy Staging's Account | LogDNA Readers, global_iks_kubernetes_admin |
|  | Alchemy Support | container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator |
|  | Argonauts Dev 659437 |  |
|  | Argonauts Production 531277 | iks-security_au-syd_certmanager_viewer, iks-security_br-sao_certmanager_viewer, iks-security_ca-tor_certmanager_viewer, iks-security_eu-gb_certmanager_viewer, iks-security_in-che_certmanager_viewer, iks-security_jp-osa_certmanager_viewer, iks-security_jp-tok_certmanager_viewer, iks-security_kr-seo_certmanager_viewer, iks-security_us-east_certmanager_viewer, iks-security_us-south_certmanager_viewer |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SECURITY-COMPLIANCE-SQUAD, Search cases, SysDigViewer, View account summary, View cases |
| ROLE_IKS_SRE-AU | Alch Dev - test | SRE |
|  | Alchemy Production's Account | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, containers-kubernetes_au-syd_all_admin, containers-kubernetes_br-sao_all_admin, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_eu-de_all_admin, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_global_cos_viewer, containers-kubernetes_global_xo-cos_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-south_all_admin |
|  | Alchemy Staging's Account | ActivityTracker Readers, IKS View Only, LogDNA Readers, SRE, SysDig Readers, global_iks_kubernetes_admin, icd-stage-reader |
|  | Alchemy Support | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, bot-ap-north-full, bot-ap-south-full, bot-dev-full, bot-full, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-full, bot-us-east-full, bot-us-south-full, br-sao_bast_admin, ca-tor_bast_admin, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, containers-kubernetes_prod_au-syd_all_admin, containers-kubernetes_prod_br-sao_all_admin, containers-kubernetes_prod_ca-tor_all_admin, containers-kubernetes_prod_eu-gb_all_admin, containers-kubernetes_prod_in-che_all_admin, containers-kubernetes_prod_jp-osa_all_admin, containers-kubernetes_prod_jp-tok_all_admin, containers-kubernetes_prod_kr-seo_all_admin, containers-kubernetes_prod_us-east_all_admin, containers-kubernetes_prod_us-south_all_admin, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Argo Staging | ActivityTracker Readers, Add cases and view orders, Edit cases, IKS View Only, LogDNA Readers, SRE, Search cases, SysDig Readers, View account summary, View cases, icd-stage-reader |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, SRE, Search cases, View account summary, View cases |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, br-sao_bast_admin, ca-tor_bast_admin, containers-kubernetes_au-syd_all_admin, containers-kubernetes_au-syd_observability_viewer, containers-kubernetes_br-sao_all_admin, containers-kubernetes_br-sao_observability_viewer, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_ca-tor_observability_viewer, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_eu-gb_observability_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_in-che_observability_viewer, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-osa_observability_viewer, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_jp-tok_observability_viewer, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_kr-seo_observability_viewer, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-east_observability_viewer, containers-kubernetes_us-south_all_admin, containers-kubernetes_us-south_observability_viewer, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SRE, Search cases, SysDigViewer, View account summary, View cases |
|  | IKS BNPP Prod | Add cases and view orders, Edit cases, LogDNA-eu-fr2-access, Search cases, SysDig Access Reader, View account summary, View cases |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_IKS_SRE-BNPP | Alchemy Staging's Account | ActivityTracker Readers, LogDNA Readers, SRE, SysDig Readers, global_iks_kubernetes_admin |
|  | Alchemy Support | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, bot-dev-base, bot-dev-full, bot-eu-fr2-full, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-de_logdna_operator, container-kubernetes_prod_eu-fr2_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, containers-kubernetes_prod_au-syd_all_admin, containers-kubernetes_prod_br-sao_all_admin, containers-kubernetes_prod_ca-tor_all_admin, containers-kubernetes_prod_eu-de_all_admin, containers-kubernetes_prod_eu-fr2_all_admin, containers-kubernetes_prod_eu-gb_all_admin, containers-kubernetes_prod_in-che_all_admin, containers-kubernetes_prod_jp-osa_all_admin, containers-kubernetes_prod_jp-tok_all_admin, containers-kubernetes_prod_kr-seo_all_admin, containers-kubernetes_prod_us-east_all_admin, containers-kubernetes_prod_us-south_all_admin |
|  | Argo Staging | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, SRE, Search cases, SysDig Readers, View account summary, View cases |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, SRE, Search cases, View account summary, View cases, bastionx-test |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SRE, Search cases, SysDigViewer, View account summary, View cases |
|  | IKS BNPP Prod | Add cases and view orders, Edit cases, LogDNA-eu-fr2-access, SRE-BNPP, Search cases, SysDig Access Reader, View account summary, View cases |
| ROLE_IKS_SRE-BNPP-SUPERADMIN | IKS BNPP Prod | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, Limit EU case restriction, One-time payments, SUPERADMIN, Search cases, Update payment details, View account summary, View cases |
| ROLE_IKS_SRE-CN | Alch Dev - test | SRE |
|  | Alchemy Staging's Account | ActivityTracker Readers, IKS View Only, LogDNA Readers, SRE, SysDig Readers, global_iks_kubernetes_admin, icd-stage-reader |
|  | Alchemy Support | bot-ap-north-base, bot-ap-south-base, bot-base, bot-dev-full, bot-eu-central-base, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-base, bot-us-east-base, bot-us-south-base |
|  | Argo Staging | ActivityTracker Readers, Add cases and view orders, Edit cases, IKS View Only, LogDNA Readers, SRE, Search cases, SysDig Readers, View account summary, View cases, icd-stage-reader |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, SRE, Search cases, View account summary, View cases |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SRE, Search cases, SysDigViewer, View account summary, View cases |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_IKS_SRE-DE | Alch Dev - test | SRE |
|  | Alchemy Production's Account | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, containers-kubernetes_au-syd_all_admin, containers-kubernetes_br-sao_all_admin, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_eu-de_all_admin, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_global_cos_viewer, containers-kubernetes_global_xo-cos_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-south_all_admin |
|  | Alchemy Staging's Account | ActivityTracker Readers, IKS View Only, LogDNA Readers, SRE, SysDig Readers, global_iks_kubernetes_admin, icd-stage-reader |
|  | Alchemy Support | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, bot-ap-north-full, bot-ap-south-full, bot-dev-full, bot-eu-central-full, bot-full, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-full, bot-us-east-full, bot-us-south-full, br-sao_bast_admin, ca-tor_bast_admin, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-de_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, containers-kubernetes_prod_au-syd_all_admin, containers-kubernetes_prod_br-sao_all_admin, containers-kubernetes_prod_ca-tor_all_admin, containers-kubernetes_prod_eu-de_all_admin, containers-kubernetes_prod_eu-gb_all_admin, containers-kubernetes_prod_in-che_all_admin, containers-kubernetes_prod_jp-osa_all_admin, containers-kubernetes_prod_jp-tok_all_admin, containers-kubernetes_prod_kr-seo_all_admin, containers-kubernetes_prod_us-east_all_admin, containers-kubernetes_prod_us-south_all_admin, eu-de_bast_admin, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Argo Staging | ActivityTracker Readers, Add cases and view orders, Edit cases, IKS View Only, LogDNA Readers, SRE, Search cases, SysDig Readers, View account summary, View cases, icd-stage-reader |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, SRE, Search cases, View account summary, View cases |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, br-sao_bast_admin, ca-tor_bast_admin, containers-kubernetes_au-syd_all_admin, containers-kubernetes_au-syd_observability_viewer, containers-kubernetes_br-sao_all_admin, containers-kubernetes_br-sao_observability_viewer, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_ca-tor_observability_viewer, containers-kubernetes_eu-de_all_admin, containers-kubernetes_eu-de_observability_viewer, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_eu-gb_observability_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_in-che_observability_viewer, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-osa_observability_viewer, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_jp-tok_observability_viewer, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_kr-seo_observability_viewer, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-east_observability_viewer, containers-kubernetes_us-south_all_admin, containers-kubernetes_us-south_observability_viewer, eu-de_bast_admin, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SRE, Search cases, SysDigViewer, View account summary, View cases |
|  | IKS BNPP Prod | Add cases and view orders, Edit cases, LogDNA-eu-fr2-access, Search cases, SysDig Access Reader, View account summary, View cases |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-de_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_IKS_SRE-GB | Alch Dev - test | SRE |
|  | Alchemy Production's Account | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, containers-kubernetes_au-syd_all_admin, containers-kubernetes_br-sao_all_admin, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_eu-de_all_admin, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_global_cos_viewer, containers-kubernetes_global_xo-cos_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-south_all_admin |
|  | Alchemy Staging's Account | ActivityTracker Readers, IKS View Only, LogDNA Readers, SRE, SysDig Readers, global_iks_kubernetes_admin, icd-stage-reader |
|  | Alchemy Support | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, bot-ap-north-full, bot-ap-south-full, bot-dev-full, bot-full, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-full, bot-us-east-full, bot-us-south-full, br-sao_bast_admin, ca-tor_bast_admin, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, containers-kubernetes_prod_au-syd_all_admin, containers-kubernetes_prod_br-sao_all_admin, containers-kubernetes_prod_ca-tor_all_admin, containers-kubernetes_prod_eu-gb_all_admin, containers-kubernetes_prod_in-che_all_admin, containers-kubernetes_prod_jp-osa_all_admin, containers-kubernetes_prod_jp-tok_all_admin, containers-kubernetes_prod_kr-seo_all_admin, containers-kubernetes_prod_us-east_all_admin, containers-kubernetes_prod_us-south_all_admin, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Argo Staging | ActivityTracker Readers, Add cases and view orders, Edit cases, IKS View Only, LogDNA Readers, SRE, Search cases, SysDig Readers, View account summary, View cases, icd-stage-reader |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, SRE, Search cases, View account summary, View cases |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, br-sao_bast_admin, ca-tor_bast_admin, containers-kubernetes_au-syd_all_admin, containers-kubernetes_au-syd_observability_viewer, containers-kubernetes_br-sao_all_admin, containers-kubernetes_br-sao_observability_viewer, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_ca-tor_observability_viewer, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_eu-gb_observability_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_in-che_observability_viewer, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-osa_observability_viewer, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_jp-tok_observability_viewer, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_kr-seo_observability_viewer, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-east_observability_viewer, containers-kubernetes_us-south_all_admin, containers-kubernetes_us-south_observability_viewer, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SRE, Search cases, SysDigViewer, View account summary, View cases |
|  | IKS BNPP Prod | Add cases and view orders, Edit cases, LogDNA-eu-fr2-access, Search cases, SysDig Access Reader, View account summary, View cases |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_IKS_SRE-IE | Alch Dev - test | SRE |
|  | Alchemy Production's Account | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, containers-kubernetes_au-syd_all_admin, containers-kubernetes_br-sao_all_admin, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_eu-de_all_admin, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_global_cos_viewer, containers-kubernetes_global_xo-cos_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-south_all_admin |
|  | Alchemy Staging's Account | ActivityTracker Readers, IKS View Only, LogDNA Readers, SRE, SysDig Readers, global_iks_kubernetes_admin, icd-stage-reader |
|  | Alchemy Support | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, bot-ap-north-full, bot-ap-south-full, bot-dev-full, bot-eu-central-full, bot-full, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-full, bot-us-east-full, bot-us-south-full, br-sao_bast_admin, ca-tor_bast_admin, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-de_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, containers-kubernetes_prod_au-syd_all_admin, containers-kubernetes_prod_br-sao_all_admin, containers-kubernetes_prod_ca-tor_all_admin, containers-kubernetes_prod_eu-de_all_admin, containers-kubernetes_prod_eu-gb_all_admin, containers-kubernetes_prod_in-che_all_admin, containers-kubernetes_prod_jp-osa_all_admin, containers-kubernetes_prod_jp-tok_all_admin, containers-kubernetes_prod_kr-seo_all_admin, containers-kubernetes_prod_us-east_all_admin, containers-kubernetes_prod_us-south_all_admin, eu-de_bast_admin, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Argo Staging | ActivityTracker Readers, Add cases and view orders, Edit cases, IKS View Only, LogDNA Readers, SRE, Search cases, SysDig Readers, View account summary, View cases, icd-stage-reader |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, SRE, Search cases, View account summary, View cases |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, br-sao_bast_admin, ca-tor_bast_admin, containers-kubernetes_au-syd_all_admin, containers-kubernetes_au-syd_observability_viewer, containers-kubernetes_br-sao_all_admin, containers-kubernetes_br-sao_observability_viewer, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_ca-tor_observability_viewer, containers-kubernetes_eu-de_all_admin, containers-kubernetes_eu-de_observability_viewer, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_eu-gb_observability_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_in-che_observability_viewer, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-osa_observability_viewer, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_jp-tok_observability_viewer, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_kr-seo_observability_viewer, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-east_observability_viewer, containers-kubernetes_us-south_all_admin, containers-kubernetes_us-south_observability_viewer, eu-de_bast_admin, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SRE, Search cases, SysDigViewer, View account summary, View cases |
|  | IKS BNPP Prod | Add cases and view orders, Edit cases, LogDNA-eu-fr2-access, Search cases, SysDig Access Reader, View account summary, View cases |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-de_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_IKS_SRE-IN | Alch Dev - test | SRE |
|  | Alchemy Production's Account | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, containers-kubernetes_au-syd_all_admin, containers-kubernetes_br-sao_all_admin, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_eu-de_all_admin, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_global_cos_viewer, containers-kubernetes_global_xo-cos_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-south_all_admin |
|  | Alchemy Staging's Account | ActivityTracker Readers, IKS View Only, LogDNA Readers, SRE, SysDig Readers, global_iks_kubernetes_admin, icd-stage-reader |
|  | Alchemy Support | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, bot-ap-north-full, bot-ap-south-full, bot-dev-full, bot-full, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-full, bot-us-east-full, bot-us-south-full, br-sao_bast_admin, ca-tor_bast_admin, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, containers-kubernetes_prod_au-syd_all_admin, containers-kubernetes_prod_br-sao_all_admin, containers-kubernetes_prod_ca-tor_all_admin, containers-kubernetes_prod_eu-gb_all_admin, containers-kubernetes_prod_in-che_all_admin, containers-kubernetes_prod_jp-osa_all_admin, containers-kubernetes_prod_jp-tok_all_admin, containers-kubernetes_prod_kr-seo_all_admin, containers-kubernetes_prod_us-east_all_admin, containers-kubernetes_prod_us-south_all_admin, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Argo Staging | ActivityTracker Readers, Add cases and view orders, Edit cases, IKS View Only, LogDNA Readers, SRE, Search cases, SysDig Readers, View account summary, View cases, icd-stage-reader |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, SRE, Search cases, View account summary, View cases |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, br-sao_bast_admin, ca-tor_bast_admin, containers-kubernetes_au-syd_all_admin, containers-kubernetes_au-syd_observability_viewer, containers-kubernetes_br-sao_all_admin, containers-kubernetes_br-sao_observability_viewer, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_ca-tor_observability_viewer, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_eu-gb_observability_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_in-che_observability_viewer, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-osa_observability_viewer, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_jp-tok_observability_viewer, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_kr-seo_observability_viewer, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-east_observability_viewer, containers-kubernetes_us-south_all_admin, containers-kubernetes_us-south_observability_viewer, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SRE, Search cases, SysDigViewer, View account summary, View cases |
|  | IKS BNPP Prod | LogDNA-eu-fr2-access, SysDig Access Reader |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_IKS_SRE-NETINT | Alchemy Production's Account | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, containers-kubernetes_au-syd_all_admin, containers-kubernetes_br-sao_all_admin, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_eu-de_all_admin, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_global_cos_viewer, containers-kubernetes_global_xo-cos_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-south_all_admin |
|  | Alchemy Staging's Account | ActivityTracker Readers, IKS View Only, LogDNA Readers, Netint, SysDig Readers, global_iks_kubernetes_admin, icd-stage-reader |
|  | Alchemy Support | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, bot-ap-north-base, bot-ap-south-base, bot-base, bot-dev-full, bot-eu-central-base, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-base, bot-us-east-base, bot-us-south-base, br-sao_bast_admin, ca-tor_bast_admin, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, containers-kubernetes_prod_au-syd_all_admin, containers-kubernetes_prod_br-sao_all_admin, containers-kubernetes_prod_ca-tor_all_admin, containers-kubernetes_prod_eu-gb_all_admin, containers-kubernetes_prod_in-che_all_admin, containers-kubernetes_prod_jp-osa_all_admin, containers-kubernetes_prod_jp-tok_all_admin, containers-kubernetes_prod_kr-seo_all_admin, containers-kubernetes_prod_us-east_all_admin, containers-kubernetes_prod_us-south_all_admin, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Argo Staging | ActivityTracker Readers, Add cases and view orders, Edit cases, IKS View Only, LogDNA Readers, Netint, Search cases, SysDig Readers, View account summary, View cases, icd-stage-reader |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, SRE, Search cases, View account summary, View cases |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Search cases, View account summary, View cases, containers-kubernetes_au-syd_all_admin, containers-kubernetes_au-syd_observability_viewer, containers-kubernetes_br-sao_all_admin, containers-kubernetes_br-sao_observability_viewer, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_ca-tor_observability_viewer, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_eu-gb_observability_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_in-che_observability_viewer, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-osa_observability_viewer, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_jp-tok_observability_viewer, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_kr-seo_observability_viewer, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-east_observability_viewer, containers-kubernetes_us-south_all_admin, containers-kubernetes_us-south_observability_viewer |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SRE, Search cases, SysDigViewer, View account summary, View cases |
|  | IKS Registry Production EU-FR2 | container-registry_au-syd_all-sre_admin, container-registry_br-sao_all-sre_admin, container-registry_ca-tor_all-sre_admin, container-registry_eu-de_all-sre_admin, container-registry_eu-fr2_all-sre_admin, container-registry_eu-gb_all-sre_admin, container-registry_in-che_all-sre_admin, container-registry_jp-osa_all-sre_admin, container-registry_jp-tok_all-sre_admin, container-registry_kr-seo_all-sre_admin, container-registry_us-east_all-sre_admin, container-registry_us-south_all-sre_admin |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | registry-dev | Add cases and view orders, Edit cases, Retrieve users, SRE, Sysdig writers, View account summary, View cases |
|  | registry-prod | Add cases and view orders, Edit cases, Retrieve users, View account summary, View cases, container-registry_au-syd_all-sre_admin, container-registry_au-syd_logs-metrics_viewer, container-registry_br-sao_all-sre_admin, container-registry_br-sao_logs-metrics_viewer, container-registry_ca-tor_all-sre_admin, container-registry_ca-tor_logs-metrics_viewer, container-registry_eu-gb_all-sre_admin, container-registry_eu-gb_logs-metrics_viewer, container-registry_in-che_all-sre_admin, container-registry_in-che_logs-metrics_viewer, container-registry_jp-osa_all-sre_admin, container-registry_jp-osa_logs-metrics_viewer, container-registry_jp-tok_all-sre_admin, container-registry_jp-tok_logs-metrics_viewer, container-registry_kr-seo_all-sre_admin, container-registry_kr-seo_logs-metrics_viewer, container-registry_us-east_all-sre_admin, container-registry_us-east_logs-metrics_viewer, container-registry_us-south_all-sre_admin, container-registry_us-south_logs-metrics_viewer |
|  | registry-stage | Add cases and view orders, Edit cases, Retrieve users, SRE, View account summary, View cases |
| ROLE_IKS_SRE-NETINT-AUTOMATION | Alchemy Production's Account | Add cases and view orders, Edit cases, Search cases, View account summary, View cases, containers-kubernetes_global_kubernetes_admin |
|  | Alchemy Staging's Account |  |
|  | Alchemy Support | Add cases and view orders, Edit cases, Search cases, View account summary, View cases, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-de_logdna_operator, container-kubernetes_prod_eu-fr2_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, containers-kubernetes_global_kubernetes_admin, containers-kubernetes_prod_au-syd_all_admin, containers-kubernetes_prod_br-sao_all_admin, containers-kubernetes_prod_ca-tor_all_admin, containers-kubernetes_prod_eu-de_all_admin, containers-kubernetes_prod_eu-fr2_all_admin, containers-kubernetes_prod_eu-gb_all_admin, containers-kubernetes_prod_in-che_all_admin, containers-kubernetes_prod_jp-osa_all_admin, containers-kubernetes_prod_jp-tok_all_admin, containers-kubernetes_prod_kr-seo_all_admin, containers-kubernetes_prod_us-east_all_admin, containers-kubernetes_prod_us-south_all_admin |
|  | Argo Staging | Add cases and view orders, Edit cases, Netint, Search cases, View account summary, View cases, iks_global_kubernetes_admin |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, SRE, Search cases, View account summary, View cases, containers-kubernetes_global_kubernetes_admin |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Search cases, View account summary, View cases, iks_global_kubernetes_admin |
|  | Dev Containers | Add cases and view orders |
|  | IKS Registry Production EU-FR2 |  |
|  | Satellite Production | global_sre_automation, global_tugboat_automation |
|  | Satellite Stage | global_sre_automation, global_tugboat_automation |
|  | Satellite Stage TEST | global_sre_automation, global_tugboat_automation |
|  | registry-dev | Add cases and view orders, Edit cases, Retrieve users, SRE, View cases |
|  | registry-prod | Add cases and view orders, Edit cases, Retrieve users, View account summary, View cases, container-registry_au-syd_all-sre_admin, container-registry_au-syd_logs-metrics_viewer, container-registry_br-sao_all-sre_admin, container-registry_br-sao_logs-metrics_viewer, container-registry_ca-tor_all-sre_admin, container-registry_ca-tor_logs-metrics_viewer, container-registry_eu-de_all-sre_admin, container-registry_eu-de_logs-metrics_viewer, container-registry_eu-fr2_all-sre_admin, container-registry_eu-fr2_logs-metrics_viewer, container-registry_eu-gb_all-sre_admin, container-registry_eu-gb_logs-metrics_viewer, container-registry_in-che_all-sre_admin, container-registry_in-che_logs-metrics_viewer, container-registry_jp-osa_all-sre_admin, container-registry_jp-osa_logs-metrics_viewer, container-registry_jp-tok_all-sre_admin, container-registry_jp-tok_logs-metrics_viewer, container-registry_kr-seo_all-sre_admin, container-registry_kr-seo_logs-metrics_viewer, container-registry_us-east_all-sre_admin, container-registry_us-east_logs-metrics_viewer, container-registry_us-south_all-sre_admin, container-registry_us-south_logs-metrics_viewer |
|  | registry-stage | Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SRE, SRE_EU, Search cases, View account summary, View cases |
| ROLE_IKS_SRE-SUPERADMIN | Alch Dev - test | global_superadmin |
|  | Alchemy Production's Account | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, One-time payments, Retrieve users, Search cases, Update payment details, View account summary, View cases, global_superadmin |
|  | Alchemy Staging's Account | global_superadmin |
|  | Alchemy Support | Add cases and view orders, Edit cases, Get compliance report, Retrieve users, Search cases, View account summary, View cases, global_superadmin |
|  | Argo Staging | global_superadmin |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, Limit EU case restriction, One-time payments, Retrieve users, Search cases, Update payment details, View account summary, View cases, global_superadmin |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, Limit EU case restriction, One-time payments, Retrieve users, Search cases, Update payment details, View account summary, View cases, global_superadmin |
|  | Dev Containers | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, Limit EU case restriction, One-time payments, Retrieve users, Search cases, Update payment details, View account summary, View cases, global_superadmin |
|  | IKS Registry Production EU-FR2 | global_superadmin |
|  | Razee Dev | global_superadmin |
|  | Razee Stage | global_superadmin |
|  | Satellite Production | global_superadmin |
|  | Satellite Stage | global_superadmin |
|  | Satellite Stage TEST | global_superadmin |
|  | registry-dev | Get compliance report, Limit EU case restriction, One-time payments, Update payment details, global_superadmin |
|  | registry-prod | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, One-time payments, Retrieve users, Update payment details, View account summary, View cases, global_superadmin |
|  | registry-stage | Add cases and view orders, Edit cases, Edit company profile, Get compliance report, Limit EU case restriction, One-time payments, Retrieve users, Search cases, Update payment details, View account summary, View cases, global_superadmin |
| ROLE_IKS_SRE-US | Alch Dev - test | SRE |
|  | Alchemy Production's Account | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, containers-kubernetes_au-syd_all_admin, containers-kubernetes_br-sao_all_admin, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_eu-de_all_admin, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_global_cos_viewer, containers-kubernetes_global_xo-cos_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-south_all_admin |
|  | Alchemy Staging's Account | ActivityTracker Readers, IKS View Only, LogDNA Readers, SRE, SysDig Readers, global_iks_kubernetes_admin, icd-stage-reader |
|  | Alchemy Support | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, bot-ap-north-full, bot-ap-south-full, bot-dev-full, bot-full, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-full, bot-us-east-full, bot-us-south-full, br-sao_bast_admin, ca-tor_bast_admin, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, containers-kubernetes_prod_au-syd_all_admin, containers-kubernetes_prod_br-sao_all_admin, containers-kubernetes_prod_ca-tor_all_admin, containers-kubernetes_prod_eu-gb_all_admin, containers-kubernetes_prod_in-che_all_admin, containers-kubernetes_prod_jp-osa_all_admin, containers-kubernetes_prod_jp-tok_all_admin, containers-kubernetes_prod_kr-seo_all_admin, containers-kubernetes_prod_us-east_all_admin, containers-kubernetes_prod_us-south_all_admin, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Argo Staging | ActivityTracker Readers, Add cases and view orders, Edit cases, IKS View Only, LogDNA Readers, SRE, Search cases, SysDig Readers, View account summary, View cases, icd-stage-reader |
|  | Argonauts Dev 659437 | Add cases and view orders, Edit cases, Retrieve users, SRE, Search cases, View account summary, View cases |
|  | Argonauts Production 531277 | Add cases and view orders, Edit cases, Retrieve users, Search cases, View account summary, View cases, au-syd_bast_admin, br-sao_bast_admin, ca-tor_bast_admin, containers-kubernetes_au-syd_all_admin, containers-kubernetes_au-syd_observability_viewer, containers-kubernetes_br-sao_all_admin, containers-kubernetes_br-sao_observability_viewer, containers-kubernetes_ca-tor_all_admin, containers-kubernetes_ca-tor_observability_viewer, containers-kubernetes_eu-gb_all_admin, containers-kubernetes_eu-gb_observability_viewer, containers-kubernetes_in-che_all_admin, containers-kubernetes_in-che_observability_viewer, containers-kubernetes_jp-osa_all_admin, containers-kubernetes_jp-osa_observability_viewer, containers-kubernetes_jp-tok_all_admin, containers-kubernetes_jp-tok_observability_viewer, containers-kubernetes_kr-seo_all_admin, containers-kubernetes_kr-seo_observability_viewer, containers-kubernetes_us-east_all_admin, containers-kubernetes_us-east_observability_viewer, containers-kubernetes_us-south_all_admin, containers-kubernetes_us-south_observability_viewer, eu-gb_bast_admin, in-che_bast_admin, jp-osa_bast_admin, jp-tok_bast_admin, kr-seo_bast_admin, us-east_bast_admin, us-south_bast_admin |
|  | Dev Containers | ActivityTracker Readers, Add cases and view orders, Edit cases, LogDNA Readers, Retrieve users, SRE, Search cases, SysDigViewer, View account summary, View cases |
|  | IKS BNPP Prod | Add cases and view orders, Edit cases, LogDNA-eu-fr2-access, Search cases, SysDig Access Reader, View account summary, View cases |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_RAZEE_AUTOMATION-NON-PRODUCTION | Dev Containers | global_iks_kubernetes_admin, satellite-config |
| ROLE_RAZEE_DEVELOPER | Alchemy Production's Account | containers-kubernetes_au-syd_logs-metrics_viewer, containers-kubernetes_br-sao_logs-metrics_viewer, containers-kubernetes_ca-tor_logs-metrics_viewer, containers-kubernetes_eu-de_logs-metrics_viewer, containers-kubernetes_eu-gb_logs-metrics_viewer, containers-kubernetes_in-che_logs-metrics_viewer, containers-kubernetes_jp-osa_logs-metrics_viewer, containers-kubernetes_jp-tok_logs-metrics_viewer, containers-kubernetes_kr-seo_logs-metrics_viewer, containers-kubernetes_us-east_logs-metrics_viewer, containers-kubernetes_us-south_logs-metrics_viewer |
|  | Alchemy Staging's Account | ActivityTracker Readers, LogDNA Readers, SysDig Readers, global_iks_kubernetes_admin |
|  | Alchemy Support | bot-ap-north-base, bot-ap-south-base, bot-base, bot-dev-full, bot-eu-central-base, bot-iksstg-full, bot-pre-stage-full, bot-stage-full, bot-uk-south-base, bot-us-east-base, bot-us-south-base, container-kubernetes_prod_au-syd_logdna_operator, container-kubernetes_prod_br-sao_logdna_operator, container-kubernetes_prod_ca-tor_logdna_operator, container-kubernetes_prod_eu-de_logdna_operator, container-kubernetes_prod_eu-gb_logdna_operator, container-kubernetes_prod_in-che_logdna_operator, container-kubernetes_prod_jp-osa_logdna_operator, container-kubernetes_prod_jp-tok_logdna_operator, container-kubernetes_prod_kr-seo_logdna_operator, container-kubernetes_prod_us-east_logdna_operator, container-kubernetes_prod_us-south_logdna_operator, satellite-config_au-syd_all_admin, satellite-config_br-sao_all_admin, satellite-config_ca-tor_all_admin, satellite-config_eu-de_all_admin, satellite-config_eu-gb_all_admin, satellite-config_in-che_all_admin, satellite-config_jp-osa_all_admin, satellite-config_jp-tok_all_admin, satellite-config_kr-seo_all_admin, satellite-config_us-east_all_admin, satellite-config_us-south_all_admin |
|  | Argo Staging | ActivityTracker Readers, LogDNA Readers, SysDig Readers |
|  | Argonauts Dev 659437 | IKS View Only, armada-log-collector |
|  | Dev Containers | ActivityTracker Readers, LogDNA Readers, SysDigViewer, csutil-automation, global_iks_kubernetes_admin |
|  | Razee Dev | SQUAD |
|  | Razee Stage | Razee Developers |
|  | Satellite Production | satellite-config_au-syd_metrics-logs_viewer, satellite-config_br-sao_metrics-logs_viewer, satellite-config_ca-tor_metrics-logs_viewer, satellite-config_eu-de_metrics-logs_viewer, satellite-config_eu-gb_metrics-logs_viewer, satellite-config_in-che_metrics-logs_viewer, satellite-config_jp-osa_metrics-logs_viewer, satellite-config_jp-tok_metrics-logs_viewer, satellite-config_kr-seo_metrics-logs_viewer, satellite-config_us-east_metrics-logs_viewer, satellite-config_us-south_metrics-logs_viewer |
|  | Satellite Stage | satellite-config_us-south_all_viewer, satellite-config_us-south_kubernetes_admin, satellite-config_us-south_metrics-logs_viewer |
|  | Satellite Stage TEST | satellite-location_us-south_all_viewer, satellite-location_us-south_kubernetes_admin |
| ROLE_RAZEE_PRODUCTION | Satellite Production | satellite-config_au-syd_all_viewer, satellite-config_br-sao_all_viewer, satellite-config_ca-tor_all_viewer, satellite-config_eu-gb_all_viewer, satellite-config_in-che_all_viewer, satellite-config_jp-osa_all_viewer, satellite-config_jp-tok_all_viewer, satellite-config_kr-seo_all_viewer, satellite-config_us-east_all_viewer, satellite-config_us-south_all_viewer |
|  | Satellite Stage | satellite-config_us-south_all_viewer, satellite-config_us-south_kubernetes_admin, satellite-config_us-south_metrics-logs_viewer |
|  | Satellite Stage TEST | satellite-location_us-south_all_viewer, satellite-location_us-south_kubernetes_admin |
| ROLE_RAZEE_SRE-AU | Razee Dev | SRE |
|  | Razee Stage | SRE |
| ROLE_RAZEE_SRE-CN | Razee Dev | SRE |
|  | Razee Stage | SRE |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_RAZEE_SRE-DE | Razee Dev | SRE |
|  | Razee Stage | SRE |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-de_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_RAZEE_SRE-GB | Razee Dev | SRE |
|  | Razee Stage | SRE |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_RAZEE_SRE-IE | Razee Dev | SRE |
|  | Razee Stage | SRE |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-de_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_RAZEE_SRE-IN | Razee Dev | SRE |
|  | Razee Stage | SRE |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_RAZEE_SRE-US | Razee Dev | SRE |
|  | Razee Stage | SRE |
|  | Satellite Production | satellite_au-syd_all_admin, satellite_br-sao_all_admin, satellite_ca-tor_all_admin, satellite_eu-gb_all_admin, satellite_in-che_all_admin, satellite_jp-osa_all_admin, satellite_jp-tok_all_admin, satellite_kr-seo_all_admin, satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage | satellite_us-east_all_admin, satellite_us-south_all_admin |
|  | Satellite Stage TEST | satellite_us-south_all_admin |
| ROLE_SAT_AUTOMATION-NON-PRODUCTION | Alch Dev - test | iks_multishift_dev_squad |
|  | Satellite Stage | global_tugboat_automation |
|  | Satellite Stage TEST | global_tugboat_automation |
| ROLE_SAT_AUTOMATION-PRODUCTION | Satellite Production | global_tugboat_automation |
|  | Satellite Production | global_tugboat_automation |
| ROLE_SAT_DEVELOPER-LINK | Satellite Production | satellite-link_au-syd_metrics-logs_viewer, satellite-link_br-sao_metrics-logs_viewer, satellite-link_ca-tor_metrics-logs_viewer, satellite-link_eu-de_metrics-logs_viewer, satellite-link_eu-gb_metrics-logs_viewer, satellite-link_in-che_metrics-logs_viewer, satellite-link_jp-osa_metrics-logs_viewer, satellite-link_jp-tok_metrics-logs_viewer, satellite-link_kr-seo_metrics-logs_viewer, satellite-link_us-east_metrics-logs_viewer, satellite-link_us-south_metrics-logs_viewer |
|  | Satellite Stage | satellite-link_global_registry_viewer, satellite-link_us-south_all_viewer, satellite-link_us-south_kubernetes_admin, satellite-link_us-south_metrics-logs_viewer |
|  | Satellite Stage TEST | satellite-location_us-south_all_viewer, satellite-location_us-south_kubernetes_admin |
| ROLE_SAT_DEVELOPER-LOCATION | Satellite Production | satellite-location_au-syd_metrics-logs_viewer, satellite-location_br-sao_metrics-logs_viewer, satellite-location_ca-tor_metrics-logs_viewer, satellite-location_eu-de_metrics-logs_viewer, satellite-location_eu-gb_metrics-logs_viewer, satellite-location_in-che_metrics-logs_viewer, satellite-location_jp-osa_metrics-logs_viewer, satellite-location_jp-tok_metrics-logs_viewer, satellite-location_kr-seo_metrics-logs_viewer, satellite-location_us-east_metrics-logs_viewer, satellite-location_us-south_metrics-logs_viewer |
|  | Satellite Stage | satellite-location_us-south_all_viewer, satellite-location_us-south_kubernetes_admin, satellite-location_us-south_metrics-logs_viewer |
|  | Satellite Stage TEST | satellite-location_us-south_all_viewer, satellite-location_us-south_kubernetes_admin |
| ROLE_SAT_LINK-SRE-CA | Satellite Production | satellite-link_au-syd_all_admin, satellite-link_br-sao_all_admin, satellite-link_ca-tor_all_admin, satellite-link_eu-de_all_admin, satellite-link_eu-gb_all_admin, satellite-link_in-che_all_admin, satellite-link_jp-osa_all_admin, satellite-link_jp-tok_all_admin, satellite-link_kr-seo_all_admin, satellite-link_us-east_all_admin, satellite-link_us-south_all_admin |
|  | Satellite Stage | satellite-link_us-south_all_admin |
| ROLE_SAT_LINK-SRE-DE | Satellite Production | satellite-link_au-syd_all_admin, satellite-link_br-sao_all_admin, satellite-link_ca-tor_all_admin, satellite-link_eu-de_all_admin, satellite-link_eu-gb_all_admin, satellite-link_in-che_all_admin, satellite-link_jp-osa_all_admin, satellite-link_jp-tok_all_admin, satellite-link_kr-seo_all_admin, satellite-link_us-east_all_admin, satellite-link_us-south_all_admin |
|  | Satellite Stage | satellite-link_us-south_all_admin |
| ROLE_SAT_LINK-SRE-GB | Satellite Production | satellite-link_au-syd_all_admin, satellite-link_br-sao_all_admin, satellite-link_ca-tor_all_admin, satellite-link_eu-gb_all_admin, satellite-link_in-che_all_admin, satellite-link_jp-osa_all_admin, satellite-link_jp-tok_all_admin, satellite-link_kr-seo_all_admin, satellite-link_us-east_all_admin, satellite-link_us-south_all_admin |
|  | Satellite Stage | satellite-link_us-south_all_admin |
| ROLE_SAT_LINK-SRE-IT | Satellite Production | satellite-link_au-syd_all_admin, satellite-link_br-sao_all_admin, satellite-link_ca-tor_all_admin, satellite-link_eu-de_all_admin, satellite-link_eu-gb_all_admin, satellite-link_in-che_all_admin, satellite-link_jp-osa_all_admin, satellite-link_jp-tok_all_admin, satellite-link_kr-seo_all_admin, satellite-link_us-east_all_admin, satellite-link_us-south_all_admin |
|  | Satellite Stage | satellite-link_us-south_all_admin |
| ROLE_SAT_LINK-SRE-US | Satellite Production | satellite-link_au-syd_all_admin, satellite-link_br-sao_all_admin, satellite-link_ca-tor_all_admin, satellite-link_eu-de_all_admin, satellite-link_eu-gb_all_admin, satellite-link_in-che_all_admin, satellite-link_jp-osa_all_admin, satellite-link_jp-tok_all_admin, satellite-link_kr-seo_all_admin, satellite-link_us-east_all_admin, satellite-link_us-south_all_admin |
|  | Satellite Stage | satellite-link_us-south_all_admin |
| ROLE_SAT_PRODUCTION-EU_EMERG | Satellite Production | satellite_eu-de_all_eu_emerg |
| ROLE_SAT_PRODUCTION-LINK | Satellite Production | satellite-link_au-syd_all_viewer, satellite-link_br-sao_all_viewer, satellite-link_ca-tor_all_viewer, satellite-link_eu-de_all_admin, satellite-link_eu-gb_all_viewer, satellite-link_in-che_all_viewer, satellite-link_jp-osa_all_viewer, satellite-link_jp-tok_all_viewer, satellite-link_kr-seo_all_viewer, satellite-link_us-east_all_viewer, satellite-link_us-south_all_viewer |
|  | Satellite Stage | satellite-link_global_registry_viewer, satellite-link_us-south_all_viewer, satellite-link_us-south_kubernetes_admin, satellite-link_us-south_metrics-logs_viewer |
|  | Satellite Stage TEST | satellite-location_us-south_all_viewer, satellite-location_us-south_kubernetes_admin |
| ROLE_SAT_PRODUCTION-LOCATION | Satellite Production | satellite-location_au-syd_all_viewer, satellite-location_br-sao_all_viewer, satellite-location_ca-tor_all_viewer, satellite-location_eu-gb_all_viewer, satellite-location_in-che_all_viewer, satellite-location_jp-osa_all_viewer, satellite-location_jp-tok_all_viewer, satellite-location_kr-seo_all_viewer, satellite-location_us-east_all_viewer, satellite-location_us-south_all_viewer |
|  | Satellite Stage | satellite-location_us-south_all_viewer, satellite-location_us-south_kubernetes_admin, satellite-location_us-south_metrics-logs_viewer |
|  | Satellite Stage TEST | satellite-location_us-south_all_viewer, satellite-location_us-south_kubernetes_admin |

## Roles with access to each account

| Account | AccessGroup | Roles |
| :---: | :-- | :-- |
| Alch Dev - test | SRE | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | iks_multishift_dev_squad | ROLE_IKS_DEVELOPER-BOOTSTRAP, ROLE_SAT_AUTOMATION-NON-PRODUCTION |
| Alchemy Production's Account | Add cases and view orders | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-PRODUCTION, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-PRODUCTION-CLUSTER, ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP, ROLE_IKS_SRE-SUPERADMIN |
|  | Edit cases | ROLE_IKS_AUTOMATION-PRODUCTION, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-PRODUCTION-CLUSTER, ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP, ROLE_IKS_SRE-SUPERADMIN |
|  | Edit company profile | ROLE_IKS_SRE-SUPERADMIN |
|  | Get compliance report | ROLE_IKS_SRE-SUPERADMIN |
|  | One-time payments | ROLE_IKS_SRE-SUPERADMIN |
|  | Retrieve users | ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-SUPERADMIN |
|  | Search cases | ROLE_IKS_AUTOMATION-PRODUCTION, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-PRODUCTION-CLUSTER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP, ROLE_IKS_SRE-SUPERADMIN |
|  | Update payment details | ROLE_IKS_SRE-SUPERADMIN |
|  | View account summary | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | View cases | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-PRODUCTION, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-PRODUCTION-CLUSTER, ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP, ROLE_IKS_SRE-SUPERADMIN |
|  | containers-kubernetes_au-syd_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_au-syd_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | containers-kubernetes_br-sao_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_br-sao_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | containers-kubernetes_ca-tor_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_ca-tor_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | containers-kubernetes_eu-de_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_eu-de_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | containers-kubernetes_eu-gb_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_eu-gb_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | containers-kubernetes_global_billing_viewer | ROLE_IKS_DEVELOPER-BILLING |
|  | containers-kubernetes_global_catalog_admin | ROLE_IKS_DEVELOPER-OFFERING-ADMIN |
|  | containers-kubernetes_global_cos_viewer | ROLE_IKS_PRODUCTION-OPS, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_global_kubernetes_admin | ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_AUTOMATION-PRODUCTION, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR |
|  | containers-kubernetes_global_postgresDB_viewer | ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR |
|  | containers-kubernetes_global_registry_admin | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-PRODUCTION, ROLE_IKS_AUTOMATION-PRODUCTION-TUGBOAT |
|  | containers-kubernetes_global_xo-cos_viewer | ROLE_IKS_DEVELOPER, ROLE_IKS_DEVELOPER-OFFERING, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_in-che_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_in-che_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | containers-kubernetes_jp-osa_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_jp-osa_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | containers-kubernetes_jp-tok_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_jp-tok_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | containers-kubernetes_kr-seo_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_kr-seo_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | containers-kubernetes_us-east_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_us-east_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | containers-kubernetes_us-south_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_us-south_logs-metrics_viewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | watson_us-south_logs-metrics_viewer | ROLE_IKS_OPS-PRODUCTION-WATSON |
| Alchemy Staging's Account | ActivityTracker Readers | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT |
|  | Containers-Test-Automation | ROLE_IKS_AUTOMATION-NON-PRODUCTION |
|  | IKS Development | ROLE_IKS_DEVELOPER |
|  | IKS View Only | ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | LogDNA Readers | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SECURITY |
|  | Netint | ROLE_IKS_SRE-NETINT |
|  | SRE | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP |
|  | SysDig Readers | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_global_billing_viewer | ROLE_IKS_DEVELOPER-BILLING |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_catalog_admin | ROLE_IKS_DEVELOPER-OFFERING-ADMIN |
|  | global_iks_kubernetes_admin | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SECURITY |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | icd-stage-reader | ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | iks_global_billing_viewer | ROLE_IKS_DEVELOPER-CLUSTER, ROLE_IKS_DEVELOPER-CLUSTER-ADMIN |
| Alchemy Support | Add cases and view orders | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Edit cases | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Get compliance report | ROLE_IKS_SRE-SUPERADMIN |
|  | Retrieve users | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-SUPERADMIN |
|  | Search cases | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | View account summary | ROLE_IKS_AUTOMATION-PRODUCTION-BLUEFRINGE, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | View cases | ROLE_IKS_AUTOMATION-PRODUCTION-BLUEFRINGE, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | au-syd_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | bot-ap-north-base | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-ap-north-full | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | bot-ap-south-base | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-ap-south-full | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | bot-base | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-dev-base | ROLE_IKS_SRE-BNPP |
|  | bot-dev-full | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-eu-central-base | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-eu-central-full | ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE |
|  | bot-eu-fr2-full | ROLE_IKS_SRE-BNPP |
|  | bot-full | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | bot-iksstg-full | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-pre-stage-full | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-stage-full | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-uk-south-base | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-uk-south-full | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | bot-us-east-base | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-us-east-full | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | bot-us-south-base | ROLE_ICCR_DEVELOPER, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | bot-us-south-full | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | br-sao_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | ca-tor_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | container-kubernetes_prod_au-syd_logdna_operator | ROLE_ICCR_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-BUILD |
|  | container-kubernetes_prod_br-sao_logdna_operator | ROLE_ICCR_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-BUILD |
|  | container-kubernetes_prod_ca-tor_logdna_operator | ROLE_ICCR_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-BUILD |
|  | container-kubernetes_prod_eu-de_logdna_operator | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-kubernetes_prod_eu-fr2_logdna_operator | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-kubernetes_prod_eu-gb_logdna_operator | ROLE_ICCR_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-BUILD |
|  | container-kubernetes_prod_in-che_logdna_operator | ROLE_ICCR_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-BUILD |
|  | container-kubernetes_prod_jp-osa_logdna_operator | ROLE_ICCR_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-BUILD |
|  | container-kubernetes_prod_jp-tok_logdna_operator | ROLE_ICCR_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-BUILD |
|  | container-kubernetes_prod_kr-seo_logdna_operator | ROLE_ICCR_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-BUILD |
|  | container-kubernetes_prod_us-east_logdna_operator | ROLE_ICCR_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-BUILD |
|  | container-kubernetes_prod_us-south_logdna_operator | ROLE_ICCR_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-BUILD |
|  | container-kubernetes_stage_global_dashboardclusters_admin | ROLE_IKS_DEVELOPER-CARRIERRUNTIME |
|  | containers-kubernetes_global_iam_viewer | ROLE_IKS_AUTOMATION-SRE-BOT |
|  | containers-kubernetes_global_kubernetes_admin | ROLE_IKS_AUTOMATION-ICDEVOPS, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_au-syd_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_br-sao_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_ca-tor_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_eu-de_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_eu-fr2_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_eu-gb_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_in-che_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_jp-osa_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_jp-tok_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_kr-seo_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_us-east_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | containers-kubernetes_prod_us-south_all_admin | ROLE_IKS_AUTOMATION-BUILD, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | eu-de_bast_admin | ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE |
|  | eu-gb_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_sre_automation | ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | in-che_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | jp-osa_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | jp-tok_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | kr-seo_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite-config_au-syd_all_admin | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_br-sao_all_admin | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_ca-tor_all_admin | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_eu-de_all_admin | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_eu-gb_all_admin | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_in-che_all_admin | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_jp-osa_all_admin | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_jp-tok_all_admin | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_kr-seo_all_admin | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_us-east_all_admin | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_us-south_all_admin | ROLE_RAZEE_DEVELOPER |
|  | us-east_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | us-south_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
| Argo Staging | ActivityTracker Readers | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_DEVELOPER-CARRIERRUNTIME, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT |
|  | Add cases and view orders | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_DEVELOPER, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | Edit cases | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_DEVELOPER, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | Edit company profile | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | Get compliance report | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | IKS Development | ROLE_IKS_DEVELOPER |
|  | IKS View Only | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | IKS tugboat automation | ROLE_IKS_AUTOMATION-NON-PRODUCTION |
|  | LogDNA Readers | ROLE_ICCR_DEVELOPER, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_DEVELOPER, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_RAZEE_DEVELOPER, ROLE_IKS_DEVELOPER-CARRIERRUNTIME, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP |
|  | Netint | ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | One-time payments | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | SRE | ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP |
|  | Search cases | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_DEVELOPER, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | SysDig Readers | ROLE_ICCR_DEVELOPER, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_IKS_DEVELOPER-CARRIERRUNTIME, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT |
|  | Update payment details | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | View account summary | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_DEVELOPER, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | View cases | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_DEVELOPER, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | icd-stage-reader | ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | iks_global_kubernetes_admin | ROLE_IKS_SRE-NETINT-AUTOMATION |
| Argonauts Dev 659437 | Add cases and view orders | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-SUPERADMIN, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR, ROLE_IKS_AUTOMATION-PERFORMANCE |
|  | Edit cases | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-SUPERADMIN, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR, ROLE_IKS_AUTOMATION-PERFORMANCE |
|  | Edit company profile | ROLE_IKS_SRE-SUPERADMIN |
|  | Get compliance report | ROLE_IKS_SRE-SUPERADMIN |
|  | IKS Tugboat Automation | ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_AUTOMATION-NON-PRODUCTION-TUGBOAT, ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY |
|  | IKS View Only | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_DEVELOPER-STORAGE, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY |
|  | Limit EU case restriction | ROLE_IKS_SRE-SUPERADMIN |
|  | One-time payments | ROLE_IKS_SRE-SUPERADMIN |
|  | Retrieve users | ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-SUPERADMIN, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR, ROLE_IKS_AUTOMATION-PERFORMANCE |
|  | SRE | ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | Search cases | ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-SUPERADMIN, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY, ROLE_IKS_AUTOMATION-PERFORMANCE |
|  | Update payment details | ROLE_IKS_SRE-SUPERADMIN |
|  | View account summary | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-SUPERADMIN, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR, ROLE_IKS_AUTOMATION-PERFORMANCE |
|  | View cases | ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-SUPERADMIN, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR, ROLE_IKS_AUTOMATION-PERFORMANCE |
|  | armada-log-collector | ROLE_ICCR_DEVELOPER, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_DEVELOPER, ROLE_IKS_DEVELOPER-STORAGE, ROLE_IKS_DEVELOPER-DOCUMENTATION, ROLE_RAZEE_DEVELOPER, ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY |
|  | bastionx-test | ROLE_IKS_SRE-BNPP |
|  | containers-kubernetes_global_kubernetes_admin | ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
| Argonauts Production 531277 | Add cases and view orders | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Edit cases | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Edit company profile | ROLE_IKS_SRE-SUPERADMIN |
|  | Get compliance report | ROLE_IKS_SRE-SUPERADMIN |
|  | Limit EU case restriction | ROLE_IKS_SRE-SUPERADMIN |
|  | One-time payments | ROLE_IKS_SRE-SUPERADMIN |
|  | Retrieve users | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-SUPERADMIN |
|  | Search cases | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Update payment details | ROLE_IKS_SRE-SUPERADMIN |
|  | View account summary | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | View cases | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | au-syd_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | br-sao_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | ca-tor_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | containers-kubernetes_au-syd_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_au-syd_observability_viewer | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_br-sao_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_br-sao_observability_viewer | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_ca-tor_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_ca-tor_observability_viewer | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_eu-de_all_admin | ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE |
|  | containers-kubernetes_eu-de_observability_viewer | ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE |
|  | containers-kubernetes_eu-gb_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_eu-gb_observability_viewer | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_in-che_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_in-che_observability_viewer | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_jp-osa_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_jp-osa_observability_viewer | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_jp-tok_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_jp-tok_observability_viewer | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_kr-seo_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_kr-seo_observability_viewer | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_us-east_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_us-east_observability_viewer | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_us-south_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | containers-kubernetes_us-south_observability_viewer | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-NETINT |
|  | cto-security_global_certmanager_viewer | ROLE_IKS_AUTOMATION-SCORECARD |
|  | eu-de_bast_admin | ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE |
|  | eu-gb_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | global_tugboat_automation | ROLE_IKS_AUTOMATION-PRODUCTION, ROLE_IKS_AUTOMATION-PRODUCTION-TUGBOAT |
|  | iks-security_au-syd_certmanager_viewer | ROLE_IKS_SECURITY |
|  | iks-security_br-sao_certmanager_viewer | ROLE_IKS_SECURITY |
|  | iks-security_ca-tor_certmanager_viewer | ROLE_IKS_SECURITY |
|  | iks-security_eu-gb_certmanager_viewer | ROLE_IKS_SECURITY |
|  | iks-security_in-che_certmanager_viewer | ROLE_IKS_SECURITY |
|  | iks-security_jp-osa_certmanager_viewer | ROLE_IKS_SECURITY |
|  | iks-security_jp-tok_certmanager_viewer | ROLE_IKS_SECURITY |
|  | iks-security_kr-seo_certmanager_viewer | ROLE_IKS_SECURITY |
|  | iks-security_us-east_certmanager_viewer | ROLE_IKS_SECURITY |
|  | iks-security_us-south_certmanager_viewer | ROLE_IKS_SECURITY |
|  | iks_global_kubernetes_admin | ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | iks_global_sre_automation_nothing | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-PRODUCTION-ARGONAUTS, ROLE_IKS_AUTOMATION-SRE-BOT, ROLE_IKS_AUTOMATION-PRODUCTION-BOOTSTRAP, ROLE_IKS_AUTOMATION-PRODUCTION-CLUSTER, ROLE_IKS_AUTOMATION-VULNERABILITY-ADVISOR |
|  | in-che_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | jp-osa_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | jp-tok_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | kr-seo_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | us-east_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | us-south_bast_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
| Dev Containers | ActivityTracker Readers | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT |
|  | Add cases and view orders | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_SRE-SUPERADMIN |
|  | Containers-Test-Automation | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_AUTOMATION-PRODUCTION-TUGBOAT |
|  | Edit cases | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_SRE-SUPERADMIN |
|  | Edit company profile | ROLE_IKS_SRE-SUPERADMIN |
|  | Get compliance report | ROLE_IKS_SRE-SUPERADMIN |
|  | Limit EU case restriction | ROLE_IKS_SRE-SUPERADMIN |
|  | LogDNA Readers | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT |
|  | One-time payments | ROLE_IKS_SRE-SUPERADMIN |
|  | Retrieve users | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_SRE-SUPERADMIN |
|  | SECURITY-COMPLIANCE-SQUAD | ROLE_IKS_SECURITY |
|  | SRE | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT |
|  | Search cases | ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_SRE-SUPERADMIN |
|  | SysDigViewer | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_RAZEE_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-PRODUCTION-ALCHEMY |
|  | Update payment details | ROLE_IKS_SRE-SUPERADMIN |
|  | View account summary | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_AUTOMATION-CONTAINERBOT, ROLE_IKS_SRE-SUPERADMIN |
|  | View cases | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_DEVELOPER, ROLE_IKS_SECURITY, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_IKS_SRE-SUPERADMIN |
|  | csutil-automation | ROLE_RAZEE_DEVELOPER |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_iks_kubernetes_admin | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-NON-PRODUCTION, ROLE_IKS_DEVELOPER, ROLE_RAZEE_DEVELOPER, ROLE_RAZEE_AUTOMATION-NON-PRODUCTION, ROLE_IKS_AUTOMATION-PERFORMANCE |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | satellite-config | ROLE_RAZEE_AUTOMATION-NON-PRODUCTION |
| IKS BNPP Prod | Add cases and view orders | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-BNPP-SUPERADMIN, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION-TESTING, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | Edit cases | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-BNPP-SUPERADMIN, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION-TESTING, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | Edit company profile | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_SRE-BNPP-SUPERADMIN |
|  | Get compliance report | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_SRE-BNPP-SUPERADMIN |
|  | Limit EU case restriction | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_SRE-BNPP-SUPERADMIN |
|  | LogDNA-eu-fr2-access | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-BNPP, ROLE_IKS_DEVELOPER-MANAGERS, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | LogDNA-eu-fr2-editors | ROLE_IKS_DEVELOPER |
|  | One-time payments | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_SRE-BNPP-SUPERADMIN |
|  | ProductionAutomation | ROLE_IKS_BNPP-AUTOMATION-PRODUCTION |
|  | ProductionAutomationTesting | ROLE_IKS_BNPP-AUTOMATION-PRODUCTION-TESTING |
|  | SRE-BNPP | ROLE_IKS_SRE-BNPP |
|  | SUPERADMIN | ROLE_IKS_SRE-BNPP-SUPERADMIN |
|  | Search cases | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-BNPP-SUPERADMIN, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION-TESTING, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | SysDig Access Reader | ROLE_ICCR_DEVELOPER, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-BNPP, ROLE_IKS_DEVELOPER-MANAGERS, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | Teleport Admins | ROLE_IKS_BNPP-TELEPORT-ADMIN |
|  | Update payment details | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_SRE-BNPP-SUPERADMIN |
|  | View account summary | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-BNPP-SUPERADMIN, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION-TESTING, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | View cases | ROLE_IKS_AUTOMATION-ACCESSHUB, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION, ROLE_IKS_SRE-BNPP, ROLE_IKS_SRE-BNPP-SUPERADMIN, ROLE_IKS_BNPP-AUTOMATION-PRODUCTION-TESTING, ROLE_IKS_DEVELOPER, ROLE_IKS_SRE-AU, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-US |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
| IKS Registry Production EU-FR2 | container-registry_au-syd_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_au-syd_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_au-syd_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_au-syd_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_au-syd_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_br-sao_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_br-sao_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_br-sao_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_br-sao_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_br-sao_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_ca-tor_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_ca-tor_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_ca-tor_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_ca-tor_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_ca-tor_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_eu-de_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_eu-de_all-sre_admin | ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_eu-de_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_eu-de_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_eu-de_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_eu-fr2_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_eu-fr2_all-sre_admin | ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_eu-fr2_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_eu-fr2_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_eu-fr2_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_eu-gb_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_eu-gb_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_eu-gb_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_eu-gb_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_eu-gb_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_global_all-automation_admin | ROLE_ICCR_AUTOMATION-PRODUCTION |
|  | container-registry_in-che_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_in-che_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_in-che_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_in-che_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_in-che_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_jp-osa_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_jp-osa_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_jp-osa_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_jp-osa_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_jp-osa_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_jp-tok_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_jp-tok_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_jp-tok_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_jp-tok_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_jp-tok_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_kr-seo_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY |
|  | container-registry_kr-seo_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_kr-seo_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_kr-seo_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_kr-seo_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_us-east_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_us-east_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_us-east_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_us-east_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_us-east_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_us-south_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_us-south_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_us-south_all_viewer | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_us-south_catalog_admin | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_us-south_logs-metrics_editor | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
| Razee Dev | SQUAD | ROLE_RAZEE_DEVELOPER |
|  | SRE | ROLE_RAZEE_SRE-AU, ROLE_RAZEE_SRE-CN, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-US |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
| Razee Stage | Razee Developers | ROLE_RAZEE_DEVELOPER |
|  | SRE | ROLE_RAZEE_SRE-AU, ROLE_RAZEE_SRE-CN, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-US |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
| Satellite Production | containers-kubernetes_global_billing_viewer | ROLE_IKS_DEVELOPER-BILLING |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_certificate_automation | ROLE_IKS_AUTOMATION-SCORECARD |
|  | global_sre_automation | ROLE_IKS_AUTOMATION-PRODUCTION, ROLE_IKS_AUTOMATION-PRODUCTION-COMPLIANCE, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-SRE-BOT |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | global_tugboat_automation | ROLE_IKS_AUTOMATION-PRODUCTION-TUGBOAT, ROLE_SAT_AUTOMATION-PRODUCTION, ROLE_SAT_AUTOMATION-PRODUCTION, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-SRE-BOT |
|  | satellite-config_au-syd_all_viewer | ROLE_RAZEE_PRODUCTION |
|  | satellite-config_au-syd_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_br-sao_all_viewer | ROLE_RAZEE_PRODUCTION |
|  | satellite-config_br-sao_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_ca-tor_all_viewer | ROLE_RAZEE_PRODUCTION |
|  | satellite-config_ca-tor_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_eu-de_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_eu-gb_all_viewer | ROLE_RAZEE_PRODUCTION |
|  | satellite-config_eu-gb_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_in-che_all_viewer | ROLE_RAZEE_PRODUCTION |
|  | satellite-config_in-che_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_jp-osa_all_viewer | ROLE_RAZEE_PRODUCTION |
|  | satellite-config_jp-osa_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_jp-tok_all_viewer | ROLE_RAZEE_PRODUCTION |
|  | satellite-config_jp-tok_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_kr-seo_all_viewer | ROLE_RAZEE_PRODUCTION |
|  | satellite-config_kr-seo_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_us-east_all_viewer | ROLE_RAZEE_PRODUCTION |
|  | satellite-config_us-east_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-config_us-south_all_viewer | ROLE_RAZEE_PRODUCTION |
|  | satellite-config_us-south_metrics-logs_viewer | ROLE_RAZEE_DEVELOPER |
|  | satellite-link_au-syd_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_au-syd_all_viewer | ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_au-syd_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-link_br-sao_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_br-sao_all_viewer | ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_br-sao_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-link_ca-tor_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_ca-tor_all_viewer | ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_ca-tor_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-link_eu-de_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_PRODUCTION-LINK, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_eu-de_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-link_eu-gb_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_eu-gb_all_viewer | ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_eu-gb_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-link_in-che_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_in-che_all_viewer | ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_in-che_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-link_jp-osa_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_jp-osa_all_viewer | ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_jp-osa_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-link_jp-tok_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_jp-tok_all_viewer | ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_jp-tok_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-link_kr-seo_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_kr-seo_all_viewer | ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_kr-seo_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-link_us-east_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_us-east_all_viewer | ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_us-east_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-link_us-south_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_us-south_all_viewer | ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_us-south_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LINK |
|  | satellite-location_au-syd_all_viewer | ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_au-syd_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite-location_br-sao_all_viewer | ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_br-sao_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite-location_ca-tor_all_viewer | ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_ca-tor_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite-location_eu-de_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite-location_eu-gb_all_viewer | ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_eu-gb_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite-location_in-che_all_viewer | ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_in-che_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite-location_jp-osa_all_viewer | ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_jp-osa_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite-location_jp-tok_all_viewer | ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_jp-tok_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite-location_kr-seo_all_viewer | ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_kr-seo_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite-location_us-east_all_viewer | ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_us-east_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite-location_us-south_all_viewer | ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_us-south_metrics-logs_viewer | ROLE_SAT_DEVELOPER-LOCATION |
|  | satellite_au-syd_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_au-syd_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
|  | satellite_br-sao_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_br-sao_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
|  | satellite_ca-tor_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_ca-tor_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
|  | satellite_eu-de_all_admin | ROLE_IKS_SRE-DE, ROLE_IKS_SRE-IE, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-IE |
|  | satellite_eu-de_all_eu_emerg | ROLE_SAT_PRODUCTION-EU_EMERG |
|  | satellite_eu-de_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
|  | satellite_eu-gb_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_eu-gb_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
|  | satellite_in-che_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_in-che_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
|  | satellite_jp-osa_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_jp-osa_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
|  | satellite_jp-tok_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_jp-tok_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
|  | satellite_kr-seo_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_kr-seo_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
|  | satellite_us-east_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_us-east_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
|  | satellite_us-south_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_us-south_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID |
| Satellite Stage | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_certificate_automation | ROLE_IKS_AUTOMATION-SCORECARD |
|  | global_sre_automation | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-PRODUCTION, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-SRE-BOT |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | global_tugboat_automation | ROLE_IKS_AUTOMATION-NON-PRODUCTION-TUGBOAT, ROLE_SAT_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-SRE-BOT |
|  | satellite-config_us-south_all_viewer | ROLE_RAZEE_DEVELOPER, ROLE_RAZEE_PRODUCTION |
|  | satellite-config_us-south_kubernetes_admin | ROLE_RAZEE_DEVELOPER, ROLE_RAZEE_PRODUCTION |
|  | satellite-config_us-south_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID, ROLE_RAZEE_DEVELOPER, ROLE_RAZEE_PRODUCTION |
|  | satellite-link_global_registry_viewer | ROLE_SAT_DEVELOPER-LINK, ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_us-south_all_admin | ROLE_SAT_LINK-SRE-CA, ROLE_SAT_LINK-SRE-DE, ROLE_SAT_LINK-SRE-IT, ROLE_SAT_LINK-SRE-GB, ROLE_SAT_LINK-SRE-US |
|  | satellite-link_us-south_all_viewer | ROLE_SAT_DEVELOPER-LINK, ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_us-south_kubernetes_admin | ROLE_SAT_DEVELOPER-LINK, ROLE_SAT_PRODUCTION-LINK |
|  | satellite-link_us-south_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID, ROLE_SAT_DEVELOPER-LINK, ROLE_SAT_PRODUCTION-LINK |
|  | satellite-location_us-south_all_viewer | ROLE_SAT_DEVELOPER-LOCATION, ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_us-south_kubernetes_admin | ROLE_SAT_DEVELOPER-LOCATION, ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite-location_us-south_metrics-logs_viewer | ROLE_IKS_DEVELOPER-HYBRID, ROLE_SAT_DEVELOPER-LOCATION, ROLE_SAT_PRODUCTION-LOCATION |
|  | satellite_us-east_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-CN, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
|  | satellite_us-south_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-CN, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US, ROLE_IKS_SRE-NETINT |
| Satellite Stage TEST | containers-kubernetes_global_billing_viewer | ROLE_IKS_DEVELOPER-BILLING |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_certificate_automation | ROLE_IKS_AUTOMATION-SCORECARD |
|  | global_sre_automation | ROLE_IKS_AUTOMATION-PRODUCTION, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | global_tugboat_automation | ROLE_IKS_AUTOMATION-NON-PRODUCTION-TUGBOAT, ROLE_SAT_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | satellite-location_us-south_all_viewer | ROLE_IKS_DEVELOPER-BOOTSTRAP, ROLE_RAZEE_DEVELOPER, ROLE_SAT_DEVELOPER-LINK, ROLE_SAT_DEVELOPER-LOCATION, ROLE_RAZEE_PRODUCTION, ROLE_SAT_PRODUCTION-LOCATION, ROLE_SAT_PRODUCTION-LINK |
|  | satellite-location_us-south_kubernetes_admin | ROLE_IKS_DEVELOPER-BOOTSTRAP, ROLE_RAZEE_DEVELOPER, ROLE_SAT_DEVELOPER-LINK, ROLE_SAT_DEVELOPER-LOCATION, ROLE_RAZEE_PRODUCTION, ROLE_SAT_PRODUCTION-LOCATION, ROLE_SAT_PRODUCTION-LINK |
|  | satellite_us-south_all_admin | ROLE_IKS_SRE-AU, ROLE_IKS_SRE-CN, ROLE_IKS_SRE-IN, ROLE_IKS_SRE-DE, ROLE_IKS_SRE-GB, ROLE_IKS_SRE-IE, ROLE_IKS_SRE-US, ROLE_RAZEE_SRE-CN, ROLE_RAZEE_SRE-IN, ROLE_RAZEE_SRE-DE, ROLE_RAZEE_SRE-GB, ROLE_RAZEE_SRE-IE, ROLE_RAZEE_SRE-US |
| registry-dev | Add cases and view orders | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | Edit cases | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | Get compliance report | ROLE_IKS_SRE-SUPERADMIN |
|  | Limit EU case restriction | ROLE_IKS_SRE-SUPERADMIN |
|  | One-time payments | ROLE_IKS_SRE-SUPERADMIN |
|  | Retrieve users | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | SQUAD | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_IKS_AUTOMATION-PERFORMANCE, ROLE_ICCR_DEVELOPER-VA |
|  | SQUAD_FCTID | ROLE_ICCR_AUTOMATION-NON-PRODUCTION |
|  | SRE | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-CN, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | SRE_Automation | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-PRODUCTION |
|  | SRE_EU | ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE |
|  | Sysdig writers | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_IKS_DEVELOPER-PERFORMANCE, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-CN, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT |
|  | Update payment details | ROLE_IKS_SRE-SUPERADMIN |
|  | View account summary | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT |
|  | View cases | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
|  | performance_global_kubernetes_admin | ROLE_IKS_DEVELOPER-PERFORMANCE |
| registry-prod | Add cases and view orders | ROLE_ICCR_AUTOMATION-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Edit cases | ROLE_ICCR_AUTOMATION-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Edit company profile | ROLE_ICCR_AUTOMATION-PRODUCTION, ROLE_IKS_SRE-SUPERADMIN |
|  | Get compliance report | ROLE_ICCR_AUTOMATION-PRODUCTION, ROLE_IKS_SRE-SUPERADMIN |
|  | One-time payments | ROLE_ICCR_AUTOMATION-PRODUCTION, ROLE_IKS_SRE-SUPERADMIN |
|  | Retrieve users | ROLE_ICCR_AUTOMATION-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Update payment details | ROLE_ICCR_AUTOMATION-PRODUCTION, ROLE_IKS_SRE-SUPERADMIN |
|  | View account summary | ROLE_ICCR_AUTOMATION-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | View cases | ROLE_ICCR_AUTOMATION-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | container-registry_au-syd_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_au-syd_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_au-syd_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_au-syd_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_au-syd_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_br-sao_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_br-sao_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_br-sao_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_br-sao_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_br-sao_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_ca-tor_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_ca-tor_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_ca-tor_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_ca-tor_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_ca-tor_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_eu-de_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_eu-de_all-sre_admin | ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_eu-de_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_eu-de_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_eu-de_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_eu-fr2_all-sre_admin | ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_eu-fr2_all_auditor | ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_eu-fr2_logs-metrics_viewer | ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_eu-gb_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_eu-gb_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_eu-gb_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_eu-gb_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_eu-gb_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_global_all-automation_admin | ROLE_ICCR_AUTOMATION-PRODUCTION |
|  | container-registry_in-che_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_in-che_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_in-che_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_in-che_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_in-che_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_jp-osa_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_jp-osa_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_jp-osa_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_jp-osa_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_jp-osa_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_jp-tok_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_jp-tok_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_jp-tok_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_jp-tok_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_jp-tok_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_kr-seo_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_kr-seo_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_kr-seo_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_kr-seo_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_kr-seo_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_us-east_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_us-east_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_us-east_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_us-east_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_us-east_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | container-registry_us-south_all-squad_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | container-registry_us-south_all-sre_admin | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_AUTOMATION-COMPLIANCE |
|  | container-registry_us-south_all_auditor | ROLE_ICCR_DEVELOPER-LEAD, ROLE_IKS_AUTOMATION-COMPLIANCE, ROLE_IKS_AUTOMATION-SCORECARD |
|  | container-registry_us-south_globalcatalog_viewer | ROLE_ICCR_DEVELOPER-LEAD |
|  | container-registry_us-south_logs-metrics_viewer | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |
| registry-stage | AUDITOR | ROLE_ICCR_DEVELOPER-LEAD |
|  | Add cases and view orders | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Edit cases | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Edit company profile | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-SUPERADMIN |
|  | Get compliance report | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-SUPERADMIN |
|  | Limit EU case restriction | ROLE_IKS_SRE-SUPERADMIN |
|  | LogDNA Readers | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-CN, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | One-time payments | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-SUPERADMIN |
|  | Retrieve users | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | SQUAD | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | SQUAD_EU | ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA |
|  | SQUAD_FCTID | ROLE_ICCR_AUTOMATION-NON-PRODUCTION |
|  | SQUAD_LEADS | ROLE_ICCR_DEVELOPER-LEAD, ROLE_ICCR_DEVELOPER-LEAD |
|  | SRE | ROLE_ICCR_SRE-AU, ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-CN, ROLE_ICCR_SRE-IE, ROLE_ICCR_SRE-GB, ROLE_ICCR_SRE-IN, ROLE_ICCR_SRE-US, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | SRE_EU | ROLE_ICCR_SRE-DE, ROLE_ICCR_SRE-IE, ROLE_IKS_SRE-NETINT-AUTOMATION |
|  | Search cases | ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | Update payment details | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_IKS_SRE-SUPERADMIN |
|  | View account summary | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | View cases | ROLE_ICCR_AUTOMATION-NON-PRODUCTION, ROLE_ICCR_DEVELOPER-REGISTRY, ROLE_ICCR_DEVELOPER-VA, ROLE_IKS_SRE-NETINT, ROLE_IKS_SRE-NETINT-AUTOMATION, ROLE_IKS_SRE-SUPERADMIN |
|  | global_accesshub_automation | ROLE_IKS_AUTOMATION-ACCESSHUB |
|  | global_superadmin | ROLE_IKS_SRE-SUPERADMIN |