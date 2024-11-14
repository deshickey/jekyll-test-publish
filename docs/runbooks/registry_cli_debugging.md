---
layout: default
title: containers-registry - Debugging Container Registry CLI issues using Incident IDs
type: Informational
runbook-name: "Debugging Container Registry CLI issues using Incident IDs"
description: "How to find logs for a CLI error in IBM Container Registry"
service: Registry
link: /runbooks/registry_cli_debugging.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

IBM Bluemix Container Registry tracks each request using a unique request ID, known internally as an "Incident ID". When a customer raises a ticket which includes an Incident ID, first responders can use the ID to find server logs related to the customer's request and find out what went wrong. In this document, you'll learn how to get the Incident ID for a request, and how to use it to find logs.

## Detailed Information

### Gathering required information

You need two pieces of information in order to find logs for an issue: the Incident ID itself, and the Bluemix Region the customer is using.

#### Finding the Incident ID

The Container Registry CLI handles user errors differently to server errors. If a server error occurs, the incident ID is automatically printed out:

```
$ bx cr quota
Getting quotas and usage for the current month, for account 'Project Alchemy's Account'...

FAILED
An internal server error occurred.
Incident ID: 1366-1495797046.963-199591
```

However, if it's a user error, the incident ID might not be printed out.

```
$ bx cr namespace-add ibm
Adding namespace 'ibm'...

FAILED
The requested namespace is not valid.
Choose a valid namespace value. Namespaces must be between 4 and 30 characters long, and contain lowercase letters, numbers, and underscores only.
```

If no incident ID is displayed but the issue isn't immediately apparent from the command the user is running or the error message displayed isn't enough to identify the issue, you can find the Incident ID in the trace. To get trace, ask the user to run the command again, with the `BLUEMIX_TRACE` environment variable set to `true`, then find the Incident ID in the "request-id" field of the response object, or the X-Request-Id header, as shown below:

```
$ BLUEMIX_TRACE=true bx cr namespace-add ibm
Adding namespace 'ibm'...


REQUEST: [2017-05-26T12:23:36+01:00]
PUT /api/v1/namespaces/ibm HTTP/1.1
Host: registry.stage1.ng.bluemix.net
Accept: application/json
Authorization: [PRIVATE DATA HIDDEN]
Content-Type: application/json
Organization: 5d638f93-a2fb-44f9-8b3b-9afd691eda75
User-Agent: Bluemix-CR-CLI/0.1.0 (darwin amd64)



RESPONSE: [2017-05-26T12:23:37+01:00] Elapsed: 734ms
HTTP/1.1 400 Bad Request
Content-Length: 278
Connection: keep-alive
Content-Type: text/plain; charset=utf-8
Date: Fri, 26 May 2017 11:23:36 GMT
Server: nginx
X-Request-Id: 1686-1495797816.312-364204

{
    "code": "CRN0007E",
    "message": "The requested namespace is not valid. Choose a valid namespace value. Namespaces must be between 4 and 30 characters long, and contain lowercase letters, numbers, and underscores only.",
    "request-id": "1686-1495797816.312-364204"
}

Request failed, response object: &{400 Bad Request 400 HTTP/1.1 1 1 map[Connection:[keep-alive] X-Request-Id:[1686-1495797816.312-364204] Server:[nginx] Date:[Fri, 26 May 2017 11:23:36 GMT] Content-Type:[text/plain; charset=utf-8] Content-Length:[278]] 0xc420416ac0 278 [] false false map[] 0xc42000bc00 0xc420406210}
FAILED
The requested namespace is not valid.
Choose a valid namespace value. Namespaces must be between 4 and 30 characters long, and contain lowercase letters, numbers, and underscores only.
```

#### Finding the Bluemix Region

If you've used the `BLUEMIX_TRACE=true` process in the previous step, you can find the Registry hostname in the _REQUEST_ part of the trace. If not, you can ask the customer to run `bx cr info`, which will display the hostnames, along with more useful information, like their account ID:

```
$ bx cr info

Container Registry                registry.stage1.ng.bluemix.net   
Container Registry API endpoint   https://registry.stage1.ng.bluemix.net/api   
Bluemix API endpoint              https://api.stage1.ng.bluemix.net   
Bluemix account details           Project Alchemy's Account (dbc0645501ebc7b5d0841e95e3bf53bd)   
Bluemix organization details       ()   

OK
```

### Finding logs for your incident ID

First, you'll need to go to Kibana for the right environment. You can find links to Kibana on the View section of the [Alchemy Dashboard](https://alchemy-dashboard.containers.cloud.ibm.com/) as Logs->Infrastructure, but here's a helpful table with direct links.

| Registry Hostname | Name on Dashboard | Kibana Link |
| :- | :- | :- |
|registry.stage1.ng.bluemix.net|DAL09 Staging|[stage-dal09](https://alchemy-dashboard.containers.cloud.ibm.com/stage-dal09/stage/kibana/)|
|registry.ng.bluemix.net|US-South Production|[prod-dal09](https://alchemy-dashboard.containers.cloud.ibm.com/prod-dal09/prod/kibana/)|
|registry.eu-gb.bluemix.net|LON02/AMS03 Production|[prod-lon02](https://alchemy-dashboard.containers.cloud.ibm.com/prod-lon02/prod/kibana/)|
|registry.eu-de.bluemix.net|FRA02/PAR01 Production|[prod-fra02](https://alchemy-dashboard.containers.cloud.ibm.com/prod-fra02/prod/kibana/)|

Once Kibana loads, enter your Incident ID in the search bar, surrounded by quotes (`" "`), then press Enter on your keyboard to start searching. Depending on which environment you're using, this part might take a while.

If you know roughly when the request was performed, you can click the time selector in the top-right to search a smaller time period in order to speed up your search.

### Sharing logs with the team

Once you've found some logs, drag a selection around the coloured peaks on the graph, so that the time period is as small as possible while still including all the logs. Then, click the Share ![](images/registry/kibana_share.png) button in the top-right of the Kibana page. This button generates a temporary link to the dashboard you have open, including any graphs, search terms, or filters. Including this link in the customer ticket before you escalate the ticket to the team will enable us to diagnose the issue much more rapidly, and we'll be grateful!

### Contact the squad

The Registry squad can be found in the shared [registry-va-users](https://ibm-argonauts.slack.com/messages/C53RR7TPE) channel.

### Further reading

  * [IBM Bluemix Container Registry CLI Reference](https://console.ng.bluemix.net/docs/cli/plugins/registry/index.html)
