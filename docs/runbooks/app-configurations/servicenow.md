---
layout: default
title: IBM Cloud App Configuration Service Now
type: Informational
runbook-name: "IBM Cloud App Configuration Service Now"
description: "IBM Cloud App Configuration Service Now"
service: App Configuration
tags: app-configurations
link: /app-configurations/servicenow.html
parent: App Configs
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
# Service Now Integration

Service's service now onboarding details are available [here](https://watson.service-now.com/x_ibmwc_ssef_app.do#!/edit/52df23ce1b2a54d4a2b499ffbd4bcb62?class=u_ibm_service_cloud#serviceProfileIsOpen)

## Detailed Information
Service Now is integrated with the service for the following reasons - 

* Customer tickets - Service Now contains all the support tickets raised by the customer. This is a read-only view for the development team. Refer [here](https://watson.service-now.com/sn_customerservice_case_list.do?sysparm_query=cmdb_ci%3D52df23ce1b2a54d4a2b499ffbd4bcb62%5Estate!%3D3&sysparm_first_row=1&sysparm_view=case).  These would be send to a [service GIT repo](https://github.ibm.com/devx-app-services/support-issues/issues) which can be used by the development team to update the customers.  

* Change Requests - Service Now is used by the development team for raising Change requests. These change requests are a pre-requisite to any deployments or changes done to the infrastructure. To raise a CR refer [here](https://watson.service-now.com/nav_to.do?uri=%2Fchange_request_list.do%3Fsysparm_query%3Dcmdb_ci%3D52df23ce1b2a54d4a2b499ffbd4bcb62%5Estate!%3D3%26sysparm_first_row%3D1%26sysparm_view%3D)

* PSIRTs - PSIRT vulnerabilities are raised against the development team using Service Now. The development team can analyze these vulnerabilities and update them using the Service Now. Refer [here](https://ibm.service-now.com/nav_to.do?uri=%2Fu_cmdb_ci_spkg_ibmciso_vm_product_family.do%3Fsys_id%3D94b120191b11d4909c8642a6bc4bcbac%26sysparm_record_list%3Du_pillar.u_related_users_refDYNAMICjavascript:gs.getUserID())
  * [ITSS Guidelines](https://pages.github.ibm.com/ibmcloud/Security/policy/IR-PSIRT.html#security-vulnerability-mitigation--remediation-timelines) for PSIRT remediation
  * [CISO remediation](https://pages.github.ibm.com/ciso-psg/main/standards/itss.html#table-3-security-vulnerability-mitigationremediation-timelines-calendar-days) is in line with the ITSS guidelines

