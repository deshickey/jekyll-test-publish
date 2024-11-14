---
layout: default
title: How to investigate Qradar Gaps GHE issues for ALC and Armada C_CODEs
type: Informational
runbook-name: "How to investigate Qradar Gaps GHE issues for ALC and Armada C_CODEs"
description: How to check the transmission of audit logs to qradar collector
category: armada
service: qradar
tags: qradar
link: /qradar_gap_check.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook assists SRE investigating issues where ALC or ARMADA devices have not forwarded syslogs to the SOS QRADAR service for a period of time.

The runbook is split out by C_CODE, please review the according section, depending on the issue being investigated

- [Generic/common checks](#generic-checks)
- [ALC checks](#alc-checks)
- [ARMADA checks](#armada-checks)

## Detailed Information

The SRE team will be alerted to issues with QRadar via GHE tickets raised by the Compliance Squad.
They will be titled similar to" `ALC Qradar Gaps - XX Systems`

The below sections help SREs investigate what could be wrong with QRADAR log forwarding.

## Generic checks

These checks are common for both C_CODEs

1.  Verify that the machine(s) reported in the issue are online and operational - a machine being down (i.e in ALC, being unable to ping or SSH to it, or in ARMADA reporting as critical/NotReady) would result in no logs being sent to QRADAR.  In this instance, depending on machine type, attempt reboots or if applicable, reload the systems (generally only suitable for carrier worker nodes or ARMADA nodes which are part of kubernetes clusters)

2.  If the machine is online, see if there is a pattern to the QRADAR issue, i.e.
    - Are the issues for one region - eg: US South
    - Are the issues for a single carrier/cluster - could be a regional issue or a problem with the tooling which performs log forwarding (csutil issues on an ARMADA server?)

## ARMADA checks

These checks are specific for ARMADA QRADAR issues.  
QRadar log forwarding is controlled by PODs and processes that are deployed via csutil (a compliance tool which should be deployed to all Kubernetes clusters - both ROKS and IKS)

### Validate csutil installation

**NOTE:** The [csutil debug](./armada/tugboat_debug_csutil.html) should be used to assist with detailed debugging of csutils on a cluster.  I've linked this runbook rather than duplicate specific commands in this runbook.  

High level validation is as follows - detailed commands and debug/log gathering can be found in the above linked runbook;

1.  Check on [SOS ARMADA compliance portal](https://w3.sos.ibm.com/inventory.nsf/compliance_portal.xsp?c_code=armada) for compliance of the node(s)
2.  Log onto the cluster where the nodes are reporting issues and validate csutil is deployed and all the PODs are running
    - **note:** csutil gets deployed to `ibm-services-system` namespace 
3.  Pay particular attention to the `sos-tools` POD 
    - Issues have been observed where the `sos-ttols` pod is reporting `Running` however, the node it is located on is having issues - this certainly was an issue in kube 1.22 clusters.  If you have a scenario where many/all nodes in a single cluster stop reporting to QRADAR, then delete the `sos-tools` POD and monitor that it comes back up and the old POD terminates.  You may have to reload the node the previous `sos-tools` POD was running on.
4.  Review the `syslog-configurator` daemonset.  These PODs apply the correct settings onto the devices for logs to be forwarded to the sos-tools POD which then forwards the logs to SOS.  
5.  Monitor the SOS compliance portal for changes to the last log report time.

If this does not resolve the issue, work with the SRE squad members to debug further and add further details to this runbook when more scenarios are observed.

## ALC checks

QRADAR forwarding from a host to the syslog servers is setup via the [conductors bootstrap-one](https://github.ibm.com/alchemy-conductors/bootstrap-one/tree/master/playbooks/roles/remote-logging) code.

If you've validated that the servers are all reachable via SSH, then follow the below sections to further debug.


### Validate syslog server status

Alchemy infrastructure and Control Plane servers send logs to the syslog server for their environment. The syslog server is responsible for forwarding appropriate logs to the qradar EP which is owned by SOS.

The current list of syslog servers:

environment | syslog server
--- | ---
dev | dev-mon01-infra-syslog-01
prestage | prestage-mon01-infra-syslog-01
stage | stgiks-dal10-infra-syslog-01<br>stgiks-dal10-infra-syslog-02
us | prod-dal09-infra-syslog-01<br>prod-dal09-infra-syslog-02
eu-central | prod-fra02-infra-syslog-01<br>prod-fra02-infra-syslog-02
uk-south | prod-lon02-infra-syslog-01<br>prod-lon02-infra-syslog-02
ap | prod-tok02-infra-syslog-01<br>prod-tok02-infra-syslog-02
sup | sup-wdc04-infra-syslog-01<br>sup-wdc04-infra-syslog-02

<br>
When investigating `Qradar missing logs from ALC machines` incidents, the first step is to log into the environments' syslog server. If the environment has an HA pair of syslog servers, login to the `-01` server [^1] .  

- Check under `/server-logs/` for the fully qualified hostname. Under this directory you will see dated logs. e.g.

  ~~~
  nicholw@dev-mon01-infra-syslog-01:~$ ls /server-logs/dev-mex01-carrier0-worker-03.alchemy.ibm.com/
  2018-08-27  2018-08-28
  nicholw@dev-mon01-infra-syslog-01:~$
  ~~~

- If the *fully qualified hostname* directory does not exist, then the host has not logged in the past year, or it is logging under a different hostname.  
  In either case the problem is on the host.

- If the *fully qualified hostname* directory exists, but *today's date* sub-directory does not, then the host has stopped logging, or started logging under a different hostname. The latest *log date* sub-directory will indicate the approximate time it stopped logging.  
  The issue is on the host.

- If both *fully qualified hostname* directory and *today's date* sub-directory exists then either:
  - The syslog server has stopped logging to qradar - this will likely need SOS to assist.  
    If this is true then a very large number of hosts will be reported as not logging.
  - There is an issue with SOS reporting  
    This is typically due to a server being reloaded or cancelled and reordered. These shows up as a new server with the same hostname. SOS cleans up duplicate IDs that are not checking in, but this may make some time. So your *not logging to qradar* server maybe the *old* server (before reload).

[^1] `-01` is the primary server; `-02` is the backup. If `-01` is reachable it will be always have preference over `-02`.

<u>Useful checks if you suspect that the syslog server is not logging to the qradar SOS EP</u>

To validate the connection:

- Obtain the `port` and `ip` values from `/usr/local/etc/syslog-ng/60-qradar.conf`
- Execute `gnutls-cli -V --no-ca-verification -p <port> <ip>`  
  If this establishes an interactive session, it indicates that the syslog server can log to the qradar EP. `^C` out of it. e.g.

  ~~~
  nicholw@dev-mon01-infra-syslog-01:~$ gnutls-cli --no-ca-verification -p 6514 10.140.131.20
  Processed 148 CA certificate(s).
  Resolving '10.140.131.20'...
  Connecting to '10.140.131.20:6514'...
  - Certificate type: X.509
  - Got a certificate list of 1 certificates.
  - Certificate[0] info:
   - subject `CN=*,O=SyslogTLS_Server', issuer `CN=*,O=SyslogTLS_Server', RSA key 2048 bits, signed using RSA-SHA512, activated `2016-10-13 14:22:20 UTC', expires `2026-10-11 14:22:20 UTC', SHA-1 fingerprint `8de81412a02157613ee3e0d02349753540117a1f'
          Public Key ID:
                  0bfdb136aa4a258c25e4b263674bcf86e414a7da
          Public key's random art:
                  +--[ RSA 2048]----+
                  |  .              |
                  | o               |
                  |. o...           |
                  | o =+  .         |
                  |o..Bo o S .      |
                  |..X =o . o o     |
                  | . E.+  . =      |
                  |   ..    o .     |
                  |    .....        |
                  +-----------------+

  - Description: (TLS1.0)-(ECDHE-RSA-SECP256R1)-(AES-128-CBC)-(SHA1)
  - Session ID: 5C:C2:1B:78:86:94:07:AE:E0:48:A2:0C:5C:FB:6F:53:BF:FA:AD:14:BC:E9:5B:8D:36:29:3D:AD:81:42:08:3B
  - Ephemeral EC Diffie-Hellman parameters
   - Using curve: SECP256R1
   - Curve size: 256 bits
  - Version: TLS1.0
  - Key Exchange: ECDHE-RSA
  - Cipher: AES-128-CBC
  - MAC: SHA1
  - Compression: NULL
  - Options: extended master secret, safe renegotiation,
  - Handshake was completed

  - Simple Client Mode:

  ^C
  ~~~

Check that syslog server container is running

- run `syslog-server status` e.g.

  ~~~
  nicholw@dev-mon01-infra-syslog-01:~$ syslog-server status
  Container running
  ~~~

  Use other `syslog-server` commands as necessary to start or reload the container.

If all these checks return positive results, then the problem is unlikely with the connection from the `infra-syslog` server(s) to SOS QRADAR EP.

Continue with further machine debugging, or contact the Compliance Squad to reach out to SOS for potential issues with their reporting.

### ALC Machines further debugging

If the determination is that the problem is with the host:

- Login to server that is failing to send logs and verify the following:
  - Server is configured to send logs to the syslog server (file: `/etc/rsyslog.d/65-remote.conf`)  
    The file is created by the bootstrap process, so its existence is typically good enough.  
    If the file is missing: bootstrap the server
  - Server can communicate with the syslog server (command: `openssl s_client -connect <syslog-server ip>:<syslog-server port>`)  
    The syslog server IP and port can be obtained from the file `/etc/rsyslog.d/65-remote.conf`.  
    If the connection fails: debug and open a firewall request (if necessary)
  - `rsyslog` service is running  
  	If `rsyslog` service is not running: start it
  - Hostname is as expected `hostname -f`  
    If incorrect, debug
  - run  
  `sudo auditctl -l`
    - This should dump a long list of rules (100+ lines). If it responds with `no rules` or a very short list, examine /etc/audit/audit.rules.  
    - If missing or incorrect, run [alchemy-bootstrap](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/job/alchemy-bootstrap/)
  - If other systems are generating logs on the syslog server under `/server-logs` then consider rebooting the machine which is no longer logging - use `chlorine` to perform a safe reboot.  Once the reboot is complete, check both syslog machines to verify that logs are now flowing from the server to syslog, then onto qradar.
  


## Escalation Information

Reach out for assistance in the `#iks-sre-compliance` slack channel, tagging `@sre-compliance-focals` if more assistance is required.

If you need to raise an SOS ticket, then use [this link to raise a ticket](https://ibm.service-now.com/nav_to.do?uri=%2Fsn_vul_sos_service_request.do%3Fsys_id%3D-1%26sys_is_list%3Dtrue%26sys_target%3Dsn_vul_sos_service_request%26sysparm_checked_items%3D%26sysparm_fixed_query%3D%26sysparm_group_sort%3D%26sysparm_list_css%3D%26sysparm_query%3Dactive%253dtrue%26sysparm_referring_url%3Dsn_vul_sos_service_request_list.do%253fsysparm_query%253dactive%25253Dtrue%25255EEQ%26sysparm_target%3D%26sysparm_view%3D) - You should select the correct C_CODE, and use assignment group `SOS SIEM (QRADAR)`

