---
layout: default
description: How to deal with Alerts from USAM Reconciliation
service: Security
title: USAM Reconciliation Alerts
runbook-name: "USAM Reconciliation Alert"
playbooks: [""]
failure: ["USAM reconciliation has failed or found users needed reconciliation"]
link: /usam_reconcile_alert.html
type: Troubleshooting
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

# USAM Reconciliation Alerts

## Overview

This runbook describes how to handle issues with Users that have been identified as falling into any of these categories:
 * Users in USAM who are missing from the datasource
 * Users in the datasource who are missing from USAM
 * Users who are in the wrong USAM group, given their datasource permissions level

It will also cover alerts where something unexpected has happened with the USAM reconciliation tool.

## Background

As part of security compliance all user IDs must be managed by USAM. USAM provides an audit trail for users being given permissions, CBN, and users leaving the company/department.

Many types of user IDs do not have any automatic integration with USAM, so we have a tool that reads users from various systems, then compares these users and their permissions with the USAM groups they are members of. If any users do not have matching permissions in both systems then an alert will be generated, and the user needs to be manually reconciled - by either adding/modifying permissions in the system where an error has been flagged, or by modifying their USAM permissions.

An example of the systems that are reconciled using this approach are:

* Softlayer non-linked accounts
* GHE Org membership
* Local IDs used by SRE
* Jenkins access, represented by membership of bluegroups associated with the top level folders
* Compose accounts
* Saucelab.com account and sub-accounts

## Example alert(s)

USAM RECONCILE ALERT - Error occurred during reconciliation

USAM RECONCILE ALERT - Users need manual reconciliation

## Investigation and Action

The USAM reconciliation is driven from [this](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Security-Compliance/job/compliance-usam-reconcile/job/usam-reconcile/) Jenkins job.

The results from the reconciliation process are written to [https://github.ibm.com/alchemy-conductors/compliance-usam-reconcile-records](https://github.ibm.com/alchemy-conductors/compliance-usam-reconcile-records).

In this repository there are 2 json files at the top level:

### usam-reconcile-success.json

This file contains a list of systems and datasources (a sub-type of system) , and the user IDs within them that were successfully reconciled. There are 2 lists of user IDs - `systemUserIDs` and `usamUserIDs`. `systemUserIDs` is the list of system users that were successfully reconciled with USAM. `usamUserIDs` is the list of USAM user IDs that were successfully reconciled in the corresponding system. These lists should be the same - if there are any discrepancies then these should have ben flagged in `usam-reconcile-unsuccessful.json`.

It should not normally be necessary to investigate the contents of this file - it is just included for information.

### usam-reconcile-unsuccessful.json

This file contains a list of systems and datasources (a sub-type of system), and the user IDs within them that were not successfully reconciled. It also contains information about any unexpected errors that occurred during reconciliation.

If either of the above alerts were generated then this file should contain the information necessary to investigate.

If a reconciliation run has been successful then this file should contain no errors. e.g. :

```
[
    {
        "system": "softlayer",
        "datasource": "Acct531277",
        "timestamp": "2018-04-30T14:05:04Z",
        "usersMissingFromSystem": {},
        "usersMissingFromUsam": {},
        "permissionErrors": {},
        "reconcileErrors": {}
    }
]
```

## USAM RECONCILE ALERT - Error occurred during reconciliation

This means something unexpected has happened during reconciliation. If this alert has been fired then the last Job status is probably failed.

Review the full output of the Jenkins job - if a failure occurs with one system, the job will continue with the other systems regardless, so the error might not be near the end of the log.

Check for any obvious errors from the Jenkins job configuration, such as unable to clone one of the source Git repositories.

Otherwise, search for `*** FAILURE`:

### Datasource Generation Failure
You might find a data source generation failure, e.g.
* `*** FAILURE: Data source generation failed for softlayer Acct531277. ***`

The reconciler attempts to read in the list of users for a system that it can use during the reconciler. If an error occurred during the generation of this list then you may see this error.

In this case look at the logs above the failure report to find out why we have been unable to generate the datasource for this system.

An example of one of these types of errors is:
```
{"level":"error","ts":"2018-04-30T15:42:31Z","msg":"permissions.go:92: Unable to find matching permissions template in file","datasourceType":"softlayer","datasourceID":"Acct531277","templateFile":"provisioning-app/config/user-templates.json","permissionsLevel":"superadmin","permissionsDef":
{"template":"usam.softlayer.superadmin","machine_access":"ALL","Permissions":null}}
{"level":"error","ts":"2018-04-30T15:42:31Z","msg":"softlayer.go:51: Failed to initialise permissions levels","datasourceType":"softlayer","datasourceID":"Acct531277","error":"Unable to find matching permissions template in file"}
*** FAILURE: Data source generation failed for softlayer Acct531277. ***
*** FAILURE: Script compliance-usam-reconcile/data_sources/softlayer/generate_softlayer_data_source.sh did not complete successfully
```
This shows that it was unable to find a matching template for `usam.softlayer.superadmin` in `provisioning-app/config/user-templates.json`

### Reconciliation Failure
Alternatively you might find an error occurred during the USAM reconciliation, e.g.
* `*** FAILURE: USAM reconciliation failed. ***`

In this case, if there is nothing obvious in the Job output above this log message, you can check the contents of [usam-reconcile-unsuccessful.json](https://github.ibm.com/alchemy-conductors/compliance-usam-reconcile-records/blob/master/usam-reconcile-unsuccessful.json). The `reconcileErrors` structure should contain Error information describing what has gone wrong.

Some common errors include:

* `Error occurred making USAM call to https://usam.svl.ibm.com:9443/AM/rest/privileges?ID_SYSTEM=5436&search=alchemy-softlayer-531277-admin: Eror calling USAM: Get https://usam.svl.ibm.com:9443/AM/rest/privileges?ID_SYSTEM=5436&search=alchemy-softlayer-531277-admin: net/http: TLS handshake timeout`

This means the reconcile tool has been unable to call USAM - check if USAM is having an outage (Channel #devit-usam can be useful).

* `Error reading input file system_datasource_list.json, ensure this input file is valid:`

This means there is an error with file [system_datasource_list.json](https://github.ibm.com/alchemy-conductors/compliance-usam-reconcile/blob/master/config/system_datasource_list.json). Check if there have been any recent updates to this file.

* `Error reading input file for system specified in system_datasource_list.json, ensure this input file has been generated before running reconcile : <FILE_PATH> `

### Other Failures
In some cases the jenkins job might fail with the following error, when trying to install glide:

	gpg: keyring '/tmp/tmpikmi4p4t/secring.gpg' created
	gpg: keyring '/tmp/tmpikmi4p4t/pubring.gpg' created
	gpg: requesting key 890C81B2 from hkp server keyserver.ubuntu.com
	gpgkeys: key F07AEFA3D8667585FFEFD906DC9C7A41890C81B2 can't be retrieved
	gpg: no valid OpenPGP data found.
	gpg: Total number processed: 0

The above could indicate a temporary issue, in which case you can try re-running the job.

## USAM RECONCILE ALERT - Users need manual reconciliation

This alert means the reconciliation process has identified users whose status in the source system do not match their status in USAM.

Inspect the contents of [usam-reconcile-unsuccessful.json](https://github.ibm.com/alchemy-conductors/compliance-usam-reconcile-records/blob/master/usam-reconcile-unsuccessful.json)

Users can fall into 3 categories within that file:

1. **usersMissingFromSystem**  
   This is the list of Users that are in USAM - but are not in the system.
   
   The entry in the json file should give more information on what was expected. e.g. :
   
   ~~~
   "usersMissingFromSystem": {
        "system": "softlayer",
        "datasource": "Acct531277",
        "usersMissing": [
            {
                "userID": "virtanen",
                "group": "alchemy-softlayer-531277-admin-stage_machines",
                "detail": "User virtanen is in USAM Group alchemy-softlayer-531277-admin-stage_machines but is not in datasource Acct531277"
            }
        ]
    },
   ~~~

   This shows that user ID `virtanen` is in a USAM Group, but is not in the expected softlayer account. (The USAM Group to system mapping is specified in [system_datasource_list.json](https://github.ibm.com/alchemy-conductors/compliance-usam-reconcile/blob/master/config/system_datasource_list.json)). This means that the user has been approved to get the related access, but such access has not been provisioned yet.
   
   **Action required**: either create the user ID `virtanen` in the SoftLayer account 531277 with the related permissions, or remove it from the USAM group.

1. **usersMissingFromUsam**  
   This is a list of Users that were found in the system datasource, but do not exist in the expected USAM group.
   
   The json file should give more information:
   
   ~~~
   "usersMissingFromUsam": {
       "system": "ghe",
       "datasource": "alchemy-conductors",
       "usersMissing": [
           {
	       "userID": "AKEHURST",
	       "group": "ghe-alchemy-conductors-owner",
	       "detail": "User AKEHURST was not found as member of the required USAM group ghe-alchemy-conductors-member with permissions 'owner'"
	   },
   ~~~

   This example shows that User ID `AKEHURST` in GHE Org alchemy-conductors is not a member of USAM group `ghe-alchemy-conductors-owner`
   
   **Action required**: either remove the ID `AKEHURST` from the GHE Org or add it to the related USAM group, triggering a transaction to subscribe to that group.
   
   The following examples shows different cases of Users missing from USAM but present in the target system:
   
   ```
		{
        	"userID": "Diana-Sun1",
            "group": "ghe-alchemy-containers-member",
            "detail": "User Diana-Sun1 already has a transaction to subscribe to group ghe-alchemy-containers-member, which is waiting for the approvers approval"
		}, 
   ```

   In this case, the user is still not an active member of the required USAM group, because its request to subscribe is still pending approval, either from a manager or from an access approver.
   
   Action required: check the USAM transaction for that user ID, and solicit the approvers to take an action on that. Appropriate actions for the approvers can be either approving the transaction or rejecting it.

   ```
		{
                    "userID": "vkalangu@in.ibm.com",
                    "group": "launchdarkly-reader",
                    "detail": "User vkalangu@in.ibm.com already has a transaction to subscribe to group launchdarkly-reader, which is waiting for the sysadmin actions"
		},
   ```

   In this case, the user is still not an active member of the required USAM group, because its request to subscribe has been approved by both the manager and the access approver, however it is still pending on final actions to be performed by the USAM system administrators.
   
   **Action required**: check the USAM transaction for that user ID, and solicit the system administrators to take an action on that. In this case, the only valid action is to accept the USAM transaction, because the related user ID is already defined in the target system and all the approvals have been gathered.


1. **permissionErrors**  
   These are users that exist in the System and in USAM but the permissions they have do not match the ones expected for members of the selected USAM group.  These can also be reported if a user's permissions in the system do not match a known set.
   
   The json file will contain information such as:
   
   ```
   "permissionErrors": {
       "system": "softlayer",
       "datasource": "Acct531277",
       "permissionErrors": [
           {
               "userID": "531277-admin",
               "expectedPermissions": "n/a",
               "actualPermissions": "UNKNOWN",
               "detail": "User 531277-admin's permissions do not correspond to any of the known permissions templates and cannot be validated."
           },
   ```
   
   This example shows the permission level for SoftLayer user 531277-admin could not be determined.
   
   **Action required**: do one of the following:
   
   1. reset this user's permissions to a known template (see the list at https://github.ibm.com/gianluca-bernardini/compliance-usam-reconcile/tree/master/data_sources/softlayer/permissions_definitions)
   1. define a template that matches the permissions this user has
   1. revoke this user's access to account 531277.
   

For other permissions related errors you will need to refer to the datasource for this system to understand what this means. The code for each datasource is under https://github.ibm.com/alchemy-conductors/compliance-usam-reconcile/tree/master/data_sources


In general all errors in `usam-reconcile-unsuccessful.json` will need some investigation to understand whether users need adding to USAM or removing from a system - and the mechanism to do this will depend on the system.
<Further Information needed here from Colin/Paul??>

## Escalation Policy

[Conductors](https://ibm.pagerduty.com/escalation_policies#PZRV4HB)
