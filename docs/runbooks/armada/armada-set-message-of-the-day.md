---
layout: default
title: How to set the message of the day
type: Informational
runbook-name: "How to set the message of the day"
description: How to set the message of the day
category: armada
service: armada-api
tags: alchemy, armada, kubernetes, armada-api, microservice, logs, wanda
link: /armada/armada-set-message-of-the-day.html
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook documents the steps for setting and deleting message of the days in Aramda environments.
The message of the day is an informational message that is presented to the user in the CLI as well as the UI.
The message can be used to communicate many things from outages to informational message such as server reboots or master patching.

## Detailed Information
The steps below document on how to set the message of the day.

In the Argonauts slack switch to the channel called #xo-conductors.  If you are not a member reach out to your country lead to get added.
There are 3 commands that Xo can perform in regards to the message of the day.  The bot can get the messages, set them, and delete them.

### Get Messages
No approvals needed.

Description:
This command will retrieve the messages set in an environment.

Syntax: To retrieve messages for an environment  
`@xo get_messages --env <env:bluemix|staging>`

   - `<env>` needs to be either `bluemix` for production or `staging` for stage, dev, and prestage
   - If you wish to get information for stage you need to tag the stage xo bot, replace `@xo` with `@Armada Xo - Stage`.


### Set Messages
**Approval is needed to run this command (see below for information on that in the approval section).**

Description:
This command set messages set in an environment.

Syntax: To add a message to an environment  
`@xo add_message --env <env:bluemix|staging> --id <id> "<msg>"`

   - `<env>` needs to be either `bluemix` for production or `staging` for stage, dev, and prestage
   - `<id>` must be a unique id for the message, for example `msg02012018`  
   _To construct the id for the message use `msg<todays date>`_
   - `<msg>` needs to be replaced with the message you wish to use  
   _**NOTE** it must be wrapped in quotes, `"`, it can not be wrapped in smart quotes, make sure you have those turned off_

If you wish to get information for stage you need to tag the stage xo bot, replace `@xo` with `@Armada Xo - Stage`.

### Delete Messages
Approval is needed to run this command (see below for information on that in the approval section).

Description:
This command set messages set in an environment.

Syntax: To delete a message from an environment and region  
`@xo del_message --env <env:bluemix|staging> --id <id>`

   - `<env>` needs to be either `bluemix` for production or `staging` for stage, dev, and prestage
   - `<id>` needs to be replaced with the id of the message you wish to delete  
   If you do not know the message id see the section above, Get Messages
   - If you wish to get information for stage you need to tag the stage xo bot, replace `@xo` with `@Armada Xo - Stage`.

### Approvals

Since this bot can serve content directly to the user before posting a message you need to obtain approval the following approvals:
- The SRE on shift lead
- Chris Rosen (@crosen in slack)
- Jeff Sloyer (@jsloyer in slack) or Jake Kitchener (@kitch in slack)
