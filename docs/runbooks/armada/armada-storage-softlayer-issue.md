---
layout: default
description: How to debug the softlayer credential issues.
title: armada-storage -  How to debug the issue when there is a wrong softlayer credential issue.
service: armada-storage
category: armada
runbook-name: "How to debug the issue for wrong softlayer credentials."
tags: alchemy, armada, kubernetes, kube, kubectl, wanda
link: /armada/armada-storage-softlayer-issue.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview
This runbook describes how to check wrong softlayer credentails issues.

## Example Alert(s)

### Possible issues to be looked in the logs of storage pod obtained from cluster owner

1.      If you see following error in storage pod logs, User might not have sufficient permission to create, authorise, view and delete storage.<br>
        1. {<i>"level":"error","ts":"2017-04-20T15:34:27Z","msg":"nfs-provisioner.go:108: Storage creation failed with error: ","error":"Failed to Provision Storage with orderid 13992609 after a max retry time of 900 seconds. Description: Unable to find storage with order id 13992609 .One of the Possible Reason could be that the {{ site.data.storage.slname.name }} User has limited permission to place storage Orders. kindly correct it through {{ site.data.storage.slname.name }} Portal.Other Possible Reason could be, {{ site.data.storage.slname.name }} taking moretime to provision.Kindly retry after sometime."<i>}
        1. To check the permission please run the following steps.
           1.  If you have SL portal Access, try creating a Storage from there using the same User login that uses to create PVC.
           1.  Run the curl command to Verify your orders status,  {{ site.data.storage.creds.link }}/rest/v3/{{ site.data.storage.slname.name }}_Account/getNetworkStorage.json.<br>
           1.  If you don’t have permissions to create Storage or not able to view your storages with above Curl command, Please ask user to get the access for create, authorise, view and delete storage from the `"Master user"` of his account.
&nbsp;

## Investigation and Action

### **Steps**:

1.      Check if its a Wrong {{ site.data.storage.slname.name }} credential issue
        1. Update the credentails with following bx cs command<br>
           `bx cs credentials-set --infrastructure-username <> --infrastructure-api-key <>`
        1. Using clusterid
           1. Get the cluster id from Customer/Ticket and fetch the DC and CARRIER Name from “armada-xo”
           1. Login to master node and navigate to `/mnt/nfs/<clusterid>/etc/kubernetes/addons` folder update the secret file and apply the changes with following commands.<br>
              `get the storage secret details by using following commands and Copy the content of slclient.toml tag and save in slclient.toml file and follow the steps.`<br>
              `cat customer-master-components-secret-store.yaml | grep slclient.toml`<br>
              `echo <slclient.toml tag value > | base64 --decode` <br>
              `This will provide content of storage secret, There would be two [{{ site.data.storage.bxname.name }}] and [{{ site.data.storage.slname.name }}] section in this file please verify few things in these section.`<br>
              `Either {{ site.data.storage.slname.name }}_api_key & {{ site.data.storage.slname.name }}_username or iam_api_key, iam_client_secret and iam_client_id should be there.`
                  
              1. If {{ site.data.storage.slname.name }}_api_key & {{ site.data.storage.slname.name }}_username are there, then storage plugin will use these keys as per flag `encryption` and if there is any issue with content of these properties and `encryption` is true then please reach out to #armada-storage channel, if `encryption` is false the conductor team can verify/change correct information after  consulting with customer/user.<br>
              2. Updating of secret can be done by conductor team only when  `encryption` value is false for {{ site.data.storage.slname.name }}_api_key & {{ site.data.storage.slname.name }}_username properties, rest of properties can be modified by conductor as per requirement and following steps can be useful Steps for modifying secrets: <br>
                 1. `cat customer-master-components-secret-store.yaml | grep slclient.toml`<br>
                 2. `echo <slclient.toml tag value > | base64 --decode` <br>
                 3.  Copy the result of above command in slclient.toml and save it and udpate the correct information. <br>
                 4. `cat slclient.toml | base64` <br>
                 5.  update/replace the encrypted value from step4 into the slclient.toml tag of customer-master-components-secret-store.yaml file and then apply these changes with following command <br>
                 6. `kubectl apply -f customer-master-components-secret-store.yaml -n kube-system`
        


## Escalation Policy

For more help in searching the logs, please visit the [{{site.data.storage.armada-storage.comm.name}}]({{site.data.storage.armada-storage.comm.link}}) {{site.data.storage.commname.name}} channel.

If you are here because of a PD incident and need more help on an issue, you can escalate to the development squad by using the [{{site.data.storage.armada-storage.escalate.name}}]({{site.data.storage.armada-storage.escalate.link}}) PD escalation policy.

If you run across any armada-storage problems during your search, you can open a GHE issue for armada-storage [{{site.data.storage.armada-storage.name}}]({{site.data.storage.armada-storage.issue}}).

## Automation

None
