---
layout: default
description: Restore account Key Protect key in armada ETCD
title: armada-ETCD - Restore Account EEK
service: armada-ETCD
runbook-name: "armada-ETCD - Restore Account EEK"
tags: alchemy, armada, ETCD, armada-ETCD, keyprotect, kp, eek
link: /armada/armada-ETCD-restore-account-key.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook contains the steps need to restore an account Key Protect key into ETCD.
The account keys in ETCD allow for ETCD fields to be encrypted on a per account basis.

## Example Alerts

There are no existing alerts for this runbook.

## Investigation and Action

The following sections describe the actions to take to restore an account eek key.

## When to execute this runbook

In the following cases this runbook will allow the key to be restored into ETCD for an account.

- The account key was deleted from ETCD and/or Key Protect inadvertently. Key Protect allows 30 days to restore a key.
- The account key or it's related info was somehow corrupted in ETCD.

All other cases need to use the [escalation policy](#escalation-policy) below.

## How are KP keys stored in ETCD

The KP keys are stored in ETCD on a per account basis.  The [Account](https://github.ibm.com/alchemy-containers/armada-model/blob/master/model/structs.go#L1080) struct contains the
`EnvelopeEncryptionKeys` field.  This field is a json blob defined as a map of keys with an
 interger index:

- type EnvelopeEncryptionKeys map[int]EnvelopeEncryptionKey
- Example from XO command: `@xo account <account ID> show=all`

  ~~~~~text
  "EnvelopeEncryptionKeys": "{\"1\":{\"crk\":\"6d88c6a4-f515-4606-a11b-926933f722d7\",\"wrappedDEK\":\"eyJjaXBoZXJ0ZXh0IjoiTUl1QVhZNEZCMzd6VEp4ZFEzUzZJV2JrYVRadGRuTUtDZzl5eVdsSkRFRERFRGd5N3lwWGlqNlF3dEk9IiwiaXYiOiJ4dzVodXRPQzFCTEh4aHFiIiwidmVyc2lvbiI6IjQuMC4wIiwiaGFuZGxlIjoiNmQ4OGM2YTQtZjUxNS00NjA2LWExMWItOTI2OTMzZjcyMmQ3In0=\",\"algorithm\":\"AES-256\"}}"
  ~~~~~

In most cases there will be just 1 key, but there could be multiple keys as needed for rotations.

Fields in the key:

- crk - This is the Key Protect `Key ID`.
- wrappedDEK - This is the wrapped Data Encryption Key to use. It's returned by calling the KP `WrappedDEK` API with the crk.
- algorithm - cipher used, right now this is always `AES-256`.

Key Protect uses envelope encryption to assist in protecting your Key Protect data. Envelope encryption involves encrypting your data with a Data Encryption Key, then encrypting the Data Encryption Key with a root key.

Account keys are created in KP and added to EnvelopeEncryptionKeys automatically via the [armada-soyuz cipher](https://github.ibm.com/alchemy-containers/armada-soyuz/blob/master/soyuz/kp/cipher.go) package logic when the first encrypted field is written for this account.

## Steps to Restore Account Key

1. Create a Production Train for this restore request

   - Use the Production Trains channel to request a change for this region.
   - Will be used as `TRAINID` in below commands.

1. Gather the region

   - Region - This is the production region where the key needs to be restored.
   - For example:
     - us-east
     - uk-south
     - us-south
     - eu-central
     - eu-fr2
     - ca-tor
     - ap-north
     - ap-south
     - br-sao
     - jp-osa
   - Will be used as `REGION` in the commands below.

1. Gather account ID

    - Account ID - This is the account id for the key.
    For a cluster, this would be the `AccountID` field in the ETCD model which can be seen with
    the XO command: `@xo cluster <cluster ID>`.
    - Will be used as `ACCOUNTID` in the commands below.

1. Find correct EnvelopeEncryptionKeys index to restore into

    - Index - This is the EnvelopeEncryptionKeys map index and needs to match the index of existing
    encrypted fields.

    - Run the XO command:
    `@xo eek.summary account=<account ID> region=<region>`
    to see the account key information.
    - Example output

    ~~~~text
    Account: 3ce8ff83b9d19998cc529fc94b511596
    Account Create Enabled: true
    Account Delete Enabled: false
    Keys: 2
    Key Indexes: [1 2]
    Creating: no
    Deleting: no
    Encrypting: no
    Desired Index: 2
    Actual Index: 2
    Rotation Date: 2022-10-13T19:06:30+0000
    Keys Error:
    Index Error:
    ~~~~

    - The `Creating`, `Deleting` and `Encrypting` action should all be `no`.
    - The `Keys Error` and `Index Error` should be empty.
    - The `Actual Index` shows the current index being used to encrypt fields.
       - If the use case is the key was deleted from ETCD, it will be missing from the `Key Indexes` list. The index to restore needs to be found by looking at the delete action logs in Reaper for this ACCOUNTID.
       - If the use case is the key is corrupted in ETCD, use ths index from the corrupted key, it will be one of the key indexes in the `Key Indexes` list.  Use service logs to determine which index is corrupt.
    - Will be used as `INDEX` in the commands below.

1. Gather key ID from Key Protect

    - Key ID/crk - This is the Key Protect `Key ID` for the key to be restored.

    - Using the IBM Cloud UI, navigate to the resource list for the production account that contains all the account keys for the region.
       - The production account: **1185207 - Alchemy Production Account**
    - Open the Security section to see all the Key Protect instances.
    - The Key Protect instance name will be the same as the ACCOUNTID gathered above.
    - Select to see `Deleted` keys in the filter for the Keys list view. There should be a deleted key that needs to be restored in the list.
    - Select the `Restore` action for the key that needs to be restored. Click to have the key restored.
    - The key state is now `Enabled`.
    - Select the `Details` action for the key and click record the `Key ID:` at the top.
    - Will be used as `KEYID` in the commands below.

1. Gather wrapped DEK from IBM Cloud Logs

    - wrapped DEK - This is the Key Protect `wrapped DEK` for the key to be restored.

    - Bring up IBM Cloud Logs for the `REGION` and set app filter to `armada-reaper`
    - Search using the first part of the `KEYID`
      - Should see a log entry like this:

        ~~~text
        Oct 14 16:23:39 armada-reaper-696c789cc4-rjfvs armada-reaper info {"level":"info","ts":"2022-10-14T21:23:39.600Z","caller":"kp/rotation.go:109","msg":"Deleting key","prefix":"/us-south/accounts/delete_unused_eek/","worker":"worker4","reqID":"c83a172a-01c4-4497-8b87-f08c9b9fba1c","accountID":"2ee3a768e34a48a59c98ecef6f68d07c","dryRun":false,"index":1,"key":{"crk":"c8f42b14-3052-40dd-a000-edd84e559264","wrappedDEK":"eyJjaXBoZXJ0ZXh0IjoiNmkyR293QjhOOEcvZ0NBOTY2eGozaFFyS3RhamxOb1BMNGRKN0FIVC9BNTdPaEV6M3c2blRlY0VQYVk9IiwiaXYiOiJEREVmNU1RQmtjZDBTSTVBIiwidmVyc2lvbiI6IjQuMC4wIiwiaGFuZGxlIjoiYzhmNDJiMTQtMzA1Mi00MGRkLWEwMDAtZWRkODRlNTU5MjY0In0=","algorithm":"AES-256"}}
        ~~~

    - The `crk` should match the `KEYID`
    - Save the `wrappedDEK` part of the message.
    - Will be used as `WRAPPEDDEK` in the commands below.

1. Run the restore command in dry run mode

    - Run the XO command:
    `@xo eek.summary account=<account ID> region=<region>`
    to see the account key information before the restore is done.
        - The `Creating`, `Deleting` and `Encrypting` action should all be `no`.
        - The `Keys Error` and `Index Error` should be empty.
    - Run the XO command:
    `@xo account <account ID> show=all`
    to see the `EnvelopeEncryptionKeys` field before the restore is done.

    - Run the XO command:
    `@xo eek.restore region=REGION account=ACCOUNT keyid=KEYID wrappedDEK=WRAPPEDDEK keyindex=INDEX force=false train=TRAINID`
    - Example output

    ~~~~text
    Attempting to restore account key. Account: 3ce8ff83b9d19998cc529fc94b511596, Index: 1, Dryrun: true

    Restore account key successful. Account: 3ce8ff83b9d19998cc529fc94b511596, Index: 1, Dryrun: true
    ~~~~

    - If this command is not successful, use the [escalation policy](#escalation-policy) below.

1. Run the restore command

    - Run the XO command:
    `@xo eek.summary account=<account ID> region=<region>`
    to see the account key information before the restore is done.
        - The `Creating`, `Deleting` and `Encrypting` action should all be `no`.
        - The `Keys Error` and `Index Error` should be empty.
    - Run the XO command:
    `@xo account <account ID> show=all`
    to see the `EnvelopeEncryptionKeys` field before the restore is done.

    - Run the XO command:
    `@xo eek.restore region=REGION account=ACCOUNT keyid=KEYID wrappedDEK=WRAPPEDDEK keyindex=INDEX force=true train=TRAINID`
    - Example output

    ~~~~text
    Attempting to restore account key. Account: 3ce8ff83b9d19998cc529fc94b511596, Index: 1, Dryrun: false

    Restore account key successful. Account: 3ce8ff83b9d19998cc529fc94b511596, Index: 1, Dryrun: false
    ~~~~

    - If this command is not successful, use the [escalation policy](#escalation-policy) below.
    - Run the XO command:
    `@xo eek.summary account=<account ID> region=<region>`
    to see the account key information after the restore.
        - The `Key Indexes` list will include the restored INDEX value.
    - Run the XO command:
    `@xo account <account ID> show=all`
    to see the `EnvelopeEncryptionKeys` field after the restore is done.
       - The key at INDEX will have the CRKID restored.

1. Re-Encryption

    - In some cases, fields in ETCD will need to be re-encrypted with the new key information.
    - The `armada-data` command can be used to Set field
    values.  This [job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-cruiser-automated-recovery/view/Ballast%20Squad/job/armada-etcd-run-armada-data/) can be used to run that command.

## Escalation policy

First open an issue against [armada-ballast](https://github.ibm.com/alchemy-containers/armada-ballast) with all the debugging steps and information done to get to this point.
Escalate to [{{ site.data.teams.armada-ballast.escalate.name }}]({{ site.data.teams.armada-ballast.escalate.link }}) escalation policy.
