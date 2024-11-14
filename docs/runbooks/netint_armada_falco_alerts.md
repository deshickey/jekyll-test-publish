---
layout: default
description: Details of Netint Aramda Falco Alerts and Resolution
service: Network Intelligence
title: Network Intelligence AlertManger for Armada Falco
runbook-name: Network Intelligence AlertManger for Armada Falco
playbooks: ["NoPlaybooksSpecified"]
failure: ["NoFailuresSpecified"]
ownership-details:
  escalation: "Alchemy - Network Intel 24x7"
  owner-link: "https://ibm-cloudplatform.slack.com/messages/netint"
  corehours: "UK"
  owner-notification: False
  group-for-rtc-ticket: Runbook needs to be Updated with group-for-rtc-ticket
  owner: "Network Intelligence [#netint]"
  owner-approval: False
link: /netint_armada_falco_alerts.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

Falco provides alerting for unexpected network traffic which could identify an intrusion. A liveness check is done with the help of the falco-exporter module and a rule is set to make sure all pods that exist are up. If not, an alert is triggered with Alertmanager which will notify in different places depending on the alert rules.

## Example Alert(s)

### Netint Armada-Falco Pods for <env> have been down for longer than 30 mins.

This means that the falco pods have been restarted and have crashed or could not get to ready state for 30 mins.

## Investigation and Action

### Issue "FalcoPodsDown"

This means one or more of the armada falco pods has gone down. This could be due to an invalid config or failed rules validation.

### Solution:

1. Log on the the machine as specified in the alert

2. List the pods in the armada namespace and grep for falco:

   ```
   mnayer@dev-mex01-carrier5-master-01:~$ kubectl get po -n armada -o wide | grep falco
   armada-falco-2jsnz                                    1/1     Running                      0          41d     10.130.231.139   10.130.231.139   <none>           <none>
   armada-falco-48x2s                                    1/1     Running                      0          41d     10.130.231.149   10.130.231.149   <none>           <none>
   armada-falco-4djvv                                    1/1     Running                      0          41d     10.131.16.15     10.131.16.15     <none>           <none>
   armada-falco-4lhw5                                    1/1     Running                      2          41d     10.131.16.127    10.131.16.127    <none>           <none>
   armada-falco-4nc9z                                    1/1     Running                      0          6d2h    10.131.16.80     10.131.16.80     <none>           <none>
   armada-falco-4phjg                                    1/1     Running                      6          41d     10.131.16.67     10.131.16.67     <none>           <none>
   armada-falco-4vvbf                                    1/1     Running                      0          39d     10.130.231.140   10.130.231.140   <none>           <none>
   armada-falco-56cq9                                    1/1     Running                      2          41d     10.130.231.232   10.130.231.232   <none>           <none>
   armada-falco-57v82                                    1/1     Running                      0          41d     10.131.16.25     10.131.16.25     <none>           <none>
   armada-falco-58fjp                                    1/1     Running                      1          41d     10.130.231.197   10.130.231.197   <none>           <none>
   ...
   ```


3. Check if there are any pods that in crashed, errored state or not ready.

4. If any pod matching the description in 3. exists, check the armada falco logs for that pod:

```
mnayer@dev-mex01-carrier5-master-01:~$ kubectl logs armada-falco-9wvkg -n armada
Cannot read config file (/etc/falco/falco.yaml): yaml-cpp: error at line 128, column 2: end of map not found
Thu Aug 12 06:29:55 2021: Runtime error: yaml-cpp: error at line 128, column 2: end of map not found. Exiting.
2021/08/12 06:29:56 [INFO]  : Enabled Outputs : [AlertManager]
2021/08/12 06:29:56 [INFO]  : Falco Sidekick is up and listening on 127.0.0.1:2801
2021/08/12 06:29:56 [ERROR] : listen tcp 127.0.0.1:2801: bind: address already in use
Cannot read config file (/etc/falco/falco.yaml): yaml-cpp: error at line 128, column 2: end of map not found
Thu Aug 12 06:30:05 2021: Runtime error: yaml-cpp: error at line 128, column 2: end of map not found. Exiting.
2021/08/12 06:30:06 [INFO]  : Enabled Outputs : [AlertManager]
2021/08/12 06:30:06 [INFO]  : Falco Sidekick is up and listening on 127.0.0.1:2801
2021/08/12 06:30:06 [ERROR] : listen tcp 127.0.0.1:2801: bind: address already in use
```

If there is a problem, you will usually easily find out in here what it might be. For example in the case above, there was a syntax error in the config causing the problem. 

[WIP - MORE STEPS AND DETAILS TO BE ADDED SOON, JUST NEED A LINK TO THE RUNBOOK FOR NOW FOR THE ALERT]


## Escalation Policy

If after completing the checks mentioned above, the problem could not be resolved, please reach out on the #netint channel on slack, or page out netint for prod.

---

## Detailed Information

---

