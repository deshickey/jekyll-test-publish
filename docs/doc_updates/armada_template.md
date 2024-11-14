---
layout: default
title: PD Incident Runbook Template
type: alert
runbook-name: "Info on Runbook template for Runbook of Type 'PagerDuty'"
description: "Info on Runbook template for Runbook of Type 'PagerDuty'"
service: Conductors
link: /doc_updates/pd_runbook_template.html
type: Informational
parent: Documentation Contribution
---

Informational
{: .label }

#### Required Metadata
```yaml
---
layout: default
title: <Replace with a title to be displayed on the runbook page e.g. PD Incident Runbook Template>
type: Informational
runbook-name: <Replace with runbook-name e.g. "Info on Runbook template for Runbook of Type 'PagerDuty'">
description: <Replace with description e.g. "Info on Runbook template for Runbook of Type 'PagerDuty'">
service: <Replace with service, e.g. Conductors>
link: <link to Runbook - replace .md with .html e.g. /doc_updates/pd_runbook_template.html>
---
```
_**Explanation Section:**  Completing the metadata section above will eliminate the need to update the
'runbook-list.json' file. Please complete this._

_Below is a suggested template for runbooks documenting actions for Conductors to take when responding to a PD incident. Such a runbook is required for PD incidents assigned to Conductors and should be written with a quick resolution (or escalation) and future automation in mind. During business hours (24X7) Conductors will attempt debugging steps outside the scope of PD incident runbooks._

## Title of Runbook (required)

**_Make sure the title is sensible, sharing the same keywords as the PagerDuty incident, making it easier to find from [here](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/)._**

Example:

```
How to handle a blackbox-exporter up check reporting down
```

### Overview (required)

**_No more than a couple of sentences on why the user has been directed to this runbook and what the issue is:_**

_Example:_

```
This runbook describes how to handle a blackbox-exporter up check reporting down.
The exporter runs as a process on armada worker hosts and it allows blackbox probing
of endpoints over HTTP, HTTPS, DNS, TCP and ICMP.

These alerts are triggered when blackbox-exporter runs into problems and is not
running and probing one or more services. The alerts does not mean the service itself
is troubled, but it will mean no uptime probing will be occurring for the affected services.
```

### Example Alerts (required)

**_Give an example of the PagerDuty alert which has brought the user here:_**

Example:

    - `bluemix.containers-kubernetes.node_status_ready_is_false.us-south`
    - `bluemix.containers-kubernetes.10.176.31.236_node_scrape_failure.us-south`


  * _(Provide a list of **all** possible alerts that could bring the user to this runbook in the list above)_ - this is important as certain alerts will send users to different sections of this runbook.

### Create a process flowchart

**_Follow this guide here to create a flowchart for the symptoms and solutions for the existing issue_**

Example: (currently using one drafted in draw.io for VA's Crawler services, will investigate markdown compatible flowcharts)

![Crawlers Flowchart](https://pages.github.ibm.com/alchemy-va/team/Crawlers%20Runbook.svg)

* _(Provide a list of **all** known steps that could bring the user to this runbook in the list above)_ - this way the SRE team can fix the issue quicker.

### Actions to take (required) - quick steps to bring back to process

**_Give clear, short steps for fixing the issue quickly, more information on the issue should be provided in `Components and Understanding` below._**

1) What steps should be taken to fix the problem?

Example:

```
For alert: `bluemix.containers-kubernetes.10.176.31.236_node_scrape_failure.us-south`, do the following:

1. Log onto the corresponding prometheus environment:
 - [carrier0 in stage-dal09](https://alchemy-dashboard.containers.cloud.ibm.com/stage-dal09/carrier0/prometheus/graph)
 - [carrier1 in prod-dal10](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier1/prometheus/graph)


2. Click on Status drop down menu and then select targets - this should present further detail in the section titled `kubernetes-services`


3. Logon to the carrier master for that environment.

4. Run `kubectl get pods -n monitoring` - this will list all the pods running on this environment, make a note of blackbox-exporter pod name


NAME                                  READY     STATUS    RESTARTS   AGE
blackbox-exporter-60644949-47vbl      1/1       Running   0          1h


5. If the blackbox-exporter is reporting `Not Ready`, or if READY column states `(0/1)` then follow these steps (otherwise escalate to the #armada-ops squad):

6. `kubectl describe pod <blackbox-exporter-pod-name> -n monitoring` - this will describe the health of the pod and the latest messages associated with it

7. `kubectl logs <blackbox-exporter-pod-name> -n monitoring > file.log 2>&1` - collect the logs for the pod, this may be needed later for further debug

8. `kubectl delete pod <blackbox-exporter-pod-name> -n monitoring` - this deletes the pod (which will be in not ready state) and the pod is recreated automatically.

9. Finish by running `kubectl get pods -n monitoring` to ensure the pod has recovered successfully. If problems persist, call out the #armada-ops squad.
```

2) What might go wrong in attempting the fix?

Example:

```
While running `kubectl get pods -n monitoring | grep blackbox` to find the pod name, you may get back multiple results, this is because the pod could be restarting, if the alert looks like this, the service will fix itself:


NAME                                  READY     STATUS    RESTARTS   AGE
blackbox-exporter-6jhksgfd-43jh3      1/2       NotReady  0          1m
blackbox-exporter-60644949-47vbl      1/0       NotReady  1          2h

The old process will be blown away while the new one will take it's place, effectively the process gets disconnected from the host, while the new service is spinning up.
```

### Further Debugging/Monitoring (required)

**_Provide links to the relevant locations for monitoring metrics/logs if a quick fix is not available or for checking the incident resolves correctly._**

Example: (taken from ingress alerts, as this section doesn't apply for blackbox-exporter)

```
### Grafana checks to determine the rate of 5xx errors

Use the [alchemy-prod dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and
navigate to `View` -> `Grafana` for the carrier the alert is triggering for,
and open the `Ingress Stats` grafana dashboard.

Here is an example link to [prod-dal10-carrier1](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal10/carrier1/grafana/dashboard/db/ingress-stats?refresh=30s&orgId=1)

The graph name `Armada API 500 Errors` shows the rate at which 5xx errors are
occurring over a 2min delta period for both UI and v1.

### Prometheus checks to determine the rate of 5xx errors

1) Begin by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier)
and selecting the `Prometheus` icon in the alerted environment.

2) Click on the `Alerts` tab in Prometheus, it should show an active alert
(indicated in red) for the corresponding failure and a value. This value
will show the number of occurrences in the past 30 minute window.

<a href="images/armada-ops/Prometheus_ui_alert.png">
<img src="images/armada-ops/Prometheus_ui_alert.png" alt="Prometheus_ui_alert" style="width: 640px;"/></a>

3) The `IF` condition is the is the Prometheus query triggering the alert - click
that to go to the graphical view.

From here you can view the query. The amount of `5xx` triggers will be used later
to determine the severity of this alert.

<a href="images/armada-ops/Prometheus_ui_graph.png">
<img src="images/armada-ops/Prometheus_ui_graph.png" alt="armada-Prometheus_graph_view" style="width: 640px;"/></a>

4.) To see the rate of errors over a much shorter delta period (2 minutes rather
than 30 minutes) then execute this query in Prometheus:

`sum(delta(ingress_endpoint_rtime_count{handler=~"_ui.*",status=~"5.."}[2m]))`

Querying over a shorter delta provides a much better picture of whether this was
a short lived issue, or whether a problem has occurred, and is still persisting.
```

### RCA and pCIEs

**_At what point does an issue need to be escalated? Does it affect customers directly?_**

Example:

```
The best way of determining if alerts should trigger a pCIE or CIE is to design
alerts specifically for this. The SRE team includes `CIE` or `potential CIE` in
the title of alerts.

Another suspect would be seeing multiple PagerDuty alerts for a single host/service.
If in doubt, ask in the #containers-cie channel in slack.

To create a pCIE/CIE use the following runbook:
https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/creating_incident_notification.html
```

### Components and Understanding

**_This is where you can speak about the ins and outs of the Components when a quick-fix is not the desired solution. Treat this as a knowledge base for how the component works._**

Example:

```
For more information on the blackbox-exporter component, see the following sources:
 - https://github.com/prometheus/blackbox_exporter
 - https://michael.stapelberg.de/Artikel/prometheus-blackbox-exporter
```

### Escalation Policy (required)

**_If an alert cannot be resolved, it gets escalated to the team owners, typically speaking, it is the squad who wrote the runbook_**

Example:

```
Escalate the issue to the armada-ops squad as per their [escalation policy](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada_pagerduty_escalation_policies.html)

Slack Channel: https://ibm-argonauts.slack.com/messages/C534XTE49 (#armada-ops)
GitHub Issues: https://github.ibm.com/alchemy-containers/armada-ops/issues
```
