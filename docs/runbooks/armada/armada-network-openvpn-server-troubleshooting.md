---
layout: default
title: armada-network - HA Master OpenVPN Server is down troubleshooting
type: Troubleshooting
runbook-name: "armada-network - HA Master OpenVPN Server is down troubleshooting"
description: "armada-network - HA Master OpenVPN Server is down troubleshooting"
service: armada
link: /armada/armada-network-openvpn-server-troubleshooting.html
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

# HA Master OpenVPN Server is down runbook

## Overview

This alert fires when the openvpn server deployment has no available replicas for an extended period of time. If the openvpn server pod is down, customers will not be able to do kubectl exec, logs, or proxy. Their actual workload will run no problem though it just causes the debugging tools of kubectl to not work properly.

| Alert_Situation | Info | Start |
|--
| `CustomerOpenVPNServerUnavailable`| deployment_xxxx  deployment has had no available replicas for 10 minutes | [actions-to-take](#investigation-and-action) |
{:.table .table-bordered .table-striped}

## Example Alert(s)

~~~
Labels:
 - alertname = CustomerOpenVPNServerUnavailable
 - alert_situation = openvpnserver-xxxx_down
 - service = armada-network
 - severity = critical
 - deployment_name = openvpnserver-xxxx
~~~

## Investigation and Action

Note the following values from the alert
1. `deployment_name`

### Delete the openvpnserver deployment if necessary
1. Investigate the cluster details using XO, note the `CLUSTER_ID`  
_`CLUSTER_ID` is the the portion of `deployment_name` following `openvpnserver-`_  
_e.g. `bl5715sf0q99ptcucftg` from `deployment_name = openvpnserver-bl5715sf0q99ptcucftg`_

1. Determine whether we need to delete the `openvpnserver deployment`  
In the Slack channel [`#armada-xo`](https://ibm-argonauts.slack.com/messages/G90E71LSV), enter:  
`@xo cluster CLUSTER_ID`

1. If the cluster's `DesiredState` is `deleted`
   * Delete the openvpnserver deployment by running the following command on the carrier master  
_NB. Info on how to get to a carrier master can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_  
`kubectl -n kubx-masters delete deploy <deployment_name>`  
_e.g. `kubectl -n kubx-masters delete deploy openvpnserver-bl5715sf0q99ptcucftg`_

   * The alert should resolve within a few minutes and you are done!

### Check to see if any of the OpenVPN Server pods are running
1. Find and login into the carrier master having issues, or if it is a tugboat (carrier100+) log onto the hub in the region.  
_More info on how to do this step can be found [here](./armada-general-debugging-info.html#finding-the-carrier-to-log-into-from-pagerduty-alert)_
1. check to see if any of the openvpnserver pods are in running state with the following command subbing the deployment label in for $DEPLOYMENT_NAME.
~~~ sh
export DEPLOYMENT_NAME=<deployment_name>
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME
~~~
* example
~~~ sh
kubectl get pods -n kubx-masters | grep openvpnserver-71833a9becda40e58765d85f716317b3
openvpnserver-71833a9becda40e58765d85f716317b3-85ff79955b-9qhqk   1/1       Running            0          3h
~~~
2. If there is a running pod that is in ready state, this alert will auto resolve and can be ignored.
* An example of a pod not in ready state is shown below
~~~ sh
kubectl get pods -n kubx-masters | grep openvpnserver-c93e9f84e38b4132b1cde67c522a1bac
openvpnserver-c93e9f84e38b4132b1cde67c522a1bac-944f68c9f-czmf9    0/1       CrashLoopBackOff    413        5d
~~~ 
2. Before moving onto the next section please gather logs using the following commands first and add them to a new issue in [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues) titled "OpenVPN Server failure: $DEPLOYMENT_NAME".
~~~ sh
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME |  awk '{print $1}' > podforlogs && kubectl -n kubx-masters logs $(cat podforlogs) -p > previouslogs.txt
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME |  awk '{print $1}' > podforlogs && kubectl -n kubx-masters logs $(cat podforlogs)  > currentlogs.txt
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME | awk '{print $1}' > podforlogs && kubectl -n kubx-masters exec  $(cat podforlogs) cat /etc/openvpn/apiserver.ovpn | grep remote > apiserver_remotes
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME | awk '{print $1}' > podforlogs && kubectl -n kubx-masters exec  $(cat podforlogs) cat /etc/openvpn/ccd/worker > worker_ccd
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME | awk '{print $1}' > podforlogs && kubectl -n kubx-masters exec  $(cat podforlogs) cat /etc/openvpn/openvpn.conf > openvpn.conf
~~~
* example. Title: "OpenVPN Server failure: openvpnserver-c93e9f84e38b4132b1cde67c522a1bac"
~~~ sh
kubectl get pods -n kubx-masters | grep openvpnserver-c93e9f84e38b4132b1cde67c522a1bac |  awk '{print $1}' > podforlogs && kubectl -n kubx-masters logs $(cat podforlogs) -p > previouslogs.txt
cat previouslogs.txt
  openvpn/
  openvpn/ovpn_initpki
  openvpn/openvpn.conf
  openvpn/worker.ovpn
  openvpn/dh.pem
  ...
kubectl get pods -n kubx-masters | grep openvpnserver-c93e9f84e38b4132b1cde67c522a1bac |  awk '{print $1}' > podforlogs && kubectl -n kubx-masters logs $(cat podforlogs)  > currentlogs.txt
cat currentlogs.txt
  openvpn/
  openvpn/ovpn_initpki
  openvpn/openvpn.conf
  openvpn/worker.ovpn
  openvpn/dh.pem
  ...
~~~

### OpenVPN Server Pod is not in running state
1. If the pod is not in ready state, try to delete the pod and let it re-spin up to see if that will resolve the problem. That will be done by deleting the pod and waiting for a new one to spin up (commands below)  
`kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME | awk '{print $1}' > podtodelete && cat podtodelete`
* example
~~~ sh
kubectl get pods -n kubx-masters | grep openvpnserver-c93e9f84e38b4132b1cde67c522a1bac |  awk '{print $1}' > podtodelete && cat podtodelete
openvpnserver-c93e9f84e38b4132b1cde67c522a1bac-944f68c9f-lwsww
~~~
2. ASSERT That the above command only has pods associated with this deployment (should all have the the deployment label as the start of the pod name. Using the example, notice how the pod starts with `openvpnserver-c93e9f84e38b4132b1cde67c522a1bac`. If it does not, the deployment label was not substituted in properly.
3. If the output looks right, proceed to delete the pod with the following command  
`kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME | awk '{print $1}' > podtodelete && kubectl -n kubx-masters delete pod --grace-period=1 $(cat podtodelete) && rm podtodelete`
* example  
~~~ sh
kubectl get pods -n kubx-masters | grep openvpnserver-c93e9f84e38b4132b1cde67c522a1bac | awk '{print $1}' > podtodelete && kubectl -n kubx-masters delete pod --grace-period=1 $(cat podtodelete) && rm podtodelete
pod "openvpnserver-c93e9f84e38b4132b1cde67c522a1bac-944f68c9f-czmf9" deleted
~~~
4. Now that the pod is deleted  wait for the pod to come back up by running the following command every 10 seconds for 4 minutes.  
`kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME`
* example
~~~ sh
kubectl get pods -n kubx-masters | grep openvpnserver-c93e9f84e38b4132b1cde67c522a1bac
openvpnserver-c93e9f84e38b4132b1cde67c522a1bac-944f68c9f-nxs7g    1/1       Running             0          2m
~~~
5. In the example above, the pod went back to `Running` state and is `1/1 Ready`. That means that the pod is Running and the alert should resolve itself the next time prometheus scrapes for available replicas (happens about every 5 minutes). Continue to monitor periodically to ensure it stays in `Running` state till the alert resolves.
6. If deleting the pod does not resolve the situation, gather logs on the new pod. Also gather the openvpn confs for the worker, apiserver, and openvpn server deployment. Add them to the same issue you opened up previously and state that these logs are from after you deleted the initial pod.
~~~ sh
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME |  awk '{print $1}' > podforlogs && kubectl -n kubx-masters logs $(cat podforlogs) -p > previouslogs.txt
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME |  awk '{print $1}' > podforlogs && kubectl -n kubx-masters logs $(cat podforlogs)  > currentlogs.txt
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME | awk '{print $1}' > podforlogs && kubectl -n kubx-masters exec  $(cat podforlogs) cat /etc/openvpn/apiserver.ovpn | grep remote > apiserver_remotes
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME | awk '{print $1}' > podforlogs && kubectl -n kubx-masters exec  $(cat podforlogs) cat /etc/openvpn/ccd/worker > worker_ccd
kubectl get pods -n kubx-masters | grep $DEPLOYMENT_NAME | awk '{print $1}' > podforlogs && kubectl -n kubx-masters exec  $(cat podforlogs) cat /etc/openvpn/openvpn.conf > openvpn.conf
~~~
* example
~~~ sh
kubectl get pods -n kubx-masters | grep openvpnserver-c93e9f84e38b4132b1cde67c522a1bac |  awk '{print $1}' > podforlogs && kubectl -n kubx-masters logs $(cat podforlogs) -p > previouslogs.txt
cat previouslogs.txt
  openvpn/
  openvpn/ovpn_initpki
  openvpn/openvpn.conf
  openvpn/worker.ovpn
  openvpn/dh.pem
  ...
kubectl get pods -n kubx-masters | grep openvpnserver-c93e9f84e38b4132b1cde67c522a1bac |  awk '{print $1}' > podforlogs && kubectl -n kubx-masters logs $(cat podforlogs)  > currentlogs.txt
cat currentlogs.txt
  openvpn/
  openvpn/ovpn_initpki
  openvpn/openvpn.conf
  openvpn/worker.ovpn
  openvpn/dh.pem
  ...
~~~

Link the issue in the [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network) Slack channel when escalating.

## Escalation Policy
Use the escalation steps below to involve the `armada-network` squad:

  * Escalation policy: [Alchemy - Containers Tribe - armada-network](https://ibm.pagerduty.com/escalation_policies#P2MK3WQ)
  * Slack channels: [#armada-dev](https://ibm-argonauts.slack.com/messages/armada-dev), [#armada-network](https://ibm-argonauts.slack.com/messages/armada-network)
  * GHE issues: [armada-network](https://github.ibm.com/alchemy-containers/armada-network/issues/)
