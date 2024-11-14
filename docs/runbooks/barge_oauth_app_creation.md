---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Barge Oauth App Creation
service: Conductors
title: Barge Oauth App Creation
runbook-name: "Barge Oauth App Creation"
link: /docs/runbooks/barge_oauth_app_creation.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

This runbook provides the steps required to manually create Git Hub Enterprise (GHE) Oauth Application required to authenticate Barge users via GHE teams. Unfortunately the GHE API does not currently support creating oauth or github apps 😭 so for now they must be created manually before deploying a new barge.

## Detailed Information

The procedure is split into 2 subsections, creating the GHE oauth application and creating the secrets in Secrets Manager.

## Detailed Procedure

### Creating Oauth App


1. Set up authenticator code with IBM Verify mobile application
    - Click `+` icon to add new authenticator code
    - Select, `Enter code manually` using the  [sre.bot@uk.ibm.com - w3ID Authenticator code](https://pimconsole.sos.ibm.com/SecretServer/app/#/secrets/60679/general)
    
1. Go to Thycotic to retrieve the FID W3 ID credentials
    - FID: `sre.bot@uk.ibm.com`
    - Pimconsole link: <https://pimconsole.sos.ibm.com/SecretServer/app/#/secrets/92085/general>

1. Open a new incognito browser window (this is easier than having to signout of your personal W3 ID)

1. Go to <https://github.ibm.com/settings/applications/new> which will prompt you to login to W3, then use the username and password from step 1 above.

1. Provide<i style="font-size: 18px"><b> Application name</b></i>:`<barge-name>-user-sync-oauth-app`
    - barge-name: `<env>-<data_center>-carrier<number>`
    - Example: `dev-dal10-carrier10-user-sync-oauth-app`

1. Provide <i style="font-size: 18px"><b>Homepage URL</b></i>:`https://oauth-openshift.apps.<barge-name>.-<base-domain>`
    - The base-domain is composed of the vpc_prefix plus the root cloud domain (cloud/test.cloud).  See <https://github.ibm.com/alchemy-containers/barge-deploy-module/blob/main/scaffold/dev/us-south/env.hcl#L27>
        - Example: `dev-us-south-hub01.test.cloud`
    - Example: `https://oauth-openshift.apps.dev-dal10-carrier10.dev-us-south-hub01.test.cloud`
1. Provide <i style="font-size: 18px"><b>Application description</b></i>: Oauth application required for `<barge-name>` barge-user-sync.
    - Example: `Oauth application required for dev-us-east-barge1 barge-user-sync.`

1. Provide <i style="font-size: 18px"><b>Authorization callback URL</b></i> `<Homepage URL>/oauth2callback/github`
    - Example: `https://oauth-openshift.apps.dev-dal10-carrier10.dev-us-south-hub01.test.cloud/oauth2callback/github`

1. Register application.

### Creating Secrets in Secrets Manager

NOTE: In an attempt to simplify the workflow, please keep you incognito browser session open (Referred to as `GHE window`) and a standard non incognito  browser session open (Referred to as `Cloud UI window`).

1. From your `Cloud UI window`, navigate to the Secrets Manager instance in the account where the barge cluster is to be deployed. (name: env_region_secrets_manager)

1. Select `add` to create a new secret

1. Select `Other secret type` and click next.

1. Add secret name `<barge-name>-oauth-app-clientid` and click next.

1. From the `GHE window` copy client id for the new app.

1. Back in the `Cloud UI window` paste the client id into the `Enter data` text box and click next.

1. This will display a review section, click add to complete the secret creation.

1. Repeat steps 1 - 4 for the client secret using the name `<barge-name>-oauth-app-client-secret`

1. From the `GHE window` click the <i style="font-size: 18px"><b>Generate a new client secret</b></i> button and copy client secret.

1. Repeat steps 6 and 7. 