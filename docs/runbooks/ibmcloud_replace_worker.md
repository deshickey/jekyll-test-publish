---
layout: default
title: Replace worker node on a carrier or tugboat
type: Informational
runbook-name: "Replace worker node on a carrier or tugboat"
description: Instructions to Replace worker node on a carrier or tugboat
category: armada
service: sre_operations
link: /ibmcloud_replace_worker.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

This runbook describes the process of replacing worker node on a carrier or tugboat.

## Detailed Information

1. Log into the associated IBM Cloud account  
`ibmcloud login --sso`

1. Target the correct region  
`ibmcloud target -r <region>`  
_e.g. `ibmcloud target -r us-south`_

1. Identifiy the correct cluster  
`ibmcloud ks cluster ls`

   ~~~shell
   pcullen@pcullen-VirtualBox:~$ ibmcloud ks cluster ls
   OK
   Name                ID                                 State    Created        Workers   Location   Version   
   va-us-south-zone1   d5dc142d62ef4d23b44c10b9976c790d   normal   8 months ago   9         dal10      1.8.11_1509*   
   va-us-south-zone2   4e13b43147c043e5ab00632b676f95d1   normal   8 months ago   9         dal12      1.8.11_1509*
   ~~~

1. Identify the worker node  
`ibmcloud ks worker ls --cluster <cluster id> | grep <worker ip>`

1. Issue a replacement for the worker  
`ibmcloud ks worker replace --worker <worker id> --cluster <cluster id>`  
_New worker will be scheduled in the same zone and with same configuration as previous node._  
_NB. The process of decomissioning the current node and issuing a new node may take from 10 to 30 minutes._

1. Direct your K8s commands to the cluster  
   `ibmcloud ks cluster config --cluster <cluster id>`  
   Verify new node has joined the cluster and is ready  
   `kubectl get nodes --sort-by=.metadata.creationTimestamp`  
   _Look for recently created node at bottom of result of `kubectl get nodes` command_

   You can also check also check status of nodes on [IBM Cloud web interface](https://cloud.ibm.com/)
