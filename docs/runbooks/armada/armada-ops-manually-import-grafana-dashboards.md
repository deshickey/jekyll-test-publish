---
layout: default
description: Use this when grafana-import-dashboard fails to deploy or when it's separated from grafana
title: armada-ops - How to manually add grafana dashboards to an environment
service: armada
runbook-name: "armada-ops - how to manually add grafana dashboards to an environment"
tags: alchemy, armada, grafana, dashboards
link: /armada/armada-ops-manually-import-grafana-dashboards.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to import all the dashboards on a running grafana instance when no dashboards exist.

## Example Alerts

There are no alerts raised for this situation. 
Use this runbook if there is a report that the dashboards in one environment do not match the other regions. 

## Investigation and Action

In instances where grafana dashboards have been modified on a single environment or the dashboards are detached from the main grafana instance, the imported dashboards will need to be fixed.

This can be fixed by doing the following:


  1) First thing to do in this scenario is to find the right node to log on. All the following operations has to be ran on the *carrier-master* node of the environment reporting the problem. If your `/etc/hosts` file cannot resolve the name of the node, you can use the slackbot netmax to find the IP. The command to log on the node will be:

  ```
  ssh <your-ssh-username>@<hostname>
  ```

  or

  ```
  ssh <your-ssh-username>@<host-IP>
  ```

  for example:

  ```
  ssh valerioponza@prod-dal10-carrier5-master-01
  ```

  If you have done everything right, you should be able to run

  ```
  kubectl cluster-info
  ```

  to get the information about the kubernetes cluster in the selected environment.


  2)  The next command to run is

  ```
  kubectl get jobs -n monitoring
  ```

  The `-n monitoring` flag is used to specify the namespace we are interested (in this scenario, grafana is deployed under `monitoring`).

  The expected output of this is a list of the jobs in your cluster:

  ```
  NAME                        DESIRED   SUCCESSFUL   AGE
  grafana-import-dashboards   1         1            49m
  ```

  We are interested in the job `grafana-import-dashboards`, which is the job that imports all the dashboards into the grafana instance for the environment.
  If the job is there, continue following this runbook, otherwise you should page Conductors to investigate on the incident. You can do this posting in the Slack channel #conductors.

  3)  We now need to get the yaml information for that job, so that we can try to run it again and fill grafana with all the dashboards.
  To do so, use the flag `-o yaml`.

  ```
  kubectl get job grafana-import-dashboards -o yaml -n monitoring > grafana-import-dashboards-temp.yaml
  ```

  4)  The next thing to do is to  edit the created file to remove all the useless informations. to do that run:

  ```
  vi grafana-import-dashboards-temp.yaml
  ```
  and then edit the file to make it looks like this one:

  ```
  apiVersion: batch/v1
  kind: Job
  metadata:
    name: grafana-import-dashboards
    namespace: monitoring
  spec:
    template:
      metadata:
        name: grafana-import-dashboards
      spec:
        containers:
        - name: grafana-import-dashboards
          image: [% REGISTRY_URL %]/[% NAMESPACE %]/tiny-tools:[% TAG %]
          command: ["/bin/sh", "-c"]
          workingDir: /var/grafana-dashboards
          args:
            - >
              echo "waiting for Grafana to be up";
              while true; do
                curl -s --connect-timeout 5 --head http://grafana.monitoring:3000/login | grep "200 OK"
                if [ $? -eq 0 ]; then
                  echo "Grafana is Up"
                  break;
                fi;
                echo "Sleeping for one second";
                sleep 1;
              done;
              cat /var/grafana-dashboards/prometheus-datasource.json;
              curl -v -d "@prometheus-datasource.json" -H "Content-Type:application/json" \
                http://<userid>:<password>@grafana.monitoring:3000/api/datasources; # pragma: whitelist secret
              echo "Current dir: $(pwd)";
              ls -l;
              for file in *-dashboard.json ; do
                if [ -e "$file" ] ; then
                  echo "importing $file" &&
                  ( echo '{"dashboard":'; \
                    cat "$file"; \
                    echo ',"overwrite":true,"inputs":[{"name":"DS_PROMETHEUS","type":"datasource","pluginId":"prometheus","value":"prometheus"}]}' ) \
                  | jq -c '.' \
                  | curl --silent --fail --show-error \
                    http://<userid>:<password>@grafana.monitoring:3000/api/dashboards/import \ # pragma: whitelist secret
                    --header "Content-Type: application/json" \
                    --data-binary "@-" ;
                  echo "" ;
                fi
              done
          volumeMounts:
          - name: config-volume
            mountPath: /var/grafana-dashboards
        restartPolicy: Never
        volumes:
        - name: config-volume
          configMap:
            name: {{ SERVICE_NAME }}-config
  ```

  the file should have only the fields present in the showed example. You can use `dd` to remove an entire line, ora `#dd` to remove # lines. Once you have finished, press `:`, write `wq` and press `enter` to save.

  5)  We can now delete the old job by running

  ```
  kubectl delete job grafana-import-dashboards -n monitoring
  ```

  6) And then create a new one

  ```
    kubectl create -f grafana-import-dashboards-temp.yaml
  ```

  7)  To check the status of the created you run:

  ```
  kubectl get jobs -n monitoring
  ```

  8) Once the job is marked as SUCCESSFUL, remove the temporary file you have created by running:

  ```
  rm grafana-import-dashboards-temp.yaml
  ```

## Escalation Policy

Escalate to conductors during business hours.
