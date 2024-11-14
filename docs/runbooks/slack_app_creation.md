---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: slack App Creation
type: Informational
runbook-name: "slack_app_creation"
description: "slack_app_creation"
service: Conductors
link: /docs/runbooks/slack_app_creation.md
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
How to create a slack app from scrach

## Detailed Information
This document describes the procedure to create a new slack app from scrach.
### Step 1: Create app
* Create a new slack app by navigating to https://api.slack.com/apps
* Sign in as functional user, for example `SRE.bot`.  
 If unsure which one to use, check in the [#iks_sre_development](https://ibm-argonauts.slack.com/archives/CDUHGBVV0) channel or [#conductors-for-life](https://ibm-argonauts.slack.com/archives/G53NY6QH0/p1632498834009800) channel.
  - The W3 login details should be in [Thycotic](https://pimconsole.sos.ibm.com/SecretServer/app/#/secrets/all)
* Select `Create New App` -> `From scrach`. Fill out your App Name and select the Development Workspace where you'll install and build your app.

 ### Note: 
   [Since the mails are moved to Outlook you need to request for access the shared mailbox to get the OTP.]
 * During the slack app creation using the FID, You must have access to the email to copy the OTP that has been sent from slack. To get this access you can write a request email to Hannah Devlin (who is the owner of this FID -> sre.bot@uk.ibm.com) and permission to access the shared email box.

 * To Setup & Open shared mailbox follow the steps given here:
 https://w3.ibm.com/#/support/article/shared-mailbox/shared-mailbox-open

* The Steps to add users to grant permissions:
https://w3.ibm.com/#/support/article/shared-mailbox/shared-mailbox-access?requestedTopicId=shared-mailbox-access&section=permissions
 

### Step 2: Request scopes for the slack app

* Go to `Socket Mode` section and enable `Enable Socket Mode`. 
* Click on `Event Subscriptions` and toggle `Enable Events` on and generate the token (xapp) with permission `connections:write`
* Under `Subscribe to bot events` add the following Bot User Event.
   ```
   message.channels
   message.groups
   message.im
   ```

* Go to `App Home` section.Under `Show Tabs` make sure `Message Tab` toggle is on and check `Allow users to send Slash commands and messages from the messages tab`

* Go to `OAuth & Permissions` section. Under `Bot Token Scopes` add the following permissions 
    ```
    app_mentions:read
    channels:history
    channels:read
    chat:write
    commands
    files:write
    groups:history
    groups:read
    groups:write
    im:history
    im:read
    im:write
    mpim:history
    mpim:read
    mpim:write
    users.profile:read
    users:read
    users:read.email
    users:write
    ```
    Under `User Token Scopes` add the following permissions
    ```
    groups:history
    groups:read
    groups:write
    identify
    im:read
    im:write
    users:read
    users:read.email
    users:write
    ```
* Then Request to install (this will send notification to the workspace admins) and wait for the approval.  
 ( For argonauts workspace,  Ask in [#conductors-for-life](https://ibm-argonauts.slack.com/archives/G53NY6QH0/p1632498834009800) )

### Step 3: Install app to workspace
* Once approved, click on 'Install your App' button on the sidebar.

### Step 4: IBM CIO team approval

* Join slack channel `#slack-at-ibm-appgov-support` for support

### Step 5: Create app entry on EAL (Enterprise application library)

* Create a EAL record for your app on https://ibm.decisionfocus.com/ .

* On the side bar click on "New Application"

    ```
    Name: "Name of your app"

    Description : "Enter a brief description of the purpose of the asset and the asset´s key functionality"

    Type: Development Software

    Is this a clone for a Newco application? : No

    Owned by IBM non-integrated Subsidiary or Joint Venture : No
    ```
* Create the application. Sample EAL application can be found [here](https://ibm.ent.box.com/folder/150895104799).  
* Wait for approval from the EAL Team. The approval name will be in the application, you can contact the person for any issues.  
* Once the **Domains and Ownership** is approved, move the app to `In Development` state and fill out the rest.
* Ensure your app is moved to production state on EAL after completing the assessment in `Step 6`

* While completing the EAL form - in the data privacy section. When asked does the app Process IBM-owned/controlled Personal Information PI, select Yes. This is because regardless if whether or not the app itself handles PI(personal information). If the app has scopes that are capable of handling PI (the ones with "read" in this case), it must have a GPA.

#### Step 5.1: Watch Your learning Video (Optional)

* Watch 15mins video on Your learning about PIMs https://yourlearning.ibm.com/activity/ITS-DL52502G

#### Step 5.2: Privacy information system

* The Privacy information system (PIMS) will pull your app's data from EAL and you'll shortly be emailed to complete a Global Privacy Assessment. This might take a couple hours. Direct any question to slack channel [#privacy-at-ibm](https://ibm-cloudplatform.slack.com/archives/CREDAPAQ2)

### Step 6 Complete Global Privacy Assessment (GPA)

* Complete GPA Assessment form on https://app.onetrust.com/app/#/pia/assessment. Sample GPA assessment can be found [here](https://ibm.ent.box.com/folder/150895104799).
* Before submitting assessment, ensure an approval is assigned. The approval name will be in the EAL Application (Domain Approver)
* After assessment is approved, edit the EAL application `Data Privacy` section

    ```
    Global Privacy Assessment Completed : Yes
    GPA Assessment Identifier : <ID of the GPA Assessment>
    ```

### Step 7 CIO Team approval

* Go to slack channel `#slack-at-ibm-appgov-support`. Click on the lightning icon. Select `App approval Request`
* Complete the application form using the EAL IMAP Number, GPA Number, ITSS(yes) and provide the scope of your app
* Submit your application form

### Step 8 - Update bot's code base to use the Goslack v3 library [Optional, You can skip]

* Update your bots code based to use the goslack V3 library [here](https://github.ibm.com/sre-bots/goslack/tree/master/v3 ) - This requires both your new Bot Token (prefix `xoxb`) and App Token (prefix `xapp`)

### Step 9 - Deploy your bot to the IKS Cluster

* Hurrary- You've reached the final step. Redeploy your bot to the kubernetes cluster

### Step 10 (Optional) - Add the bot to the relevant channels
* If upgrading an existing bot, you will need to add the bot back into the relevant channels.
