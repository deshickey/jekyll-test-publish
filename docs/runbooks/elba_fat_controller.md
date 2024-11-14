---
layout: default
title: IKS Change Management Stack
type: Informational
runbook-name: "IKS Change Management Stack"
description: "IKS Change Management Stack"
service: Conductors
link: /doc_updates/elba_fat_controller.html
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
The IKS Change Management Stack consists of multiple services:
- Elba
- Fat-controller
- Mimir
- Hofund

These manage the Change Request process for most of the Argonouts tribe.

The Change Managament Concept Doc (currently a [WIP](https://github.ibm.com/alchemy-containers/armada/pull/3042) at time of writing) describes the overall architecture.

## Detailed information
[Elba](https://github.ibm.com/alchemy-conductors/elba) is a microservice run by conductors to manage all our change requests.
It has a specific template and process which has proven itself to be audit proof.
It interfaces with service-now which stores all the Change Requests (Trains) for IBM cloud.

[Fat-controller](https://github.ibm.com/sre-bots/fat-controller) is a slack bot that fronts Elba and allows:
* Argonouts Tribe members to Raise change requests by hand
* Conductors to review, approve and reject Change requests
* Change requests to be queried
* Train approval to be suspended for a specific region.

Two additional microservices assist Elba with making SLO-based auto-approval decisions for trains.

[Mimir](https://github.ibm.com/alchemy-conductors/mimir) is a microservice which queries a running endpoint in order to determine its confidence to operate within an SLO. Once calculated, this rating will be used by Hofund to to determine if the running services meet the required threshold to be deployed.

[Hofund](https://github.ibm.com/alchemy-conductors/hofund) is a microservice which queries Mimir to get a confidence level of a service when request is sent in from Elba. Hofund then and sends a `yes` or `no` auto-approval to Elba if the the service queried was operating within its SLO. If services are outside their SLO their deployments should be manually inspected, with the expectation that they should be bug fixes rather than new code.

All configuration is stored in <https://github.ibm.com/alchemy-conductors/change-management> and is shared by the above services. Changes result in a <https://alchemy-containers-jenkins.swg-devops.com/job/Support/job/change-management-build/> build.

### Fat-Controller useful links:

* GHE repo is: <https://github.ibm.com/sre-bots/fat-controller>
* 1337 secrets are defined in: <https://github.ibm.com/alchemy-1337/fat-controller-creds>
  * production values stored in: `/fat-controller`
* Jenkins build & deploy job: <https://alchemy-containers-jenkins.swg-devops.com/job/Support/job/fat-controller-build/>

### Elba useful links:

* GHE repo is: <https://github.ibm.com/alchemy-conductors/elba>
* 1337 secrets are defined in: <https://github.ibm.com/alchemy-1337/elba-creds/tree/master/elba>
* Jenkins build & deploy job: <https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/elba-build/>

### Mimir useful links:

* GHE repo is: <https://github.ibm.com/alchemy-conductors/elba>
* 1337 secrets are defined in: <https://github.ibm.com/alchemy-1337/mimir-service-level-agreements> (_to be replaced by Secrets Manager_)
* Jenkins build & deploy job: <https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/mimir-build/>

### Hofund useful links:

* GHE repo is: <https://github.ibm.com/alchemy-conductors/hofund>
* 1337 secrets are defined in: <https://github.ibm.com/alchemy-1337/hofund-creds>
* Jenkins build & deploy job: <https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/hofund-build/>

## Deployment Description
The pods run on the `infra-accessallareas` and `infra-accessallareas-stage` clusters in Fra02 (eu-central), in the Alchemy Support 278445 account.

For example in `infra-accessallareas` (the stage version will say `change-management-test-*`):

```
sre-bots              change-management-live-elba-7c6864b445-b8ls6                      1/1     Running            0                18m     172.30.185.50    10.123.185.238   <none>           <none>
sre-bots              change-management-live-fat-controller-5d6bccc5c6-rxdhj            1/1     Running            0                10m     172.30.8.26      10.75.244.68     <none>           <none>
sre-bots              change-management-live-hofund-cb6fb5694-hkvx9                     1/1     Running            0                18m     172.30.8.47      10.75.244.68     <none>           <none>
sre-bots              change-management-live-mimir-6c98cbd694-nrkjj                     1/1     Running            0                18m     172.30.8.22      10.75.244.68     <none>           <none>
```

Deployment is managed by Netint's Alexandria service.

The Helm chart for the change management stack is stored under <https://github.ibm.com/alchemy-conductors/charts/tree/master/change-management>. Changes result in a <https://alchemy-containers-jenkins.swg-devops.com/job/Support/job/charts-build/> build.

Any changes to the individual services, the chart, or the config, will result in a new [change-management-deploy](https://alchemy-containers-jenkins.swg-devops.com/job/Support/job/change-management-deploy/) deployment of the `test` stack in the `infra-accessallareas-stage` cluster.

Interactions with Alexandria are performed in the [#iks-sre-deploy](https://ibm-argonauts.slack.com/archives/C024L2BABL0) channel, by interacting with the `@hypatia` bot.

### Deployment validation in stage

_TODO: these should become automated verification steps, which can be fed into the Alexandria pipeline._

Minimal suggested steps:
- In the [#cfs-test-prod-trains](https://ibm-argonauts.slack.com/archives/C542BQD5G) channel, manually raise, approve, reject trains.
- Verify that SLOs are honoured and trains are auto-approved in the [#cfs-test-prod-trains-autoapprovals](https://ibm-argonauts.slack.com/archives/C018NM1JH0V) channel.
- Verify that DMs to/from the `@fat-controller-test` bot work as expected.

### Manual promotion to live

At time of writing, promotions to the live stack must be done manually, pending automation of the verification tests as noted below.

In the [#iks-sre-deploy](https://ibm-argonauts.slack.com/archives/C024L2BABL0) channel, send the following commands to `@hypatia`:

```
@hypatia promote change-management in change-management-deploy from test infra-accessallareas-stage to live infra-accessallareas
```

## REST
Elba provides a REST API hosted on `elba.containers.cloud.ibm.com` - this is how fat-controller and other services (such as Igorina or rigr) talk to elba

### Digicert
Elba's REST API is protected by digicert signed certs - these can be accessed by logging into `digicert` <https://www.digicert.com/account/login.php> as `alchcond@uk.ibm.com`
The password is stored in thycotic under: `BU044-ALC > BU044-ALC-Conductor > Digicert > Digicert`

It is unlikely, but possible that the certificate may fail.
If that is the case - we need to renew it in digicert: <https://docs.digicert.com/manage-certificates/renew-ssltls-certificate/>

Once they have been renewed, the NEW certificate will need installing into Elba by adding to <https://github.ibm.com/alchemy-1337/elba-creds/tree/master/elba> and redeploying Elba again once that has been merged in.

Update the `elba_containers_cloud_ibm_com` secret in the [iks-secretsmanager-prod-us-south](https://cloud.ibm.com/services/secrets-manager/crn%3Av1%3Abluemix%3Apublic%3Asecrets-manager%3Aus-south%3Aa%2F800fae7a41e7d4a1ec1658cc0892d233%3A9f48369b-4429-422a-976c-a3705bf88253%3A%3A?paneId=manage) secrets-manager instance - located in the Alchemy Support (`278445`) account - with the new certificate and key.


## Audit logs
All audit logs are available in IBM CLoud Logs
* Elba: <https://app.us-south.logging.cloud.ibm.com/ca1620a740/logs/view/4ef94bf9dd?apps=elba>
* Fat-controller: <https://app.us-south.logging.cloud.ibm.com/ca1620a740/logs/view/b75df82d2f?apps=fat-controller>

## Quick fixes
### If Fat-controller is not responding at all
Redploy the stack using:
```
@hypatia redeploy change-management in change-management-deploy to <test|live> <infra-accessallareas(-stage)>
```

### If fat-controller is not displaying new train requests in the prod-trains channel
Most likely the websocket between FC and Elba has failed
* redeploy fat-controller <https://github.ibm.com/alchemy-conductors/charts/tree/master/fat-controller>

### If Elba is not responding
If you see errors like this from automation
* From Igorina:
```
Post http://elba.sre-bots.svc.cluster.local:10090/v1/trains/prod: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
```
* From Fat-controller
```
unexpected error retrieving trains request CHG0539697 from ServiceNow: Get https://watson.service-now.com/api/ibmwc/v1/change/CHG0539697/read: context deadline exceeded
```
or:
```
Oh dear, I dont seem to be able to schedule that train:
couldn't execute HTTP call: Post http://elba.sre-bots.svc.cluster.local:10090/v1/trains/prod: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
```

It seems that Elba (or service-now) is not responding.

Redploy the stack using:
```
@hypatia redeploy change-management in change-management-deploy to <test|live> <infra-accessallareas(-stage)>
```

Try raising the train again.
If that still doesnt work, try redeploying the service you are calling from (Eg Igorina: <https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/igorina-ha-build/>)

If that doesnt fix it, it could be either a newtworking issue for the `Access All Areas` cluster OR a problem with service-now.
We will need a [GHE issue](#raise-a-ghe) to be raised.

### If Elba cannot talk to Servicenow
* If there are timeouts, this may be a network blip, try again in a short while.
If this is persistent [Raise a GHE issue](#raise-a-ghe). We will need to investigate.

* If we are getting unauthenicated errors from servicenow like:
`{"message":"User Not Authenticated","detail":"Required to provide Auth information"`
Then there is something wrong with the Elba API Key.
This is owned by @cam (c.mcallister@uk.ibm.com) - it can be managed by his management chain working with the servicenow developemnt admins.

The token can be managed through [watson servicenow change token](https://watson.service-now.com/ess_portal?id=sc_cat_item&sys_id=02594e86db2c83408799327e9d961999)
* the owner is `elba`
* you may need to update both test and production tokens, and the new token will need to be added to:
  * [elba prod creds](https://github.ibm.com/alchemy-1337/elba-creds/blob/master/elba/snowkey)
  * [elba test creds](https://github.ibm.com/alchemy-1337/elba-creds/blob/master/elba-test/snowkey)

Then redeploy elba at: <https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/Support/job/elba-build/>

## Fat-controller usage errors

### failed to cancel train:
```
oh dear! Canceling CHG0545043 did not work:
`Internal Server Error: couldn't cancel train CHG0545043: failed three times to close trains request CHG0545043: Error with HTTP request: 400 - 400 Bad Request ;
{"error":{"message":"JSON Value error","detail":"[{\"field\":\"change record\",\"message\":\"is not in state implement\"}]"},"status":"failure"}`
```
Canceling this train has failed because it's state is already cancelled - you can verify this with `describe CHGxxxx` to lookup this change request.

### found 0 entries
an error like this from Fat-controller:
```
oh dear! Approving CHG052634 did not work:
`Internal Server Error: couldn't approve train CHG052634: failed to find train CHG052634 to approve it: unexpected error retrieving trains request CHG052634 from ServiceNow: Error with HTTP request: 400 - 400 Bad Request ;
{"error":{"detail":"[{\"field\":\"change record\",\"message\":\"CR CHG052634 invalid, found 0 entries\"}]","message":"State Error"},"status":"failure"}`
```
means that the change request wasnt found - is the ID correct?

# Escalation policy
There is no on-call pagerduty service to page out for this service.
Raise a GHE in: <https://github.ibm.com/alchemy-conductors/elba>
and ping it to `#conductors-for-life` slack channel.

## Raise a GHE
In the GHE, copy the last few hours of logs from Elba and fat-controller. (see `Useful links` above for where their logs are)

Another Useful thing to do is try the test fat-controller, to see if that is working - we cannot use it to track our work, but knowing whether it's working in test will help (test it in ##cfs-test-prod-trains channel)
