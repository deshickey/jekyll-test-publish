---
layout: default
description: Deploying new syslog server machines
title: Deploy syslog server
service: syslog, deploy
runbook-name: "Syslog Server Deploy"
tags: syslog
link: /syslog_server_deploy.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This document describes the process for deploying a standalone or HA pair of syslog servers for an environment. Because they are being *phased* in, and a given environment may or may not have a syslog server, *bootstrap* changes are required. For this reason the steps should be followed in order; jumping ahead may break the *bootstrap* pipeline.

<u>Note</u>: All environments except `dev` and `prestage` are HA.

#### The following steps are directly applicable for provisioning and deployment of a new syslog infrastructure node in a (new) region. In case of an OS upgrade or hardware change of an existing syslog server go directly to **Redeployment of syslog server** section below


## Detailed Information

1. Order the servers using the [provisioning app](https://alchemy-dashboard.containers.cloud.ibm.com/prov/api/web/). Use the following templates.

   | environment || template || regions |
   | --- || --- || --- |
   | dev-mon01 || dev-syslog
   | prestage-mon01 || dev-syslog
   | stage-dal09 || stage-syslog
   | prod-dal09 || prod-us-syslog || us-south, us-east
   | prod-fra02 || prod-eu-syslog || eu-central
   | prod-lon02 || prod-uk-syslog || uk-south
   | prod-tok02 || prod-ap-syslog || ap-north, ap-south
   | sup-wdc04 ||  dev-syslog

   <br>
   The servers should be named *\<environment\>*-infra-syslog-\<number\> e.g. `stage-dal09-infra-syslog-01`. Order two for HA.

   The servers will bootstrap incorrectly; they will have to be bootstrapped again after the proper variables have been added to [bootstrap-one](https://github.ibm.com/alchemy-conductors/bootstrap-one)

1. Once the server IPs are known, open a [firewall request](https://github.ibm.com/alchemy-netint/firewall-requests/issues) for all servers in that environment to have access to the syslog servers on port 514 (recommended). e.g.

   ```
   Squad: conductors
   Softlayer Account: 531277
   Overview: Allow all stage machines to send logs to syslog server
   Business Justification: alchemy-conductors/alcatraz#110
   Source host(s): All machines in stage environment
   Destination host(s): stage-dal09-infra-syslog-01, stage-dal09-infra-syslog-02
   Destination Port: 514
   Protocol: tcp
   Is it a secure connection?: yes
   Target date: 2018-05-03
   Previous related ticket(s):
   Slack User: @nicholw
   ```

1. Once the servers have bootstrapped, login to the servers and check if `dev/sdb`has been partitioned as RAID 5 and mounted.
   To verify RAID setup login to the server and do `lsblk`. Disk `sdb` should show up, and there should be no `sdc`, `sdd`, etc. e.g.

   ```
   root@stage-dal09-infra-syslog-02:~# lsblk
   NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
   sda      8:0    0   931G  0 disk
   |-sda1   8:1    0   243M  0 part /boot
   |-sda2   8:2    0     1K  0 part
   |-sda5   8:5    0   976M  0 part [SWAP]
   `-sda6   8:6    0 929.8G  0 part /
   sdb      8:16   0  10.9T  0 disk
   `-sdb1   8:17   0   8.7T  0 part /server-logs
   ```

   <u>Note</u>: If the RAID configuration is incorrect open a ticket with Softlayer and have them reconfigure the RAID. Then reload the servers. The RAID configuration:

   - `disk0` no RAID (os system disk)
   - The remaining disks should be a single RAID5 group

   To verify if `sdb` is mounted do `mount | grep sdb`. e.g.

   ```
   root@stage-dal09-infra-syslog-02:~# mount | grep sdb
   /dev/sdb1 on /server-logs type ext4 (rw,relatime,stripe=128,data=ordered)

   ```

   If `/dev/sdb1` is mounted on `/server-logs` the bootstrap fixed everything correctly. <br>
   if `/dev/sdb1` is mounted on some other directory, unmount it, fix `/etc/fstab` and remount it. <br>
   if `/dev/sdb1` does not show up then partition and format the drive, add it to `/etc/fstab` and mount it.

   * `sudo parted /dev/sdb  mklabel gpt`
   * `sudo parted -a opt /dev/sdb  mkpart primary ext4 0% 100%`
   * `sudo mkfs.ext4 -L datapartition /dev/sdb1`
   * Use `blkid` to get the UUID of `/dev/sdb1` and add it to `/etc/fstab`. e.g.

     ```
     root@stage-dal09-infra-syslog-02:~# blkid | grep '/dev/sdb1'
     /dev/sdb1: LABEL="datapartition" UUID="4311bad8-35f6-4bff-b5b8-3e7b71bc90b9" TYPE="ext4" PARTLABEL="primary" PARTUUID="d107e5b9-4964-458c-9f30-453912e065ee"
     root@stage-dal09-infra-syslog-02:~# echo 'UUID=4311bad8-35f6-4bff-b5b8-3e7b71bc90b9 /server-logs ext4 defaults 0 0' >> /etc/fstab
     root@stage-dal09-infra-syslog-02:~# mount /server-logs
     ```

1. Copy the self-signed CA credentials from the syslog server (/usr/local/etc/syslog/ca-cert.pem and /usr/local/etc/syslog/ca-key.pem) and put them under subdirectory https://github.ibm.com/alchemy-conductors/bootstrap-one/tree/master/playbooks/certs/*\<syslog server hostname\>*. They require check in and push **before** the final bootstrap.

1. Edit the the group_vars file for that environment (e.g. `stage-dal09.yml`) and add the required syslog and qradar information:

   * `syslog_server` - hostname for the primary or standalone syslog server
   * `syslog_ip` - IP for the primary or standalone syslog server
   * `syslog_backup_server` - hostname for the backup syslog server; absent for standalone
   * `syslog_backup_ip` - IP for the backup syslog server, absent for standalone
   * `syslog_port` - 514 (recommended); it must match the firewall request
   * `syslog_prune_age` - 365; security requirement to keep logs for 1 year
   * `syslog_compress_age` - 7 (recommended); once logs reach this age they are compressed to reduce space
   * `qradar_env` - cert filename; absent if qradar is unsecured
   * `qradar_ip` - VIP if HA
   * `qradar_port` - 6514 for TLS, 514 for simple TCP

   e.g.

   ```
   # remote syslog server
   syslog_server: "stage-dal09-infra-syslog-01"
   syslog_ip: "{ { hostvars[syslog_server]['ansible_ssh_host'] } }"
   syslog_backup_server: "stage-dal09-infra-syslog-02"
   syslog_backup_ip: "{ { hostvars[syslog_backup_server]['ansible_ssh_host'] } }"
   syslog_port: 514
   syslog_prune_age: 365
   syslog_compress_age: 7

   # qradar EP is HA/TLS
   qradar_env: "stage-dal09-qradarHA"
   qradar_ip: "{ { hostvars['stage-dal09-infra-qradar-portable1']['ansible_ssh_host'] } }"
   qradar_port: 6514
   ```

   This file will require check in and push **before** the final bootstrap.

1. Once the above changes have been pushed and the *bootstrap* pipeline has successfully built, bootstrap the syslog servers again. This will fix the configuration.

1. After the final bootstrap of the syslog servers promote the latest [syslog server build](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/syslog-server/job/syslog-server-build/) to the environment. This will push the `syslog-server` container to the syslog servers.

1. once the syslog servers are completely setup, each server in the environment will have to be bootstrapped so that it will start sending logs to the syslog servers.

## Deploy Sensu Client

1. Raise PR to [sensu-uptime-deploy](https://github.ibm.com/alchemy-conductors/sensu-uptime-deploy)
 to add new syslog-server inventory, [example PR](https://github.ibm.com/alchemy-conductors/sensu-uptime-deploy/pull/249/files) and get it reviewd and merged.
 Note that this is required only if the `syslog` server is new. In case of an OS-reinstalation/ or syslog (re)deployment of an existing `syslog` server (explained in **Redeployment of syslog server**, directly go to next step (step 2) in this section below
 

1. Run [jenkins deploy job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Monitoring/view/ansible-sensu-uptime/job/ansible-sensu-uptime-deploy/)

   - Choose `TARGET_ENV` as the target one
   - Choose `DEPLOY_TYPE` as `deploy-client.yml`
   - Leave everything else as default one unless you know exactly what to do.

1. Make sure the Jenkins job completed as SUCCESS and fix any errors if it failed.
2. Run `docker ps` command to ensure that Sensu Client` is successfully deployed and running.
   
   For eg:
```
root@sup-wdc04-infra-syslog-01:~# docker ps
CONTAINER ID   IMAGE                                              COMMAND                  CREATED       STATUS      PORTS                                                     NAMES
d9c323af4221   us.icr.io/alchemy_sensu/sensu-syslog               "dockerize -template…"   2 weeks ago   Up 8 days                                                             jenkins_syslogclient_1
ca851f7ae545   us.icr.io/alchemy_conductors/syslog-ng-server:33   "/usr/local/bin/sysl…"   2 weeks ago   Up 8 days   10.170.88.139:514->514/udp, 10.170.88.139:514->6514/tcp   syslog-server
root@sup-wdc04-infra-syslog-01:~#
```

## Redeployment of syslog server

These steps are needed for an OS installation (or upgradation) of syslog server of an active region. Note that all production deployments are HA enabled and action these steps only on a single pair at any time.

1. Login to the existing  `syslog` server and copy the following files to your local system

```
/usr/local/etc/syslog/ca-cert.pem
/usr/local/etc/syslog/ca-key.pem
```

2. Perform OS Reload with a new Ubuntu OS version (at the time of this writing we are upgrading to Ubuntu 20) from https://cloud.ibm.com device portal
3. After the installation and bootstrapping login to the system and confirm by running
```
lsb_release -a
sudo service syslog status
```
4. Check for certs, if they are not present, then copy them back from local system (step 1 above)
5. Deploy rsyslog by running the Jenkins Job - https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/job/syslog-server-deploy/ and check for any errors - 
```
sudo service syslog status
```
6. Check the status of syslog-server. It suppose to be running, 
```
syslog-server status
```
7. Go to **Deploy Sensu Client** steps above to deploy Sensu Client.
8. In case of any issues with any of the steps above, post a note in #conductors-for-life slack channel

   
