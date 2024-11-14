---
layout: default
title: Troubleshooting armada-api 5xx errors requests
type: Troubleshooting
runbook-name: "Troubleshooting armada-api 5xx errors requests"
description: "Troubleshooting armada-api 5xx errors requests"
service: armada-api
link: /armada/armada-api-5xx-errors.html
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

### Overview

This runbook describes how to troubleshoot 5xx errors reported by armada-api.

If the alert is triggering, this means that an external user has attempted to create a new resource, modify an existing resource or get information about their resource(s) through an endpoint provided by armada-api, but the service failed with an internal server error.

The `short` version of the alert means the issue lived for a shorter time, while the `long` version means the issue persists and very likely needs high attention.

SRE needs to investigate if it is a one-off issue, or if operation is disrupted at a broader scale.

This is a generic alert encompassing every HTTP request sent to the service. The alert specifies the exact path that is experiencing issues in the description section as well as the HTTP method of the request.

---
### Example Alerts

- `bluemix.containers-kubernetes.prod-dal10-carrier1.5xx-errors-short.us-south`
- `bluemix.containers-kubernetes.prod-dal10-carrier1.5xx-errors-long.us-south`

---
### Determining the severity of the issue

We trigger a PD alert when too many 5xx errors are returned to users when creating, modifying or getting resources.
The failure rates described in the alert indicate the amount of requests failing on a given endpoint, on a 0-1 scale, where 1 means 100%.

To understand the context of the alert, run the following prometheus query:

```
sum by(path, rc)(increase(armada_api_response_codes[5m])) > 0
```

The query will list every path, along with their response codes from the last hour.

To determine severity and how customers are impacted, identify the following, for each unhealthy endpoint listed in the alert:
1. Is this a one-off burst of errors?
    * We need to determine if the 5xx responses were surrounded by successful calls or were contained within a short burst.
    * If 2xx responses have occurred, then the problem may have resolved already. The alert may still need investigating, so details should be passed to the `armada-ironsides` squad.
2. Are all calls to the endpoint failing?
    * If only 5xx errors are being reported and no 201, or 200 success return codes are observed, then interacting with resources on the unhealthy endpoint may be impacted.
    * **However**, the data is gathered from actual customer attempts so be aware that there may not be further attempts to call the endpoint.
3. Are both IKS and Satellite affected?
    * If you see 5xx response codes with `/satellite` in the paths, then Satellite is impacted.
    * If you see 5xx response codes without `/satellite` in the paths, then IKS is impacted.

---
### Investigation and Action
1) If this alert is seen in conjunction with the `response_time_increasing` alert, the 5XX errors may be due to timeout issues. Start by following the `response time increasing` [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-api-response_time_increasing.html). If not, continue with this runbook.

2) The alert contains a link to the Prometheus query triggering it. Click on the link to navigate to Prometheus.
   From here you can view the query. If a CIE is required, the number triggering will need to be communicated to the development team and ERMs as they will be looking to understand the impact of the problem and how many users have or could be affected.

3) To get a more detailed view of what endpoints are failing, run the following query in prometheus:
   - `sum by(path, rc)(increase(armada_api_response_codes[5m])) > 0`
   - If either one or multiple paths are failing at a high rate, please check the section titled [Is it a pCIE?](#is-it-a-pcie) and then continue to gather the information and [open a GHE issue](#raise-a-ghe).

4) Check armada-api's [Grafana dashboard](#grafana-dashboard) to see if a dependency is causing the errors. 

---
### Grafana dashboard

One of the reasons armada-api can return 5xx errors is due to a failing dependency. Visit armada-api's Grafana dashboard at `Dashboards > other > Armada API`. Here you'll find 2 helpful visualizations:

#### `API and Dependencies - Status Codes`
Shows the status codes returned by both armada-api and all of our dependencies, on top of each other. Correlating 5xx status codes may indicate that indeed a dependency's failure is the reason why API is returning 5xx codes.
Once such a correlation is suspected, you can fine tune the graphs by setting the following variables:
- Dependency: the name of the dependency as it is registered in the backing prometheus metrics. For example: `iam_pdp`
- Dependency method: specific service methods of dependencies. For example: `authz`
- HTTP method: pick the HTTP method of the armada-api requests that are failing. The alert contains this information.
- API path: pick the failing armada-api path. The alert contains this information.

With the help of logs (in case error logs can be traced back to specific dependencies and their methods), you can set the graph up to show how a suspicious dependency's responses correlate with armada-api's responses.

If the graph together with the logs confirm that a dependency has an outage, contact the dependency (for example IAM), and see if they have a CIE already. Inform them otherwise about the failing calls.

#### `API and Dependencies - Response Times`
Shows potential correlations between the response times of dependencies and armada-api. The graph works in a similar fashion as the `Status Codes` graph, except it cannot be filtered by HTTP methods.
If checking the `Status Codes` graph didn't result in a definitive answer, a dependency taking too long to respond can still cause armada-api to return 5xx errors. Using the dashboard variables, check if there's any dependency that seemingly affects
armada-api responses. If suspicion arises, contact the specific dependency's team and see if they are aware of any ongoing problem.

---
### Raise a GHE

1) Use `kubectl` commands on the master node to analyse the situation further. These steps will need running for both the `armada-api` and `armada-deploy` PODs:
   - Log onto the carrier master node for the environment the alerts are triggering, for example, `prod-dal10-carrier1-master-01`.
   - `kubectl get pods -n armada` - this will show all pods running in the armada namespace
   - `kubectl describe pod armada-api-4034288990-fthbq -n armada` - will give further info on the pod (where `4034288990-fthbq` is the instance/pod) within the armada namespace
   - `kubectl logs armada-api-4034288990-fthbq -n armada` - displays the logs for that pod - this will have to be repeated for all pods - re-direct this output to a log file on the server for further analysis - You can use [ scripts located here](https://github.ibm.com/alchemy-conductors/conductors-tools/tree/master/armada/kubectl_tools) to help with obtaining logs.

2) Add results from the Prometheus query, the logs gathered, reinforced with `kubectl` results to a [New Issue in GitHub](https://github.ibm.com/alchemy-containers/armada-ironsides/issues)

---
### LogDNA logs

For further investigation, you should be able to find the corresponding error in LogDNA as all logs are forwarded here.
Access LogDNA by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `LogDNA` icon in the alerted environment.

#### LogDNA single account check: Ensure a single account isn't generating many 5xx errors

Access LogDNA by going to the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/carrier) and selecting the `LogDNA` icon in the alerted environment.

1. In LogDNA run the following query `app:armada-api "statusCode":(>=500)`.
2. Expand a single log entry and select `Extract fields`.
3. In the menu, set the following:
   - Select `iamAccountID` under Include auto-parsed fields.
   - Set the Time Range according to when the errors triggered the alert.
   - Query should autopopulate as set in Step 1.
4. Click `Run`, an Aggregated fields menu will pop up. This will show how frequently particular accounts showed up in the current 5xx errors. This can be viewed as % instead of count. If the majority of errors are triggered from one account, this could indicate that it is not a true CIE situation.

---
### Escalation Policy

#### Is it a pCIE?
Any sustained stream of 5xx responses requires a pCIE!

To determine pCIE severity and its impact, see the [Determining severity](#determining-the-severity-of-the-issue) section above.

If a single customer is generating an error, it needs to be evaluated, why they are able to trigger a 500 RC with user input, or we need to check what the armada-api errors are in LogDNA.

Any `500` error for a failure to create/get a resource that has been exposed to a customer: if resource creates/gets have been successful following the error (eg: can see spikes of `201`s/`200`s on the graph after the `500` error that triggered this alert), and no errors occur for 30 minutes after the fact, then the pCIE can be closed.

If the alert is sustained, a pCIE is required as possibly a large number of users are affected. Follow the pCIE process as [documented here](../clm-incidents.html) Check the "Cruiser master health" dashboard in Grafana to find the total number of cruiser masters in that specific environment.

Monitor and contribute to the CIE in the #containers-cie channel

If the `500` errors are a large proportion (or all) of the traffic response codes, then something is seriously wrong, and the pCIE should probably become a full CIE.

Work with the development team and the ERMs to resolve the CIE as soon as possible.

#### For all issues

If the investigation above is not successful, and the issue requires the development team to be involved, escalate it to the armada-api squad as per their [escalation policy](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada_pagerduty_escalation_policies.html)

Slack Channel: https://ibm-argonauts.slack.com/archives/C53NQCME0 (#armada-ironsides)
GitHub Issues: https://github.ibm.com/alchemy-containers/armada-ironsides/issues
