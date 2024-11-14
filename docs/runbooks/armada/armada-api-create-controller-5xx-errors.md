---
layout: default
title: Troubleshooting armada-api 5xx errors for the controller create path
type: Troubleshooting
runbook-name: "Troubleshooting armada-api 5xx errors for the controller create path"
description: "Troubleshooting armada-api 5xx errors for the controller create path"
service: armada-api
link: /armada/armada-api-create-controller-5xx-errors.html
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

### Overview

This runbook describes how to troubleshoot 5xx errors reported by armada-api on the satellite controller create path.

The alert triggering means that external users have attempted to create new satellite controllers through armada-api, but the service failed with an internal server error at a high rate over an hour long period.
SRE needs to investigate if it is a one-off issue, or if operation is disrupted at a broader scale.

---
### Example Alerts

- `bluemix.containers-kubernetes.prod-dal10-carrier1.create-controller-5xx-errors.us-south`

---
### Determining the severity of the issue

We trigger a PD alert when too many 5xx errors are returned to users while trying to create satellite controllers.
The failure rate described in the alert indicate the amount of requests failing on the satellite controller create endpoint only, on a 0-1 scale, where 1 means 100%.

To understand the context of the alert, run the following prometheus queries:
- `sum by(path, rc)(increase(armada_api_response_codes{rc=~"5.."}[5m])) > 0`: the query will list every path of armada-api, along with their response codes from the last hour, in case of 5xx codes.
- `sum by(path, rc)(increase(armada_api_response_codes{rc!~"5.."}[5m])) > 0`: the query will list every path of armada-api, along with their response codes from the last hour, in case it was NOT an 5xx code.

To determine severity and how customers are impacted, identify the following, based on the alert:
1. Is `/v2/satellite/createController` the only path affected?
    * If other paths are also reporting an increase in 5xx response code and decrease in 2xx codes, then the issue is more widespread, and not contained within this alert.
2. Is this a one-off burst of errors?
    * We need to determine if the 5xx responses were surrounded by successful calls or were contained within a short burst.
    * If 2xx responses have occurred, then the problem may have resolved already. The alert may still need investigating, so details should be passed to the `armada-ironsides` squad.
3. Are all calls to the endpoint failing?
    * If only 5xx errors are being reported and no 2xx success return codes are observed, then creating satellite controllers is not possible.
    * **However**, the data is gathered from actual customer attempts so be aware that there may not be further attempts to call the endpoint.

---
### Investigation and Action
1) If this alert is seen in conjunction with the `response_time_increasing` alert, the 5XX errors may be due to timeout issues. Start by following the `response time increasing` [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-api-response_time_increasing.html). If not, continue with this runbook.

2) If this alert is seen in conjunction with the `dependency_5xx_errors` alert (warning severity, won't cause an incident), the errors might be caused by issues with our dependencies. Start by following the `dependency_5xx_errors` [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/service-engine-5xx-errors.html). If not, continue with this runbook.

3) If this alert is seen in conjunction with the `critical_number_of_5xx_response_received_for_handler` alert, the errors are not unique to the satellite controller create path. Start by following the `critical_number_of_5xx_response_received_for_handler`  [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-ingress-v1-handler-5xx-errors). If not, continue with this runbook.

4) The alert contains a link to the Prometheus query triggering it. Click on the link to navigate to Prometheus.
   From here you can view the query. If a CIE is required, the number triggering will need to be communicated to the development team and ERMs as they will be looking to understand the impact of the problem and how many users have or could be affected.

---
### Raise a GHE

1) Use `kubectl` commands on the master node to analyse the situation further. These steps will need running for the `armada-api` PODs:
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

1. In LogDNA run the following query `app:armada-api status_code:(>=500) request_path:"/v2/satellite/createController"`.
2. Expand a single log entry and select `View in context`.
3. In the popup, search for the nearest error lines above the message. Some of these error lines will indicate what the underlying issue is.

---
### Escalation Policy

#### Is it a pCIE?
Any sustained stream of 5xx responses requires a pCIE!

To determine pCIE severity and its impact, see the [Determining severity](#determining-the-severity-of-the-issue) section above.

If a single customer is generating an error, it needs to be evaluated, why they are able to trigger a 500 RC with user input, or we need to check what the armada-api errors are in LogDNA.

Any `500` error for a failure to create a controller that has been exposed to a customer: if controller creates have been successful following the error (eg: can see spikes of `200`s on the graph after the `500` error that triggered this alert), and no errors occur for 30 minutes after the fact, then the pCIE can be closed.

If the alert is sustained, then the endpoint has less than 85% success rate. In this case, a pCIE is required as possibly a large number of users are affected. Follow the pCIE process as [documented here](../clm-incidents.html) Check the "Cruiser master health" dashboard in Grafana to find the total number of cruiser masters in that specific environment.

Monitor and contribute to the CIE in the #containers-cie channel

If the `500` errors are a large proportion (or all) of the traffic response codes, then something is seriously wrong, and th pCIE should probably become a full CIE.

Work with the development team and the ERMs to resolve the CIE as soon as possible.

#### For all issues

If the investigation above is not successful, and the issue requires the development team to be involved, escalate it to the armada-api squad as per their [escalation policy](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada_pagerduty_escalation_policies.html)

Slack Channel: https://ibm-argonauts.slack.com/archives/C53NQCME0 (#armada-ironsides)
GitHub Issues: https://github.ibm.com/alchemy-containers/armada-ironsides/issues
