---
layout: default
description: How to view kubelet and other systemd logs via journalctl.
title: How to view kubelet and other systemd logs via journalctl.
service: armada-carrier
runbook-name: "How to view kubelet and other systemd logs via journalctl"
tags: alchemy, armada, kubernetes, armada-carrier, kubelet, journalctl, systemd, logs
link: /armada/armada-carrier-view-systemd-logs.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook describes how to view the kubelet logs as well as other logs (docker, etcd, etc) using the journalctl command.

## Detailed Information
To view the logs, you first need to ssh to the node in question (ex. prod-dal10-carrier1-worker-05).

To view the kublet logs, run `sudo journalctl -u kubelet.service`. This command will output all of the kubelet systemd logs. If you would like to see live output of the logs, add the -f (follow) option.

~~~
armada@stage-dal09-carrier0-worker-05:~$ sudo journalctl -fu kubelet.service
-- Logs begin at Fri 2017-05-19 14:53:54 UTC. --
May 19 16:06:03 stage-dal09-carrier0-worker-05.alchemy.ibm.com hyperkube[4429]: I0519 16:06:03.037512    4429 operation_executor.go:917] MountVolume.SetUp succeeded for volume "kubernetes.io/secret/5bf8e5f0-3b69-11e7-887f-061f0cae3644-ibm-kube-fluentd-token-r4s4z" (spec.Name: "ibm-kube-fluentd-token-r4s4z") pod "5bf8e5f0-3b69-11e7-887f-061f0cae3644" (UID: "5bf8e5f0-3b69-11e7-887f-061f0cae3644").
May 19 16:06:05 stage-dal09-carrier0-worker-05.alchemy.ibm.com hyperkube[4429]: I0519 16:06:05.038824    4429 server.go:740] GET /stats/summary/: (10.777341ms) 200 [[Go-http-client/1.1] 10.143.139.253:58022]
May 19 16:06:12 stage-dal09-carrier0-worker-05.alchemy.ibm.com hyperkube[4429]: I0519 16:06:12.492370    4429 server.go:740] GET /metrics: (130.26176ms) 200 [[Prometheus/1.6.2] 10.143.139.212:59626]
May 19 16:06:15 stage-dal09-carrier0-worker-05.alchemy.ibm.com hyperkube[4429]: I0519 16:06:15.000679    4429 operation_executor.go:917] MountVolume.SetUp succeeded for volume "kubernetes.io/secret/919a11fd-3c20-11e7-887f-061f0cae3644-default-token-lqx0p" (spec.Name: "default-token-lqx0p") pod "919a11fd-3c20-11e7-887f-061f0cae3644" (UID: "919a11fd-3c20-11e7-887f-061f0cae3644").
May 19 16:07:04 stage-dal09-carrier0-worker-05.alchemy.ibm.com hyperkube[4429]: I0519 16:07:04.992535    4429 operation_executor.go:917] MountVolume.SetUp succeeded for volume "kubernetes.io/secret/6923b451-3c33-11e7-8366-061f0cae3644-default-token-lqx0p" (spec.Name: "default-token-lqx0p") pod "6923b451-3c33-11e7-8366-061f0cae3644" (UID: "6923b451-3c33-11e7-8366-061f0cae3644").
May 19 16:07:05 stage-dal09-carrier0-worker-05.alchemy.ibm.com hyperkube[4429]: I0519 16:07:05.123733    4429 server.go:740] GET /stats/summary/: (84.591037ms) 200 [[Go-http-client/1.1] 10.143.139.253:58022]
May 19 16:07:06 stage-dal09-carrier0-worker-05.alchemy.ibm.com hyperkube[4429]: I0519 16:07:06.997405    4429 operation_executor.go:917] MountVolume.SetUp succeeded for volume "kubernetes.io/secret/ec78bc0c-0fe3-11e7-8f37-061f0cae3644-default-token-g7hps" (spec.Name: "default-token-g7hps") pod "ec78bc0c-0fe3-11e7-8f37-061f0cae3644" (UID: "ec78bc0c-0fe3-11e7-8f37-061f0cae3644").
May 19 16:07:27 stage-dal09-carrier0-worker-05.alchemy.ibm.com hyperkube[4429]: I0519 16:07:27.048647    4429 operation_executor.go:917] MountVolume.SetUp succeeded for volume "kubernetes.io/secret/5bf8e5f0-3b69-11e7-887f-061f0cae3644-logmet-secrets-volume" (spec.Name: "logmet-secrets-volume") pod "5bf8e5f0-3b69-11e7-887f-061f0cae3644" (UID: "5bf8e5f0-3b69-11e7-887f-061f0cae3644").
May 19 16:07:27 stage-dal09-carrier0-worker-05.alchemy.ibm.com hyperkube[4429]: I0519 16:07:27.048683    4429 operation_executor.go:917] MountVolume.SetUp succeeded for volume "kubernetes.io/configmap/5bf8e5f0-3b69-11e7-887f-061f0cae3644-fluentd-config" (spec.Name: "fluentd-config") pod "5bf8e5f0-3b69-11e7-887f-061f0cae3644" (UID: "5bf8e5f0-3b69-11e7-887f-061f0cae3644").
May 19 16:07:27 stage-dal09-carrier0-worker-05.alchemy.ibm.com hyperkube[4429]: I0519 16:07:27.048809    4429 operation_executor.go:917] MountVolume.SetUp succeeded for volume "kubernetes.io/secret/5bf8e5f0-3b69-11e7-887f-061f0cae3644-ibm-kube-fluentd-token-r4s4z" (spec.Name: "ibm-kube-fluentd-token-r4s4z") pod "5bf8e5f0-3b69-11e7-887f-061f0cae3644" (UID: "5bf8e5f0-3b69-11e7-887f-061f0cae3644").
~~~ 


## View other systemd logs
To view other systemd logs, run the same command above but insert a different service instead of kubelet. For example, run `sudo journalctl -fu docker.service` to view docker logs.

To view a list of enabled systemd services, run `sudo systemctl list-unit-files --all | grep enabled` to view the logs that can be viewed with systemctl.

~~~
armada@stage-dal09-carrier0-master-01:~$ sudo systemctl list-unit-files --all | grep enabled
acpid.path                                 enabled
accounts-daemon.service                    enabled
atd.service                                enabled
auditd.service                             enabled
autovt@.service                            enabled
calico-node.service                        enabled
cloud-config.service                       enabled
cloud-final.service                        enabled
cloud-init-local.service                   enabled
cloud-init.service                         enabled
cron.service                               enabled
dbus-org.freedesktop.thermald.service      enabled
docker.service                             enabled
etcd.service                               enabled
etcd2.service                              enabled
friendly-recovery.service                  enabled
getty@.service                             enabled
iscsi.service                              enabled
iscsid.service                             enabled
kubelet.service                            enabled
lvm2-monitor.service                       enabled
lxcfs.service                              enabled
lxd-containers.service                     enabled
networking.service                         enabled
open-iscsi.service                         enabled
pollinate.service                          enabled
resolvconf.service                         enabled
rsyslog.service                            enabled
snapd.autoimport.service                   enabled
snapd.service                              enabled
ssh.service                                enabled
sshd.service                               enabled
sssd.service                               enabled
syslog.service                             enabled
systemd-timesyncd.service                  enabled
thermald.service                           enabled
ufw.service                                enabled
unattended-upgrades.service                enabled
ureadahead.service                         enabled
xe-daemon.service                          enabled
acpid.socket                               enabled
apport-forward.socket                      enabled
dm-event.socket                            enabled
docker.socket                              enabled
lvm2-lvmetad.socket                        enabled
lvm2-lvmpolld.socket                       enabled
lxd.socket                                 enabled
rpcbind.socket                             enabled
snapd.socket                               enabled
uuidd.socket                               enabled
nfs-client.target                          enabled
remote-fs.target                           enabled
apt-daily.timer                            enabled
snapd.refresh.timer                        enabled
~~~


## More Help
For more help in searching the logs, please visit the [{{ site.data.teams.armada-carrier.comm.name }}]({{ site.data.teams.armada-carrier.comm.link }}) slack channel.

If you run across any armada-carrier problems during your search, you can open a GHE issue for armada-carrier [here](https://github.ibm.com/alchemy-containers/armada-carrier/issues/new).
