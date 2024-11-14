---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Runbook needs to be updated with description
service: Runbook needs to be updated with service
title: Suppressing a Pager Duty incident
runbook-name: Suppressing a Pager Duty incident
link: /suppress_pager_alert.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

There might be a reason that a particular pager alert needs to be suppressed for X amount of minutes, preventing it from paging again for the specified amount of time.
Here are instructions on how to do so using our container's API.

Important note: The request **defaults to 2 hrs (120 mins)** if no time is supplied.

---

### Suppress a PD alert/ POST request:

POST /{version}/admin/pagerduty/suppress/{incident_key}{?time}

where

incident_key is the pager duty incident key

time (optional) is the number in minutes to suppress the particular alert, defaults to 120 mins (2 hrs)

* Basic authorization required (user: alchemy)
* Headers
    * Content-Type: application/json


Example POST request:

    curl -u alchemy:<password> -X POST https://containers-api-dev.stage1.ng.bluemix.net/v3/admin/pagerduty/suppress/group_failed?time=5

The above request supressed incident group_failed for 5 mins

---

### Retrieving list of suppressed alerts/ GET request:

GET /{version}/admin/pagerduty/suppress

* Basic authorization required (user: alchemy)
* Headers
    * Content-Type: application/json


Example GET request:

    curl -u alchemy:<password> -X GET -H "Content-Type: application/json" https://containers-api-dev.stage1.ng.bluemix.net/v3/admin/pagerduty/suppress

which returns a list of suppressed Pager Duty incidents, with incident keys prepended with the string "PD_sup_".
