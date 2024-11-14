---
layout: default
description: Information about armada etcd backups
title: Armada ETCD keyprotect instance migration
service: armada-etcd
runbook-name: "Armada etcd kp migration"
tags:  armada, etcd, backup, etcd-backup, armada-ballast
link: /armada/armada-etcd-kp-migration.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook describes the process to migrate keys between two different KeyProtect instances. These keys are maintained within armada-etcd for encryption purposes.

## Detailed Information

Each region contains a list of KeyProtect instances, including a default if none are specified. There is a specific instance defined per region which is used when creating any Envelope Encryption Keys for encrypting etcd data. This process includes the steps to add a new KeyProtect instance to a region and rotate all keys so that it is used for all encrypted data in the region.

### Migration Steps

1. Create a new key provider instance to be used for new encryption key inception
1. Update the key provider secure information in the corresponding `kp.yaml` ([example](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/armada/ca-tor/kp.yaml)) with the following:
    * `(NEW_INSTANCE_NAME)_KP_API_KEY = ...`
    * `(NEW_INSTANCE_NAME)_KP_URL = ...`
    * `(NEW_INSTANCE_NAME)_KP_INSTANCE_ID = ...`
    * `KP_DEFAULT_INSTANCE_ID = (NEW_INSTANCE_NAME)`
    * `KP_INSTANCE_IDS += ",(NEW_INSTANCE_NAME)"`

    `NEW_INSTANCE_NAME` must only include capital letters and underscores to be detected properly. It should be short and descriptive to uniquely identify the backing key provider instance.

    `KP_INSTANCE_IDS` is a comma separated list. If it doesn't currently exist in the file, then only the default instance is currently in use in the region.

    Similarly, if `KP_DEFAULT_INSTANCE_ID` is not set then the default instance is the current specified instance for use for key inception.

1. Promote secure fully to allow the regions to pick up the new changes. Dev tags are not recommended, as any data encrypted during the tag may be lost or unable to be decrypted once the tag is removed.

1. Run [this](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/job/armada-etcd-eek-rotate-verify/build?delay=0sec) Jenkins Job to test the key rotation and ensure that the new KP instance appears in the EEK maps. In the job logs, search for the printed `"EnvelopeEncryptionKeys":` below the `Account after EEK delete` header. The new instance ID should be visible in the field as `\"instanceID\":\"NEW_ID\"`
1. Run a full KP rotation for the region so that all data is encrypted using a key from the new instance, which can be kicked off with armada-xo command `@xo eek.triggerAdd`. This step should be completed by the Armada-Ballast squad.
1. Use the armada-xo `@xo eek.summary` command to verify that the new instance ID is in use. In order to see the instance IDs, an account must be specified:
    * `@Armada Xo - Stage eek.summary region=dev-south account=some-dev-account`
1. Old KP keys related to the prior instance will be deleted as usual, no action is required unless immediate deletion is required
1. Key provider instance deletion will be handled by the Armada-Ballast squad

### Further Information

If there are any questions related to this process, please reach out to the Ballast squad on slack in the `#armada-ballast` channel.

Any related issues can be opened up at [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast)
