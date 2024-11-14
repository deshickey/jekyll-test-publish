---
layout: default
title: Diagnose and fix infrastructure syslog server failures
type: Alert
runbook-name: "Diagnose and fix infrastructure syslog server failures"
description: "Diagnose and fix infrastructure syslog server failures"
service: syslog
category: armada
link: /syslog_alert.html
tags: syslog
playbooks: []
failure: ["syslog server not reponding", "syslog server cpu usage", "syslog server disk usage", "qradar cert file expired"]
parent: Armada Runbooks

---

Alert
{: .label .label-purple}

## Overview

All Alchemy infrastructure machines (includes carriers) send their logs, including audit logs, to a syslog-server. The syslog-server, in addition to providing remote server log storage, is responsible for forwarding the appropriate logs to the qradar EP. <br>
*Note*:

- A syslog-server may serve multiple regions
- The syslog-server may be an HA pair

The current syslog servers:


| syslog-server | region |
| --- | --- |
| dev-mon01-infra-syslog-01 | dev/test |
| prestage-mon01-infra-syslog-01 | prestage |
| stage-dal09-infra-syslog-01<br>stage-dal09-infra-syslog-02 | stage |
| prod-dal09-infra-syslog-01<br>prod-dal09-infra-syslog-02 | us-south, us-east, ca-tor |
| prod-fra02-infra-syslog-01<br>prod-fra02-infra-syslog-02 | eu-central |
| prod-lon02-infra-syslog-01<br>prod-lon02-infra-syslog-02 | uk-south |
| prod-tok02-infra-syslog-01<br>prod-tok02-infra-syslog-02 | ap-north, ap-south, jp-osa |
| sup-wdc04-infra-syslog-01<br>sup-wdc04-infra-syslog-02 | Foundations |

<br>

When the syslog-server is an HA pair, the `-01` server is **always** primary. The `-02` server is backup and only used when communication is lost with the primary; logging switches back to the primary as soon as communication is reestablished. This behavior includes the backup server; it sends its logs to the primary. There is **no** shared disk between primary and backup; both servers may need to be interrogated to obtain the desired logs.

This runbook describes how to fix syslog issue:
- [syslog-server status](#syslog-server-not-responding-alert)
- [cpu usage](#cpu-usage-alert)
- [disk usage](#disk-usage-alert)
- [qradar cert file expired](#qradar-cert-file-expired)

*Note*: stage and production environments are HA, so pay attention to which of the syslog-servers the alert is from.


## Example alerts

Example PD titles and alerts:

- [`dev-mon01-infra-syslog-01/keepalive : No keepalive sent from client for 117 seconds (>=90)`](https://ibm.pagerduty.com/incidents/PT8AEAI)

- [`dev-mon01-infra-syslog-01/SysLog-syslogcheck-dev-mon01-infra-syslog-01 : {"status_code":1, "response_code":"Failed to connect Syslog server", "time_total":0.006460, "upstatus...`](https://ibm.pagerduty.com/incidents/PQIMDPF)

- [`dev-mon01-infra-syslog-01/SysLog-diskcheck-dev-mon01-infra-syslog-01 : CheckDiskUsage CRITICAL: Found 1 problems`](https://ibm.pagerduty.com/incidents/P8JT8FV)

- [`dev-mon01-infra-syslog-01/SysLog-cpucheck-dev-mon01-infra-syslog-01 : CheckCPU TOTAL CRITICAL: total=18.95 user=14.67 nice=0.0 system=3.99 idle=81.05 iowait=0.0 irq=0.0 so...`](https://ibm.pagerduty.com/incidents/PP9OS8Y)

-  [`dev-mon01-infra-syslog-01/Qradar-cert-check : b70744b94ad3: qradar cert Error opening Certificate /root_mount/usr/local/etc/qradar/dev-mon01-infra-...`](https://ibm.pagerduty.com/incidents/POYG7VG/timeline)

## Automation

N/A

## Actions to take

### syslog-server not responding alert

This alert is generated when the syslog-server is **not** healthy. Log into the syslog-server node and check status using:
`syslog-server status`. Use the following list to take action based on the status.

- **Container running**  
The syslog-server is running; the issue is probably intermittent.
If that does not work, escalate
- **Container stopped**  
Try to start it again using  
`syslog-server start`  
If that does does work try  
`syslog-server reload`.
- **Container not loaded**  
The container does not exist, but the image is in the local repository. Reload the container using  
`syslog-server reload`
- **Image not found**  
The container image is not in the repository. Re-promote the syslog-server to the appropriate environment from [syslog-server-build](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/syslog-server/job/syslog-server-build/)

### cpu usage alert

This alert is generated when cpu usage is higher on Syslog-server with warning value is 75% and critical value is 80%.

Log into the syslog-server node and run `top -c -b -n1 -o %CPU` to show processes ordered by the cpu being consumed. From the `top` output, find processes consuming high percentages of CPU and investigate why these processes are consuming high CPU.

Open an issue against [syslog-server](https://github.ibm.com/alchemy-conductors/syslog-server/issues) GHE.

### disk usage alert

The mount point for the remote server logs is typically `/server-logs`, and disk usage is monitored with warning value is 75% and critical value is 80%.

1. **Verify alert**  
Login to the syslog server and verify disk usage using `df -h /server-logs`.
If the alert is a false positive, open an issue against [conductors](https://github.ibm.com/alchemy-conductors/team/issues/) GHE. Otherwise, continue with this diagnosis.

 1. **Check `cron` status**  
   The `log-prune` command should run daily as a `cron` job.  
   Use `systemctl` to check `cron` status. Verify that the service is running and review the log messages for additional clues.
    
    ```
    prod-dal09-infra-syslog-01:~$ sudo systemctl status cron
    * cron.service - Regular background program processing daemon
       Loaded: loaded (/lib/systemd/system/cron.service; enabled; vendor preset: enabled)
       Active: active (running) since Thu 2021-03-04 15:50:17 UTC; 2 weeks 6 days ago
         Docs: man:cron(8)
     Main PID: 1349 (cron)
        Tasks: 1 (limit: 6143)
       CGroup: /system.slice/cron.service
               `-1349 /usr/sbin/cron -f

    Mar 25 04:40:01 prod-dal09-infra-syslog-01 sudo[20688]:     root : TTY=unknown ; PWD=/root ; USER=root ; COMMAND=/bin/rm -f /usr/local/data/route-repair-flap
    Mar 25 04:40:01 prod-dal09-infra-syslog-01 sudo[20688]: pam_unix(sudo:session): session opened for user root by (uid=0)
    Mar 25 04:40:01 prod-dal09-infra-syslog-01 sudo[20688]: pam_unix(sudo:session): session closed for user root
    Mar 25 04:40:01 prod-dal09-infra-syslog-01 CRON[20684]: pam_unix(cron:session): session closed for user root
    Mar 25 04:42:01 prod-dal09-infra-syslog-01 CRON[20776]: pam_unix(cron:session): session opened for user root by (uid=0)
    Mar 25 04:42:01 prod-dal09-infra-syslog-01 CRON[20777]: (root) CMD (/home/jenkins/sensu-vip-check)
    Mar 25 04:42:01 prod-dal09-infra-syslog-01 sudo[20780]:     root : TTY=unknown ; PWD=/root ; USER=root ; COMMAND=/bin/rm -f /usr/local/data/route-repair-flap
    Mar 25 04:42:01 prod-dal09-infra-syslog-01 sudo[20780]: pam_unix(sudo:session): session opened for user root by (uid=0)
    Mar 25 04:42:01 prod-dal09-infra-syslog-01 sudo[20780]: pam_unix(sudo:session): session closed for user root
    Mar 25 04:42:01 prod-dal09-infra-syslog-01 CRON[20776]: pam_unix(cron:session): session closed for user root
    ```  

    If the `cron` service is not running, you can start it with `sudo systemctl start cron`

    1. Cron jobs will not run for a user with an expired password. If `root`'s password has expired, the `systemctl` output from the previous step would likely have messages like:

    ```
    Mar 12 01:40:01 prod-dal09-infra-syslog-01 CRON[33959]: Authentication token is no longer valid; new one required
    Mar 12 01:42:01 prod-dal09-infra-syslog-01 CRON[34654]: pam_unix(cron:account): expired password for user root (password aged)
    ```

   1. [Check/reset root password expiration](./change_root_password.html)

   1. **Check whether the `log-prune` job has been running**  
      If the `cron` service was not running or `root`'s password was expired, move on to the next step, since the job couldn't have run.

      Spot check the logs of one server to determine whether they have been pruned. If pruning is working, the result should be `0`.  
      ```
      prod-dal09-infra-syslog-01:~$ sudo find /server-logs/prod-dal10-carrier3-master-01 -mtime +365 |wc -l
      67
      ```  
        - If the result of the `find` is `0`, the logs have been pruned, and the syslog server is simply out of space. Skip to "Add disks" below.  
        - If the result is greater than `0`, continue with the next step.  

   1. **Verify that `log-prune` is scheduled to run daily**  
     The `/usr/local/bin/log-prune` line may have a different number in the second field, but it should exist and otherwise look exactly like the example below.
      
      ```
      prod-dal09-infra-syslog-01:~$ sudo cat /etc/cron.d/alchemy-tab
      #Ansible: Syslog Log Prune
      0 2 * * * root /usr/local/bin/log-prune
      #Ansible: Daily docker housekeeping
      * 18 * * * root /usr/local/bin/alchemy-docker-cleanup
      ```  

      If any corrections are needed, make them, then restart the `cron` service with `sudo systemctl restart cron`  

   1. **Verify `log-prune` is using appropriate values**  
     Determine the config values that `log-prune` is using.  
      
      ```
      prod-dal09-infra-syslog-01:~$ sudo grep -A1 -B2 "default=" /usr/local/bin/log-prune

      parser.add_argument('--path',
                          default='/server-logs',
                          help='Path to root directory for server logs')
      parser.add_argument('--keep',
                          type=int,
                          default=365,
                          help='Max number of days to keep logs')
      parser.add_argument('--compress',
                          type=int,
                          default=7,
                          help='Max number of days before logs are compressed')
      ```  

      The `--keep` and `--compress` values correspond to `syslog_prune_age` and `syslog_compress_age`, respectively, in the [group_vars](https://github.ibm.com/alchemy-conductors/bootstrap-one/tree/master/playbooks/group_vars) yml file for the syslog server's environment. e.g. [group_vars/prod-dal09.yml](https://github.ibm.com/alchemy-conductors/bootstrap-one/blob/master/playbooks/group_vars/prod-dal09.yml)

      If the environment is `dev/test` or `prestage`, either value can be adjusted until the disk usage falls below the warning value. For `stage` and `prod` environments the `syslog_prune_age` must remain greater than or equal to `365`. Only the `syslog_compress_age` can be adjusted, and it must be greater than `0`.  

      If one or both values should be changed, make note of the proposed values and use them in the next step.

   1. **Manually run the `log-prune` command**  
      If it has been several days or weeks since `log-prune` last ran, it could take 12 hours or more for the process to complete. Use `nohup` to allow the process to continue even after your session times out or expires.  

      If values other than the defaults should be used, specify them with `--keep` and/or `--compress` in the command. For example:  
       `nohup sudo /usr/local/bin/log-prune --keep 365 --compress 7`  

      When the task completes check disk usage again using  
       `df -h /server-logs`  
         - If the disk usage is still too high, repeat the `log-prune` with smaller values
         - If the values are already as small as permitted (or desired) skip to "Add disks" below
         - If the disk usage is acceptable then update the syslog-server configuration with any changes that were made (see below)

   1. **Update the syslog-server configuration with the new limits**  
     If new "keep" or "compress" values were used in the previous step,  
       - Update the appropriate [group_vars](https://github.ibm.com/alchemy-conductors/bootstrap-one/tree/master/playbooks/group_vars) file for the region with the new limit(s).
       - Create a pull request for [bootstrap-one](https://github.ibm.com/alchemy-conductors/bootstrap-one)
       - When the bootstrap pipeline has built (and the bootstrap servers are updated) bootstrap the syslog servers in the appropriate environment

   1. **Add disks**  
     If pruning the logs does not sufficiently reduce the disk usage, open a [syslog-server issue](https://github.ibm.com/alchemy-conductors/syslog-server/issues) and request a review by SRE leads to determine whether disks should be added to the existing syslog server or if a new syslog server should be added to another region to spread the load.  


### qradar cert file expired

The qradar cert file is used for TLS and an alert is generated when the expiration is <= 30 days. When this happens a new qradar cert is required.

<u>To replace the qradar cert</u>

- Open a [Service Request](https://ibm.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3D45ef56a7db7c4c10c717e9ec0b96193a%26sysparm_link_parent%3D109f0438c6112276003ae8ac13e7009d%26sysparm_catalog%3De0d08b13c3330100c8b837659bba8fb4%26sysparm_catalog_view%3Dcatalog_default%26sysparm_view%3Dcatalog_default) against team `SOS SIEM (Qradar)` for a new qradar cert.  
_Provide the hostname & IP (both private and management) of the qradar servers_

- open a [team](https://github.ibm.com/alchemy-conductors/team) ticket to track the progress of this task e.g. [prestage-mon01-infra-syslog](https://github.ibm.com/alchemy-conductors/team/issues/21842)
- When the cert is received replace the existing copy in the [bootstrap certs](https://github.ibm.com/alchemy-conductors/bootstrap-one/tree/master/playbooks/certs/qradar) directory
  - Pay attention to the names for these certs. If the environment is HA then the cert is named `<environment>-qradarHA.crt`. Otherwise it is named using the qradar EP hostname.
- Create a *pull request* for [bootstrap-one](https://github.ibm.com/alchemy-conductors/bootstrap-one)
- After bootstrap-one PR is merged need to get rolled out a corresponding change in bootstrap-one-server,
- clone the [bootstrap-one-server](https://github.ibm.com/alchemy-conductors/bootstrap-one-server) and in the bootstrap-one-server folder run the `./updatePlaybooks.sh` to create a new PR.
- After bootstrap-one-server PR is get merged needs to be promote and create a [checklist issue](https://github.ibm.com/alchemy-conductors/bootstrap-one-server/issues/new?assignees=&labels=&template=promotion-checklist.md&title=BUILD+%23%3Cbootstrap-one-server+BUILD+NUMBER%3E+%3A+Tracking+Promotion), refrence link for [Tracking Promotion](https://github.ibm.com/alchemy-conductors/bootstrap-one-server/issues/475).
- BUILD number will be a new build in [razee](https://razeeflags.containers.cloud.ibm.com/alchemy-containers/flags/default/production/bootstrap-one-server) for the `dev-`. 

- complete the steps in the 'BUILD #** :Tracking Promotion' to promot in all environment.

<u>To verify the qradar cert expiration</u>

- login to the syslog-server
- get name of qradar cert  
`ls -lh /usr/local/etc/qradar/`  
_the qrader cert will end in `.pem`_
- get the end date from the cert using `openssl`. e.g.  
`openssl x509 -enddate -noout -in /usr/local/etc/qradar/dev-mon01-infra-qradar-01.pem`  
_if the expiration is > 30 days open an issue against [conductors](https://github.ibm.com/alchemy-conductors/team/issues/) GHE._

## Escalation Policy

  If none of the above suggestions work, slack in the #sos-armada channel and request that the runbook be updated if possible.
