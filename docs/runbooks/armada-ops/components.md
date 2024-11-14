---
layout: default
description: This runbook includes the information on new armada-ops components
service: armada-ops
runbook-name: "armada-ops-compents"
title: "Deploy and Configuration for armada-ops Components"
link: /armada-ops/components.html
type: Informational
parent: Armada Ops
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

Previous [armada-ops project](https://github.ibm.com/alchemy-containers/armada-ops/)
 includes all the components for monitoring infrastructure in armada carriers.

- [Prometheus](https://github.ibm.com/alchemy-containers/prometheus)
- [Alertmanager](https://github.ibm.com/alchemy-containers/alertmanager)
- [Grafana](https://github.ibm.com/alchemy-containers/grafana/)
- [NodeExporter](https://github.ibm.com/alchemy-containers/node_exporter/)
- [BlackboxExporter](https://github.ibm.com/alchemy-containers/blackbox-exporter/)
- [KubeStateMetrics](https://github.ibm.com/alchemy-containers/kube-state-metrics/)
- [Pushgateway](https://github.ibm.com/alchemy-containers/pushgateway/)

We used the single one project to build and package them, which made all the 7
 components bound together. Single updates required all the components to be
 updated together. And it is also very difficult to integration with razee
 pipeline. Therefore, following guideline needs to be followed when building up
 new repositories for armada-ops:

- De-couple with each other to integrate with razee pipeline
- Separate microservices and their configurations, especially for those
   frequently updated configurations (e.g. alert rules)

We split the previous armada-ops project into 9 repositories:

- [armada-ops-prometheus](https://github.ibm.com/alchemy-containers/armada-ops-prometheus)
- [armada-ops-alertmanager](https://github.ibm.com/alchemy-containers/armada-ops-alertmanager)
- [armada-ops-grafana](https://github.ibm.com/alchemy-containers/armada-ops-grafana)
- [armada-ops-node-exporter](https://github.ibm.com/alchemy-containers/armada-ops-node-exporter)
- [armada-ops-blackbox-exporter](https://github.ibm.com/alchemy-containers/armada-ops-blackbox-exporter)
- [armada-ops-kube-state-metrics](https://github.ibm.com/alchemy-containers/armada-ops-kube-state-metrics)
- [armada-ops-pushgateway](https://github.ibm.com/alchemy-containers/armada-ops-pushgateway)
- [armada-ops-alert-conf](https://github.ibm.com/alchemy-containers/armada-ops-alert-conf)

   This is for alert related configurations. It will be fed into both prometheus
    and alertmanager. All the future alert related updates (including rules,
    routes, Pagerduty services etc.) will happen here.

- [armada-ops-dashboard](https://github.ibm.com/alchemy-containers/armada-ops-dashboard)

   This is for all the internal grafana dashboards. Any update on dashboards
    will happen here.


## Detailed Information

### Changes

1. **Pod Name Change**

   All the running pods have been added prefix `armada-ops-`

1. **Service Name Change**

   All the services have been added prefix `armada-ops-`

1. **Service Port Kept**

   We will keep to use the existing ports (nodePort and ClusterIP)

### Build and PR Checks

All the above repositories have been setup followed by the [razee integration
 guideline](https://github.ibm.com/alchemy-containers/Razee/blob/master/README.md)

[build-tools](https://github.ibm.com/alchemy-containers/build-tools) has been
 incorporated into the whole build and deploy process defined in .travis.yml
 (see [example](https://github.ibm.com/alchemy-containers/armada-ops-prometheus/blob/master/.travis.yml))

As above indicated, PR check and deployment after merge will all be done within
 travis. There will be no dependency on Jenkins anymore.

### Components Update

All the components version bump will be handled separately in the above seven
 repositories. Basically it will be update the docker image version tag and
 then raise PR, merge, and then deploy through [razeeflags](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/)

For example, update version for Prometheus [here](https://github.ibm.com/alchemy-containers/armada-ops-prometheus/blob/master/.travis.yml#L25)

Deployment pipeline is through razee rules. Simply click the dropdown list,
 choose which version to promote and then click `Request Change` for raising
 approval request (trains, depends on which region it is). Once the request has
 been approved, the `Start Deploy` button will be enabled, click it to trigger
 promotion. Verify the deployment and then, choose `Complete Deployment`.

The backend supporting services are actually [LaunchDarkly](https://app.launchdarkly.com/default/production/features)
 & [cluster-updater](https://github.ibm.com/alchemy-containers/cluster-updater)

- [armada-ops-prometheus rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-ops-prometheus)
- [armada-ops-alertmanager rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-ops-alertmanager)
- [armada-ops-grafana rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-ops-grafana)
- [armada-ops-node-exporter rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-ops-node-exporter)
- [armada-ops-blackbox-exporter rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-ops-blackbox-exporter)
- [armada-ops-kube-state-metrics rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-ops-kube-state-metrics)
- [armada-ops-pushgateway rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-ops-pushgateway)

**NOTE:** dev-mex01-carrier5 will be automatically deployed with latest merge on
 the above 9 repositories.

### Alert Updates

[armada-ops-alert-conf](https://github.ibm.com/alchemy-containers/armada-ops-alert-conf/blob/master/README.md)
 has been designed to minimize the export to create and update alert rules.
 Other development teams can follow very similar steps they previously used to
 do the update.

1. **Alert Receivers Update**

   All the receivers are defined [here](https://github.ibm.com/alchemy-containers/armada-ops-alert-conf/blob/master/alerts/receivers/receivers.yml)
    Adding new receivers require first to create a new Pagerduty service and
    store the service integration key into [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure/tree/master/build-env-vars/pagerduty)
    by following the steps described [here](https://github.ibm.com/alchemy-containers/armada-secure#secure-build-environment-variables)
    Then add the key reference to corresponding configmap in armada-secure
    (see [example](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/ap-north/armada-ops-alert-conf.yaml))

   There is an [ansible script](https://github.ibm.com/alchemy-containers/armada-ops-alert-conf/blob/master/ansible/gen-pdkeys.yaml)
    for initial creation of these Pagerduty keys in batch.

   Following variables in receivers.yaml are actually from armada-info configmap
    deployed into each carrier namespaces.

   - CRN_CNAME
   - CRN_SERVICE
   - CARRIER_NAME
   - REGION_NAME

   **IMPORTANT:** To avoid blind update on receivers (implies adding new
    service), we've enabled a check during PR time. People will be required to
    update [test file](https://github.ibm.com/alchemy-containers/armada-ops-alert-conf/blob/master/test/alertmanager-config-gold.yml)
    accordingly. Or their PR check will fail, and armada-ops team will be asked
    and they can provided guidance on how to update them correctly.

1. **Alert Routes & Rules Update**

   Each service team can find their service specific alert definition [here](https://github.ibm.com/alchemy-containers/armada-ops-alert-conf/tree/master/alerts/services)
    Updates to these files should be as previously done in old armada-ops
    repository.

   **IMPORTANT:** As indicated above, routes files will be also monitored by
    PR check.

1. **Updates Rolling Out**

   Same as the components update, alert related updates will be rolled out by
    [razee rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-ops-alert-conf)
    as well. A kubernetes job will be promoted to the target carrier to update
    the configuration files and trigger reload against running prometheus and
    alertmanager instances.

### Dashboard Updates

New [dashboard repository](https://github.ibm.com/alchemy-containers/armada-ops-dashboard)
 was created to contain all the internal Grafana dashboard JSON files. A small
 web service was developed there to provide dashboard import support to running
 Grafana.

1. Raise PR against dashboard [folder](https://github.ibm.com/alchemy-containers/armada-ops-dashboard/tree/master/dashboards)
2. PR check will be performed to make sure updated dashboard(s) is valid
3. Merge will trigger build and packaging. And dev-mex01-carrier5 will be
   deployed with latest one automatically
4. Promotion can be done by following the razee dash [rules](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/armada-ops-dashboard).

### New Carrier Onboard

With razee integration, rolling out new carrier will require very small part of
 updates to [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure)

For new regions (suppose won't happen in near future), need to add a new
 configmap for armada-ops-alert-conf, similar to [this one](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/ap-north/armada-ops-alert-conf.yaml)

For new carriers:

   1. New master IP needs to be added into armada-info (see [example](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/ap-north/hubs/prod-hkg02-carrier2/armada-info.yaml#L38))
   1. A new performance NFS storage needs to be ordered, the specification should follow:
      - The data center hosts this NFS storage should be the same data center where tainted Prometheus nodes are in
      - For dev/prestage: 100GB 1000IOPS
      - For stage: 500GB 1000IOPS
      - For prod: 1000GB 1000IOPS
      - Add allowed subnets for all the carrier workers
   1. New armada-ops-config configmap needs to be created (see [example](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/ap-north/hubs/prod-hkg02-carrier2/armada-ops-config.yaml))
      - Fill in the `armada_ops_nfs_perf_server`, `armada_ops_nfs_perf_path` and `armada_ops_nfs_perf_capacity` gained from above step.
      - `armada_ops_nfs_zone` is the data center name of the NFS storage hosted
      - For dev: PROMETHEUS2_RETENTION_POLICY=48h
      - For prestage: PROMETHEUS2_RETENTION_POLICY=72h
      - For stage: PROMETHEUS2_RETENTION_POLICY=96h
      - For prod: PROMETHEUS2_RETENTION_POLICY=168h

      **NOTICE:** We don't need `CARRIER_NAME`, `CARRIER_ID` and `ENV` anymore.
       It should be fetched from armada-info configmap mentioned above.

## Further Information

### PVG Test

All the 9 components have been enabled old pvg test (see [example](https://github.ibm.com/alchemy-containers/armada-ops-alertmanager/blob/master/.pvg.yml)).
 You can run [pipeline-test](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/armada-ops/job/promotion-pipeline-test/)
 to get result and fill in the `Acceptance Test` field when promoting with razee flags.
